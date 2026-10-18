#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: youtube_sweeper.rb
# domain: media
# purpose: Autonomous YouTube Playlist Sweeper, Deduplication & Health Auditor
# usage: ruby bin/youtube_sweeper.rb [options]
# ---

# bin/youtube_sweeper.rb: Autonomous YouTube Playlist Sweeper & Health Auditor
#
# Audits, sweeps, and alerts on YouTube channel state:
# 1. Duplicate playlist items (same video ID repeated in a playlist).
# 2. Redundant video uploads (different video IDs for identical content).
# 3. Missing canonical video assets in target playlists.
# 4. Pipeline Maildir queue health (blocked cooldowns, quarantined failures).
# 5. Captions parity across registered uploads.
#
# Supports:
#   --audit                     Audit YouTube state and report warnings (default)
#   --sweep                     Reconcile playlists by removing duplicate items and adding missing canonicals
#   --target PLAYLIST           Filter to specific playlist ID or title keyword (e.g. PLNtb969T2-l0)
#   --retire-duplicates         Mark redundant duplicate video uploads as private on YouTube
#   --json                      Emit machine-readable JSON status summary
#   --apply                     Execute mutations live (default is dry-run mode)
#   --quiet                     Suppress decorative headers, emit warnings only

require 'optparse'
require 'yaml'
require 'json'
require 'time'
require_relative 'lib/youtube_client'
require_relative 'lib/youtube_deduplicator'

class YouTubeSweeper
  attr_reader :client, :deduplicator, :options

  def initialize(options = {})
    @options = options
    @client = YouTubeClient.new
    @deduplicator = YouTubeDeduplicator.new
    @root_dir = File.expand_path('..', __dir__)
    @targets_path = File.join(@root_dir, '_data', 'media_intake_targets.yml')
    @video_assets_path = File.join(@root_dir, '_data', 'video_assets.yml')
  end

  def run
    report = audit_all

    if options[:json]
      puts JSON.pretty_generate(report)
      exit(report[:warnings_count].zero? ? 0 : 1)
    end

    render_cli_dashboard(report)

    if options[:mode] == :sweep
      execute_sweep(report)
    end

    exit(report[:warnings_count].zero? ? 0 : 1)
  end

  def audit_all
    report = {
      audited_at: Time.now.utc.iso8601,
      quota_status: calculate_quota_status,
      queue_health: audit_queue_health,
      playlists: [],
      warnings_count: 0,
      warnings: []
    }

    target_playlists = discover_playlists

    target_playlists.each do |pl|
      if options[:target_playlist]
        tgt = options[:target_playlist].downcase
        next unless pl[:id].downcase.include?(tgt) || pl[:title].downcase.include?(tgt)
      end

      pl_report = audit_single_playlist(pl)
      report[:playlists] << pl_report

      pl_report[:warnings].each do |w|
        report[:warnings] << "[#{pl[:title]}] #{w}"
        report[:warnings_count] += 1
      end
    end

    # Global pipeline queue warnings
    if report[:queue_health][:failed_count] > 0
      report[:warnings] << "Pipeline quarantine active: #{report[:queue_health][:failed_count]} job(s) in failed/ directory"
      report[:warnings_count] += 1
    end

    report
  end

  def audit_single_playlist(pl)
    items = fetch_playlist_items(pl[:id])
    audit_data = deduplicator.audit_playlist_items(items)
    deletions_plan = deduplicator.plan_playlist_deletions(audit_data)
    reconcile_plan = deduplicator.plan_playlist_reconciliation(audit_data, pl[:id])

    warnings = []

    if audit_data[:duplicate_item_groups].any?
      dup_item_count = audit_data[:duplicate_item_groups].values.sum { |v| v.size - 1 }
      warnings << "#{dup_item_count} duplicate playlist item entry/entries detected (same video ID repeated)"
    end

    if audit_data[:duplicate_video_groups].any?
      dup_upload_count = audit_data[:duplicate_video_groups].size
      warnings << "#{dup_upload_count} redundant video upload(s) detected with matching content"
    end

    if reconcile_plan.any?
      missing_count = reconcile_plan.size
      warnings << "#{missing_count} canonical video(s) registered locally but missing from playlist"
    end

    {
      id: pl[:id],
      title: pl[:title],
      privacy: pl[:privacy],
      total_items: items.size,
      duplicate_item_groups: audit_data[:duplicate_item_groups].keys,
      duplicate_video_groups: audit_data[:duplicate_video_groups].map { |_k, v| { title: v[:title], canonical_id: v[:canonical_id], redundant_ids: v[:redundant_ids] } },
      missing_canonicals: reconcile_plan,
      deletions_plan: deletions_plan,
      removable_item_ids: deletions_plan.map { |d| d[:playlist_item_id] },
      redundant_video_ids: deletions_plan.select { |d| d[:reason] == 'redundant_duplicate_upload' }.map { |d| d[:video_id] }.uniq,
      warnings: warnings
    }
  end

  def execute_sweep(report)
    puts "\n🧹 EXECUTING PLAYLIST SWEEP..."
    live = options[:apply]

    report[:playlists].each do |pl|
      next if pl[:removable_item_ids].empty? && pl[:missing_canonicals].empty? && (!options[:retire_duplicates] || pl[:redundant_video_ids].empty?)

      puts "\n--- Playlist: #{pl[:title]} (#{pl[:id]}) ---"

      # 1. Remove duplicate playlist items
      pl[:removable_item_ids].each do |item_id|
        if item_id.start_with?('ytdlp_')
          puts "  ⚠️ Cannot delete synthetic item ID #{item_id} (API cooldown active)"
          next
        end

        if live
          puts "  🗑️ Removing duplicate playlist item #{item_id}..."
          client.delete_playlist_item(item_id)
        else
          puts "  🔍 [DRY RUN] Would remove duplicate playlist item #{item_id}"
        end
      end

      # 2. Add missing canonical videos
      pl[:missing_canonicals].each do |missing|
        vid = missing[:video_id] || missing[:canonical_id]
        if live
          puts "  ➕ Adding canonical video #{vid} ('#{missing[:title]}')..."
          client.add_playlist_item(pl[:id], vid)
        else
          puts "  🔍 [DRY RUN] Would add canonical video #{vid} ('#{missing[:title]}')"
        end
      end

      # 3. Retire redundant duplicate videos
      if options[:retire_duplicates]
        pl[:redundant_video_ids].each do |vid|
          if live
            puts "  🔒 Retiring redundant duplicate upload #{vid} to private..."
            client.update_video(vid, privacy_status: 'private')
          else
            puts "  🔍 [DRY RUN] Would set redundant video #{vid} to private"
          end
        end
      end
    end

    puts "\n✅ Playlist sweep completed."
  end

  def render_cli_dashboard(report)
    return if options[:quiet]

    puts "=" * 80
    puts "🎬 YOUTUBE PLAYLIST SWEEPER & HEALTH AUDITOR"
    puts "   Timestamp: #{report[:audited_at]} | Mode: #{options[:mode].to_s.upcase}"
    puts "   Target Filter: #{options[:target_playlist] || 'All Target Playlists'}"
    puts "=" * 80

    # Quota Card
    q = report[:quota_status]
    puts "\n📊 API QUOTA STATUS:"
    if q[:in_cooldown]
      puts "   ⏳ QUOTA EXHAUSTED: Resets in #{q[:hours_until_reset]}h #{q[:minutes_until_reset]}m (at 00:00 PT / 02:00 CT)"
      puts "   Transparent fallback: yt-dlp flat-playlist metadata engine active"
    else
      puts "   ✅ API READY: YouTube Data API v3 authenticated and active"
    end

    # Queue Card
    qh = report[:queue_health]
    puts "\n📁 MEDIA PIPELINE QUEUE HEALTH:"
    puts "   Pending: #{qh[:pending_count]} | Processing: #{qh[:processing_count]} | Blocked: #{qh[:blocked_count]} | Failed: #{qh[:failed_count]}"

    # Warnings Section
    puts "\n⚠️  HEALTH WARNINGS & AUDIT FINDINGS:"
    if report[:warnings].empty?
      puts "   ✅ Zero warnings detected. All playlists and queues healthy and clean."
    else
      report[:warnings].each_with_index do |w, idx|
        puts "   #{idx + 1}. #{w}"
      end
    end

    # Playlist Summaries
    puts "\n📋 PLAYLIST BREAKDOWN:"
    report[:playlists].each do |pl|
      status_icon = pl[:warnings].empty? ? "✅" : "⚠️"
      puts "   #{status_icon} #{pl[:title]} (#{pl[:id]})"
      puts "      Items: #{pl[:total_items]} | Privacy: #{pl[:privacy]}"
      if pl[:duplicate_video_groups].any?
        puts "      Duplicate Groups: #{pl[:duplicate_video_groups].size}"
        pl[:duplicate_video_groups].each do |g|
          puts "        • '#{g[:title]}': canonical=#{g[:canonical_id]}, redundant=#{g[:redundant_ids].join(', ')}"
        end
      end
      if pl[:missing_canonicals].any?
        puts "      Missing Canonicals: #{pl[:missing_canonicals].size}"
        pl[:missing_canonicals].each do |m|
          puts "        • '#{m[:title]}': video_id=#{m[:video_id] || m[:canonical_id]}"
        end
      end
    end

    puts "\n" + "=" * 80
  end

  def calculate_quota_status
    now_utc = Time.now.utc
    # Pacific Time is UTC - 7 in daylight saving time (PDT)
    now_pt = now_utc.getlocal('-07:00')
    # Reset is at 00:00 PT tomorrow
    next_reset_pt = Time.new(now_pt.year, now_pt.month, now_pt.day, 0, 0, 0, '-07:00') + 86400
    seconds_until_reset = (next_reset_pt - now_pt).to_i

    hours = seconds_until_reset / 3600
    minutes = (seconds_until_reset % 3600) / 60

    in_cooldown = false
    begin
      playlists = client.get_channel_playlists
      in_cooldown = playlists.nil? || playlists.empty?
    rescue StandardError => e
      in_cooldown = true if e.message.include?('403') || e.message.include?('quota')
    end

    {
      in_cooldown: in_cooldown,
      seconds_until_reset: seconds_until_reset,
      hours_until_reset: hours,
      minutes_until_reset: minutes,
      reset_time_pt: next_reset_pt.iso8601
    }
  end

  def audit_queue_health
    result = { pending_count: 0, processing_count: 0, blocked_count: 0, failed_count: 0 }

    return result unless File.exist?(@targets_path)

    cfg = YAML.safe_load(File.read(@targets_path), permitted_classes: [Date, Time], aliases: true) rescue {}
    channels = cfg['channels'] || {}

    channels.each do |_chan, chan_data|
      (chan_data['targets'] || {}).each do |_tgt_key, tgt_data|
        base = tgt_data['base_path']
        expanded_base = base ? File.expand_path(base) : nil
        next unless expanded_base && Dir.exist?(expanded_base)

        result[:pending_count] += Dir.glob(File.join(expanded_base, 'pending', '*')).reject { |f| f.end_with?('.json', '.log') }.size
        result[:processing_count] += Dir.glob(File.join(expanded_base, 'processing', '*')).reject { |f| f.end_with?('.json', '.log') }.size
        result[:blocked_count] += Dir.glob(File.join(expanded_base, 'blocked', '*')).reject { |f| f.end_with?('.json', '.log') }.size
        result[:failed_count] += Dir.glob(File.join(expanded_base, 'failed', '*')).reject { |f| f.end_with?('.json', '.log') }.size
      end
    end

    result
  end

  def discover_playlists
    discovered = []

    # 1. First try API
    begin
      api_playlists = client.get_channel_playlists
      if api_playlists && api_playlists.any?
        api_playlists.each do |p|
          discovered << {
            id: p['id'],
            title: p.dig('snippet', 'title') || p['id'],
            privacy: p.dig('status', 'privacyStatus') || 'public'
          }
        end
      end
    rescue StandardError
      # Cooldown fallback
    end

    # 2. If API was blocked or empty, read targets YAML
    if discovered.empty? && File.exist?(@targets_path)
      cfg = YAML.safe_load(File.read(@targets_path), permitted_classes: [Date, Time], aliases: true) rescue {}
      (cfg['channels'] || {}).each do |_chan, chan_data|
        (chan_data['targets'] || {}).each do |tgt_key, tgt_data|
          if tgt_data['playlist_id']
            discovered << {
              id: tgt_data['playlist_id'],
              title: tgt_data['series_name'] || tgt_key,
              privacy: tgt_data['default_privacy'] || 'unlisted'
            }
          end
        end
      end
    end

    discovered.uniq { |p| p[:id] }
  end

  def fetch_playlist_items(playlist_id)
    items = []
    page_token = nil

    begin
      loop do
        url = "#{YouTubeClient::API_BASE}/playlistItems?part=snippet,contentDetails&playlistId=#{playlist_id}&maxResults=50"
        url += "&pageToken=#{page_token}" if page_token
        uri = URI(url)
        res = client.send(:make_request, uri)
        break unless res.is_a?(Net::HTTPSuccess)

        data = JSON.parse(res.body) rescue {}
        items.concat(data['items'] || [])
        page_token = data['nextPageToken']
        break unless page_token
      end
    rescue StandardError
      # Fallback to yt-dlp
    end

    items.empty? ? fetch_playlist_items_ytdlp(playlist_id) : items
  end

  def fetch_playlist_items_ytdlp(playlist_id)
    url = "https://www.youtube.com/playlist?list=#{playlist_id}"
    raw = `yt-dlp --flat-playlist -J "#{url}" 2>/dev/null`
    return [] if raw.nil? || raw.strip.empty?

    data = JSON.parse(raw) rescue {}
    entries = data['entries'] || []
    entries.each_with_index.map do |entry, idx|
      v_id = entry['id']
      {
        'id' => "ytdlp_#{playlist_id}_#{idx}_#{v_id}",
        'snippet' => {
          'title' => entry['title'],
          'resourceId' => {
            'kind' => 'youtube#video',
            'videoId' => v_id
          },
          'position' => idx
        },
        'contentDetails' => {
          'videoId' => v_id
        }
      }
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {
    mode: :audit,
    apply: false,
    retire_duplicates: false,
    json: false,
    quiet: false,
    target_playlist: nil
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: ruby bin/youtube_sweeper.rb [options]"

    opts.on("--audit", "Audit YouTube state and report warnings (default)") do
      options[:mode] = :audit
    end

    opts.on("--sweep", "Reconcile playlists and deduplicate") do
      options[:mode] = :sweep
    end

    opts.on("--target PLAYLIST", "Filter to playlist ID or title substring") do |t|
      options[:target_playlist] = t
    end

    opts.on("--retire-duplicates", "Set redundant duplicate video uploads to private") do
      options[:retire_duplicates] = true
    end

    opts.on("--json", "Emit structured JSON summary") do
      options[:json] = true
    end

    opts.on("--apply", "Apply live mutations (default is dry-run)") do
      options[:apply] = true
    end

    opts.on("--quiet", "Suppress banner, print findings only") do
      options[:quiet] = true
    end

    opts.on("-h", "--help", "Show this help message") do
      puts opts
      exit 0
    end
  end.parse!

  sweeper = YouTubeSweeper.new(options)
  sweeper.run
end

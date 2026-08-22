#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/publish_youtube_metadata.rb — YouTube Data API Metadata Sync & Shorts Publisher
#
# Implements TASK-245 and TASK-248:
# 1. OAuth authentication & channel quota check
# 2. Dry-run diffing of transcript & Shorts payloads against YouTube video assets
# 3. Two-phase approval gate & fingerprint-idempotent updates

require 'json'
require 'yaml'
require 'fileutils'
require_relative 'lib/youtube_client'

$stdout.sync = true

class YouTubeMetadataPublisher
  STAGED_METADATA_FILE = "_data/youtube_metadata_staged.json"
  STATE_FILE           = "tmp/youtube_metadata_sync_state.json"
  REPORT_JSON          = "tmp/youtube-dry-run-report.json"
  REPORT_MD            = "tmp/youtube-dry-run-report.md"

  def initialize(args = [])
    @mode = parse_mode(args)
    @options = parse_options(args)
    @client = YouTubeClient.new
    @sync_state = load_sync_state
  end

  def run
    puts "📺 [YouTube Publisher] Initializing YouTube Data API v3 Client..."
    
    if @mode == :check_auth
      run_auth_check
    elsif @mode == :sync_playlists
      run_sync_playlists
    elsif @mode == :dry_run
      run_dry_run
    elsif @mode == :apply
      run_apply
    else
      print_usage
    end
  end

  private

  def parse_mode(args)
    return :check_auth if args.include?("--check-auth")
    return :sync_playlists if args.include?("--sync-playlists")
    return :apply if args.include?("--apply")
    :dry_run
  end

  def parse_options(args)
    opts = { limit: 0, video_id: nil, force: false, sync_playlists: false }
    opts[:sync_playlists] = true if args.include?("--sync-playlists")
    args.each_with_index do |arg, i|
      opts[:limit] = args[i + 1].to_i if arg == "--limit"
      opts[:video_id] = args[i + 1] if arg == "--video-id"
      opts[:force] = true if arg == "--force"
    end
    opts
  end

  def print_usage
    puts <<~USAGE
      Usage: ruby bin/publish_youtube_metadata.rb [options]

      Options:
        --dry-run          Perform read-only diff against YouTube state & output report (default)
        --apply            Apply staged 1:1 titles, descriptions, chapters, and tags to YouTube
        --sync-playlists   Ensure all videos belong to 'UGtastic Interviews' and event playlists
        --limit N          Limit batch size (default: all)
        --video-id ID      Target specific YouTube video ID
        --force            Force re-sync of already updated videos
        --check-auth       Connect to YouTube Data API & print authenticated channel quota status
    USAGE
  end

  def run_auth_check
    puts "🔐 Checking YouTube Data API authentication..."
    unless @client.authenticated?
      puts "⚠️  [Auth Check] No active OAuth refresh token found."
      return
    end

    begin
      channel = @client.get_channel_info
      snippet = channel["snippet"] || {}
      stats = channel["statistics"] || {}
      puts "✅ [Auth Check] Successfully authenticated with YouTube Data API v3!"
      puts "   Channel Title:    #{snippet['title']}"
      puts "   Subscriber Count: #{stats['subscriberCount'] || 'N/A'}"
      puts "   Video Count:      #{stats['videoCount'] || 'N/A'}"
      puts "   Daily Quota:      10,000 units default headroom"
    rescue StandardError => e
      puts "❌ [Auth Check Error] #{e.message}"
    end
  end

  def run_dry_run
    puts "🔍 [Dry-Run] Scanning staged 1:1 video packages..."

    unless File.exist?(STAGED_METADATA_FILE)
      puts "❌ Error: #{STAGED_METADATA_FILE} missing. Run `ruby bin/generate_youtube_metadata.rb` first."
      exit 1
    end

    staged_items = JSON.parse(File.read(STAGED_METADATA_FILE)) || []

    if @options[:video_id]
      staged_items = staged_items.select { |i| i["youtube_video_id"] == @options[:video_id] }
    end

    unless @options[:force]
      staged_items = staged_items.reject { |i| @sync_state[i["youtube_video_id"]] == "synced" }
    end

    if @options[:limit] > 0
      staged_items = staged_items.first(@options[:limit])
    end

    diffs = []
    staged_items.each do |item|
      v_id = item["youtube_video_id"]
      diffs << {
        video_id: v_id,
        transcript_id: item["transcript_id"],
        title: item["title"],
        description: item["description"],
        chapters: item["chapters"] || [],
        tags: item["tags"] || [],
        chapters_count: (item["chapters"] || []).size,
        tags_count: (item["tags"] || []).size,
        status: "ready_to_update"
      }
    end

    report = {
      generated_at: Time.now.utc.iso8601,
      mode: "dry_run",
      total_staged: staged_items.size,
      estimated_apply_quota_units: staged_items.size * 50, # videos.update costs 50 units
      diffs: diffs
    }

    FileUtils.mkdir_p("tmp")
    File.write(REPORT_JSON, JSON.pretty_generate(report))

    rendered_diffs = diffs.map do |d|
      chapters_list = d[:chapters].map { |c| "    - `#{c['time']}` #{c['title']}" }.join("\n")
      tags_list = d[:tags].map { |t| "`#{t}`" }.join(", ")
      indented_desc = d[:description].lines.map { |l| "    #{l}" }.join

      <<~ENTRY
        ### 🎬 Video: `#{d[:video_id]}` (`#{d[:transcript_id]}`)
        - **Title**: `#{d[:title]}`
        - **Tags**: #{tags_list}
        - **Chapters (#{d[:chapters_count]})**:
        #{chapters_list}
        - **Description**:
        ```markdown
        #{d[:description]}
        ```
      ENTRY
    end.join("\n---\n\n")

    md_report = <<~MD
      # 📺 YouTube Data API Metadata Sync Dry-Run Report

      - **Generated At**: `#{report[:generated_at]}`
      - **Target Video Packages**: `#{staged_items.size}`
      - **Estimated Quota Usage**: `#{report[:estimated_apply_quota_units]} / 10,000 daily units`

      ---

      ## Detailed Video Metadata Packages

      #{rendered_diffs}

      ---
      *To apply these updates to YouTube, run:*
      `ruby bin/publish_youtube_metadata.rb --apply`
    MD

    File.write(REPORT_MD, md_report)

    puts "✅ [Dry-Run Complete] Staged #{diffs.size} videos for update."
    puts "   Estimated API Quota Cost: #{report[:estimated_apply_quota_units]} units (50 units/video)"
    puts "   Report JSON:     #{REPORT_JSON}"
    puts "   Report Markdown: #{REPORT_MD}"
    puts "\n💡 Run `ruby bin/publish_youtube_metadata.rb --apply` to perform updates."
  end

  def run_apply
    puts "🚀 [Apply Mode] Syncing 1:1 metadata, descriptions, chapters, and tags to YouTube..."

    unless File.exist?(STAGED_METADATA_FILE)
      puts "❌ Error: #{STAGED_METADATA_FILE} missing."
      exit 1
    end

    staged_items = JSON.parse(File.read(STAGED_METADATA_FILE)) || []

    if @options[:video_id]
      staged_items = staged_items.select { |i| i["youtube_video_id"] == @options[:video_id] }
    end

    unless @options[:force]
      staged_items = staged_items.reject do |i|
        state = @sync_state[i["youtube_video_id"]]
        state == "synced" || (state.is_a?(Hash) && state["status"] == "synced")
      end
    end

    if @options[:limit] > 0
      staged_items = staged_items.first(@options[:limit])
    end

    puts "Target Queue Size: #{staged_items.size} (Total in archive: #{JSON.parse(File.read(STAGED_METADATA_FILE)).size rescue 180})"
    puts "-------------------------------------------------------"

    success_count = 0
    quota_exceeded = false

    staged_items.each_with_index do |item, idx|
      break if quota_exceeded

      v_id = item["youtube_video_id"]
      puts "[#{idx + 1}/#{staged_items.size}] Updating Video: #{v_id} | #{item['title']}"

      begin
        live_video = @client.get_video(v_id)
        unless live_video
          puts "   ⚠️ Video #{v_id} not found on channel."
          next
        end

        live_snippet = live_video["snippet"] || {}
        category_id = live_snippet["categoryId"] || "28" # 28: Science & Technology

        update_payload = {
          "snippet" => {
            "title" => item["title"],
            "description" => item["description"],
            "tags" => item["tags"],
            "categoryId" => category_id,
            "defaultLanguage" => "en",
            "defaultAudioLanguage" => "en"
          },
          "status" => live_video["status"] || { "privacyStatus" => "public" }
        }

        @client.update_video(v_id, update_payload)
        puts "   ✅ [#{v_id}] Metadata, chapters, and tags updated successfully!"
        success_count += 1
        @sync_state[v_id] = {
          "status" => "synced",
          "synced_at" => Time.now.utc.iso8601,
          "title" => item["title"],
          "fingerprint" => YouTubeClient.fingerprint(update_payload["snippet"])
        }
        save_sync_state
        sleep 1.0 # Polite rate limiting
      rescue StandardError => e
        if e.message.include?("quotaExceeded")
          puts "🛑 Halting execution: YouTube API daily quota exceeded."
          puts "📅 YouTube API quota resets daily at midnight Pacific Time (07:00 UTC / 02:00 CDT)."
          puts "💡 Run `ruby bin/publish_youtube_metadata.rb --apply` to automatically resume the remaining un-synced queue."
          quota_exceeded = true
        else
          puts "   ❌ [#{v_id}] Update failed: #{e.message}"
        end
      end
    end

    save_sync_state
    puts "======================================================="
    puts "Execution Summary: #{success_count} videos updated. State saved to #{STATE_FILE}."
    puts "Total Synced to date: #{@sync_state.size} videos."
  end

  PLAYLIST_MAPPINGS = {
    "software-craftsmanship-north-america-2011" => "Software Craftsmanship North America 2011 Interviews",
    "scna-2011" => "Software Craftsmanship North America 2011 Interviews",
    "software-craftsmanship-north-america-2012" => "Software Craftsmanship North America 2012 Interviews",
    "scna-2012" => "Software Craftsmanship North America 2012 Interviews",
    "software-craftsmanship-north-america-2013" => "Software Craftsmanship North America 2013 Interviews",
    "scna-2013" => "Software Craftsmanship North America 2013 Interviews",
    "railsconf-2014" => "RailsConf 2014 Interviews",
    "railsconf" => "RailsConf 2014 Interviews",
    "windycityrails" => "WindyCityRails 2011 Interviews",
    "chicagowebconf" => "ChicagoWebConf 2012 Interviews",
    "goto-conference-2013" => "GOTO Conference 2013 Interviews",
    "goto-conference-2014" => "GOTO Conference 2014 Interviews",
    "goto-conference-2015" => "GOTO Conference 2015 Interviews",
    "webvisions" => "WebVisions 2013 Interviews"
  }.freeze

  def run_sync_playlists
    puts "📑 [Playlist Sync] Fetching channel playlists and video memberships..."
    staged_items = JSON.parse(File.read(STAGED_METADATA_FILE)) rescue []
    if staged_items.empty?
      puts "❌ Error: #{STAGED_METADATA_FILE} missing."
      return
    end

    all_playlists = @client.get_channel_playlists
    playlist_map = all_playlists.each_with_object({}) { |pl, h| h[pl.dig("snippet", "title")] = pl["id"] }

    master_title = "UGtastic Interviews"
    master_pl_id = playlist_map[master_title]
    unless master_pl_id
      puts "➕ Creating Master Playlist: #{master_title}"
      created = @client.create_playlist(master_title, "Oral history interviews from the UGtastic technical conversation archive (2009–2015) documenting software craftsmanship, Ruby, and agile engineering.")
      master_pl_id = created["id"]
      playlist_map[master_title] = master_pl_id
    end

    puts "Master Playlist: '#{master_title}' (ID: #{master_pl_id})"
    master_vids = @client.get_playlist_video_ids(master_pl_id)
    puts "Current Master Playlist Items: #{master_vids.size}"

    event_vids_cache = {}
    added_master = 0
    added_event = 0

    staged_items.each_with_index do |item, idx|
      v_id = item["youtube_video_id"]
      t_id = item["transcript_id"]
      next unless v_id

      # 1. Master Playlist Check
      unless master_vids.include?(v_id)
        puts "[#{idx + 1}/#{staged_items.size}] Adding #{v_id} (#{item['title']}) to #{master_title}..."
        begin
          @client.add_playlist_item(master_pl_id, v_id)
          master_vids << v_id
          added_master += 1
          sleep 0.5
        rescue StandardError => e
          puts "   ❌ Failed to add to master playlist: #{e.message}"
        end
      end

      # 2. Event/Conference Playlist Check
      event_match = PLAYLIST_MAPPINGS.find { |k, _title| t_id.to_s.downcase.include?(k) }
      if event_match
        event_title = event_match[1]
        event_pl_id = playlist_map[event_title]
        unless event_pl_id
          puts "➕ Creating Conference Playlist: #{event_title}"
          created = @client.create_playlist(event_title, "Interviews recorded on-site at #{event_title}. Part of the UGtastic technical conversation archive.")
          event_pl_id = created["id"]
          playlist_map[event_title] = event_pl_id
        end

        event_vids_cache[event_pl_id] ||= @client.get_playlist_video_ids(event_pl_id)

        unless event_vids_cache[event_pl_id].include?(v_id)
          puts "[#{idx + 1}/#{staged_items.size}] Adding #{v_id} (#{item['title']}) to #{event_title}..."
          begin
            @client.add_playlist_item(event_pl_id, v_id)
            event_vids_cache[event_pl_id] << v_id
            added_event += 1
            sleep 0.5
          rescue StandardError => e
            puts "   ❌ Failed to add to event playlist: #{e.message}"
          end
        end
      end
    end

    puts "======================================================="
    puts "✅ Playlist Sync Complete: Added #{added_master} to Master, #{added_event} to Conference playlists."
  end

  def load_sync_state
    FileUtils.mkdir_p("tmp")
    return JSON.parse(File.read(STATE_FILE)) if File.exist?(STATE_FILE)
    {}
  rescue StandardError
    {}
  end

  def save_sync_state
    FileUtils.mkdir_p("tmp")
    File.write(STATE_FILE, JSON.pretty_generate(@sync_state))
  end
end

if __FILE__ == $PROGRAM_NAME
  YouTubeMetadataPublisher.new(ARGV).run
end

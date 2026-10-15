#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# bin/youtube_pipeline.rb
#
# Unified YouTube Publishing Pipeline CLI & Operational Orchestrator.
# Tracks state, audits best practices, manages scheduling, and compiles
# telemetry for the YouTube Publishing & Operations Dashboard.
#
# Commands:
#   status    : High-density CLI status report of the publication pipeline
#   audit     : Run comprehensive best practices audit on metadata and captions
#   telemetry : Regenerate _data/youtube_pipeline_telemetry.json for dashboards
#   schedule  : Inspect and manage scheduled livestreams and cued broadcasts
#   quota     : Calculate quota consumption and budgeting for planned jobs
# ==============================================================================

require 'json'
require 'yaml'
require 'fileutils'
require 'optparse'
require 'time'
require 'date'

ROOT_DIR = File.expand_path('..', __dir__)
VIDEO_ASSETS_PATH = File.join(ROOT_DIR, '_data', 'video_assets.yml')
INTERVIEWS_PATH = File.join(ROOT_DIR, '_data', 'interviews.yml')
STAGED_METADATA_PATH = File.join(ROOT_DIR, '_data', 'youtube_metadata_staged.json')
CAPTIONS_MANIFEST_PATH = File.join(ROOT_DIR, '_data', 'youtube_captions_manifest.json')
SEQUENCE_MANIFEST_PATH = File.join(ROOT_DIR, 'obs', 'curation', 'sequence-manifest.json')
ERRATA_MANIFEST_PATH = File.join(ROOT_DIR, 'obs', 'curation', 'errata-manifest.json')
OVERLAY_STATE_PATH = File.join(ROOT_DIR, 'obs', 'overlays', 'overlay-state.json')
METADATA_SYNC_STATE_PATH = File.join(ROOT_DIR, 'tmp', 'youtube_metadata_sync_state.json')
CAPTIONS_SYNC_STATE_PATH = File.join(ROOT_DIR, 'tmp', 'youtube_captions_sync_state.json')
PUBLICATION_SCHEDULE_PATH = File.join(ROOT_DIR, '_data', 'publication_schedule.yml')
TELEMETRY_OUTPUT_PATH = File.join(ROOT_DIR, '_data', 'youtube_pipeline_telemetry.json')

class YouTubePipeline
  DAILY_QUOTA_BUDGET = 10_000
  COST_VIDEO_UPDATE = 50
  COST_CAPTION_INSERT = 50
  COST_VIDEO_UPLOAD = 1600

  def initialize(options = {})
    @options = options
    load_all_data!
  end

  def run(command)
    case command.to_s.downcase
    when 'status'
      print_status
    when 'audit'
      run_audit
    when 'telemetry'
      generate_telemetry
    when 'schedule', 'calendar'
      print_schedule
    when 'script', 'teleprompter'
      run_teleprompter_script
    when 'quota'
      print_quota_assessment
    when 'help', '-h', '--help'
      print_help
    else
      warn "Unknown command: #{command}"
      print_help
      exit 1
    end
  end

  private

  def load_all_data!
    @assets_data = YAML.safe_load(File.read(VIDEO_ASSETS_PATH), permitted_classes: [Date, Time], aliases: true) || {}
    @assets = @assets_data['items'] || []

    @interviews_data = YAML.safe_load(File.read(INTERVIEWS_PATH), permitted_classes: [Date, Time], aliases: true) || {}
    @interviews = @interviews_data['items'] || []

    @staged_metadata = load_json(STAGED_METADATA_PATH) || []
    @captions_manifest = load_json(CAPTIONS_MANIFEST_PATH) || { 'items' => [] }
    @sequence_manifest = load_json(SEQUENCE_MANIFEST_PATH) || { 'episodes' => [] }
    @errata_manifest = load_json(ERRATA_MANIFEST_PATH) || { 'items' => [] }
    @overlay_state = load_json(OVERLAY_STATE_PATH) || {}
    @metadata_sync = load_json(METADATA_SYNC_STATE_PATH) || {}
    @captions_sync = load_json(CAPTIONS_SYNC_STATE_PATH) || {}
    @publication_schedule = File.exist?(PUBLICATION_SCHEDULE_PATH) ? (YAML.safe_load(File.read(PUBLICATION_SCHEDULE_PATH), permitted_classes: [Date, Time], aliases: true) || {}) : {}

    index_lookups!
  end

  def load_json(path)
    return nil unless File.exist?(path)
    JSON.parse(File.read(path))
  rescue JSON::ParserError => e
    warn "JSON parse error in #{path}: #{e.message}"
    nil
  end

  def index_lookups!
    @interviews_by_video_asset = {}
    @interviews.each { |i| @interviews_by_video_asset[i['video_asset_id']] = i }

    @staged_by_video_id = {}
    @staged_by_transcript_id = {}
    @staged_metadata.each do |s|
      @staged_by_video_id[s['youtube_video_id']] = s if s['youtube_video_id']
      @staged_by_transcript_id[s['transcript_id']] = s if s['transcript_id']
    end

    @captions_by_video_id = {}
    @captions_by_transcript_id = {}
    (@captions_manifest['items'] || []).each do |c|
      @captions_by_video_id[c['youtube_video_id']] = c if c['youtube_video_id']
      @captions_by_transcript_id[c['transcript_id']] = c if c['transcript_id']
    end
  end

  def print_status
    puts '=================================================================='
    puts ' 📺 YOUTUBE PUBLISHING PIPELINE & OPERATIONAL STATUS'
    puts '=================================================================='
    puts 'Channel:           UGtastic / WHOIS Tech Community (@whoistechcmty)'
    puts 'Canonical Host:    https://www.just3ws.com'
    puts 'Local Control:     https://www.just3ws.localhost/youtube/dashboard/'
    puts 'Active Archetype:  ' + (@overlay_state['broadcast_type'] || 'rewatch').upcase
    puts 'Live Overlay Host: ' + (@overlay_state.dig('stream', 'host') || 'Mike Hall (Staff Software Engineer)')
    puts '------------------------------------------------------------------'
    puts '📦 ASSET & PUBLICATION FUNNEL'
    puts "  1. Canonical Video Assets:   #{@assets.size.to_s.rjust(4)}"
    puts "  2. Oral History Interviews:  #{@interviews.size.to_s.rjust(4)}"
    puts "  3. Timed WebVTT Captions:    #{(@captions_manifest['items'] || []).size.to_s.rjust(4)}"
    puts "  4. 1:1 Staged Metadata:      #{@staged_metadata.size.to_s.rjust(4)}"
    puts "  5. Live on YouTube Channel:  #{count_youtube_assets.to_s.rjust(4)}"
    puts "  6. Metadata Synced (State):  #{@metadata_sync.size.to_s.rjust(4)}"
    puts "  7. Captions Synced (State):  #{@captions_sync.size.to_s.rjust(4)}"
    puts '------------------------------------------------------------------'
    puts '🎙️ LIVESTREAMING ARCHETYPES'
    puts "  • The Sound Above (Rewatch): #{@sequence_manifest['episodes']&.size || 0} curated episodes (35 primary + 2 codas)"
    puts "  • Errata (Readings & Demos): #{@errata_manifest['items']&.size || 0} pre-curated topics & practice runs"
    puts '  • Current Overlay Topic:     ' + (@overlay_state.dig('stream', 'topic') || 'Standby')
    puts '------------------------------------------------------------------'
    puts '⚡ GOOGLE CLOUD QUOTA BUDGETING'
    puts "  • Daily Quota Limit:         #{DAILY_QUOTA_BUDGET.to_s.rjust(6)} units/day"
    pending_meta = [@staged_metadata.size - @metadata_sync.size, 0].max
    pending_cap = [(@captions_manifest['items']&.size || 0) - @captions_sync.size, 0].max
    needed_quota = (pending_meta * COST_VIDEO_UPDATE) + (pending_cap * COST_CAPTION_INSERT)
    puts "  • Pending Metadata Updates:  #{pending_meta.to_s.rjust(6)} (#{pending_meta * COST_VIDEO_UPDATE} units)"
    puts "  • Pending Caption Uploads:   #{pending_cap.to_s.rjust(6)} (#{pending_cap * COST_CAPTION_INSERT} units)"
    puts "  • Estimated Quota Needed:    #{needed_quota.to_s.rjust(6)} units (#{(needed_quota.to_f / DAILY_QUOTA_BUDGET * 100).round(1)}% of daily limit)"
    puts '=================================================================='
    puts 'Run `bin/youtube_pipeline.rb audit` for best practices compliance report.'
    puts 'Run `bin/youtube_pipeline.rb telemetry` to refresh web dashboard data.'
    puts '=================================================================='
  end

  def run_audit
    puts '=================================================================='
    puts ' 🔍 YOUTUBE CONTENT MANAGEMENT & BEST PRACTICES AUDIT'
    puts '=================================================================='

    violations_em_dash = []
    titles_over_70 = []
    titles_missing_speaker = []
    missing_chapters = []
    few_chapters = []
    micro_chapters = []
    missing_transcript_links = []
    missing_captions = []

    @staged_metadata.each do |record|
      tid = record['transcript_id'] || 'unknown'
      title = record['title'].to_s
      desc = record['description'].to_s
      chapters = record['chapters'] || []

      # Rule 1: Zero em dashes in titles or descriptions
      if title.include?("\u2014") || desc.include?("\u2014")
        violations_em_dash << { id: tid, title: title }
      end

      # Rule 2: Title length (optimal <= 70 chars for mobile readability)
      if title.length > 70
        titles_over_70 << { id: tid, length: title.length, title: title }
      end

      # Rule 3: Chapter invariants
      if chapters.empty?
        missing_chapters << tid
      elsif chapters.size < 3
        few_chapters << { id: tid, count: chapters.size }
      end

      # Check for micro chapters (< 10 seconds apart)
      check_micro_chapters(tid, chapters, micro_chapters)

      # Rule 4: Canonical site transcript link in description
      unless desc.include?('just3ws.com/interviews/')
        missing_transcript_links << tid
      end

      # Rule 5: Captions track parity
      yid = record['youtube_video_id']
      unless @captions_by_video_id[yid] || @captions_by_transcript_id[tid]
        missing_captions << tid
      end
    end

    total_records = @staged_metadata.size
    perfect_records = total_records - [
      violations_em_dash.size,
      missing_chapters.size,
      missing_transcript_links.size,
      missing_captions.size
    ].max

    score = ((perfect_records.to_f / total_records) * 100).round(1)

    puts "Total Records Audited:       #{total_records}"
    puts "Overall Compliance Score:    #{score}%"
    puts '------------------------------------------------------------------'
    puts "1. Zero Em-Dash Invariant:   #{violations_em_dash.empty? ? '✅ PASS (0 violations)' : "❌ FAIL (#{violations_em_dash.size} violations)"}"
    puts "2. Title Length (<= 70 ch):  #{titles_over_70.empty? ? '✅ PASS (all <= 70)' : "⚠️ NOTICE (#{titles_over_70.size} exceed 70 chars, acceptable for conference clarity)"}"
    puts "3. Chapters Present:         #{missing_chapters.empty? ? '✅ PASS (all have chapters)' : "❌ FAIL (#{missing_chapters.size} missing chapters)"}"
    puts "4. Chapter Depth (>= 3):     #{few_chapters.size} records have single chapter (Intro)"
    puts "5. Canonical Transcript URL: #{missing_transcript_links.empty? ? '✅ PASS (all contain just3ws.com links)' : "❌ FAIL (#{missing_transcript_links.size} missing)"}"
    puts "6. WebVTT Caption Parity:    #{missing_captions.empty? ? '✅ PASS (all have captions)' : "⚠️ PENDING (#{missing_captions.size} pending caption alignment)"}"
    puts '=================================================================='

    if violations_em_dash.any?
      puts "\nEm-Dash Violations:"
      violations_em_dash.first(5).each do |v|
        puts "  • [#{v[:id]}] #{v[:title]}"
      end
    end

    if titles_over_70.any?
      puts "\nLongest Titles (Sample):"
      titles_over_70.sort_by { |t| -t[:length] }.first(5).each do |t|
        puts "  • (#{t[:length]} chars) [#{t[:id]}] #{t[:title]}"
      end
    end
  end

  def check_micro_chapters(tid, chapters, micro_chapters)
    times_in_sec = chapters.map do |c|
      time_to_seconds(c['time'])
    end.compact

    times_in_sec.each_cons(2) do |t1, t2|
      if (t2 - t1) < 10
        micro_chapters << { id: tid, gap: (t2 - t1) }
        break
      end
    end
  end

  def time_to_seconds(time_str)
    parts = time_str.to_s.split(':').map(&:to_i)
    if parts.size == 2
      parts[0] * 60 + parts[1]
    elsif parts.size == 3
      parts[0] * 3600 + parts[1] * 60 + parts[2]
    else
      nil
    end
  end

  def generate_telemetry
    puts "Compiling telemetry to #{TELEMETRY_OUTPUT_PATH}..."

    conference_counts = Hash.new(0)
    @interviews.each do |i|
      conf = i['conference'] || 'Independent / General'
      conference_counts[conf] += 1
    end

    assets_payload = []
    @assets.each do |asset|
      aid = asset['id']
      tid = asset['transcript_id'] || asset['interview_id'] || aid
      interview = @interviews_by_video_asset[aid] || {}
      
      yt_platform = (asset['platforms'] || []).find { |p| p['platform'] == 'youtube' }
      v_id = yt_platform ? yt_platform['asset_id'] : nil

      staged_rec = @staged_by_video_id[v_id] || @staged_by_transcript_id[tid]
      v_id ||= staged_rec ? staged_rec['youtube_video_id'] : nil

      meta_status = @metadata_sync[v_id] || (staged_rec ? 'staged' : 'local_only')
      cap_rec = @captions_by_video_id[v_id] || @captions_by_transcript_id[tid]
      cap_status = @captions_sync[v_id] || (cap_rec ? 'manifest_ready' : 'missing')

      title = staged_rec ? staged_rec['title'] : asset['title']
      chapters_count = staged_rec ? (staged_rec['chapters'] || []).size : (asset['chapters'] || []).size
      tags_count = staged_rec ? (staged_rec['tags'] || []).size : (asset['tags'] || []).size

      assets_payload << {
        'id' => aid,
        'transcript_id' => tid,
        'youtube_video_id' => v_id,
        'title' => title,
        'speaker' => asset['speaker'] || interview['interviewees']&.first || 'Speaker',
        'event' => asset['event'] || interview['conference'] || 'Archival Event',
        'conference' => interview['conference'] || 'Independent / General',
        'conference_year' => interview['conference_year'] || asset['recorded_at']&.to_s&.slice(0, 4),
        'duration' => asset['duration'] || '00:00',
        'metadata_status' => meta_status,
        'caption_status' => cap_status,
        'chapters_count' => chapters_count,
        'tags_count' => tags_count,
        'has_em_dash' => title.to_s.include?("\u2014"),
        'title_length' => title.to_s.length
      }
    end

    pending_meta = [@staged_metadata.size - @metadata_sync.size, 0].max
    pending_cap = [(@captions_manifest['items']&.size || 0) - @captions_sync.size, 0].max
    needed_quota = (pending_meta * COST_VIDEO_UPDATE) + (pending_cap * COST_CAPTION_INSERT)

    telemetry = {
      'generated_at' => Time.now.utc.iso8601,
      'channel' => {
        'name' => 'UGtastic / WHOIS Tech Community',
        'handle' => '@whoistechcmty',
        'url' => 'https://www.youtube.com/@whoistechcmty',
        'studio_url' => 'https://studio.youtube.com',
        'status' => 'authorized'
      },
      'metrics' => {
        'total_canonical_assets' => @assets.size,
        'total_interviews' => @interviews.size,
        'youtube_live_videos' => count_youtube_assets,
        'staged_metadata_records' => @staged_metadata.size,
        'metadata_synced_count' => @metadata_sync.size,
        'metadata_pending_count' => pending_meta,
        'captions_manifest_count' => (@captions_manifest['items'] || []).size,
        'captions_synced_count' => @captions_sync.size,
        'captions_pending_count' => pending_cap,
        'sound_above_episodes_count' => @sequence_manifest['episodes']&.size || 0,
        'errata_catalog_count' => @errata_manifest['items']&.size || 0,
        'daily_quota_budget' => DAILY_QUOTA_BUDGET,
        'quota_needed_for_pending' => needed_quota,
        'quota_budget_percentage' => (needed_quota.to_f / DAILY_QUOTA_BUDGET * 100).round(1)
      },
      'conferences' => conference_counts.sort_by { |_, v| -v }.to_h,
      'overlay_state' => @overlay_state,
      'publication_schedule' => @publication_schedule,
      'sound_above_sequence' => (@sequence_manifest['episodes'] || []).first(10),
      'errata_catalog' => (@errata_manifest['items'] || []).first(10),
      'assets' => assets_payload
    }

    File.write(TELEMETRY_OUTPUT_PATH, JSON.pretty_generate(telemetry) + "\n")
    puts "✅ Telemetry generated successfully with #{assets_payload.size} assets."
  end

  def print_schedule
    puts '=================================================================='
    puts ' 📅 MEDIA PUBLICATION CALENDAR & RELEASE TIMELINE'
    puts '=================================================================='
    weeks = @publication_schedule['schedule'] || []
    if weeks.any?
      puts "Cadence: #{@publication_schedule['cadence']}"
      weeks.each do |w|
        puts "\n--- WEEK #{w['week']}: #{w['theme'].to_s.upcase} ---"
        (w['releases'] || []).each do |rel|
          status_tag = "[#{rel['status'].to_s.upcase.ljust(9)}]"
          puts "  #{rel['date']} | #{status_tag} | #{rel['slot'].to_s.ljust(25)}: #{rel['title']}"
        end
      end
      puts "\n------------------------------------------------------------------"
    end

    puts ' 🎙️ LIVESTREAM SCHEDULING & ORCHESTRATION'
    puts '------------------------------------------------------------------'
    puts 'Series 1: The Sound Above (35 Oral History Rewatch Episodes)'
    episodes = @sequence_manifest['episodes'] || []
    episodes.each do |ep|
      status_pill = ep['youtube_broadcast_id'] ? "[Live ID: #{ep['youtube_broadcast_id']}]" : '[Planned]'
      cued_marker = (ep['number'] == @overlay_state.dig('episode', 'number')) ? '👉 CUED' : '       '
      puts "#{cued_marker} Ep #{ep['number'].to_s.rjust(2)}: #{ep['interviewee'].to_s.ljust(24)} #{status_pill} #{ep['title']}"
    end
    puts "\nSeries 2: Errata (Pre-Curated Concept, Reading & Demo Catalog)"
    errata = @errata_manifest['items'] || []
    errata.each do |item|
      cued_marker = (item['title'] == @overlay_state.dig('errata', 'title')) ? '👉 CUED' : '       '
      puts "#{cued_marker} [#{item['mode'].to_s.upcase.ljust(7)}] #{item['id'].ljust(35)}: #{item['title']}"
    end
    puts '=================================================================='
  end

  def run_teleprompter_script
    ep_num = ARGV[0] ? ARGV[0].to_i : (@overlay_state.dig('episode', 'number') || 1)
    ep_num = 1 if ep_num <= 0
    script_runner = File.join(ROOT_DIR, 'bin', 'generate_sound_above_teleprompter.rb')
    system("ruby #{script_runner} --episode #{ep_num}")
  end

  def print_quota_assessment
    puts '=================================================================='
    puts ' ⚡ GOOGLE CLOUD YOUTUBE DATA API V3 QUOTA BUDGETING'
    puts '=================================================================='
    puts "Daily Quota Pool:          #{DAILY_QUOTA_BUDGET} units/day (resets at 02:00 CST)"
    puts "Cost per Video Update:     #{COST_VIDEO_UPDATE} units"
    puts "Cost per Caption Insert:   #{COST_CAPTION_INSERT} units"
    puts "Cost per Video Upload:     #{COST_VIDEO_UPLOAD} units"
    puts '------------------------------------------------------------------'
    pending_meta = [@staged_metadata.size - @metadata_sync.size, 0].max
    pending_cap = [(@captions_manifest['items']&.size || 0) - @captions_sync.size, 0].max
    puts "Pending Metadata Updates:  #{pending_meta} videos = #{pending_meta * COST_VIDEO_UPDATE} units"
    puts "Pending Caption Tracks:    #{pending_cap} tracks = #{pending_cap * COST_CAPTION_INSERT} units"
    total_cost = (pending_meta * COST_VIDEO_UPDATE) + (pending_cap * COST_CAPTION_INSERT)
    puts "Total Required Quota:      #{total_cost} units"
    if total_cost <= DAILY_QUOTA_BUDGET
      puts "Status:                    ✅ Safe to execute in single batch (#{(total_cost.to_f / DAILY_QUOTA_BUDGET * 100).round(1)}% of budget)"
    else
      batches = (total_cost.to_f / DAILY_QUOTA_BUDGET).ceil
      puts "Status:                    ⚠️ Exceeds daily budget. Recommended batches: #{batches} days"
    end
    puts '=================================================================='
  end

  def count_youtube_assets
    @assets.count do |a|
      (a['platforms'] || []).any? { |p| p['platform'] == 'youtube' && p['asset_id'] }
    end
  end

  def print_help
    puts <<~HELP
      Usage: bin/youtube_pipeline.rb <command> [options]

      Commands:
        status      Display high-density publication pipeline status report
        audit       Run best practices audit across titles, descriptions, and chapters
        telemetry   Regenerate _data/youtube_pipeline_telemetry.json for dashboard
        schedule    List scheduled livestreams and cued broadcast topics
        quota       Assess Google Cloud quota budgeting and batch requirements
        help        Show this message

      Examples:
        bin/youtube_pipeline.rb status
        bin/youtube_pipeline.rb audit
        bin/youtube_pipeline.rb telemetry
    HELP
  end
end

if __FILE__ == $PROGRAM_NAME
  command = ARGV.shift || 'status'
  YouTubePipeline.new.run(command)
end

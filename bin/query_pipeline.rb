#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: query_pipeline.rb
# domain: media
# role: Lightweight Media & Publication Pipeline Inspector
# description: Fast CLI and MCP query engine for live intake queues, worker state, quota cooldown, and recent events
# usage: bin/query_pipeline.rb [options]
# ---
# ponytail: fast HTTP probe to live streamer with graceful disk fallback;
# upgrade trigger: migrate to unified event-driven socket client if multi-operator IPC is required.

require 'json'
require 'yaml'
require 'time'
require 'net/http'
require 'uri'
require 'optparse'
require 'fileutils'

class PipelineQuery
  ROOT_DIR = File.expand_path('..', __dir__)
  INTAKE_CONFIG_PATH = File.join(ROOT_DIR, '_data', 'media_intake_targets.yml')
  TELEMETRY_PATH = File.join(ROOT_DIR, '_data', 'youtube_pipeline_telemetry.json')
  DEFAULT_PORT = (ENV['LIVE_STREAM_PORT'] || 7025).to_i

  attr_reader :port, :state_dir

  def initialize(port: DEFAULT_PORT, state_dir: nil)
    @port = port
    @state_dir = state_dir || File.expand_path('~/.local/state/just3ws')
  end

  def fetch_status
    live_status = fetch_http_status
    live_telemetry = fetch_http_telemetry

    if live_status && live_telemetry
      build_payload_from_streamer(live_status, live_telemetry)
    else
      build_payload_from_disk
    end
  end

  private

  def fetch_http_status
    uri = URI("http://127.0.0.1:#{@port}/status")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 0.5
    http.read_timeout = 0.5
    res = http.get(uri.request_uri)
    return JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)

    nil
  rescue StandardError
    nil
  end

  def fetch_http_telemetry
    uri = URI("http://127.0.0.1:#{@port}/telemetry.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 0.5
    http.read_timeout = 0.8
    res = http.get(uri.request_uri)
    return JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)

    nil
  rescue StandardError
    nil
  end

  def build_payload_from_streamer(status_json, telemetry_json)
    worker_info = status_json['worker'] || {}
    queue_summary = status_json['queue_summary'] || {}
    recent_activity = status_json['recent_activity'] || []
    health = status_json['health'] || 'unknown'

    media_intake = telemetry_json['media_intake'] || {}
    targets_data = media_intake['targets'] || {}
    metrics = telemetry_json['metrics'] || {}

    quota_data = compute_quota_metrics(metrics, health, recent_activity)

    worker_state = determine_worker_state(worker_info, media_intake)

    {
      'status' => 'ok',
      'source' => 'live_streamer',
      'health' => health,
      'streamer' => {
        'status' => 'online',
        'port' => @port,
        'connected_clients' => status_json['connected_clients'] || 0,
        'server_time' => status_json['time']
      },
      'worker' => {
        'active_pid' => worker_info['active_pid'],
        'is_locked' => worker_info['is_locked'],
        'auto_intake_enabled' => worker_info['auto_intake_enabled'],
        'state' => worker_state
      },
      'quota' => quota_data,
      'queue_summary' => queue_summary,
      'targets' => format_targets(targets_data),
      'recent_activity' => recent_activity
    }
  end

  def build_payload_from_disk
    config = load_yaml(INTAKE_CONFIG_PATH)
    base_p = config['base_path'] ? File.expand_path(config['base_path']) : nil
    cloud_p = config['cloud_archive_path'] ? File.expand_path(config['cloud_archive_path']) : nil
    channel = 'whoistechcmty'
    targets_config = config.dig('channels', channel, 'targets') || {}

    halted = File.exist?(File.join(@state_dir, 'pipeline.halt'))
    stopped = File.exist?(File.join(@state_dir, 'pipeline.stop'))
    pid_file = File.join(@state_dir, 'pipeline.pid')
    active_pid = File.exist?(pid_file) ? (File.read(pid_file).strip rescue nil) : nil
    auto_intake = File.exist?(File.join(@state_dir, 'auto_intake.enabled'))

    # Check if active PID is running
    if active_pid && !active_pid.empty?
      pid_num = active_pid.to_i
      is_alive = begin
        pid_num > 0 && Process.kill(0, pid_num)
        true
      rescue Errno::ESRCH, Errno::EPERM
        false
      end
      active_pid = nil unless is_alive
    end

    targets = {}
    total_staged = 0
    total_pending = 0
    total_processing = 0
    total_processed = 0
    total_failed = 0
    total_blocked = 0

    targets_config.each do |target_name, target_info|
      search_dirs = [
        (base_p && Dir.exist?(base_p)) ? File.join(base_p, channel, target_name) : nil,
        (cloud_p && Dir.exist?(cloud_p)) ? File.join(cloud_p, channel, target_name) : nil
      ].compact

      staged_files = inspect_files(search_dirs, 'staged')
      pending_files = inspect_files(search_dirs, 'pending')
      processing_files = inspect_files(search_dirs, 'processing')
      processed_files = inspect_files(search_dirs, 'processed')
      failed_files = inspect_files(search_dirs, 'failed')
      blocked_files = inspect_files(search_dirs, 'blocked')

      total_staged += staged_files.size
      total_pending += pending_files.size
      total_processing += processing_files.size
      total_processed += processed_files.size
      total_failed += failed_files.size
      total_blocked += blocked_files.size

      targets[target_name] = {
        'series_name' => target_info['series_name'] || target_name,
        'playlist_id' => target_info['playlist_id'],
        'default_privacy' => target_info['default_privacy'] || 'unlisted',
        'staged_count' => staged_files.size,
        'staged_items' => staged_files,
        'pending_count' => pending_files.size,
        'pending_items' => pending_files,
        'processing_count' => processing_files.size,
        'processing_items' => processing_files,
        'processed_count' => processed_files.size,
        'failed_count' => failed_files.size,
        'failed_items' => failed_files,
        'blocked_count' => blocked_files.size,
        'blocked_items' => blocked_files
      }
    end

    cooldown_active = quota_cooldown_active?
    health = if stopped
      'stopped'
    elsif halted
      'halted'
    elsif total_failed > 0
      'degraded_quarantine'
    elsif total_blocked > 0 && cooldown_active
      'quota_cooldown_blocked'
    elsif total_processing > 0
      'processing'
    elsif total_pending > 0 || total_blocked > 0
      'pending'
    else
      'idle_ready'
    end

    telemetry = File.exist?(TELEMETRY_PATH) ? (JSON.parse(File.read(TELEMETRY_PATH)) rescue {}) : {}
    metrics = telemetry['metrics'] || {}

    activity_log_file = File.join(@state_dir, 'pipeline_activity.jsonl')
    recent_activity = []
    if File.exist?(activity_log_file)
      recent_activity = File.readlines(activity_log_file).last(10).map do |line|
        JSON.parse(line) rescue nil
      end.compact.reverse
    end

    quota_data = compute_quota_metrics(metrics, health, recent_activity)

    worker_info = {
      'active_pid' => active_pid,
      'is_locked' => !active_pid.nil? || total_processing > 0,
      'auto_intake_enabled' => auto_intake
    }

    worker_state = if stopped
      'STOPPED'
    elsif halted
      'HALTED'
    elsif active_pid
      "PROCESSING (PID #{active_pid})"
    else
      'IDLE'
    end

    {
      'status' => 'ok',
      'source' => 'disk_fallback',
      'health' => health,
      'streamer' => {
        'status' => 'offline',
        'port' => @port,
        'connected_clients' => 0,
        'server_time' => Time.now.utc.iso8601
      },
      'worker' => {
        'active_pid' => active_pid,
        'is_locked' => worker_info['is_locked'],
        'auto_intake_enabled' => auto_intake,
        'state' => worker_state
      },
      'quota' => quota_data,
      'queue_summary' => {
        'staged' => total_staged,
        'pending' => total_pending,
        'processing' => total_processing,
        'processed' => total_processed,
        'quarantined' => total_failed,
        'blocked' => total_blocked
      },
      'targets' => targets,
      'recent_activity' => recent_activity.first(5)
    }
  end

  def format_targets(targets_data)
    formatted = {}
    targets_data.each do |target_name, info|
      formatted[target_name] = {
        'series_name' => info['series_name'] || target_name,
        'playlist_id' => info['playlist_id'],
        'default_privacy' => info['default_privacy'] || 'unlisted',
        'staged_count' => info['staged_count'] || 0,
        'staged_items' => extract_item_names(info['staged_items']),
        'pending_count' => info['pending_count'] || 0,
        'pending_items' => extract_item_names(info['pending_items']),
        'processing_count' => info['processing_count'] || 0,
        'processing_items' => extract_item_names(info['processing_items']),
        'processed_count' => info['processed_count'] || 0,
        'failed_count' => info['failed_count'] || 0,
        'failed_items' => extract_item_names(info['failed_items']),
        'blocked_count' => info['blocked_count'] || 0,
        'blocked_items' => extract_item_names(info['blocked_items'])
      }
    end
    formatted
  end

  def extract_item_names(items)
    return [] unless items.is_a?(Array)

    items.map do |it|
      if it.is_a?(Hash)
        {
          'filename' => it['filename'] || it['name'],
          'size_mb' => it['size_bytes'] ? (it['size_bytes'].to_f / 1_048_576.0).round(1) : nil
        }
      elsif it.is_a?(String)
        { 'filename' => File.basename(it) }
      else
        it
      end
    end
  end

  MEDIA_EXTS = %w[.mp4 .mov .mkv .m4v .webm].freeze

  def inspect_files(search_dirs, subdir)
    found = []
    seen = {}
    search_dirs.each do |dir|
      sub = File.join(dir, subdir)
      next unless Dir.exist?(sub)

      Dir.glob(File.join(sub, '**', '*')).each do |f|
        next unless File.file?(f)
        ext = File.extname(f).downcase
        next unless MEDIA_EXTS.include?(ext)

        basename = File.basename(f)
        next if seen[basename]

        seen[basename] = true
        found << {
          'filename' => basename,
          'size_mb' => (File.size(f).to_f / 1_048_576.0).round(1)
        }
      end
    end
    found
  end

  def compute_quota_metrics(metrics, health, recent_activity)
    daily_budget = metrics['daily_quota_budget'] || 10_000
    needed = metrics['quota_needed_for_pending'] || 0
    pct = metrics['quota_budget_percentage'] || ((needed.to_f / daily_budget.to_f) * 100.0).round(1)

    in_cooldown = quota_cooldown_active?

    now_utc = Time.now.utc
    now_pt = now_utc.getlocal('-07:00')
    next_reset_pt = Time.new(now_pt.year, now_pt.month, now_pt.day, 0, 0, 0, '-07:00') + 86_400
    diff_sec = [0, (next_reset_pt - now_pt).to_i].max
    hours = diff_sec / 3600
    mins = (diff_sec % 3600) / 60

    {
      'daily_limit' => daily_budget,
      'units_needed' => needed,
      'budget_percentage' => pct,
      'in_cooldown' => in_cooldown,
      'next_reset' => '02:00 CT (00:00 PT)',
      'time_to_reset' => "#{hours}h #{mins}m",
      'reset_timestamp' => next_reset_pt.utc.iso8601
    }
  end

  def quota_cooldown_active?
    return false unless File.exist?(INTAKE_CONFIG_PATH)

    config = load_yaml(INTAKE_CONFIG_PATH)
    base_p = config['base_path'] ? File.expand_path(config['base_path']) : nil
    cloud_p = config['cloud_archive_path'] ? File.expand_path(config['cloud_archive_path']) : nil
    now_utc = Time.now.utc
    now_pt = now_utc.getlocal('-07:00')
    last_reset_pt = Time.new(now_pt.year, now_pt.month, now_pt.day, 0, 0, 0, '-07:00')

    search_dirs = []
    (config['channels'] || {}).each do |ch_name, ch_conf|
      (ch_conf['targets'] || {}).each do |target_name, _|
        search_dirs << File.join(base_p, ch_name, target_name, 'blocked') if base_p
        search_dirs << File.join(cloud_p, ch_name, target_name, 'blocked') if cloud_p
      end
    end

    search_dirs.compact.uniq.select { |d| Dir.exist?(d) }.each do |bdir|
      Dir.glob(File.join(bdir, '*.blocked.json')).each do |bf|
        bdata = JSON.parse(File.read(bf)) rescue {}
        if bdata['reason'] == 'upstream_quota_blocked' && bdata['blocked_at']
          blocked_at = Time.parse(bdata['blocked_at']) rescue nil
          return true if blocked_at && blocked_at >= last_reset_pt
        end
      end
    end
    false
  end

  def determine_worker_state(worker_info, media_intake)
    if media_intake['stopped']
      'STOPPED'
    elsif media_intake['halted']
      'HALTED'
    elsif worker_info['active_pid']
      "PROCESSING (PID #{worker_info['active_pid']})"
    else
      'IDLE'
    end
  end

  def load_yaml(path)
    return {} unless File.exist?(path)

    YAML.safe_load(File.read(path)) rescue {}
  end
end

class PipelineQueryPresenter
  def initialize(payload, options = {})
    @data = payload
    @options = options
  end

  def render
    if @options[:json]
      render_json
    elsif @options[:compact]
      render_compact
    else
      render_full_dashboard
    end
  end

  private

  def render_json
    filtered = filter_data
    JSON.pretty_generate(filtered)
  end

  def filter_data
    case @options[:section]
    when 'queues'
      { 'queue_summary' => @data['queue_summary'], 'targets' => filtered_targets }
    when 'quota'
      @data['quota']
    when 'worker'
      @data['worker']
    when 'activity'
      @data['recent_activity'].first(@options[:activity_count] || 5)
    else
      if @options[:target]
        @data.merge('targets' => filtered_targets)
      else
        @data
      end
    end
  end

  def filtered_targets
    targets = @data['targets'] || {}
    if @options[:target]
      targets.select { |k, _| k == @options[:target] }
    else
      targets
    end
  end

  def render_compact
    q = @data['queue_summary'] || {}
    quota = @data['quota'] || {}
    w = @data['worker'] || {}
    streamer = @data['streamer'] || {}

    quota_txt = "#{quota['units_needed']}/#{quota['daily_limit']}"
    if quota['in_cooldown']
      quota_txt += " (cooldown until #{quota['next_reset']}, resets in #{quota['time_to_reset']})"
    end

    "[HEALTH: #{@data['health']}] " \
    "Queues: #{q['staged']} staged, #{q['pending']} pending, #{q['processing']} proc, #{q['processed']} done, #{q['blocked']} blocked | " \
    "Worker: #{w['state']} | " \
    "Quota: #{quota_txt} | " \
    "Streamer: #{streamer['status']} (port #{streamer['port']})"
  end

  def render_full_dashboard
    lines = []
    lines << '=' * 74
    lines << '🎥 MEDIA INTAKE & PUBLISHING PIPELINE STATUS'
    lines << '=' * 74

    health = @data['health']
    streamer = @data['streamer'] || {}
    worker = @data['worker'] || {}
    quota = @data['quota'] || {}
    q = @data['queue_summary'] || {}

    streamer_desc = if streamer['status'] == 'online'
      "Online (port #{streamer['port']}, #{streamer['connected_clients']} clients)"
    else
      'Offline (fallback to disk state)'
    end

    lines << format('System Health:     %s', health)
    lines << format('Streamer Daemon:   %s', streamer_desc)
    lines << format('Worker Status:     %s (lock: %s, auto-intake: %s)',
                    worker['state'],
                    worker['is_locked'] ? 'LOCKED' : 'free',
                    worker['auto_intake_enabled'] ? 'enabled' : 'disabled')

    quota_status_str = "#{quota['units_needed']} / #{quota['daily_limit']} units (#{quota['budget_percentage']}%)"
    if quota['in_cooldown']
      quota_status_str += " [COOLDOWN ACTIVE: resets in #{quota['time_to_reset']} at #{quota['next_reset']}]"
    else
      quota_status_str += ' [API READY]'
    end
    lines << format('YouTube Quota:     %s', quota_status_str)
    lines << format('Queue Summary:     %d staged, %d pending, %d processing, %d processed, %d blocked',
                    q['staged'], q['pending'], q['processing'], q['processed'], q['blocked'])

    if @options[:section].nil? || @options[:section] == 'all' || @options[:section] == 'queues'
      lines << ''
      lines << '📁 TARGET QUEUES'
      lines << '-' * 74

      targets = filtered_targets
      if targets.empty?
        lines << '  (No targets configured or target not found)'
      else
        targets.each do |tname, tinfo|
          lines << "  • #{tname} (#{tinfo['series_name']} - #{tinfo['playlist_id']}):"
          lines << "    [staged] #{tinfo['staged_count']} | [pending] #{tinfo['pending_count']} | [processing] #{tinfo['processing_count']} | [processed] #{tinfo['processed_count']} | [blocked] #{tinfo['blocked_count']}"

          if tinfo['pending_items'] && !tinfo['pending_items'].empty?
            lines << '    Pending candidates:'
            tinfo['pending_items'].each do |item|
              size_str = item['size_mb'] ? " (#{item['size_mb']} MB)" : ''
              lines << "      -> #{item['filename']}#{size_str}"
            end
          end

          if tinfo['staged_items'] && !tinfo['staged_items'].empty?
            lines << '    Staged hold:'
            tinfo['staged_items'].each do |item|
              size_str = item['size_mb'] ? " (#{item['size_mb']} MB)" : ''
              lines << "      -> #{item['filename']}#{size_str}"
            end
          end

          if tinfo['blocked_items'] && !tinfo['blocked_items'].empty?
            lines << '    Blocked items:'
            tinfo['blocked_items'].each do |item|
              lines << "      -> #{item['filename']}"
            end
          end
        end
      end
    end

    if @options[:section].nil? || @options[:section] == 'all' || @options[:section] == 'activity'
      lines << ''
      lines << '📜 RECENT ACTIVITY'
      lines << '-' * 74
      acts = @data['recent_activity'] || []
      limit = @options[:activity_count] || 5
      if acts.empty?
        lines << '  (No recent activity recorded)'
      else
        acts.first(limit).each do |act|
          time_str = act['timestamp'] ? act['timestamp'].sub(/^.*T(\d{2}:\d{2}:\d{2}).*$/, '\1') : '--:--:--'
          stage_str = (act['stage'] || 'info').upcase
          msg = act['message'] || ''
          # Truncate long error messages for display
          msg_clean = msg.lines.first.to_s.strip
          msg_clean = msg_clean[0..110] + '...' if msg_clean.length > 110
          lines << "  • [#{time_str}] [#{stage_str}] #{msg_clean}"
        end
      end
    end

    lines << '=' * 74
    lines.join("\n")
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: bin/query_pipeline.rb [options]'
    opts.separator ''
    opts.separator 'Fast CLI query engine for media intake, publishing, and YouTube quota status'
    opts.separator ''

    opts.on('-j', '--json', 'Output raw JSON status payload') do
      options[:json] = true
    end

    opts.on('-c', '--compact', 'Output single-line compact status summary') do
      options[:compact] = true
    end

    opts.on('-q', '--queues', 'Inspect queues across all targets') do
      options[:section] = 'queues'
    end

    opts.on('--quota', 'Inspect YouTube quota budget and cooldown status') do
      options[:section] = 'quota'
    end

    opts.on('--worker', 'Inspect worker PID and concurrency lock state') do
      options[:section] = 'worker'
    end

    opts.on('-a', '--activity [N]', Integer, 'Inspect recent activity log entries (default: 5)') do |n|
      options[:section] = 'activity'
      options[:activity_count] = n || 5
    end

    opts.on('-t', '--target NAME', 'Filter reporting to specific target') do |t|
      options[:target] = t
    end

    opts.on('-p', '--port PORT', Integer, 'Override live streamer HTTP port (default: 7025)') do |p|
      options[:port] = p
    end

    opts.on('-h', '--help', 'Show this help message') do
      puts opts
      exit 0
    end
  end.parse!

  query = PipelineQuery.new(port: options[:port] || PipelineQuery::DEFAULT_PORT)
  payload = query.fetch_status
  presenter = PipelineQueryPresenter.new(payload, options)
  puts presenter.render
end

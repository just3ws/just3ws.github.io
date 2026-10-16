#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: live_dashboard_streamer.rb
# domain: media
# role: Real-time SSE & Telemetry Daemon for Operations Cockpit
# description: Near-realtime broadcast updates for Google Drive queues, BPMN step transitions, and pipeline telemetry
# ports: 127.0.0.1:7025 (or proxied via nginx /api/live/events)
# endpoints: /events (SSE), /telemetry.json (REST), /status (Health)
# usage: bin/pipeline media stream
# ---

require 'socket'
require 'json'
require 'yaml'
require 'time'
require 'fileutils'
require 'optparse'
require 'uri'
require 'digest'
require 'open3'

ROOT_DIR ||= File.expand_path('..', __dir__)
TELEMETRY_PATH = File.join(ROOT_DIR, '_data', 'youtube_pipeline_telemetry.json')
PUBLIC_TELEMETRY_PATH = File.join(ROOT_DIR, 'assets', 'data', 'youtube_pipeline_telemetry.json')
INTAKE_CONFIG_PATH = File.join(ROOT_DIR, '_data', 'media_intake_targets.yml')
PORT = (ENV['LIVE_STREAM_PORT'] || 7025).to_i

class LiveDashboardStreamer
  attr_reader :port, :clients, :mutex, :last_state_hash

  def initialize(port = PORT)
    @port = port
    @clients = []
    @mutex = Mutex.new
    @last_state_hash = ""
    @running = true
  end

  def start
    server = TCPServer.new('127.0.0.1', @port)
    puts "🚀 [Live Streamer] SSE daemon listening on http://127.0.0.1:#{@port}/events"
    puts "   Endpoints: /events (SSE), /telemetry.json (REST), /status (Health)"

    # Thread 1: Intake Queue & Telemetry Watcher
    watcher_thread = Thread.new { run_watcher }

    # Thread 2: Heartbeat Keep-Alive (every 15s)
    heartbeat_thread = Thread.new { run_heartbeat }

    # Main Accept Loop
    while @running
      begin
        socket = server.accept
        Thread.new(socket) { |client| handle_request(client) }
      rescue StandardError => e
        warn "⚠️ Accept error: #{e.message}" if @running
      end
    end
  ensure
    server&.close
    watcher_thread&.kill
    heartbeat_thread&.kill
  end

  def handle_request(client)
    request_line = client.gets
    return client.close unless request_line

    method, path, = request_line.split
    headers = {}
    while (line = client.gets) && line.strip != ""
      k, v = line.split(":", 2)
      headers[k.downcase.strip] = v.strip if k && v
    end

    clean_path = path.to_s.split('?').first
    case clean_path
    when "/events", "/api/live/events"
      handle_sse(client)
    when "/telemetry.json", "/api/live/telemetry.json"
      handle_telemetry_json(client)
    when "/status", "/api/live/status"
      handle_status(client)
    when "/pipeline/halt", "/api/live/pipeline/halt"
      handle_pipeline_halt(client)
    when "/pipeline/stop", "/api/live/pipeline/stop"
      handle_pipeline_stop(client)
    when "/pipeline/resume", "/api/live/pipeline/resume"
      handle_pipeline_resume(client)
    when "/pipeline/retry", "/api/live/pipeline/retry"
      handle_pipeline_retry(client, path)
    when "/pipeline/run", "/api/live/pipeline/run"
      handle_pipeline_run(client)
    when "/pipeline/auto_toggle", "/api/live/pipeline/auto_toggle"
      handle_pipeline_auto_toggle(client)
    when "/pipeline/cue_obs", "/api/live/pipeline/cue_obs"
      handle_pipeline_cue_obs(client, path)
    when "/pipeline/stage_to_pending", "/api/live/pipeline/stage_to_pending"
      handle_pipeline_stage_to_pending(client, path)
    else
      respond_404(client)
    end
  rescue StandardError => e
    client.close rescue nil
  end

  def handle_sse(client)
    response_headers = [
      "HTTP/1.1 200 OK",
      "Content-Type: text/event-stream; charset=utf-8",
      "Cache-Control: no-cache, no-transform",
      "Connection: keep-alive",
      "Access-Control-Allow-Origin: *",
      "Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept",
      "X-Accel-Buffering: no",
      "",
      ""
    ].join("\r\n")

    client.write(response_headers)

    # Initial connect handshake
    initial_payload = {
      status: "connected",
      server_time: Time.now.utc.iso8601,
      port: @port
    }
    client.write("event: connected\ndata: #{JSON.generate(initial_payload)}\n\n")

    # Send current state immediately
    current_snapshot = compile_current_state
    client.write("event: telemetry\ndata: #{JSON.generate(current_snapshot)}\n\n")

    mutex.synchronize { @clients << client }

    # Keep client socket open; read blocks until disconnection
    begin
      while client.gets
        # client keeps connection open
      end
    ensure
      mutex.synchronize { @clients.delete(client) }
      client.close rescue nil
    end
  end

  def handle_telemetry_json(client)
    snapshot = compile_current_state
    body = JSON.generate(snapshot)
    resp = [
      "HTTP/1.1 200 OK",
      "Content-Type: application/json; charset=utf-8",
      "Content-Length: #{body.bytesize}",
      "Access-Control-Allow-Origin: *",
      "Cache-Control: no-cache",
      "",
      body
    ].join("\r\n")
    client.write(resp)
    client.close
  end

  def handle_status(client)
    state = compile_live_intake_queues
    targets = state['targets'] || {}

    total_staged = targets.values.sum { |t| t['staged_count'] || 0 }
    total_pending = targets.values.sum { |t| t['pending_count'] || 0 }
    total_processing = targets.values.sum { |t| t['processing_count'] || 0 }
    total_processed = targets.values.sum { |t| t['processed_count'] || 0 }
    total_failed = targets.values.sum { |t| t['failed_count'] || 0 }

    health_status = if state['stopped']
      'stopped'
    elsif state['halted']
      'halted'
    elsif total_failed > 0
      'degraded_quarantine'
    elsif total_processing > 0
      'processing'
    elsif total_pending > 0
      'pending'
    else
      'idle_ready'
    end

    payload = {
      status: "ok",
      health: health_status,
      connected_clients: @clients.size,
      time: Time.now.utc.iso8601,
      worker: {
        active_pid: state['active_pid'],
        is_locked: state['locked'],
        auto_intake_enabled: state['auto_intake']
      },
      queue_summary: {
        staged: total_staged,
        pending: total_pending,
        processing: total_processing,
        processed: total_processed,
        quarantined: total_failed
      },
      self_healing: {
        last_events: state['self_healing_events'] || []
      },
      recent_activity: (state['activity_stream'] || []).first(5)
    }
    body = JSON.generate(payload)
    resp = [
      "HTTP/1.1 200 OK",
      "Content-Type: application/json; charset=utf-8",
      "Content-Length: #{body.bytesize}",
      "Access-Control-Allow-Origin: *",
      "",
      body
    ].join("\r\n")
    client.write(resp)
    client.close
  end

  def respond_404(client)
    body = "Not Found"
    resp = [
      "HTTP/1.1 404 Not Found",
      "Content-Type: text/plain",
      "Content-Length: #{body.bytesize}",
      "Access-Control-Allow-Origin: *",
      "",
      body
    ].join("\r\n")
    client.write(resp)
    client.close
  end

  def run_watcher
    loop do
      sleep 1.5
      state = compile_current_state
      state_hash = Digest::SHA256.hexdigest(JSON.generate(state))

      if state_hash != @last_state_hash
        @last_state_hash = state_hash
        broadcast("intake_update", state)

        # Broadcast active BPMN stage step if an item is processing
        active_step = detect_active_bpmn_step(state)
        broadcast("bpmn_transition", active_step) if active_step
      end

      # Autonomous Hands-Off Ingress Trigger
      check_autonomous_ingress(state['media_intake'])
    end
  end

  def check_autonomous_ingress(intake)
    return unless intake && intake['auto_intake']
    return if intake['locked'] || intake['halted'] || intake['stopped']

    total_pending = (intake['targets'] || {}).values.sum { |t| t['pending_count'] || 0 }
    return unless total_pending > 0
    return if worker_running?

    spawn_intake_worker!
  end

  def worker_running?
    state_dir = File.expand_path('~/.local/state/just3ws')
    pid_file = File.join(state_dir, 'pipeline.pid')
    return false unless File.exist?(pid_file)
    pid = File.read(pid_file).strip.to_i
    return false if pid <= 0
    Process.kill(0, pid)
    true
  rescue Errno::ESRCH, Errno::EPERM
    false
  end

  def spawn_intake_worker!
    state_dir = File.expand_path('~/.local/state/just3ws')
    FileUtils.mkdir_p(state_dir)
    worker_log = File.join(state_dir, 'pipeline_worker.log')

    pid = Process.spawn(
      RbConfig.ruby, File.join(ROOT_DIR, 'bin', 'intake_drive_video.rb'), '-1',
      chdir: ROOT_DIR,
      out: [worker_log, 'a'],
      err: [:child, :out]
    )
    Process.detach(pid)
    log_activity('autonomous', "Autonomous intake triggered single-worker ingestion (PID #{pid})", level: 'info', details: { 'pid' => pid })
    broadcast_state!
  rescue StandardError => e
    log_activity('error', "Could not spawn autonomous intake worker: #{e.message}", level: 'error')
  end

  def log_activity(stage, message, level: 'info', details: {})
    state_dir = File.expand_path('~/.local/state/just3ws')
    FileUtils.mkdir_p(state_dir)
    log_file = File.join(state_dir, 'pipeline_activity.jsonl')
    entry = {
      'timestamp' => Time.now.utc.iso8601,
      'stage' => stage.to_s,
      'level' => level.to_s,
      'message' => message.to_s,
      'details' => details
    }
    File.open(log_file, 'a') { |f| f.puts(JSON.generate(entry)) }
  rescue StandardError
  end

  def run_heartbeat
    loop do
      sleep 15
      broadcast_raw(": keepalive\n\n")
    end
  end

  def broadcast(event_name, data)
    payload = "event: #{event_name}\ndata: #{JSON.generate(data)}\n\n"
    broadcast_raw(payload)
  end

  def broadcast_raw(payload)
    dead_clients = []
    mutex.synchronize do
      @clients.each do |c|
        begin
          c.write(payload)
          c.flush
        rescue StandardError
          dead_clients << c
        end
      end
      dead_clients.each { |dc| @clients.delete(dc); dc.close rescue nil }
    end
  end

  def compile_current_state
    # 1. Base telemetry
    telemetry = {}
    if File.exist?(TELEMETRY_PATH)
      telemetry = JSON.parse(File.read(TELEMETRY_PATH)) rescue {}
    end

    # 2. Real-time Google Drive queue audit
    intake = compile_live_intake_queues
    telemetry['media_intake'] = intake
    telemetry['updated_at'] = Time.now.utc.iso8601

    # Keep public assets JSON in sync for static fallbacks
    mirror_public_telemetry(telemetry)

    telemetry
  end

  def compile_live_intake_queues
    return {} unless File.exist?(INTAKE_CONFIG_PATH)
    config = YAML.safe_load(File.read(INTAKE_CONFIG_PATH)) rescue {}
    base_p = config['base_path']
    channel = 'whoistechcmty'
    targets = config.dig('channels', channel, 'targets') || {}

    state_dir = File.expand_path('~/.local/state/just3ws')
    halted = File.exist?(File.join(state_dir, 'pipeline.halt'))
    stopped = File.exist?(File.join(state_dir, 'pipeline.stop'))
    pid_file = File.join(state_dir, 'pipeline.pid')
    active_pid = File.exist?(pid_file) ? (File.read(pid_file).strip rescue nil) : nil
    auto_intake_file = File.join(state_dir, 'auto_intake.enabled')
    auto_intake = File.exist?(auto_intake_file) || ENV['AUTONOMOUS_INTAKE'] == 'true'

    self_healing_events = []

    # Self-healing 1: Check if recorded active worker PID is actually running
    if active_pid && !active_pid.empty?
      pid_num = active_pid.to_i
      is_alive = begin
        if pid_num > 0
          Process.kill(0, pid_num)
          true
        else
          false
        end
      rescue Errno::ESRCH, Errno::EPERM
        false
      end

      unless is_alive
        FileUtils.rm_f(pid_file)
        msg = "Self-healed dead worker PID #{active_pid}: unlinked stale PID lock"
        log_activity('self_healing', msg, level: 'warning', details: { 'stale_pid' => active_pid })
        self_healing_events << msg
        active_pid = nil
      end
    end

    # Self-healing 2: If no worker is active, restore any stranded files in processing/ back to pending/
    if active_pid.nil? && base_p && Dir.exist?(base_p)
      targets.each_key do |target_name|
        proc_dir = File.join(base_p, channel, target_name, 'processing')
        pend_dir = File.join(base_p, channel, target_name, 'pending')
        next unless Dir.exist?(proc_dir)

        Dir.glob(File.join(proc_dir, '*')).each do |f|
          next unless File.file?(f)
          dest = File.join(pend_dir, File.basename(f))
          FileUtils.mv(f, dest)
          msg = "Self-healed stranded file #{File.basename(f)}: restored from processing/ to pending/ in #{target_name}"
          log_activity('self_healing', msg, level: 'warning', details: { 'target' => target_name, 'file' => File.basename(f) })
          self_healing_events << msg
        end
      end
    end

    activity_log_file = File.join(state_dir, 'pipeline_activity.jsonl')
    activity_stream = []
    if File.exist?(activity_log_file)
      activity_stream = File.readlines(activity_log_file).last(40).map do |line|
        JSON.parse(line) rescue nil
      end.compact.reverse
    end

    target_stats = {}
    targets.each do |target_name, target_info|
      target_dir = File.join(base_p, channel, target_name)
      staged_files = Dir.glob(File.join(target_dir, 'staged', '*')).select { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }
      pending_files = Dir.glob(File.join(target_dir, 'pending', '*')).select { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }
      processing_files = Dir.glob(File.join(target_dir, 'processing', '*')).select { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }
      processed_files = Dir.glob(File.join(target_dir, 'processed', '**', '*')).select { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }
      failed_files = Dir.glob(File.join(target_dir, 'failed', '*')).select { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }

      pending_sorted = pending_files.sort_by do |f|
        begin
          File.birthtime(f)
        rescue StandardError
          File.mtime(f)
        end
      end

      pending_items = pending_sorted.each_with_index.map do |f, idx|
        age_ts = begin; File.birthtime(f); rescue StandardError; File.mtime(f); end
        {
          'filename' => File.basename(f),
          'size_bytes' => (File.size(f) rescue 0),
          'queue_position' => idx + 1,
          'ingress_at' => age_ts.utc.iso8601
        }
      end

      failed_items = failed_files.map do |f|
        {
          'filename' => File.basename(f),
          'size_bytes' => (File.size(f) rescue 0),
          'failed_at' => (File.mtime(f).utc.iso8601 rescue nil),
          'diagnostic' => 'Quarantined for operator review. Click Re-queue to return file to pending.'
        }
      end

      recent_processed = processed_files.sort_by { |f| File.mtime(f) rescue Time.at(0) }.reverse.first(6).map do |f|
        receipt_file = "#{f}.receipt.json"
        receipt = File.exist?(receipt_file) ? (JSON.parse(File.read(receipt_file)) rescue {}) : {}
        {
          'filename' => File.basename(f),
          'size_bytes' => (File.size(f) rescue 0),
          'archived_at' => (File.mtime(f).utc.iso8601 rescue nil),
          'archive_path' => f.sub("#{target_dir}/", ''),
          'video_id' => receipt['video_id'],
          'youtube_url' => receipt['youtube_url'] || (receipt['video_id'] ? "https://youtu.be/#{receipt['video_id']}" : nil),
          'title' => receipt['title'],
          'playlist_id' => receipt['playlist_id'] || target_info['playlist_id'],
          'privacy' => receipt['privacy'] || target_info['default_privacy'],
          'performance_metrics' => receipt['performance_metrics'] || {}
        }
      end

      target_stats[target_name] = {
        'series_name' => target_info['series_name'],
        'playlist_id' => target_info['playlist_id'],
        'archetype' => target_info['archetype'],
        'purpose' => target_info['purpose'],
        'intro_structure' => target_info['intro_structure'],
        'outro_structure' => target_info['outro_structure'],
        'default_privacy' => target_info['default_privacy'],
        'staged_count' => staged_files.size,
        'staged_items' => staged_files.map { |f| { 'filename' => File.basename(f), 'size_bytes' => (File.size(f) rescue 0) } },
        'pending_count' => pending_files.size,
        'pending_items' => pending_items,
        'processing_count' => processing_files.size,
        'processing_items' => processing_files.map { |f| { 'filename' => File.basename(f) } },
        'processed_count' => processed_files.size,
        'recent_processed' => recent_processed,
        'failed_count' => failed_files.size,
        'failed_items' => failed_items
      }
    end

    total_processing = target_stats.values.sum { |t| t['processing_count'] || 0 }
    locked = total_processing > 0 || !active_pid.nil?

    {
      'base_path' => base_p,
      'channel' => channel,
      'halted' => halted,
      'stopped' => stopped,
      'locked' => locked,
      'active_pid' => active_pid,
      'auto_intake' => auto_intake,
      'self_healing_events' => self_healing_events,
      'targets' => target_stats,
      'activity_stream' => activity_stream,
      'polled_at' => Time.now.utc.iso8601
    }
  end

  def parse_params(path)
    params = {}
    query = path.split('?')[1]
    return params unless query
    query.split('&').each do |part|
      k, v = part.split('=', 2)
      params[URI.decode_www_form_component(k)] = URI.decode_www_form_component(v || '') if k
    end
    params
  end

  def handle_pipeline_halt(client)
    state_dir = File.expand_path('~/.local/state/just3ws')
    FileUtils.mkdir_p(state_dir)
    FileUtils.touch(File.join(state_dir, 'pipeline.halt'))
    FileUtils.rm_f(File.join(state_dir, 'pipeline.stop'))
    broadcast_state!
    respond_json(client, { status: "halt_armed", message: "Pipeline will pause after current file completes" })
  end

  def handle_pipeline_stop(client)
    state_dir = File.expand_path('~/.local/state/just3ws')
    FileUtils.mkdir_p(state_dir)
    FileUtils.touch(File.join(state_dir, 'pipeline.stop'))
    pid_file = File.join(state_dir, 'pipeline.pid')
    if File.exist?(pid_file)
      pid = File.read(pid_file).strip.to_i
      Process.kill('TERM', pid) rescue nil if pid > 0
    end
    restore_processing_to_pending!
    broadcast_state!
    respond_json(client, { status: "stopped", message: "Task stopped and files restored to pending" })
  end

  def handle_pipeline_resume(client)
    state_dir = File.expand_path('~/.local/state/just3ws')
    FileUtils.rm_f(File.join(state_dir, 'pipeline.halt'))
    FileUtils.rm_f(File.join(state_dir, 'pipeline.stop'))
    broadcast_state!
    respond_json(client, { status: "resumed", message: "Pipeline resumed" })
  end

  def handle_pipeline_retry(client, path)
    params = parse_params(path)
    target = params['target']
    filename = params['file']
    if target && filename
      config = YAML.safe_load(File.read(INTAKE_CONFIG_PATH)) rescue {}
      base_p = config['base_path']
      src = File.join(base_p, 'whoistechcmty', target, 'failed', filename)
      dst = File.join(base_p, 'whoistechcmty', target, 'pending', filename)
      if File.exist?(src)
        FileUtils.mv(src, dst)
        broadcast_state!
        return respond_json(client, { status: "retried", file: filename, target: target })
      end
    end
    respond_json(client, { error: "File not found in failed" }, status: "400 Bad Request")
  end

  def handle_pipeline_stage_to_pending(client, path)
    params = parse_params(path)
    target = params['target']
    filename = params['file']
    if target && filename
      config = YAML.safe_load(File.read(INTAKE_CONFIG_PATH)) rescue {}
      base_p = config['base_path']
      src = File.join(base_p, 'whoistechcmty', target, 'staged', filename)
      dst = File.join(base_p, 'whoistechcmty', target, 'pending', filename)
      if File.exist?(src)
        FileUtils.mv(src, dst)
        broadcast_state!
        return respond_json(client, { status: "moved", file: filename, target: target })
      end
    end
    respond_json(client, { error: "File not found in staged" }, status: "400 Bad Request")
  end

  def handle_pipeline_run(client)
    state = compile_live_intake_queues
    if state['locked'] || worker_running?
      return respond_json(client, { status: "error", message: "Pipeline is currently locked with an active worker" }, status: "409 Conflict")
    end
    if state['halted'] || state['stopped']
      return respond_json(client, { status: "error", message: "Pipeline is halted or stopped. Resume queue first." }, status: "400 Bad Request")
    end

    spawn_intake_worker!
    respond_json(client, { status: "started", message: "Intake worker spawned cleanly" })
  end

  def handle_pipeline_auto_toggle(client)
    state_dir = File.expand_path('~/.local/state/just3ws')
    FileUtils.mkdir_p(state_dir)
    sentinel = File.join(state_dir, 'auto_intake.enabled')
    now_enabled = false
    if File.exist?(sentinel)
      FileUtils.rm_f(sentinel)
      log_activity('control', 'Autonomous auto-intake disabled by operator', level: 'warning')
    else
      FileUtils.touch(sentinel)
      now_enabled = true
      log_activity('control', 'Autonomous auto-intake enabled by operator', level: 'success')
    end
    broadcast_state!
    respond_json(client, { status: "toggled", auto_intake: now_enabled, message: "Autonomous auto-intake #{now_enabled ? 'enabled' : 'disabled'}" })
  end

  def handle_pipeline_cue_obs(client, path)
    params = parse_params(path)
    ep = params['episode'] || '0'
    broadcast_bin = File.join(ROOT_DIR, 'bin', 'broadcast')
    cmd = "#{RbConfig.ruby} #{broadcast_bin} cue --rewatch #{ep.to_i}"
    out, status = Open3.capture2e(cmd)
    if status.success?
      log_activity('control', "Cued Episode #{ep} directly into live OBS overlays", level: 'success', details: { 'episode' => ep.to_i })
      broadcast_state!
      respond_json(client, { status: "cued", episode: ep.to_i, message: "Episode #{ep} cued in OBS overlays" })
    else
      respond_json(client, { status: "error", message: out }, status: "500 Internal Server Error")
    end
  end

  def restore_processing_to_pending!
    return unless File.exist?(INTAKE_CONFIG_PATH)
    config = YAML.safe_load(File.read(INTAKE_CONFIG_PATH)) rescue {}
    base_p = config['base_path']
    channel = 'whoistechcmty'
    targets = config.dig('channels', channel, 'targets') || {}
    targets.each_key do |target_name|
      proc_dir = File.join(base_p, channel, target_name, 'processing')
      pend_dir = File.join(base_p, channel, target_name, 'pending')
      Dir.glob(File.join(proc_dir, '*')).each do |f|
        next unless File.file?(f)
        FileUtils.mv(f, File.join(pend_dir, File.basename(f)))
      end
    end
  end

  def respond_json(client, data, status: "200 OK")
    body = JSON.generate(data)
    resp = [
      "HTTP/1.1 #{status}",
      "Content-Type: application/json; charset=utf-8",
      "Content-Length: #{body.bytesize}",
      "Access-Control-Allow-Origin: *",
      "Cache-Control: no-cache",
      "",
      body
    ].join("\r\n")
    client.write(resp)
    client.close rescue nil
  end

  def broadcast_state!
    state = compile_current_state
    broadcast("telemetry", state)
  end

  def detect_active_bpmn_step(state)
    targets = state.dig('media_intake', 'targets') || {}
    any_processing = false
    active_target = nil
    active_file = nil

    targets.each do |tname, tdata|
      if tdata['processing_count'].to_i > 0
        any_processing = true
        active_target = tname
        active_file = tdata.dig('processing_items', 0, 'filename')
        break
      end
    end

    if any_processing
      {
        step: "step5",
        status: "processing",
        target: active_target,
        file: active_file,
        label: "Apple Silicon Whisper Recognition"
      }
    else
      {
        step: "step1",
        status: "standby",
        target: nil,
        file: nil,
        label: "Poll Queue (Inspection & Ingress)"
      }
    end
  end

  def mirror_public_telemetry(telemetry)
    FileUtils.mkdir_p(File.dirname(PUBLIC_TELEMETRY_PATH))
    File.write(PUBLIC_TELEMETRY_PATH, JSON.pretty_generate(telemetry) + "\n") rescue nil
  end
end

if __FILE__ == $PROGRAM_NAME
  port = PORT
  OptionParser.new do |opts|
    opts.banner = "Usage: bin/live_dashboard_streamer.rb [options]"
    opts.on("-p", "--port PORT", Integer, "Listen port (default: 7025)") { |p| port = p }
    opts.on("-h", "--help", "Show help") do
      puts opts
      exit 0
    end
  end.parse!

  LiveDashboardStreamer.new(port).start
end

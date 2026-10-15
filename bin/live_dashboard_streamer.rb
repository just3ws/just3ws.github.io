#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/live_dashboard_streamer.rb
# Real-time SSE (Server-Sent Events) & Telemetry Streamer for YouTube & Intake Dashboard
#
# Provides near-realtime broadcast updates for:
#   * Google Drive Media Intake queue counts (pending, processing, processed, failed)
#   * Active BPMN step execution transitions (ffmpeg, whisper, upload, etc.)
#   * Real-time pipeline telemetry and SLO health metrics
#
# Binds loopback http://127.0.0.1:7025/events (or proxied via nginx /api/live/events).

require 'socket'
require 'json'
require 'yaml'
require 'time'
require 'fileutils'
require 'optparse'

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

    case path
    when "/events", "/api/live/events"
      handle_sse(client)
    when "/telemetry.json", "/api/live/telemetry.json"
      handle_telemetry_json(client)
    when "/status", "/api/live/status"
      handle_status(client)
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
    payload = {
      status: "ok",
      connected_clients: @clients.size,
      time: Time.now.utc.iso8601
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
    end
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

    target_stats = {}
    targets.each do |target_name, target_info|
      target_dir = File.join(base_p, channel, target_name)
      pending_files = Dir.glob(File.join(target_dir, 'pending', '*')).select { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }
      processing_files = Dir.glob(File.join(target_dir, 'processing', '*')).select { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }
      processed_count = Dir.glob(File.join(target_dir, 'processed', '**', '*')).count { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }
      failed_files = Dir.glob(File.join(target_dir, 'failed', '*')).select { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }

      target_stats[target_name] = {
        'series_name' => target_info['series_name'],
        'playlist_id' => target_info['playlist_id'],
        'default_privacy' => target_info['default_privacy'],
        'pending_count' => pending_files.size,
        'pending_items' => pending_files.map { |f| { 'filename' => File.basename(f), 'size_bytes' => (File.size(f) rescue 0) } },
        'processing_count' => processing_files.size,
        'processing_items' => processing_files.map { |f| { 'filename' => File.basename(f) } },
        'processed_count' => processed_count,
        'failed_count' => failed_files.size
      }
    end

    {
      'base_path' => base_p,
      'channel' => channel,
      'targets' => target_stats,
      'polled_at' => Time.now.utc.iso8601
    }
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

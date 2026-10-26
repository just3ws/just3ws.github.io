#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: intake_drive_video.rb
# domain: media
# role: Media Intake & YouTube Publishing Pipeline Orchestrator (Legacy Fallback)
# description: Autonomous media ingestion from Google Drive queues to YouTube Data API v3
# lifecycle: staged/ -> pending/ -> processing/ -> processed/ (or failed/)
# concurrency: serialized (1 file across all channels to safeguard Apple Silicon Neural Engine)
# order: strict oldest-first FIFO by filesystem ingress age
# controls: graceful halt (finish active task), immediate stop (abort and restore to pending)
# usage: bin/pipeline media intake [--watch] [-1] [--halt] [--stop] [--resume]
# migration: Migrated to Rails 8 microservice at https://media-pipeline.localhost (port 32000).
#   SolidQueue manages concurrency and worker execution under PostgreSQL 18.
# ---

require 'json'
require 'yaml'
require 'optparse'
require 'fileutils'
require 'time'
require 'open3'
require 'shellwords'
require_relative 'lib/youtube_client'
require_relative 'lib/job_substate_tracker'
require_relative 'lib/pipeline_classifier'

ROOT_DIR = File.expand_path('..', __dir__)
CONFIG_PATH = File.join(ROOT_DIR, '_data', 'media_intake_targets.yml')
EPISODES_DIR = File.join(ROOT_DIR, '_data', 'episodes')
STATE_DIR = File.expand_path('~/.local/state/just3ws')
HALT_SENTINEL = File.join(STATE_DIR, 'pipeline.halt')
STOP_SENTINEL = File.join(STATE_DIR, 'pipeline.stop')
PID_FILE = File.join(STATE_DIR, 'pipeline.pid')
ACTIVITY_LOG_PATH = File.join(STATE_DIR, 'pipeline_activity.jsonl')
TRANSCRIPTS_DATA_DIR = File.join(ROOT_DIR, '_data', 'transcripts')
VIDEO_ASSETS_PATH = File.join(ROOT_DIR, '_data', 'video_assets.yml')
MIN_FREE_DISK_BYTES = 5 * 1024 * 1024 * 1024 # 5 GB floor to preserve localhost OS stability

class MediaIntakePipeline
  attr_reader :config, :client, :options, :state_dir
  attr_accessor :halt_requested, :stop_requested

  def self.log_activity(stage, message, level: 'info', details: {})
    FileUtils.mkdir_p(STATE_DIR)
    entry = {
      'timestamp' => Time.now.utc.iso8601,
      'stage' => stage.to_s,
      'level' => level.to_s,
      'message' => message.to_s,
      'details' => details
    }
    File.open(ACTIVITY_LOG_PATH, 'a') do |f|
      f.puts(JSON.generate(entry))
    end
  rescue StandardError
    # Non-blocking logging
  end

  def log_activity(stage, message, level: 'info', details: {})
    self.class.log_activity(stage, message, level: level, details: details)
  end

  def self.halt!
    FileUtils.mkdir_p(STATE_DIR)
    File.write(HALT_SENTINEL, "Halted at #{Time.now.utc.iso8601}\n")
    FileUtils.rm_f(STOP_SENTINEL)
    log_activity('control', 'Pipeline graceful halt armed. Current task will finish then pause queue.', level: 'warning')
    puts "⏸️ Pipeline graceful halt armed. Current video will finish, then queue will halt."
  end

  def self.stop!
    FileUtils.mkdir_p(STATE_DIR)
    File.write(STOP_SENTINEL, "Stop requested at #{Time.now.utc.iso8601}\n")
    log_activity('control', 'Pipeline force stop triggered. Active worker signaled.', level: 'error')
    puts "🛑 Pipeline force stop armed. Current active task will abort immediately."

    # Kill active worker PID if recorded and alive
    if File.exist?(PID_FILE)
      pid = File.read(PID_FILE).strip.to_i
      if pid > 0
        begin
          Process.kill('TERM', pid)
          puts "   Sent SIGTERM to active intake worker PID #{pid}."
        rescue Errno::ESRCH
          # process already terminated
        rescue StandardError => e
          warn "   Could not signal PID #{pid}: #{e.message}"
        end
      end
      FileUtils.rm_f(PID_FILE)
    end

    # Scan and restore any stranded processing/ files back to pending/
    config = YAML.safe_load(File.read(CONFIG_PATH)) rescue {}
    base_p = config['base_path'] ? File.expand_path(config['base_path']) : nil
    if base_p && Dir.exist?(base_p)
      (config.dig('channels', 'whoistechcmty', 'targets') || {}).each do |tname, _|
        proc_dir = File.join(base_p, 'whoistechcmty', tname, 'processing')
        pend_dir = File.join(base_p, 'whoistechcmty', tname, 'pending')
        next unless Dir.exist?(proc_dir)

        Dir.glob(File.join(proc_dir, '*')).each do |f|
          next unless File.file?(f)
          dest = File.join(pend_dir, File.basename(f))
          FileUtils.mv(f, dest)
          puts "🔄 Restored #{File.basename(f)} back to pending/ in #{tname}."
        end
      end
    end
  end

  def self.resume!
    FileUtils.rm_f(HALT_SENTINEL)
    FileUtils.rm_f(STOP_SENTINEL)
    log_activity('control', 'Pipeline resumed. Queue processing unblocked.', level: 'success')
    puts "▶️ Pipeline resumed. Queue processing unblocked."
  end

  def self.halted?
    File.exist?(HALT_SENTINEL)
  end

  def self.stopped?
    File.exist?(STOP_SENTINEL)
  end

  # Apply OS-level scheduling politeness so background media processing never starves interactive desktop UI
  def self.apply_process_politeness!
    return if @politeness_applied

    # 1. Lower POSIX scheduling priority (nice level 15: range 0 to 19)
    begin
      Process.setpriority(Process::PRIO_PROCESS, 0, 15)
    rescue StandardError
      # Non-blocking if OS or user limits prevent priority adjustments
    end

    # 2. macOS Apple Silicon Quality of Service (QoS): Background Priority & Throttled I/O
    if RbConfig::CONFIG['host_os'] =~ /darwin/i && File.exist?('/usr/sbin/taskpolicy')
      system("/usr/sbin/taskpolicy -b -p #{Process.pid} >/dev/null 2>&1")
    end

    @politeness_applied = true
    log_activity('scheduler', "Applied background scheduling politeness (nice 15, macOS taskpolicy -b)", level: 'info', details: { 'pid' => Process.pid })
  end

  def initialize(options = {})
    @options = options
    @config = load_config
    @client = nil unless @options[:dry_run]
    @state_dir = options[:state_dir] || STATE_DIR
    @halt_requested = false
    @stop_requested = false
    @current_processing_path = nil
    @current_original_path = nil
    @current_scratch_files = []
    @current_subprocesses = []
    self.class.apply_process_politeness! unless @options[:status]
  end

  def load_config
    raise "Configuration not found at #{CONFIG_PATH}" unless File.exist?(CONFIG_PATH)
    YAML.safe_load(File.read(CONFIG_PATH))
  end

  def ensure_client!
    return if @options[:dry_run]
    return if @client

    @client = YouTubeClient.new
    @client.fetch_access_token!
  end

  def base_path
    @base_path ||= File.expand_path(config['base_path'] || '~/ai/media-pipeline')
  end

  def cloud_archive_path
    @cloud_archive_path ||= config['cloud_archive_path'] ? File.expand_path(config['cloud_archive_path']) : nil
  end

  def channel_config(channel = 'whoistechcmty')
    config.dig('channels', channel) || raise("Channel '#{channel}' not found in configuration")
  end

  def target_config(target_name, channel = 'whoistechcmty')
    targets = channel_config(channel)['targets'] || {}
    targets[target_name] || raise("Target '#{target_name}' not found for channel '#{channel}'")
  end

  # ponytail: determine file ingress age via birthtime (APFS creation time) falling back to mtime;
  # upgrade trigger: store external queue metadata if cloud sync overwrites creation stamps.
  def file_age_timestamp(path)
    begin
      File.birthtime(path)
    rescue StandardError
      File.mtime(path)
    end
  end

  # Available disk space on media intake volume in bytes
  # ponytail: procedural df -k parse: simple standard library call without external gems;
  # upgrade trigger: multi-platform Windows support required.
  def available_disk_space_bytes(path = base_path)
    target = path || Dir.pwd
    output = `df -k "#{target}" 2>/dev/null`.lines.to_a
    return nil if output.size < 2

    parts = output[1].split(/\s+/)
    parts[3].to_i * 1024
  rescue StandardError
    nil
  end

  # Check if YouTube Data API is currently within the daily quota cooldown window
  def quota_in_cooldown?
    now_utc = Time.now.utc
    now_pt = now_utc.getlocal('-07:00')
    last_reset_pt = Time.new(now_pt.year, now_pt.month, now_pt.day, 0, 0, 0, '-07:00')

    search_dirs = []
    channels = config['channels'] || {}
    channels.each do |ch_name, ch_conf|
      (ch_conf['targets'] || {}).each do |target_name, _|
        search_dirs << File.join(base_path, ch_name, target_name, 'blocked') if base_path
        search_dirs << File.join(cloud_archive_path, ch_name, target_name, 'blocked') if cloud_archive_path
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
  rescue StandardError
    false
  end

  # ponytail: serialize processing to 1 file at a time across all channels for localhost resources;
  # upgrade trigger: multi-worker concurrency if transcription/upload offloads to cloud cluster.
  def active_processing_files
    active = []
    channels = config['channels'] || {}
    channels.each do |ch_name, ch_conf|
      (ch_conf['targets'] || {}).each do |target_name, _target_info|
        proc_dir = File.join(base_path, ch_name, target_name, 'processing')
        next unless Dir.exist?(proc_dir)

        list_media_files(proc_dir).each do |f|
          active << {
            file_path: f,
            channel: ch_name,
            target_name: target_name,
            filename: File.basename(f),
            timestamp: file_age_timestamp(f)
          }
        end
      end
    end
    active
  end

  # Collect and sort all pending files across channels/targets in FIFO order (oldest first)
  def collect_pending_candidates(channel_filter = nil, target_filter = nil)
    candidates = []
    channels = config['channels'] || {}
    channels.each do |ch_name, ch_conf|
      next if channel_filter && ch_name != channel_filter

      (ch_conf['targets'] || {}).each do |target_name, target_info|
        next if target_filter && target_name != target_filter

        search_dirs = [
          base_path ? File.join(base_path, ch_name, target_name, 'pending') : nil,
          cloud_archive_path ? File.join(cloud_archive_path, ch_name, target_name, 'pending') : nil
        ].compact.select { |d| Dir.exist?(d) }

        seen = {}
        search_dirs.each do |pending_dir|
          list_media_files(pending_dir).each do |f|
            fn = File.basename(f)
            next if seen[fn]
            seen[fn] = true

            candidates << {
              file_path: f,
              channel: ch_name,
              target_name: target_name,
              target_info: target_info,
              filename: fn,
              timestamp: file_age_timestamp(f)
            }
          end
        end
      end
    end

    # Strict FIFO: Sort ascending by birthtime/mtime (oldest first), then filename
    candidates.sort_by { |c| [c[:timestamp], c[:file_path]] }
  end

  # Display Queue Status across all configured targets and active concurrency lock
  def print_status(channel = nil)
    ch_list = channel ? [channel] : (config['channels'] || {}).keys
    ch_list.each do |ch_name|
      ch_conf = channel_config(ch_name)
      puts "\n" + ("=" * 72)
      puts "  MEDIA INTAKE QUEUE STATUS: #{ch_name} (#{ch_conf['channel_handle']})"
      puts "  Base Path: #{base_path}"
      puts ("=" * 72)

      ch_conf['targets'].each do |target_name, target_info|
        search_dirs = [
          base_path ? File.join(base_path, ch_name, target_name) : nil,
          cloud_archive_path ? File.join(cloud_archive_path, ch_name, target_name) : nil
        ].compact.select { |d| Dir.exist?(d) }

        staged_files = search_dirs.flat_map { |td| list_media_files(File.join(td, 'staged')) }.uniq { |f| File.basename(f) }
        pending_files = search_dirs.flat_map { |td| list_media_files(File.join(td, 'pending')) }.uniq { |f| File.basename(f) }
        processing_files = search_dirs.flat_map { |td| list_media_files(File.join(td, 'processing')) }.uniq { |f| File.basename(f) }
        processed_count = search_dirs.sum { |td| count_files_recursive(File.join(td, 'processed')) }
        failed_count = search_dirs.sum { |td| list_media_files(File.join(td, 'failed')).size }

        puts "\n📁 Target: #{target_name}"
        puts "   Series:    #{target_info['series_name']}"
        puts "   Playlist:  #{target_info['playlist_id']}"
        puts "   Privacy:   #{target_info['default_privacy']}"
        puts "   [staged]     #{staged_files.size} file(s) (pre-queue hold)"
        staged_files.each { |f| puts "     -> #{File.basename(f)} (#{format_size(File.size(f))})" } if staged_files.any?
        puts "   [pending]    #{pending_files.size} file(s)"
        pending_files.each { |f| puts "     -> #{File.basename(f)} (#{format_size(File.size(f))})" } if pending_files.any?
        puts "   [processing] #{processing_files.size} file(s)"
        processing_files.each { |f| puts "     -> #{File.basename(f)}" } if processing_files.any?
        puts "   [processed]  #{processed_count} completed asset(s)"
        puts "   [failed]     #{failed_count} item(s)"
      end
    end

    # Concurrency Lock status report
    active = active_processing_files
    if active.any?
      puts "\n🔒 Concurrency Lock: 1 active video in processing/ (#{active.first[:filename]} on #{active.first[:channel]}/#{active.first[:target_name]})"
    else
      puts "\n🔓 Concurrency Lock: idle (0 videos processing, ready for next FIFO file)"
    end

    if self.class.halted?
      puts "⏸️ Lifecycle State: HALTED (queue paused after active video)"
    elsif self.class.stopped?
      puts "🛑 Lifecycle State: STOPPED (tasks aborted)"
    else
      puts "▶️ Lifecycle State: ACTIVE (ready for automated intake)"
    end
    puts "\n" + ("=" * 72) + "\n"
  end

  # Detect and heal any orphaned locks or stranded processing files from crashed runs
  def self_heal_orphaned_state!
    # 1. Prune dead PID file if worker is no longer running
    if File.exist?(PID_FILE)
      pid_val = File.read(PID_FILE).strip.to_i
      if pid_val > 0 && pid_val != Process.pid
        is_alive = begin
          Process.kill(0, pid_val)
          true
        rescue Errno::ESRCH, Errno::EPERM
          false
        end

        unless is_alive
          FileUtils.rm_f(PID_FILE)
          self.class.log_activity('self_healing', "Detected dead worker PID #{pid_val}. Cleared stale PID lock.", level: 'warning')
          puts "🔄 [Self-Healing] Cleared stale worker PID #{pid_val}."
        end
      end
    end

    # 2. Check stranded files in processing/ if no other worker is alive
    other_worker_alive = begin
      if File.exist?(PID_FILE)
        p = File.read(PID_FILE).strip.to_i
        p > 0 && p != Process.pid && (Process.kill(0, p) || true rescue false)
      else
        false
      end
    end

    unless other_worker_alive
      active = active_processing_files
      if active.any?
        active.each do |stuck|
          pend_dir = File.join(base_path, stuck[:channel], stuck[:target_name], 'pending')
          FileUtils.mkdir_p(pend_dir)
          dest = File.join(pend_dir, stuck[:filename])
          FileUtils.mv(stuck[:file_path], dest)
          self.class.log_activity('self_healing', "Restored stranded file #{stuck[:filename]} from processing/ to pending/", level: 'warning', details: stuck)
          puts "🔄 [Self-Healing] Restored stranded file #{stuck[:filename]} back to pending/ in #{stuck[:target_name]}."
        end
      end
    end
  end

  # Scan and process queued items with cross-channel 1-at-a-time serialization and FIFO ordering
  def run(channel = nil, target_filter = nil)
    FileUtils.mkdir_p(@state_dir)
    self_heal_orphaned_state!

    # Concurrency Guard: Check if another worker process is already alive
    if File.exist?(PID_FILE)
      existing_pid = File.read(PID_FILE).strip.to_i
      if existing_pid > 0 && existing_pid != Process.pid
        is_alive = begin
          Process.kill(0, existing_pid)
          true
        rescue StandardError
          false
        end
        if is_alive
          puts "⏳ Another worker (PID #{existing_pid}) is currently active. Aborting."
          return 0
        end
      end
    end

    File.write(PID_FILE, Process.pid.to_s) unless options[:dry_run]

    begin
      # 1. Global Concurrency Guard: Ensure zero active processing files across ALL channels
      active = active_processing_files
      if active.any?
        active_file = active.first
        puts "⏳ Active processing in progress: #{active_file[:filename]} (#{active_file[:channel]}/#{active_file[:target_name]})."
        puts "   Processing is serialized to 1 video at a time across all channels to preserve localhost resources."
        return 0
      end

      # Check if halted before starting
      if self.class.halted? || @halt_requested
        puts "⏸️ Pipeline is halted. Queue processing paused."
        return 0
      end

      # Quota Cooldown Guard: Do not pull new candidates if YouTube API is in cooldown
      if quota_in_cooldown? && !options[:dry_run] && !options[:skip_upload]
        puts "⏳ Upstream YouTube API quota cooldown is active until 2:00 AM CT (00:00 PT). Intake queue paused to prevent local disk starvation."
        return 0
      end

      # Disk Space Pre-flight Guard: Verify local volume has safe operational headroom
      free_disk = available_disk_space_bytes
      if free_disk && free_disk < MIN_FREE_DISK_BYTES && !options[:dry_run]
        warn "⚠️ Insufficient disk space (#{format_size(free_disk)} free, minimum #{format_size(MIN_FREE_DISK_BYTES)} required). Intake queue paused to protect operating system stability."
        log_activity('disk_guard', "Intake paused: #{format_size(free_disk)} free below 5.0GB floor", level: 'warning')
        return 0
      end

      total_processed = 0
      processed_in_run = Set.new

      loop do
        if self.class.halted? || @halt_requested
          puts "⏸️ Graceful halt armed: Queue paused before processing next video."
          break
        end

        if self.class.stopped? || @stop_requested
          puts "🛑 Force stop detected: Aborting queue processing."
          break
        end

        # 2. Rescan pending candidates across all channels on each step (FIFO oldest first)
        candidates = collect_pending_candidates(channel, target_filter).reject { |c| processed_in_run.include?(c[:file_path]) }
        break if candidates.empty?

        # 3. Double-check concurrency guard before starting next file
        current_active = active_processing_files
        if current_active.any?
          puts "⏳ Another video is currently processing (#{current_active.first[:filename]}). Pausing queue."
          break
        end

        # 4. Pick single oldest candidate (FIFO)
        next_item = candidates.first
        file_path = next_item[:file_path]
        processed_in_run << file_path
        target_name = next_item[:target_name]
        target_info = next_item[:target_info]
        ch_name = next_item[:channel]
        age_desc = next_item[:timestamp].strftime('%Y-%m-%d %H:%M:%S')

        puts "\n🎬 [Intake Queue] #{candidates.size} item(s) pending across channels."
        puts "   Selected oldest (FIFO): #{next_item[:filename]} (added: #{age_desc}) -> #{ch_name}/#{target_name}"

        success = process_file(file_path, target_name, target_info, ch_name)
        total_processed += 1 if success

        # If user requested single file execution or dry-run, exit after one
        break if options[:one] || options[:single] || options[:dry_run]
      end

      if total_processed.zero? && candidates_empty?(channel, target_filter)
        puts "✓ Intake queue is clear. No pending media files found."
      else
        puts "\n✅ Intake run finished. #{total_processed} file(s) processed sequentially (FIFO, 1 at a time)."
      end

      total_processed
    ensure
      unless options[:dry_run]
        FileUtils.rm_f(PID_FILE) if File.exist?(PID_FILE) && File.read(PID_FILE).strip.to_i == Process.pid
      end
    end
  end

  def candidates_empty?(channel, target_filter)
    collect_pending_candidates(channel, target_filter).empty?
  end

  # Abort active processing task immediately, clean scratch, and revert file
  def abort_active_task!
    @stop_requested = true
    puts "\n🛑 [Abort] Terminating active processing task..."

    # Kill any active subprocesses
    @current_subprocesses.each do |pid|
      begin
        Process.kill('TERM', pid)
      rescue StandardError
        nil
      end
    end
    @current_subprocesses.clear

    # Clean transient scratch files
    @current_scratch_files.each do |f|
      FileUtils.rm_f(f) if File.exist?(f)
    end
    @current_scratch_files.clear

    # Restore processing file back to pending
    if @current_processing_path && File.exist?(@current_processing_path) && @current_original_path
      pending_dir = File.dirname(@current_original_path)
      filename = File.basename(@current_processing_path)
      restored_dest = File.join(pending_dir, filename)
      FileUtils.mv(@current_processing_path, restored_dest)
      puts "🔄 Restored #{filename} back to #{File.basename(pending_dir)}/ for safe retry."
    end

    @current_processing_path = nil
    @current_original_path = nil
    puts "✅ Abort complete. Concurrency Lock released."
  end

  # Single File Ingestion & State Machine
  def process_file(file_path, target_name, target_info, channel = 'whoistechcmty')
    filename = File.basename(file_path)
    tracker = JobSubstateTracker.load(filename, file_path, @state_dir)
    target_dir = File.join(base_path, channel, target_name)
    staged_dir = File.join(target_dir, 'staged')
    pending_dir = File.join(target_dir, 'pending')
    processing_dir = File.join(target_dir, 'processing')
    processed_dir = File.join(target_dir, 'processed')
    failed_dir = File.join(target_dir, 'failed')
    blocked_dir = File.join(target_dir, 'blocked')

    FileUtils.mkdir_p(staged_dir)
    FileUtils.mkdir_p(pending_dir)
    FileUtils.mkdir_p(processing_dir)
    FileUtils.mkdir_p(processed_dir)
    FileUtils.mkdir_p(failed_dir)
    FileUtils.mkdir_p(blocked_dir)

    puts "\n" + ("-" * 60)
    puts "▶ Processing: #{filename} -> #{target_name}"
    puts ("-" * 60)

    # 1. Verification of file stability (avoid partial uploads from phone)
    unless stable_file?(file_path)
      puts "⏳ File size is currently changing or zero bytes. Waiting for phone sync to complete."
      return false
    end

    # Ingress Idempotency Gate: Check if this file was already processed and archived
    existing_receipt = find_archived_receipt(filename, processed_dir)
    if existing_receipt && existing_receipt['video_id']
      vid = existing_receipt['video_id']
      puts "⏭️ [Idempotency] #{filename} was already archived (#{existing_receipt['archived_at']}) with YouTube ID #{vid}."
      puts "   Skipping re-processing to prevent duplicate uploads."
      log_activity('idempotency', "Skipped #{filename}: already archived as #{vid}", level: 'info', details: { 'filename' => filename, 'video_id' => vid })
      unless options[:dry_run]
        # Prune redundant pending file and companion state/error files
        FileUtils.rm_f(file_path)
        sidecar = find_sidecar(file_path)
        FileUtils.rm_f(sidecar) if sidecar
        FileUtils.rm_f("#{file_path}.state.json")
        FileUtils.rm_f("#{file_path}.error.log")
      end
      return true
    end

    if self.class.stopped? || @stop_requested
      puts "🛑 Stop detected before locking #{filename}."
      return false
    end

    # Ensure no other video is currently in processing across any channel/target
    active = active_processing_files
    active_other = active.reject { |a| a[:file_path] == file_path }
    if active_other.any?
      puts "⚠️ Cannot process #{filename}: another video is currently active in processing/ (#{active_other.first[:filename]})."
      puts "   Aborting intake for this file to maintain single-video serialization."
      return false
    end

    # Pre-flight Guard: Verify local SSD has safe operating headroom before moving file
    free_disk = available_disk_space_bytes
    if free_disk && free_disk < MIN_FREE_DISK_BYTES && !options[:dry_run]
      warn "⚠️ Cannot process #{filename}: available disk space is #{format_size(free_disk)}, below 5.0GB safety floor."
      log_activity('disk_guard', "Skipped #{filename}: #{format_size(free_disk)} free below 5.0GB floor", level: 'warning')
      return false
    end

    # Check for companion sidecar notes (.txt or .yml)
    sidecar_path = find_sidecar(file_path)
    sidecar_data = parse_sidecar(sidecar_path)

    # 2. Lock: Move to processing/
    processing_path = File.join(processing_dir, filename)
    if options[:dry_run]
      puts "🔍 [Dry Run] Would move #{filename} to processing/"
      processing_path = file_path
    else
      FileUtils.mv(file_path, processing_path)
      tracker.relocate_file_path!(processing_path)
      tracker.meta_phase = 'processing'
      puts "🔒 Locked: #{filename} moved to processing/"
      log_activity('lock', "Acquired concurrency lock for #{filename} (Target: #{target_name})", level: 'info', details: { 'filename' => filename, 'target' => target_name })
    end

    scratch_wav = tracker.scratch_wav_path
    scratch_prefix = tracker.scratch_prefix
    @current_processing_path = processing_path
    @current_original_path = file_path
    @current_scratch_files = [scratch_wav, "#{scratch_prefix}.txt", "#{scratch_prefix}.vtt"]

    t_start = Time.now
    duration_dsp = 0.0
    duration_whisper = 0.0
    duration_meta = 0.0
    duration_upload = 0.0
    duration_captions = 0.0

    begin
      if self.class.stopped? || @stop_requested
        puts "🛑 Stop detected before audio extraction. Aborting #{filename}..."
        abort_active_task!
        return false
      end

      # 3. Audio Extraction via ffmpeg stream
      if options[:dry_run]
        puts "🔍 [Dry Run] Simulating audio extraction and transcription for #{filename}"
        duration_dsp = 0.05
        duration_whisper = 0.05
        transcript_data = { text: "Simulated speech transcript for #{filename}", vtt: "" }
      elsif tracker.can_skip_audio_dsp?
        duration_dsp = tracker.step_data(:audio_dsp)['duration_seconds'] || 0.0
        puts "⏭️ [Substate: audio_dsp] Step already completed (#{duration_dsp}s). Reusing scratch audio: #{File.basename(scratch_wav)}"
      else
        tracker.start_step(:audio_dsp)
        puts "🎙 Extracting audio track to transient scratch WAV..."
        t_dsp_start = Time.now
        extract_audio(processing_path, scratch_wav)
        duration_dsp = (Time.now.-(t_dsp_start)).round(2)
        tracker.complete_step(:audio_dsp, 'wav_path' => scratch_wav, 'duration_seconds' => duration_dsp)
        log_activity('dsp', "Extracted 16kHz audio from #{filename} in #{duration_dsp}s", level: 'info', details: { 'filename' => filename, 'duration_seconds' => duration_dsp })
      end

      if self.class.stopped? || @stop_requested
        puts "🛑 Stop detected after audio extraction. Aborting #{filename}..."
        abort_active_task!
        return false
      end

      # 4. Local Transcription via zdots ztranscribe
      transcript_data ||= { text: "", vtt: "" }
      if !options[:dry_run] && (target_info['auto_title_from_speech'] || target_info['transcribe_with_whisper'])
        if tracker.can_skip_transcription?
          stt_info = tracker.step_data(:transcription)
          transcript_data[:text] = stt_info['text'] || (File.read("#{scratch_prefix}.txt") rescue "")
          transcript_data[:vtt] = stt_info['vtt'] || (File.read("#{scratch_prefix}.vtt") rescue "")
          duration_whisper = stt_info['duration_seconds'] || 0.0
          puts "⏭️ [Substate: transcription] Step already completed (#{duration_whisper}s). Reusing cached transcript."
        else
          tracker.start_step(:transcription)
          puts "🧠 Running local ztranscribe speech recognition from zdots on Apple Silicon..."
          t_whisper_start = Time.now
          transcript_data = transcribe_audio(scratch_wav, scratch_prefix, target_info['transcribe_prompt'])
          duration_whisper = (Time.now.-(t_whisper_start)).round(2)
          tracker.complete_step(:transcription, 'text' => transcript_data[:text], 'vtt' => transcript_data[:vtt], 'duration_seconds' => duration_whisper)
          log_activity('whisper', "ztranscribe STT completed for #{filename} in #{duration_whisper}s", level: 'info', details: { 'filename' => filename, 'duration_seconds' => duration_whisper })
        end
      end

      if self.class.stopped? || @stop_requested
        puts "🛑 Stop detected after transcription. Aborting #{filename}..."
        abort_active_task!
        return false
      end

      # 5. Metadata Synthesis & Dossier Resolution
      tracker.start_step(:metadata_synthesis)
      t_meta_start = Time.now
      metadata = synthesize_metadata(processing_path, target_name, target_info, transcript_data, sidecar_data)
      duration_meta = (Time.now.-(t_meta_start)).round(2)
      tracker.complete_step(:metadata_synthesis, 'title' => metadata[:title], 'privacy' => metadata[:privacy], 'tags' => metadata[:tags], 'duration_seconds' => duration_meta)
      log_activity('metadata', "Synthesized title: \"#{metadata[:title]}\" (#{duration_meta}s)", level: 'info', details: { 'filename' => filename, 'title' => metadata[:title], 'duration_seconds' => duration_meta })
      puts "\n📋 Synthesized Metadata:"
      puts "   Title:    #{metadata[:title]}"
      puts "   Privacy:  #{metadata[:privacy]}"
      puts "   Playlist: #{target_info['playlist_id']}"
      puts "   Tags:     #{metadata[:tags].take(5).join(', ')}... (#{metadata[:tags].size} total)"
      puts "   Snippet:  #{metadata[:description].lines.first(2).map(&:strip).join(' ')}"

      # 6. Resumable Upload to YouTube
      video_id = nil
      if options[:dry_run]
        puts "🔍 [Dry Run] Would stream #{format_size(File.size(processing_path))} to YouTube Data API v3"
        video_id = "DRY_RUN_#{Time.now.to_i}"
      else
        ensure_client!
        if tracker.can_skip_youtube_upload?(client)
          video_id = tracker.step_data(:youtube_upload)['video_id'] || tracker.data['video_id']
          duration_upload = tracker.step_data(:youtube_upload)['duration_seconds'] || 0.0
          puts "⏭️ [Substate: youtube_upload] Video #{video_id} already uploaded and verified on YouTube. Skipping upload."
        else
          # Cross-reference with _data/video_assets.yml and receipts before attempting live upload
          slug_candidate = generate_slug(target_name, metadata[:title])
          existing_asset = find_registered_asset(metadata[:title], slug_candidate, filename)
          existing_yt_id = existing_asset && (existing_asset["platforms"] || []).find { |p| p["platform"] == "youtube" && p["asset_id"] }&.dig("asset_id")

          if existing_yt_id.nil? || existing_yt_id.to_s.strip.empty?
            receipt = find_archived_receipt(filename)
            existing_yt_id = receipt['video_id'] if receipt && receipt['video_id']
          end

          if existing_yt_id && !existing_yt_id.to_s.strip.empty?
            video_id = existing_yt_id
            puts "⏭️ [Idempotency] Video already registered/archived as #{video_id}. Reusing to prevent duplicate upload."
            tracker.complete_step(:youtube_upload, 'video_id' => video_id, 'youtube_url' => "https://youtu.be/#{video_id}", 'progress_percent' => 100.0)
            log_activity('idempotency', "Reused existing YouTube ID #{video_id} for #{filename}", level: 'info', details: { 'filename' => filename, 'video_id' => video_id })
          else
            tracker.start_step(:youtube_upload)
            puts "🚀 Streaming #{format_size(File.size(processing_path))} to YouTube Data API v3..."
            payload = {
              "snippet" => {
                "title" => metadata[:title],
                "description" => metadata[:description],
                "tags" => metadata[:tags],
                "categoryId" => target_info['category_id'] || "28",
                "defaultLanguage" => "en"
              },
              "status" => {
                "privacyStatus" => metadata[:privacy],
                "selfDeclaredMadeForKids" => false,
                "embeddable" => true
              }
            }
            upload_res = nil
            t_upload_start = Time.now
            total_file_bytes = File.size(processing_path)
            tracker.update_step(:youtube_upload, 'progress_percent' => 0.0, 'bytes_uploaded' => 0, 'total_bytes' => total_file_bytes)
            3.times do |attempt|
              begin
                upload_res = client.upload_video(processing_path, payload) do |bytes_up, total_b, pct|
                  tracker.update_step(:youtube_upload, 'progress_percent' => pct, 'bytes_uploaded' => bytes_up, 'total_bytes' => total_b)
                  print "\r   🚀 Uploading: #{pct}% (#{format_size(bytes_up)} / #{format_size(total_b)})"
                  $stdout.flush
                end
                puts ""
                break
              rescue StandardError => err
                puts ""
                if attempt < 2
                  backoff = 2 * (attempt + 1)
                  warn "⚠️ [Self-Healing] Upload attempt #{attempt + 1} hit error: #{err.message}. Retrying in #{backoff}s..."
                  log_activity('self_healing', "Upload attempt #{attempt + 1} retrying after error: #{err.message}", level: 'warning')
                  sleep backoff
                else
                  raise err
                end
              end
            end
            duration_upload = (Time.now.-(t_upload_start)).round(2)
            video_id = upload_res["id"]
            tracker.complete_step(:youtube_upload, 'video_id' => video_id, 'youtube_url' => "https://youtu.be/#{video_id}", 'duration_seconds' => duration_upload, 'progress_percent' => 100.0)
            puts "✅ Video uploaded successfully in #{duration_upload}s! Video ID: #{video_id}"
            puts "   Link: https://youtu.be/#{video_id}"
            log_activity('youtube', "Uploaded #{filename} to YouTube as #{video_id} in #{duration_upload}s", level: 'info', details: { 'filename' => filename, 'video_id' => video_id, 'url' => "https://youtu.be/#{video_id}", 'duration_seconds' => duration_upload })
          end
        end

        # Metadata Sync Gate: Only call update_video if snippet changed since upload
        if video_id && !options[:dry_run]
          recorded_title = tracker.step_data(:metadata_synthesis)['title']
          if recorded_title && recorded_title != metadata[:title]
            begin
              client.update_video(video_id, {
                "snippet" => {
                  "title" => metadata[:title],
                  "description" => metadata[:description],
                  "tags" => metadata[:tags],
                  "categoryId" => target_info['category_id'] || "28",
                  "defaultLanguage" => "en"
                },
                "status" => {
                  "privacyStatus" => metadata[:privacy],
                  "selfDeclaredMadeForKids" => false,
                  "embeddable" => true
                }
              })
              puts "📝 [Metadata Sync] Verified and synchronized revised snippet for #{video_id} on YouTube."
            rescue StandardError => sync_err
              warn "⚠️ [Metadata Sync] Notice: Could not sync snippet for #{video_id}: #{sync_err.message}"
            end
          end
        end

        # 7. Add to Playlist
        if target_info['playlist_id']
          if tracker.step_completed?(:playlist_assignment)
            puts "⏭️ [Substate: playlist_assignment] Video #{video_id} already in playlist #{target_info['playlist_id']}."
          else
            tracker.start_step(:playlist_assignment)
            puts "📋 Adding video #{video_id} to playlist #{target_info['playlist_id']}..."

            # Check if video is already in playlist to prevent duplicate items
            already_in_pl = false
            begin
              existing_pl_vids = client.get_playlist_video_ids(target_info['playlist_id'])
              already_in_pl = existing_pl_vids.include?(video_id)
            rescue StandardError
              # Fallback to zero-quota yt-dlp check when API read check hits quota/network error
              begin
                ytdlp_cmd = ['yt-dlp', '--flat-playlist', '--print', 'id', "https://www.youtube.com/playlist?list=#{target_info['playlist_id']}"]
                out, status = Open3.capture2(*ytdlp_cmd)
                already_in_pl = out.lines.map(&:strip).include?(video_id) if status.success?
              rescue StandardError
                # Ignore fallback errors
              end
            end

            if already_in_pl
              puts "   ⏭️ [Idempotency] Video #{video_id} is already in playlist #{target_info['playlist_id']}. Skipping addition."
              tracker.complete_step(:playlist_assignment, 'playlist_id' => target_info['playlist_id'])
            else
              playlist_added = false
              3.times do |attempt|
                begin
                  client.add_playlist_item(target_info['playlist_id'], video_id)
                  puts "   ✅ Video #{video_id} added to playlist #{target_info['playlist_id']}."
                  log_activity('playlist', "Added #{video_id} to playlist #{target_info['playlist_id']}", level: 'info', details: { 'video_id' => video_id, 'playlist_id' => target_info['playlist_id'] })
                  playlist_added = true
                  break
                rescue StandardError => pl_err
                  if attempt < 2 && !(pl_err.message.include?('403') || pl_err.message.include?('quotaExceeded'))
                    sleep (2 ** attempt)
                  else
                    puts "   ⚠️ Could not add to playlist #{target_info['playlist_id']}: #{pl_err.message}"
                    log_activity('warning', "Failed adding #{video_id} to playlist #{target_info['playlist_id']}: #{pl_err.message}", level: 'warning', details: { 'video_id' => video_id, 'playlist_id' => target_info['playlist_id'], 'error' => pl_err.message })
                    raise pl_err
                  end
                end
              end
              if playlist_added
                tracker.complete_step(:playlist_assignment, 'playlist_id' => target_info['playlist_id'])
              end
            end
          end
        end

        # 8. Attach Captions Track (WebVTT)
        # Note: captions.insert costs 400 API quota units (25% of a video upload).
        # Because the full Whisper transcript is embedded in the video description,
        # saved to the local datalake, and auto-captioned by YouTube for 0 units,
        # quota exhaustion on captions_upload defers the 400-unit WebVTT track
        # and immediately completes datalake_sync and archival.
        if transcript_data[:vtt] && !transcript_data[:vtt].strip.empty?
          if tracker.step_completed?(:captions_upload)
            puts "⏭️ [Substate: captions_upload] Captions track already uploaded for #{video_id}."
          else
            tracker.start_step(:captions_upload)
            puts "📝 Uploading verified WebVTT caption track to YouTube..."
            t_cap_start = Time.now
            3.times do |attempt|
              begin
                client.upload_caption(video_id, transcript_data[:vtt])
                duration_captions = (Time.now.-(t_cap_start)).round(2)
                tracker.complete_step(:captions_upload, 'duration_seconds' => duration_captions)
                log_activity('captions', "Uploaded WebVTT captions track to video #{video_id} in #{duration_captions}s", level: 'info', details: { 'filename' => filename, 'video_id' => video_id, 'duration_seconds' => duration_captions })
                break
              rescue StandardError => cap_err
                if attempt < 2 && !(cap_err.message.include?('403') || cap_err.message.include?('quotaExceeded'))
                  sleep 2
                elsif cap_err.message.include?('403') || cap_err.message.include?('quotaExceeded')
                  warn "⚡ [Quota Conservation] Deferring 400-unit WebVTT caption upload for #{video_id} (YouTube auto-captions + description transcript active). Proceeding to datalake sync & archival."
                  tracker.complete_step(:captions_upload, 'duration_seconds' => 0.0, 'note' => 'deferred_quota_conservation')
                  log_activity('captions', "Deferred 400-unit WebVTT caption upload for #{video_id} to conserve quota; proceeding to datalake sync & archival", level: 'info', details: { 'filename' => filename, 'video_id' => video_id, 'deferred' => true })
                  break
                else
                  warn "⚠️ [Captions Warning] Could not upload captions track: #{cap_err.message}"
                  log_activity('warning', "Failed uploading captions for #{video_id}: #{cap_err.message}", level: 'warning', details: { 'video_id' => video_id, 'error' => cap_err.message })
                  raise cap_err
                end
              end
            end
          end
        end

        # 9. Optional PostgreSQL Sync (media_sources)
        record_in_postgres(video_id, metadata, target_name)

        # 10. Persist Transcript & Register in Local Knowledge System
        if tracker.step_completed?(:datalake_sync)
          puts "⏭️ [Substate: datalake_sync] Already synced to local knowledge system."
        else
          tracker.start_step(:datalake_sync)
          if transcript_data[:text] && !transcript_data[:text].strip.empty?
            metadata[:video_id] = video_id
            save_transcript_dossier(target_name, filename, metadata, transcript_data)
            update_local_knowledge_system!
            tracker.complete_step(:datalake_sync, 'transcript_saved' => true)
          else
            tracker.complete_step(:datalake_sync, 'transcript_saved' => false, 'note' => 'no_speech')
          end
        end
      end

      # 11. Archival & Eviction to processed/
      tracker.start_step(:archival)
      month_dir = File.join(processed_dir, Time.now.strftime('%Y-%m'))
      FileUtils.mkdir_p(month_dir) unless options[:dry_run]
      final_dest = File.join(month_dir, filename)

      if options[:dry_run]
        puts "🔍 [Dry Run] Would move to processed/#{Time.now.strftime('%Y-%m')}/#{filename}"
      else
        FileUtils.mv(processing_path, final_dest)
        FileUtils.mv(sidecar_path, File.join(month_dir, File.basename(sidecar_path))) if sidecar_path && File.exist?(sidecar_path)

        # Prune any previous failed or blocked artifacts from prior transient attempts
        FileUtils.rm_f(File.join(failed_dir, filename))
        FileUtils.rm_f(File.join(failed_dir, "#{filename}.error.log"))
        FileUtils.rm_f(File.join(failed_dir, "#{filename}.state.json"))
        FileUtils.rm_f(File.join(blocked_dir, filename))
        FileUtils.rm_f(File.join(blocked_dir, "#{filename}.blocked.json"))
        FileUtils.rm_f(File.join(blocked_dir, "#{filename}.state.json"))

        t_end = Time.now
        duration_total = (t_end.-(t_start)).round(2)
        final_size_bytes = (File.size(final_dest) rescue 0)
        upload_mb_s = (duration_upload > 0 && final_size_bytes > 0) ? ((final_size_bytes.to_f / 1024 / 1024) / duration_upload).round(2) : 0.0

        perf_metrics = {
          'duration_total_seconds' => duration_total,
          'duration_audio_extract_seconds' => duration_dsp,
          'duration_transcription_seconds' => duration_whisper,
          'duration_metadata_seconds' => duration_meta,
          'duration_upload_seconds' => duration_upload,
          'duration_captions_seconds' => duration_captions,
          'upload_throughput_mb_s' => upload_mb_s
        }

        receipt_path = "#{final_dest}.receipt.json"
        receipt_data = {
          'filename' => filename,
          'video_id' => video_id,
          'youtube_url' => "https://youtu.be/#{video_id}",
          'title' => (metadata && metadata[:title]) || filename,
          'playlist_id' => target_info['playlist_id'],
          'series_name' => target_info['series_name'],
          'privacy' => target_info['default_privacy'],
          'archived_at' => Time.now.utc.iso8601,
          'size_bytes' => final_size_bytes,
          'performance_metrics' => perf_metrics
        }
        File.write(receipt_path, JSON.pretty_generate(receipt_data))
        tracker.complete_step(:archival, 'final_dest' => final_dest, 'receipt_path' => receipt_path)
        tracker.cleanup_on_success!
        puts "📦 Archived: Moved to processed/#{Time.now.strftime('%Y-%m')}/#{filename}"
        puts "📄 Ingress Receipt written: #{File.basename(receipt_path)}"
        puts "⏱️ Execution Telemetry: Total #{duration_total}s (DSP: #{duration_dsp}s, Whisper: #{duration_whisper}s, Upload: #{duration_upload}s at #{upload_mb_s} MB/s)"

        # Asynchronous cold backup mirror to Google Drive if configured
        if cloud_archive_path && Dir.exist?(cloud_archive_path)
          begin
            cloud_month_dir = File.join(cloud_archive_path, channel, target_name, 'processed', Time.now.strftime('%Y-%m'))
            FileUtils.mkdir_p(cloud_month_dir)
            cloud_master_dest = File.join(cloud_month_dir, filename)
            FileUtils.cp(final_dest, cloud_master_dest)
            FileUtils.cp(receipt_path, File.join(cloud_month_dir, File.basename(receipt_path))) if File.exist?(receipt_path)
            puts "☁️ Mirrored master to cloud archive: #{cloud_month_dir}"
            log_activity('archival', "Mirrored master to cloud archive: #{cloud_month_dir}", level: 'info', details: { 'cloud_dest' => cloud_month_dir })

            # Release local master from NVMe SSD now that cloud archive is verified bit-for-bit
            if File.exist?(cloud_master_dest) && File.size(cloud_master_dest) == File.size(final_dest)
              FileUtils.rm_f(final_dest)
              puts "🧹 Released local NVMe SSD master: #{filename} (safely retained in Google Drive cold storage)."
            end
          rescue StandardError => cloud_err
            warn "⚠️ Cloud archive mirror notice: #{cloud_err.message}"
            log_activity('archival', "Cloud archive mirror skipped: #{cloud_err.message}", level: 'warning')
          end
        end

        begin
          hist_file = File.join(@state_dir, 'pipeline_execution_history.jsonl')
          File.open(hist_file, 'a') do |hf|
            hf.puts(JSON.dump({
              'timestamp' => Time.now.utc.iso8601,
              'filename' => filename,
              'video_id' => video_id,
              'target' => target_name,
              'size_bytes' => final_size_bytes,
              'performance_metrics' => perf_metrics
            }))
          end
        rescue StandardError => hist_err
          warn "⚠️ Could not record execution history: #{hist_err.message}"
        end

        log_activity('archive', "Successfully deployed #{filename} to YouTube (#{video_id}) and archived master in #{duration_total}s", level: 'success', details: { 'filename' => filename, 'video_id' => video_id, 'playlist' => target_info['playlist_id'], 'url' => "https://youtu.be/#{video_id}", 'performance_metrics' => perf_metrics })
      end

      true
    rescue StandardError => e
      triage = begin
                 PipelineClassifier.new.classify_error_triage(e.message, backtrace: e.backtrace)
               rescue StandardError => triage_err
                 warn "⚠️ Could not run classifier error triage: #{triage_err.message}"
                 { decision: 'quarantine_operator_review', confidence: 0.5 }
               end

      if triage[:decision] == 'upstream_quota_blocked'
        warn "⏳ [Blocked] Upstream rate limit or quota exceeded for #{filename}: #{e.message}. Cooldown active until 2:00 AM CT (00:00 PT)."
        log_activity('blocked', "Pipeline temporarily blocked on #{filename} due to upstream quota/rate limit: #{e.message}. Resumes upon 2:00 AM CT cooldown reset.", level: 'warning', details: triage)
        tracker.block_step(tracker.current_step || 'unknown', e.message, 'resets_at' => '2:00 AM CT (00:00 PT)', 'decision' => 'upstream_quota_blocked')

        unless options[:dry_run]
          cloud_target_dir = cloud_archive_path ? File.join(cloud_archive_path, channel, target_name) : nil
          cloud_blocked_dir = cloud_target_dir ? File.join(cloud_target_dir, 'blocked') : nil
          relocated_cloud_dest = nil

          if cloud_blocked_dir && Dir.exist?(File.dirname(cloud_blocked_dir))
            FileUtils.mkdir_p(cloud_blocked_dir)
            relocated_cloud_dest = File.join(cloud_blocked_dir, filename)
            FileUtils.mv(processing_path, relocated_cloud_dest) if File.exist?(processing_path)
            tracker.relocate_file_path!(relocated_cloud_dest)
            puts "☁️ Relocated video master to cloud archive: #{relocated_cloud_dest} (conserving local SSD space)."
          else
            blocked_dest = File.join(blocked_dir, filename)
            FileUtils.mv(processing_path, blocked_dest) if File.exist?(processing_path)
            tracker.relocate_file_path!(blocked_dest)
            puts "⏳ Moved to blocked/#{filename} (Waiting for 2:00 AM CT / 00:00 PT quota cooldown)."
          end

          FileUtils.mv(sidecar_path, File.join(blocked_dir, File.basename(sidecar_path))) if sidecar_path && File.exist?(sidecar_path)
          blocked_info = File.join(blocked_dir, "#{filename}.blocked.json")
          File.write(blocked_info, JSON.pretty_generate({
            'blocked_at' => Time.now.utc.iso8601,
            'reason' => 'upstream_quota_blocked',
            'cooldown_resets_at' => '2:00 AM CT (00:00 PT)',
            'step' => tracker.current_step,
            'diagnostic' => e.message,
            'cloud_path' => relocated_cloud_dest
          }))
        end
      else
        warn "❌ [Error] Failed processing #{filename}: #{e.message}"
        warn e.backtrace.first(5).join("\n")
        log_activity('error', "Failed processing #{filename}: #{e.message}", level: 'error', details: { 'filename' => filename, 'error' => e.message })
        tracker.fail_step(tracker.current_step || 'unknown', e.message, e.backtrace)

        puts "🧠 [Classifier Triage] Recommended action: #{triage[:decision]} (Confidence: #{(triage[:confidence] * 100).round}%)"
        log_activity('triage', "Classifier evaluated failure on #{filename}: #{triage[:decision]} (#{(triage[:confidence] * 100).round}%)", details: triage)

        unless options[:dry_run]
          failed_dest = File.join(failed_dir, filename)
          FileUtils.mv(processing_path, failed_dest) if File.exist?(processing_path)
          tracker.relocate_file_path!(failed_dest)
          FileUtils.mv(sidecar_path, File.join(failed_dir, File.basename(sidecar_path))) if sidecar_path && File.exist?(sidecar_path)
          err_log = File.join(failed_dir, "#{filename}.error.log")
          File.write(err_log, "Failed at: #{Time.now.utc.iso8601}\nError: #{e.message}\n\n#{e.backtrace.join("\n")}\n")
          puts "⚠️ Moved to failed/#{filename} with diagnostic error log."
        end
      end

      false
    ensure
      @current_processing_path = nil
      @current_original_path = nil
    end
  end

  # Metadata Synthesis
  def synthesize_metadata(video_path, target_name, target_info, transcript_data, sidecar_data)
    creation_time = resolve_creation_time(video_path)
    date_str = creation_time.strftime('%Y-%m-%d')
    date_human = creation_time.strftime('%B %-d, %Y')

    title = nil
    description = ""
    tags = (target_info['tags'] || []).dup
    tags << target_info['series_name'] if target_info['series_name']

    # 1. Dossier Lookup (e.g. episode-03)
    if target_info['dossier_lookup']
      ep_match = File.basename(video_path).match(/episode[-_]?0*(\d+)/i) || (sidecar_data['episode'] ? { 1 => sidecar_data['episode'] } : nil)
      if ep_match
        ep_num = format('%02d', ep_match[1].to_i)
        dossier_path = File.join(EPISODES_DIR, "episode-#{ep_num}.yml")
        if File.exist?(dossier_path)
          dossier = YAML.safe_load(File.read(dossier_path))
          guest_name = dossier['interviewee'] || dossier['guest'] || dossier['guest_name']
          puts "   📖 Matched Dossier: Episode #{ep_num} (#{guest_name})"
          title = dossier['title']
          tags.concat(dossier['tags'] || []) if dossier['tags']
          tags << guest_name if guest_name
          tags << dossier['conference'] if dossier['conference']

          desc_lines = []
          desc_lines << "The Sound Above: UGtastic Technical Rewatch Series (Episode #{ep_num})"
          desc_lines << "Featuring #{guest_name} at #{dossier['conference']} (#{dossier['year']})" if guest_name
          desc_lines << ""
          desc_lines << dossier.dig('narrative', 'core_inquiry') if dossier.dig('narrative', 'core_inquiry')
          desc_lines << ""
          desc_lines << "• Interactive Curriculum: https://www.just3ws.com/series/the-sound-above/"
          desc_lines << "• Archive Dossier: https://www.just3ws.com/interviews/#{dossier['slug']}/" if dossier['slug']
          desc_lines << "• Patreon Community: https://www.patreon.com/whoistechcmty"
          description = desc_lines.compact.join("\n").strip
        end
      end
    end

    # 2. Sidecar Data Override
    if sidecar_data['title']
      title = sidecar_data['title']
    end
    if sidecar_data['description']
      description = sidecar_data['description']
    end
    if sidecar_data['tags']
      tags.concat(Array(sidecar_data['tags']))
    end

    # 3. Auto-title from speech if not resolved
    if title.nil? || title.empty?
      if target_info['auto_title_from_speech'] && !transcript_data[:text].empty?
        hook = extract_hook_from_text(transcript_data[:text])
        title = "#{target_info['title_prefix'] || target_info['series_name']} (#{date_str}): #{hook}"
      else
        title = "#{target_info['title_prefix'] || target_info['series_name']} (#{date_str})"
      end
    end

    # Title character budget calibration (strictly <= 100 characters for YouTube)
    if title.length > 100
      title = title[0...97].strip + "..."
    end

    # Description generation
    if description.empty?
      tpl = target_info['description_template'] || ""
      snippet = transcript_data[:text].to_s.strip.split("\n").first(4).join(" ")
      prompt = sidecar_data['prompt'] || sidecar_data['notes'] || ""

      parts = []
      parts << tpl.strip unless tpl.empty?
      parts << "\nField Notes & Origin Context:\n#{prompt.strip}" unless prompt.empty?
      parts << "\nSpoken Overview:\n\"#{snippet[0..300]}...\"" unless snippet.empty?
      parts << "\nRecorded: #{date_human}"
      description = parts.join("\n\n").strip
    end

    # YouTube API v3 description sanitization: strictly <= 5000 characters and no angle brackets
    description = description.to_s.gsub(/[<>]/, '')
    if description.length > 5000
      description = description[0...4990].strip + "\n..."
    end

    privacy = sidecar_data['privacy'] || target_info['default_privacy'] || 'unlisted'

    classifier = PipelineClassifier.new
    archetype_res = classifier.classify_archetype(transcript_data[:text], metadata: { filename: File.basename(video_path) })
    puts "   🧠 [Classifier Archetype] Inferred: #{archetype_res[:decision]} (Confidence: #{(archetype_res[:confidence] * 100).round}%)"

    {
      title: title,
      description: description,
      tags: tags.uniq,
      privacy: privacy,
      inferred_archetype: archetype_res[:decision],
      archetype_confidence: archetype_res[:confidence]
    }
  end

  # Extract First Clean Hook from Spoken Text
  def extract_hook_from_text(text)
    clean = text.gsub(/\s+/, ' ').strip
    first_sentence = clean.split(/[.?!]/).first.to_s.strip
    return "Field Reflections" if first_sentence.empty?

    # Iteratively strip conversational filler words and punctuation at beginning
    trimmed = first_sentence
    while trimmed =~ /^(hey|hello|hi|so|yeah|yes|alright|okay|today|we are|i am|i'm|just|um|uh|well)[,\s]+/i
      trimmed = trimmed.sub(/^(hey|hello|hi|so|yeah|yes|alright|okay|today|we are|i am|i'm|just|um|uh|well)[,\s]+/i, '').strip
    end

    words = trimmed.split
    summary = words.take(8).join(' ')
    summary = summary.gsub(/\b(?:ucastic|ugtastic)\b/i, 'UGtastic')
    summary = summary.gsub(/\bblind\s+sight\b/i, 'Blindsight')
    summary = summary.sub(/\s+is a book$/i, '')
    summary[0] = summary[0].upcase if summary[0]
    summary.empty? ? "Field Reflections" : summary
  end

  # Video Creation Time via ffprobe or mtime
  def resolve_creation_time(video_path)
    return Time.now unless File.exist?(video_path)

    cmd = "ffprobe -v quiet -select_streams v:0 -show_entries format_tags=creation_time:stream_tags=creation_time -of default=noprint_wrappers=1:nokey=1 #{video_path.shellescape} 2>/dev/null"
    out = `#{cmd}`.strip.split("\n").first
    if out && !out.empty?
      Time.parse(out) rescue File.mtime(video_path)
    else
      File.mtime(video_path)
    end
  end

  # Extract Audio to 16kHz mono WAV
  def extract_audio(input_path, output_wav)
    cmd = "nice -n 15 ffmpeg -i #{input_path.shellescape} -vn -ar 16000 -ac 1 -c:a pcm_s16le #{output_wav.shellescape} -y -loglevel error"
    success = system(cmd)
    raise "ffmpeg failed to extract audio from #{input_path}" unless success && File.exist?(output_wav)
  end

  # Transcribe using canonical zdots ztranscribe pipeline
  def transcribe_audio(wav_path, output_prefix, custom_prompt = nil)
    ztranscribe_bin = find_ztranscribe_binary
    raise "ztranscribe pipeline executable not found in PATH or zdots" unless ztranscribe_bin && !ztranscribe_bin.empty? && File.exist?(ztranscribe_bin)

    out_dir = File.dirname(output_prefix)
    FileUtils.mkdir_p(out_dir)
    stem = File.basename(wav_path, '.*')

    prompt = custom_prompt || "UGtastic, Software Craftsmanship, Chicago Alt.NET, NUnit, NHibernate, StructureMap, Ruby, Rails, RSpec, Obtiva"

    puts "🧠 Running canonical ztranscribe pipeline from zdots on Apple Silicon (nice 15, background QoS)..."
    cmd = "nice -n 15 #{ztranscribe_bin.shellescape} #{wav_path.shellescape} --out-dir #{out_dir.shellescape} --profile standard --prompt #{prompt.shellescape} 2>&1"
    output = `#{cmd}`
    exit_code = $?.exitstatus

    expected_dir = File.join(out_dir, stem)
    zt_txt = File.join(expected_dir, "#{stem}.txt")
    zt_vtt = File.join(expected_dir, "#{stem}.vtt")

    FileUtils.cp(zt_txt, "#{output_prefix}.txt") if File.exist?(zt_txt)
    FileUtils.cp(zt_vtt, "#{output_prefix}.vtt") if File.exist?(zt_vtt)
    FileUtils.rm_rf(expected_dir) if Dir.exist?(expected_dir)

    txt_file = "#{output_prefix}.txt"
    vtt_file = "#{output_prefix}.vtt"

    raw_text = File.exist?(txt_file) ? File.read(txt_file).strip : ""
    raw_vtt = File.exist?(vtt_file) ? File.read(vtt_file).strip : ""

    if raw_text.empty? && raw_vtt.empty?
      warn "⚠️ ztranscribe produced empty output (exit #{exit_code}). Output: #{output.slice(0, 300)}"
    end

    text = clean_transcript_text(raw_text)
    vtt = clean_transcript_text(raw_vtt)

    { text: text, vtt: vtt }
  end

  def find_ztranscribe_binary
    candidates = [
      File.expand_path('~/.config/zsh/bin/ztranscribe'),
      File.expand_path('~/.config/zsh/recipes/yt-transcribe'),
      '/Users/mike/.config/zsh/recipes/yt-transcribe'
    ]
    candidates.find { |p| File.exist?(p) && File.executable?(p) } || `which ztranscribe 2>/dev/null`.strip
  end

  # Phonetic corrections for speech-to-text misrecognitions
  def clean_transcript_text(str)
    return "" unless str
    cleaned = str.dup
    cleaned.gsub!(/when I was doing fantastic interviews/i, 'when I was doing UGtastic interviews')
    cleaned.gsub!(/\bfantastic interviews\b/i, 'UGtastic interviews')
    cleaned.gsub!(/\byou fantastic\b/i, 'UGtastic')
    cleaned.gsub!(/\bug tastic\b/i, 'UGtastic')
    cleaned.gsub!(/\bblind\s+sight\b/i, 'Blindsight')
    cleaned
  end

  # PostgreSQL Registration
  def record_in_postgres(video_id, metadata, target_name)
    title_esc = metadata[:title].gsub("'", "''")
    db_cmd = "psql -d my -c \"INSERT INTO media_sources (source_id, source_type, title, ingest_status, updated_at) VALUES ('#{video_id}', 'youtube', '#{title_esc}', 'done', NOW()) ON CONFLICT (source_id) DO UPDATE SET ingest_status = 'done', updated_at = NOW();\" 2>/dev/null"
    system(db_cmd)
  end

  # Check if file has finished writing
  def stable_file?(path)
    return false unless File.exist?(path)
    s1 = File.size(path)
    return false if s1.zero?
    return true if options[:dry_run]

    # Multi-sample stability check: protect against in-flight uploads
    sleep 3
    return false unless File.exist?(path)
    s2 = File.size(path)
    return false if s2 != s1

    sleep 2
    return false unless File.exist?(path)
    s3 = File.size(path)
    s2 == s3
  end

  def find_sidecar(video_path)
    base = video_path.sub(/\.[^.]+$/, '')
    ['.yml', '.yaml', '.txt'].map { |ext| base + ext }.find { |p| File.exist?(p) }
  end

  def parse_sidecar(sidecar_path)
    return {} unless sidecar_path && File.exist?(sidecar_path)
    if sidecar_path.end_with?('.yml', '.yaml')
      YAML.safe_load(File.read(sidecar_path)) rescue {}
    else
      lines = File.read(sidecar_path).lines.map(&:strip)
      title = lines.find { |l| l.start_with?('Title:') }&.sub(/^Title:\s*/, '')
      prompt = lines.find { |l| l.start_with?('Prompt:') }&.sub(/^Prompt:\s*/, '')
      { 'title' => title, 'prompt' => prompt || lines.join("\n") }
    end
  end

  def list_media_files(dir)
    return [] unless Dir.exist?(dir)
    Dir.glob(File.join(dir, '*')).select do |f|
      File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i
    end.sort
  end

  def count_files_recursive(dir)
    return 0 unless Dir.exist?(dir)
    Dir.glob(File.join(dir, '**', '*')).count { |f| File.file?(f) && (f =~ /\.(mp4|mov|m4v|webm|mkv)$/i || f.end_with?('.receipt.json')) }
  end

  def format_size(bytes)
    return "0 B" if bytes.zero?
    mb = bytes.to_f / (1024 * 1024)
    if mb > 1024
      format('%.2f GB', mb / 1024)
    else
      format('%.1f MB', mb)
    end
  end

  # Generate canonical slug for asset and transcript
  def generate_slug(target_name, title)
    clean_title = title.to_s.sub(/^(?:Episode \d+|Ramblin' & Amblin' \(\d{4}-\d{2}-\d{2}\)|Errata \d+):\s*/i, '').strip
    clean_title = title if clean_title.empty?
    clean_title = clean_title.gsub(/[^\w\s-]/, '').strip
    slug_base = clean_title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
    "#{target_name}-#{slug_base}".slice(0, 80)
  end

  # Persist structured transcript to _data/transcripts/
  def save_transcript_dossier(target_name, filename, metadata, transcript_data)
    slug = generate_slug(target_name, metadata[:title])
    transcript_file = File.join(TRANSCRIPTS_DATA_DIR, "#{slug}.yml")

    # Split into clean conversational turns
    turns = []
    text_blocks = transcript_data[:text].split(/(?<=[.?!])\s+/).each_slice(4).map { |s| s.join(" ") }
    text_blocks.each do |block|
      next if block.strip.empty?
      clean_block = block.strip.gsub("\u2014", ': ').gsub(/\s+--\s+/, ': ')
      turns << {
        "speaker" => "M1",
        "text" => clean_block
      }
    end

    payload = {
      "speaker_map" => {
        "M1" => {
          "name" => "Mike Hall",
          "role" => "Host, #{metadata[:series_name] || target_name}"
        }
      },
      "turns" => turns
    }

    FileUtils.mkdir_p(TRANSCRIPTS_DATA_DIR)
    File.write(transcript_file, YAML.dump(payload))
    puts "📝 Saved interactive transcript to _data/transcripts/#{slug}.yml"

    register_in_video_assets(slug, metadata, target_name, filename)
  end

  # Register newly published asset into _data/video_assets.yml
  def register_in_video_assets(slug, metadata, target_name, filename = nil)
    raw = File.exist?(VIDEO_ASSETS_PATH) ? YAML.safe_load(File.read(VIDEO_ASSETS_PATH), permitted_classes: [Date, Time], aliases: true) : nil
    assets = if raw.is_a?(Hash) && raw['items'].is_a?(Array)
               raw['items']
             elsif raw.is_a?(Array)
               raw
             else
               []
             end

    return if assets.any? { |a| a["id"] == slug || a["transcript_id"] == slug || (a["platforms"] || []).any? { |p| p["asset_id"] == metadata[:video_id] } }

    asset_entry = {
      "id" => slug,
      "source_filename" => filename,
      "title" => metadata[:title].gsub("\u2014", ': '),
      "speaker" => "Mike Hall",
      "role" => "Host, UGtastic",
      "transcript_id" => slug,
      "description" => metadata[:description].lines.first(3).map(&:strip).join(" ").gsub("\u2014", ': '),
      "platforms" => [
        {
          "platform" => "youtube",
          "asset_id" => metadata[:video_id],
          "url" => "https://youtu.be/#{metadata[:video_id]}",
          "embed_url" => "https://www.youtube.com/embed/#{metadata[:video_id]}",
          "title_on_platform" => metadata[:title].gsub("\u2014", ': '),
          "published_date" => Time.now.strftime('%Y-%m-%d')
        }
      ],
      "primary_platform" => "youtube",
      "published_date" => Time.now.strftime('%Y-%m-%d'),
      "tags" => metadata[:tags] || [],
      "chapters" => [
        { "time" => "00:00", "title" => "Introduction & Context" }
      ]
    }

    File.open(VIDEO_ASSETS_PATH, 'a') do |f|
      f.write("\n" + YAML.dump([asset_entry]).sub(/\A---\s*\n/, ''))
    end
    puts "📚 Registered asset in _data/video_assets.yml"
  end

  # Check if a video was already archived with a completed receipt
  def find_archived_receipt(filename, processed_dir = nil)
    search_dirs = [processed_dir, base_path, cloud_archive_path].compact.uniq
    receipt_files = []
    search_dirs.each do |dir|
      next unless dir && Dir.exist?(dir)
      pattern = File.join(dir, '**', "#{filename}.receipt.json")
      receipt_files.concat(Dir.glob(pattern))
    end
    return nil if receipt_files.empty?

    receipt_path = receipt_files.sort_by { |p| File.mtime(p) }.last
    JSON.parse(File.read(receipt_path)) rescue nil
  end

  # Find registered asset in _data/video_assets.yml by title, slug, or source filename
  def find_registered_asset(title, slug = nil, filename = nil)
    raw = File.exist?(VIDEO_ASSETS_PATH) ? YAML.safe_load(File.read(VIDEO_ASSETS_PATH), permitted_classes: [Date, Time], aliases: true) : nil
    assets = if raw.is_a?(Hash) && raw['items'].is_a?(Array)
               raw['items']
             elsif raw.is_a?(Array)
               raw
             else
               []
             end

    norm_title = title.to_s.downcase.gsub(/[^a-z0-9]/, '')
    assets.find do |a|
      (filename && a["source_filename"] == filename) ||
        (slug && (a["id"] == slug || a["transcript_id"] == slug)) ||
        (a["title"] && a["title"].to_s.downcase.gsub(/[^a-z0-9]/, '') == norm_title)
    end
  end

  # Regenerate local knowledge datalake
  def update_local_knowledge_system!
    script = File.join(ROOT_DIR, 'bin', 'generate_career_datalake.rb')
    if File.exist?(script)
      system("nice -n 15 ruby #{script} > /dev/null 2>&1")
      puts "🧠 Local CareerOS Datalake updated with new video transcripts."
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {
    dry_run: false,
    channel: nil,
    target: nil,
    watch: false,
    status: false,
    verbose: false,
    one: false
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: bin/intake_drive_video.rb [options]"

    opts.on("-s", "--status", "Display visual status of queue across all targets") { options[:status] = true }
    opts.on("--drop FILE", "--ingest FILE", "Stage a local file into pending queue (e.g. from LocalSend or USB pull)") do |f|
      options[:drop_file] = f
    end
    opts.on("-m", "--move", "Move rather than copy file when using --drop to prevent duplicate storage") { options[:move] = true }
    opts.on("-t", "--target TARGET", "Process specific target (ramblin-amblin, the-sound-above, errata)") { |t| options[:target] = t }
    opts.on("-c", "--channel CHANNEL", "Channel key (defaults to all channels)") { |c| options[:channel] = c }
    opts.on("-1", "--one", "--single", "Process only the single oldest file (FIFO) and exit") { options[:one] = true }
    opts.on("-n", "--dry-run", "Simulate actions without uploading or moving files") { options[:dry_run] = true }
    opts.on("-w", "--watch", "Continuous polling loop") { options[:watch] = true }
    opts.on("-v", "--verbose", "Verbose logging") { options[:verbose] = true }

    opts.on("--halt", "--pause", "Arm graceful halt: finish active video, then halt queue") do
      MediaIntakePipeline.halt!
      exit 0
    end

    opts.on("--stop", "Force stop active task immediately and restore file to pending") do
      MediaIntakePipeline.stop!
      exit 0
    end

    opts.on("--resume", "Resume halted or stopped pipeline") do
      MediaIntakePipeline.resume!
      exit 0
    end

    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit 0
    end
  end.parse!

  pipeline = MediaIntakePipeline.new(options)

  if options[:drop_file]
    src = File.expand_path(options[:drop_file])
    unless File.file?(src)
      warn "❌ Source file does not exist: #{src}"
      exit 1
    end
    tgt = options[:target] || 'ramblin-amblin'
    chan = options[:channel] || 'whoistechcmty'

    # Direct ingest to Google Drive folder when configured so local SSD stays lean
    dest_base = (pipeline.cloud_archive_path && Dir.exist?(pipeline.cloud_archive_path)) ? pipeline.cloud_archive_path : pipeline.base_path
    dest_dir = File.join(dest_base, chan, tgt, 'pending')
    FileUtils.mkdir_p(dest_dir)
    dest_file = File.join(dest_dir, File.basename(src))

    if options[:move] || src.start_with?(File.expand_path('~/Downloads'))
      FileUtils.mv(src, dest_file)
      puts "📥 Ingested and moved #{File.basename(src)} into #{tgt} pending queue:"
    else
      FileUtils.cp(src, dest_file)
      puts "📥 Ingested #{File.basename(src)} into #{tgt} pending queue:"
    end
    puts "   Destination: #{dest_file}"
    puts "   Run './bin/pipeline media intake --single' to process now, or '--watch' for autonomous background processing."
    exit 0
  end

  if options[:status]
    pipeline.print_status(options[:channel])
    exit 0
  end

  # Signal Handling: First SIGINT halts gracefully; second SIGINT aborts task immediately
  trap("INT") do
    if pipeline.halt_requested
      puts "\n🛑 Immediate Stop requested (second SIGINT). Aborting active task..."
      pipeline.abort_active_task!
      exit 130
    else
      pipeline.halt_requested = true
      puts "\n⏸️ Graceful Halt requested (SIGINT). Finishing active video, then halting."
      puts "   (Press Ctrl+C again to abort current task immediately)"
    end
  end

  trap("TERM") do
    puts "\n🛑 SIGTERM received. Halting pipeline and releasing lock..."
    pipeline.abort_active_task!
    exit 143
  end

  trap("TSTP") do
    puts "\n⏸️ SIGTSTP received. Pausing queue after current file..."
    pipeline.halt_requested = true
  end

  if options[:watch]
    puts "👀 Watching Google Drive intake queues every 30 seconds (Press Ctrl+C to stop)..."
    loop do
      pipeline.run(options[:channel], options[:target])
      sleep 30
    end
  else
    pipeline.run(options[:channel], options[:target])
  end
end

# bin/lib/job_substate_tracker.rb
# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'time'

# JobSubstateTracker manages nested statecharts and discrete checkpointing for
# media ingestion jobs. Each job tracks its meta publication phase (pending, processing,
# quarantined, processed) and internal step progression (audio_dsp, transcription,
# metadata_synthesis, youtube_upload, playlist_assignment, captions_upload, datalake_sync, archival).
# If a job is interrupted or fails, reruns skip completed steps whose outputs exist.
class JobSubstateTracker
  STEPS = %w[
    audio_dsp
    transcription
    metadata_synthesis
    youtube_upload
    playlist_assignment
    captions_upload
    datalake_sync
    archival
  ].freeze

  STEP_LABELS = {
    'audio_dsp' => 'DSP',
    'transcription' => 'STT',
    'metadata_synthesis' => 'Meta',
    'youtube_upload' => 'Upload',
    'playlist_assignment' => 'Playlist',
    'captions_upload' => 'Captions',
    'datalake_sync' => 'Datalake',
    'archival' => 'Archive'
  }.freeze

  attr_reader :filename, :file_path, :state_dir, :data

  def self.load(filename, file_path, state_dir = nil)
    state_dir ||= File.expand_path('~/.local/state/just3ws')
    instance = new(filename, file_path, state_dir)
    instance.load_existing_state!
    instance
  end

  def initialize(filename, file_path, state_dir)
    @filename = filename
    @file_path = file_path
    @state_dir = state_dir
    @data = default_state
  end

  def meta_phase
    @data['meta_phase']
  end

  def meta_phase=(phase)
    @data['meta_phase'] = phase.to_s
    @data['updated_at'] = Time.now.utc.iso8601
  end

  def current_step
    @data['current_step']
  end

  def substates
    @data['substates'] ||= {}
  end

  def step_status(step_name)
    substates.dig(step_name.to_s, 'status') || 'pending'
  end

  def step_completed?(step_name)
    step_status(step_name) == 'completed'
  end

  def step_data(step_name)
    substates[step_name.to_s] || {}
  end

  def start_step(step_name, initial_data = {})
    s_name = step_name.to_s
    substates[s_name] ||= {}
    substates[s_name]['status'] = 'in_progress'
    substates[s_name]['started_at'] ||= Time.now.utc.iso8601
    initial_data.each { |k, v| substates[s_name][k.to_s] = v }
    @data['current_step'] = s_name
    @data['updated_at'] = Time.now.utc.iso8601
    save!
  end

  def update_step(step_name, progress_data = {})
    s_name = step_name.to_s
    substates[s_name] ||= {}
    progress_data.each { |k, v| substates[s_name][k.to_s] = v }
    @data['updated_at'] = Time.now.utc.iso8601
    save!
  end

  def complete_step(step_name, step_outputs = {})
    s_name = step_name.to_s
    substates[s_name] ||= {}
    substates[s_name]['status'] = 'completed'
    substates[s_name]['completed_at'] = Time.now.utc.iso8601
    step_outputs.each { |k, v| substates[s_name][k.to_s] = v }
    if substates[s_name]['started_at'] && !substates[s_name]['duration_seconds']
      t_start = Time.parse(substates[s_name]['started_at']) rescue nil
      substates[s_name]['duration_seconds'] = (Time.now.-(t_start)).round(2) if t_start
    end
    @data['current_step'] = next_pending_step
    @data['updated_at'] = Time.now.utc.iso8601
    save!
  end

  def fail_step(step_name, error_message, backtrace = nil)
    s_name = step_name.to_s
    substates[s_name] ||= {}
    substates[s_name]['status'] = 'failed'
    substates[s_name]['failed_at'] = Time.now.utc.iso8601
    substates[s_name]['error'] = error_message.to_s
    substates[s_name]['backtrace'] = Array(backtrace).first(10) if backtrace
    @data['meta_phase'] = 'quarantined'
    @data['current_step'] = s_name
    @data['updated_at'] = Time.now.utc.iso8601
    save!
  end

  def block_step(step_name, reason, details = {})
    s_name = step_name.to_s
    substates[s_name] ||= {}
    substates[s_name]['status'] = 'blocked'
    substates[s_name]['blocked_at'] = Time.now.utc.iso8601
    substates[s_name]['block_reason'] = reason.to_s
    details.each { |k, v| substates[s_name][k.to_s] = v }
    @data['meta_phase'] = 'blocked'
    @data['current_step'] = s_name
    @data['updated_at'] = Time.now.utc.iso8601
    save!
  end

  def next_pending_step
    STEPS.find { |s| substates.dig(s, 'status') != 'completed' }
  end

  def all_steps_completed?
    STEPS.all? { |s| substates.dig(s, 'status') == 'completed' }
  end

  # Returns discrete badge descriptors for frontend rendering
  def summary_badges
    STEPS.map do |s|
      st = step_status(s)
      {
        'id' => s,
        'label' => STEP_LABELS[s] || s,
        'status' => st
      }
    end
  end

  def local_state_path
    jobs_dir = File.join(@state_dir, 'jobs')
    FileUtils.mkdir_p(jobs_dir)
    File.join(jobs_dir, "#{@filename}.state.json")
  end

  def companion_state_path
    "#{@file_path}.state.json"
  end

  def load_existing_state!
    candidate_paths = [
      companion_state_path,
      local_state_path,
      find_state_in_queue_dirs
    ].compact.uniq

    best_candidate = nil
    best_score = -1
    discovered_vid = nil

    candidate_paths.each do |p|
      next unless p && File.exist?(p)
      begin
        raw = JSON.parse(File.read(p))
        next unless raw.is_a?(Hash) && raw['version']

        # Check for recorded video_id
        cand_vid = raw.dig('substates', 'youtube_upload', 'video_id') || raw['video_id']
        discovered_vid ||= cand_vid if cand_vid && !cand_vid.to_s.strip.empty?

        # Progress scoring: completed steps count + video_id weight + updated recency
        completed_count = (raw['substates'] || {}).values.count { |s| s['status'] == 'completed' }
        has_vid_bonus = cand_vid ? 100 : 0
        score = (completed_count * 10) + has_vid_bonus

        if score > best_score
          best_score = score
          best_candidate = raw
        end
      rescue StandardError
        next
      end
    end

    if best_candidate
      @data = best_candidate
      if discovered_vid && !(@data.dig('substates', 'youtube_upload', 'video_id'))
        @data['substates'] ||= {}
        @data['substates']['youtube_upload'] ||= {}
        @data['substates']['youtube_upload']['video_id'] = discovered_vid
        @data['substates']['youtube_upload']['status'] = 'completed'
      end
      return true
    end

    false
  end

  def save!
    json_str = JSON.pretty_generate(@data)

    # 1. Always save to local state dir
    begin
      File.write(local_state_path, json_str)
    rescue StandardError => e
      warn "⚠️ Could not save local job state for #{@filename}: #{e.message}"
    end

    # 2. Save companion alongside media file if directory exists
    if @file_path && Dir.exist?(File.dirname(@file_path))
      begin
        File.write(companion_state_path, json_str)
      rescue StandardError => e
        warn "⚠️ Could not save companion job state for #{@filename}: #{e.message}"
      end
    end

    true
  end

  def relocate_file_path!(new_file_path)
    old_companion = companion_state_path
    @file_path = new_file_path
    new_companion = companion_state_path

    # Relocate companion state file alongside media file
    if File.exist?(old_companion) && old_companion != new_companion
      begin
        FileUtils.mv(old_companion, new_companion)
      rescue StandardError
        File.write(new_companion, JSON.pretty_generate(@data)) rescue nil
      end
    else
      save!
    end
  end

  def job_scratch_dir
    dir = File.join(@state_dir, 'scratch', @filename)
    FileUtils.mkdir_p(dir)
    dir
  end

  def scratch_wav_path
    File.join(job_scratch_dir, "#{@filename}.16k.wav")
  end

  def scratch_prefix
    File.join(job_scratch_dir, @filename)
  end

  def can_skip_audio_dsp?
    return false unless step_completed?(:audio_dsp)

    wav = step_data(:audio_dsp)['wav_path'] || scratch_wav_path
    wav && File.exist?(wav) && File.size(wav) > 100
  end

  def can_skip_transcription?
    return false unless step_completed?(:transcription)

    text = step_data(:transcription)['text']
    vtt = step_data(:transcription)['vtt']
    vtt_file = "#{scratch_prefix}.vtt"
    (text && !text.strip.empty?) || (vtt && !vtt.strip.empty?) || (File.exist?(vtt_file) && File.size(vtt_file) > 0)
  end

  def can_skip_youtube_upload?(client = nil)
    vid = step_data(:youtube_upload)['video_id'] || substates.dig('youtube_upload', 'video_id') || @data['video_id']
    return false if vid.nil? || vid.to_s.strip.empty? || vid.to_s.start_with?('DRY_RUN')

    if client
      begin
        video = client.get_video(vid)
        return !video.nil? && video['id'] == vid
      rescue StandardError => err
        # If API error is quotaExceeded (403) or rate limit or transient network error:
        # Never return false when we already have the recorded video_id. Returning false
        # causes caller to re-upload, burning quota and producing duplicate video records.
        msg = err.message.to_s
        if msg.include?('quotaExceeded') || msg.include?('403') || msg.include?('rateLimit') || msg.include?('timeout') || msg.include?('401') || msg.include?('UNAUTHENTICATED') || msg.include?('authError')
          warn "⚠️ [Idempotency] Could not verify #{vid} live due to API quota/rate limit/auth: #{msg}. Preserving recorded video_id to prevent duplicate upload."
          return true
        end
        return false if msg.include?('404') || msg.include?('notFound')
        return true
      end
    end

    true
  end

  def cleanup_scratch!
    dir = File.join(@state_dir, 'scratch', @filename)
    FileUtils.rm_rf(dir) if Dir.exist?(dir)
  end

  def cleanup_on_success!
    cleanup_scratch!
    FileUtils.rm_f(companion_state_path) if File.exist?(companion_state_path)
    FileUtils.rm_f(local_state_path) if File.exist?(local_state_path)
  end

  private

  def default_state
    now_iso = Time.now.utc.iso8601
    steps_map = {}
    STEPS.each do |s|
      steps_map[s] = {
        'status' => 'pending',
        'started_at' => nil,
        'completed_at' => nil,
        'duration_seconds' => nil
      }
    end

    {
      'version' => '1.0',
      'filename' => @filename,
      'file_path' => @file_path,
      'created_at' => now_iso,
      'updated_at' => now_iso,
      'meta_phase' => 'pending',
      'current_step' => STEPS.first,
      'substates' => steps_map
    }
  end

  def find_state_in_queue_dirs
    return nil unless @file_path
    parent_target_dir = File.expand_path('..', File.dirname(@file_path))
    return nil unless Dir.exist?(parent_target_dir)

    %w[pending processing failed blocked staged processed].each do |sub|
      cand = File.join(parent_target_dir, sub, "#{@filename}.state.json")
      return cand if File.exist?(cand)
    end

    # Also search processed recursive subdirectories for state
    Dir.glob(File.join(parent_target_dir, 'processed', '**', "#{@filename}.state.json")).each do |cand|
      return cand if File.exist?(cand)
    end

    nil
  end
end

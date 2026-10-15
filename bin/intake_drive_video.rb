#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/intake_drive_video.rb
# Media Intake & YouTube Publishing Pipeline
#
# Processes on-demand video files from Google Drive queue directories:
#   pending/ -> processing/ -> processed/ (or failed/)
#
# Extracts ephemeral audio, transcribes with local whisper.cpp on Apple Silicon,
# synthesizes Craftsman metadata, performs resumable upload to YouTube Data API v3,
# attaches verified WebVTT captions, and preserves pristine cloud masters with zero
# permanent local SSD disk usage.

require 'json'
require 'yaml'
require 'optparse'
require 'fileutils'
require 'time'
require 'open3'
require_relative 'lib/youtube_client'

ROOT_DIR = File.expand_path('..', __dir__)
CONFIG_PATH = File.join(ROOT_DIR, '_data', 'media_intake_targets.yml')
EPISODES_DIR = File.join(ROOT_DIR, '_data', 'episodes')
WHISPER_MODELS_DIR = File.expand_path('~/.local/share/whisper-cpp/models')
DEFAULT_MODEL = 'ggml-large-v3-turbo.bin'

class MediaIntakePipeline
  attr_reader :config, :client, :options

  def initialize(options = {})
    @options = options
    @config = load_config
    @client = nil unless @options[:dry_run]
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
    config['base_path']
  end

  def channel_config(channel = 'whoistechcmty')
    config.dig('channels', channel) || raise("Channel '#{channel}' not found in configuration")
  end

  def target_config(target_name, channel = 'whoistechcmty')
    targets = channel_config(channel)['targets'] || {}
    targets[target_name] || raise("Target '#{target_name}' not found for channel '#{channel}'")
  end

  # Display Queue Status across all configured targets
  def print_status(channel = 'whoistechcmty')
    ch_conf = channel_config(channel)
    puts "\n" + ("=" * 72)
    puts "  MEDIA INTAKE QUEUE STATUS: #{channel} (#{ch_conf['channel_handle']})"
    puts "  Base Path: #{base_path}"
    puts ("=" * 72)

    ch_conf['targets'].each do |target_name, target_info|
      target_dir = File.join(base_path, channel, target_name)
      pending_files = list_media_files(File.join(target_dir, 'pending'))
      processing_files = list_media_files(File.join(target_dir, 'processing'))
      processed_count = count_files_recursive(File.join(target_dir, 'processed'))
      failed_count = list_media_files(File.join(target_dir, 'failed')).size

      puts "\n📁 Target: #{target_name}"
      puts "   Series:    #{target_info['series_name']}"
      puts "   Playlist:  #{target_info['playlist_id']}"
      puts "   Privacy:   #{target_info['default_privacy']}"
      puts "   [pending]    #{pending_files.size} file(s)"
      pending_files.each { |f| puts "     -> #{File.basename(f)} (#{format_size(File.size(f))})" } if pending_files.any?
      puts "   [processing] #{processing_files.size} file(s)"
      processing_files.each { |f| puts "     -> #{File.basename(f)}" } if processing_files.any?
      puts "   [processed]  #{processed_count} completed asset(s)"
      puts "   [failed]     #{failed_count} item(s)"
    end
    puts "\n" + ("=" * 72) + "\n"
  end

  # Scan and process queued items
  def run(channel = 'whoistechcmty', target_filter = nil)
    ch_conf = channel_config(channel)
    targets = ch_conf['targets']
    targets = targets.slice(target_filter) if target_filter && targets.key?(target_filter)

    total_processed = 0

    targets.each do |target_name, target_info|
      target_dir = File.join(base_path, channel, target_name)
      pending_dir = File.join(target_dir, 'pending')
      next unless Dir.exist?(pending_dir)

      media_files = list_media_files(pending_dir)
      next if media_files.empty?

      puts "\n🎬 [Intake] Found #{media_files.size} file(s) in #{target_name}/pending"
      media_files.each do |file_path|
        process_file(file_path, target_name, target_info, channel)
        total_processed += 1
      end
    end

    if total_processed.zero?
      puts "✓ Intake queue is clear. No pending media files found."
    else
      puts "\n✅ Intake run finished. #{total_processed} file(s) processed."
    end
  end

  # Single File Ingestion & State Machine
  def process_file(file_path, target_name, target_info, channel = 'whoistechcmty')
    filename = File.basename(file_path)
    target_dir = File.join(base_path, channel, target_name)
    processing_dir = File.join(target_dir, 'processing')
    processed_dir = File.join(target_dir, 'processed')
    failed_dir = File.join(target_dir, 'failed')

    FileUtils.mkdir_p(processing_dir)
    FileUtils.mkdir_p(processed_dir)
    FileUtils.mkdir_p(failed_dir)

    puts "\n" + ("-" * 60)
    puts "▶ Processing: #{filename} -> #{target_name}"
    puts ("-" * 60)

    # 1. Verification of file stability (avoid partial uploads from phone)
    unless stable_file?(file_path)
      puts "⏳ File size is currently changing or zero bytes. Waiting for phone sync to complete."
      return
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
      puts "🔒 Locked: #{filename} moved to processing/"
    end

    scratch_wav = "/tmp/intake_scratch_#{$$}_#{Time.now.to_i}.wav"
    scratch_prefix = "/tmp/intake_transcribe_#{$$}_#{Time.now.to_i}"

    begin
      # 3. Audio Extraction via ffmpeg stream
      puts "🎙 Extracting audio track to transient scratch WAV..."
      extract_audio(processing_path, scratch_wav)

      # 4. Local Transcription via whisper.cpp
      transcript_data = { text: "", vtt: "" }
      if target_info['auto_title_from_speech'] || target_info['transcribe_with_whisper']
        puts "🧠 Running local whisper.cpp speech recognition on Apple Silicon..."
        transcript_data = transcribe_audio(scratch_wav, scratch_prefix)
      end

      # 5. Metadata Synthesis & Dossier Resolution
      metadata = synthesize_metadata(processing_path, target_name, target_info, transcript_data, sidecar_data)
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
        upload_res = client.upload_video(processing_path, payload)
        video_id = upload_res["id"]
        puts "✅ Video uploaded successfully! Video ID: #{video_id}"
        puts "   Link: https://youtu.be/#{video_id}"

        # 7. Add to Playlist
        if target_info['playlist_id']
          puts "📋 Adding video #{video_id} to playlist #{target_info['playlist_id']}..."
          client.add_playlist_item(target_info['playlist_id'], video_id) rescue puts "   (Item already in playlist or warning ignored)"
        end

        # 8. Attach Captions Track (WebVTT)
        if transcript_data[:vtt] && !transcript_data[:vtt].strip.empty?
          puts "📝 Uploading verified WebVTT caption track to YouTube..."
          client.upload_caption(video_id, transcript_data[:vtt]) rescue puts "   (Captions warning ignored)"
        end

        # 9. Optional PostgreSQL Sync (media_sources)
        record_in_postgres(video_id, metadata, target_name)
      end

      # 10. Archival & Eviction to processed/
      month_dir = File.join(processed_dir, Time.now.strftime('%Y-%m'))
      FileUtils.mkdir_p(month_dir) unless options[:dry_run]
      final_dest = File.join(month_dir, filename)

      if options[:dry_run]
        puts "🔍 [Dry Run] Would move to processed/#{Time.now.strftime('%Y-%m')}/#{filename}"
      else
        FileUtils.mv(processing_path, final_dest)
        FileUtils.mv(sidecar_path, File.join(month_dir, File.basename(sidecar_path))) if sidecar_path && File.exist?(sidecar_path)
        puts "📦 Archived: Moved to processed/#{Time.now.strftime('%Y-%m')}/#{filename}"
      end

    rescue StandardError => e
      warn "❌ [Error] Failed processing #{filename}: #{e.message}"
      warn e.backtrace.first(5).join("\n")

      unless options[:dry_run]
        failed_dest = File.join(failed_dir, filename)
        FileUtils.mv(processing_path, failed_dest) if File.exist?(processing_path)
        log_path = File.join(failed_dir, "#{filename}.error.log")
        File.write(log_path, "#{Time.now.iso8601}\nError: #{e.message}\n\n#{e.backtrace.join("\n")}")
        puts "⚠️ Moved to #{failed_dest} (see #{log_path})"
      end
    ensure
      # Cleanup ephemeral scratch files
      FileUtils.rm_f(scratch_wav)
      Dir.glob("#{scratch_prefix}*").each { |f| FileUtils.rm_f(f) }
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
          desc_lines << "The Sound Above: UGtastic Oral History Rewatch (Episode #{ep_num})"
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

    privacy = sidecar_data['privacy'] || target_info['default_privacy'] || 'unlisted'

    {
      title: title,
      description: description,
      tags: tags.uniq,
      privacy: privacy
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
    cmd = "ffmpeg -i #{input_path.shellescape} -vn -ar 16000 -ac 1 -c:a pcm_s16le #{output_wav.shellescape} -y -loglevel error"
    success = system(cmd)
    raise "ffmpeg failed to extract audio from #{input_path}" unless success && File.exist?(output_wav)
  end

  # Transcribe with whisper-cli
  def transcribe_audio(wav_path, output_prefix)
    whisper_bin = find_whisper_binary
    model_path = find_whisper_model

    unless whisper_bin && File.exist?(whisper_bin) && model_path && File.exist?(model_path)
      puts "⚠️ whisper-cli or model not available; skipping transcription."
      return { text: "", vtt: "" }
    end

    cmd = "#{whisper_bin.shellescape} --model #{model_path.shellescape} --file #{wav_path.shellescape} --max-context 0 --output-vtt --output-txt -of #{output_prefix.shellescape} 2>/dev/null"
    system(cmd)

    txt_file = "#{output_prefix}.txt"
    vtt_file = "#{output_prefix}.vtt"

    text = File.exist?(txt_file) ? File.read(txt_file).strip : ""
    vtt = File.exist?(vtt_file) ? File.read(vtt_file).strip : ""

    { text: text, vtt: vtt }
  end

  def find_whisper_binary
    ['/opt/homebrew/bin/whisper-cli', '/usr/local/bin/whisper-cli'].find { |p| File.exist?(p) } || `which whisper-cli 2>/dev/null`.strip
  end

  def find_whisper_model
    candidates = [
      File.join(WHISPER_MODELS_DIR, 'ggml-large-v3-turbo.bin'),
      File.join(WHISPER_MODELS_DIR, 'ggml-large-v3.bin'),
      File.join(WHISPER_MODELS_DIR, 'ggml-base.bin')
    ]
    candidates.find { |p| File.exist?(p) }
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

    sleep 1 unless options[:dry_run]
    s2 = File.size(path)
    s1 == s2
  end

  def find_sidecar(video_path)
    base = video_path.sub(/\.[^.]+$/, '')
    ['.txt', '.yml', '.yaml'].map { |ext| base + ext }.find { |p| File.exist?(p) }
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
    Dir.glob(File.join(dir, '**', '*')).count { |f| File.file?(f) && f =~ /\.(mp4|mov|m4v|webm|mkv)$/i }
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
end

options = {
  dry_run: false,
  channel: 'whoistechcmty',
  target: nil,
  watch: false,
  status: false,
  verbose: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/intake_drive_video.rb [options]"

  opts.on("-s", "--status", "Display visual status of queue across all targets") { options[:status] = true }
  opts.on("-t", "--target TARGET", "Process specific target (ramblin-amblin, the-sound-above, errata)") { |t| options[:target] = t }
  opts.on("-c", "--channel CHANNEL", "Channel key (default: whoistechcmty)") { |c| options[:channel] = c }
  opts.on("-n", "--dry-run", "Simulate actions without uploading or moving files") { options[:dry_run] = true }
  opts.on("-w", "--watch", "Continuous polling loop") { options[:watch] = true }
  opts.on("-v", "--verbose", "Verbose logging") { options[:verbose] = true }
  opts.on("-h", "--help", "Show this help") do
    puts opts
    exit 0
  end
end.parse!

pipeline = MediaIntakePipeline.new(options)

if options[:status]
  pipeline.print_status(options[:channel])
  exit 0
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

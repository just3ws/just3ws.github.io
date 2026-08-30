#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/sync_youtube_captions.rb — YouTube Data API v3 Captions Uploader & Sync CLI
#
# Reads _data/youtube_captions_manifest.json and syncs WebVTT (.vtt) caption tracks
# to YouTube videos via YouTube Data API v3 (captions.insert).

require 'json'
require 'fileutils'
require 'optparse'

require_relative 'lib/youtube_client'

$stdout.sync = true

class YouTubeCaptionsSyncer
  MANIFEST_FILE = "_data/youtube_captions_manifest.json"
  STATE_FILE = "tmp/youtube_captions_sync_state.json"

  def initialize(options)
    @options = options
    @client = YouTubeClient.new if @options[:upload]
    @sync_state = load_sync_state
  end

  def run
    puts "🎬 YouTube Captions Sync CLI Tool"
    puts "======================================================="

    unless File.exist?(MANIFEST_FILE)
      puts "❌ Error: Manifest file #{MANIFEST_FILE} not found. Run `ruby bin/export_subtitles.rb` first."
      exit 1
    end

    manifest = JSON.parse(File.read(MANIFEST_FILE))
    items = manifest["items"] || []

    if @options[:video_id]
      items = items.select { |item| item["youtube_video_id"] == @options[:video_id] }
    end

    # Filter out already successfully synced items unless --force is given
    unless @options[:force]
      items = items.reject { |item| @sync_state[item["youtube_video_id"]] == "synced" }
    end

    if @options[:limit] && @options[:limit] > 0
      items = items.first(@options[:limit])
    end

    puts "Manifest Items Total:   #{manifest["total_captions"]}"
    puts "Already Synced:         #{@sync_state.values.count('synced')}"
    puts "Target Queue Size:      #{items.size}"
    puts "Mode:                   #{@options[:upload] ? '🚀 UPLOAD TO YOUTUBE API' : '🔍 DRY-RUN (Validation & Audit)'}"
    puts "-------------------------------------------------------"

    success_count = 0
    failure_count = 0
    quota_exceeded = false

    items.each_with_index do |item, idx|
      break if quota_exceeded

      v_id = item["youtube_video_id"]
      vtt = item["vtt_path"]
      t_id = item["transcript_id"]

      exists = File.exist?(vtt)
      status_str = exists ? "OK (#{item["turn_count"]} turns)" : "MISSING VTT FILE"

      puts "[#{idx + 1}/#{items.size}] Video: #{v_id} | Transcript: #{t_id} | Status: #{status_str}"

      if @options[:upload] && exists
        result = upload_with_retry(v_id, vtt, t_id)
        if result == :success
          success_count += 1
          record_state(v_id, "synced")
        elsif result == :quota_exceeded
          quota_exceeded = true
          record_state(v_id, "quota_exceeded")
          puts "🛑 Halting execution: YouTube API daily quota exceeded. Will resume safely next run."
        else
          failure_count += 1
          record_state(v_id, "failed")
        end

        # Polite inter-request rate limit spacing
        sleep 1.0 unless quota_exceeded
      end
    end

    save_sync_state
    puts "======================================================="
    puts "Execution Summary: #{success_count} uploaded, #{failure_count} failed, #{@sync_state.values.count('synced')}/#{manifest['total_captions']} total in sync state."
  end

  private

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

  def record_state(video_id, status)
    @sync_state[video_id] = status
  end

  def upload_with_retry(video_id, vtt_path, transcript_id, max_retries = 3)
    retries = 0
    backoff = 2.0

    loop do
      status = perform_upload(video_id, vtt_path)
      return :success if status == :success
      return :quota_exceeded if status == :quota_exceeded

      retries += 1
      if retries > max_retries
        puts "   ❌ [#{video_id}] Reached max retries (#{max_retries}). Marking for re-run."
        return :failed
      end

      puts "   ⏳ [#{video_id}] Transient failure. Retrying in #{backoff}s (attempt #{retries}/#{max_retries})..."
      sleep backoff
      backoff *= 2.0
    end
  end

  def perform_upload(video_id, vtt_path)
    unless @client && @client.authenticated?
      puts "   ⚠️ Cannot upload #{video_id}: YouTube API not authenticated."
      return :failed
    end

    @client.fetch_access_token! if @client.access_token.nil?

    metadata = {
      snippet: {
        videoId: video_id,
        language: "en",
        name: "English (Technical Conversation Archive)",
        isDraft: false
      }
    }

    uri = URI("https://www.googleapis.com/upload/youtube/v3/captions?part=snippet&uploadType=multipart")
    boundary = "----RubyMultipartBoundary#{SecureRandom.hex(8)}"

    body = []
    body << "--#{boundary}\r\n"
    body << "Content-Type: application/json; charset=UTF-8\r\n\r\n"
    body << "#{metadata.to_json}\r\n"
    body << "--#{boundary}\r\n"
    body << "Content-Type: text/vtt\r\n\r\n"
    body << File.read(vtt_path)
    body << "\r\n--#{boundary}--\r\n"

    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{@client.access_token}"
    req["Content-Type"] = "multipart/related; boundary=#{boundary}"
    req.body = body.join

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)

    if res.code.to_i == 200
      puts "   ✅ [#{video_id}] Successfully uploaded WebVTT caption track to YouTube!"
      return :success
    elsif res.code.to_i == 403 && res.body.include?("quotaExceeded")
      puts "   ⚠️ [#{video_id}] YouTube API 403: Daily Quota Exceeded."
      return :quota_exceeded
    elsif res.code.to_i == 409 || res.body.include?("captionTrackAlreadyExists")
      puts "   ℹ️ [#{video_id}] Caption track already exists on YouTube (In Sync)."
      return :success
    elsif res.code.to_i == 429 || res.code.to_i >= 500
      puts "   ⚠️ [#{video_id}] Rate limited / Server error: #{res.code}. Retrying..."
      return :retry
    else
      puts "   ⚠️ [#{video_id}] Upload response: #{res.code} - #{res.body[0..120]}"
      return :failed
    end
  rescue StandardError => e
    puts "   ❌ [#{video_id}] Network error: #{e.message}"
    return :retry
  end
end

options = { upload: false, limit: 0, video_id: nil }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/sync_youtube_captions.rb [options]"

  opts.on("--upload", "Perform live uploads to YouTube API") do
    options[:upload] = true
  end

  opts.on("--limit N", Integer, "Limit sync batch size") do |n|
    options[:limit] = n
  end

  opts.on("--video-id ID", String, "Target a specific YouTube video ID") do |id|
    options[:video_id] = id
  end
end.parse!

YouTubeCaptionsSyncer.new(options).run

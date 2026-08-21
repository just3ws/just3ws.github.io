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

class YouTubeCaptionsSyncer
  MANIFEST_FILE = "_data/youtube_captions_manifest.json"

  def initialize(options)
    @options = options
    @client = YouTubeClient.new if @options[:upload]
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

    if @options[:limit] && @options[:limit] > 0
      items = items.first(@options[:limit])
    end

    puts "Manifest Items:        #{manifest["total_captions"]}"
    puts "Selected Target Items: #{items.size}"
    puts "Mode:                  #{@options[:upload] ? '🚀 UPLOAD TO YOUTUBE API' : '🔍 DRY-RUN (Validation & Audit)'}"
    puts "-------------------------------------------------------"

    valid_count = 0
    missing_vtt_count = 0

    items.each_with_index do |item, idx|
      v_id = item["youtube_video_id"]
      vtt = item["vtt_path"]
      t_id = item["transcript_id"]

      exists = File.exist?(vtt)
      if exists
        valid_count += 1
        status_str = "OK (#{item["turn_count"]} turns)"
      else
        missing_vtt_count += 1
        status_str = "MISSING VTT FILE"
      end

      puts "[#{idx + 1}/#{items.size}] Video: #{v_id} | Transcript: #{t_id} | Status: #{status_str}"

      if @options[:upload] && exists
        upload_caption_track(v_id, vtt, t_id)
      end
    end

    puts "======================================================="
    puts "Summary: #{valid_count} ready for sync, #{missing_vtt_count} missing files."
  end

  private

  def upload_caption_track(video_id, vtt_path, transcript_id)
    unless @client && @client.authenticated?
      puts "   ⚠️ Cannot upload #{video_id}: YouTube API not authenticated."
      return
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
    else
      puts "   ⚠️ [#{video_id}] Upload response: #{res.code} - #{res.body[0..120]}"
    end
  rescue StandardError => e
    puts "   ❌ [#{video_id}] Error uploading captions: #{e.message}"
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

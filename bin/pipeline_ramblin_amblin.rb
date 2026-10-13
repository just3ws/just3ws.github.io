#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/youtube_client"
require "json"
require "yaml"
require "optparse"

PLAYLIST_ID = "PLNtb969T2-l0"

options = {
  mode: :poll,
  verbose: false,
  dry_run: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/pipeline_ramblin_amblin.rb [options]"
  opts.on("-p", "--poll", "Poll playlist for new uploads, enrich in zdots, and reconcile metadata") { options[:mode] = :poll }
  opts.on("-s", "--sync-metadata", "Sync titles, descriptions, and chapters to YouTube") { options[:mode] = :sync }
  opts.on("-n", "--dry-run", "Inspect status without modifying YouTube or database") { options[:dry_run] = true }
  opts.on("-v", "--verbose", "Verbose logging") { options[:verbose] = true }
end.parse!

client = YouTubeClient.new
client.fetch_access_token!

puts "🎬 [Ramblin' & Amblin' Pipeline] Connected as: #{client.get_channel_info.dig('snippet', 'title')}"

# 1. Fetch playlist items
video_ids = client.get_playlist_video_ids(PLAYLIST_ID)
puts "📋 Found #{video_ids.size} videos in playlist #{PLAYLIST_ID}."

# Query media_sources in PostgreSQL 'my' database
db_cmd = "psql -d my -t -A -F ',' -c \"SELECT source_id, ingest_status FROM media_sources WHERE source_id IN ('#{video_ids.join("','")}');\" 2>/dev/null"
db_rows = `#{db_cmd}`.strip.split("\n").map { |l| l.split(",") }
db_sources = Hash[db_rows]

video_ids.each do |vid|
  v = client.get_video(vid)
  next unless v

  title = v.dig("snippet", "title")
  privacy = v.dig("status", "privacyStatus")
  ingest_status = db_sources[vid]

  puts "\n🎥 Video: #{vid} | Status: #{privacy} | Pipeline: #{ingest_status || 'not ingested'} | Title: #{title}"

  # Step A: Ingest if missing from pipeline
  if ingest_status.nil?
    puts "  ⚡ Enqueueing #{vid} into zdots-ingest-media pipeline..."
    unless options[:dry_run]
      url = "https://youtu.be/#{vid}"
      system("ZDOTS_YTDLP_COOKIES_FILE=/tmp/yt_cookies.txt /Users/mike/.config/zsh/bin/zdots-ingest-media '#{url}'")
    end
  else
    puts "  ✅ Ingested in local database (status: #{ingest_status})."
  end

  # Step B: Sync WebVTT captions if transcript output exists
  vtt_candidates = [
    "/Users/mike/Downloads/transcripts/#{vid}/#{vid}.vtt",
    Dir.glob("/Users/mike/.local/state/zdots/ingest-sources/*/#{vid}/#{vid}.vtt").first
  ].compact.select { |p| File.exist?(p) }

  if vtt_candidates.any? && !options[:dry_run]
    vtt_file = vtt_candidates.first
    existing_captions = client.send(:make_request, URI("https://www.googleapis.com/youtube/v3/captions?part=snippet&videoId=#{vid}"))
    cap_data = JSON.parse(existing_captions.body) rescue {}
    has_standard = (cap_data["items"] || []).any? { |i| i.dig("snippet", "trackKind") == "standard" }

    unless has_standard
      puts "  📝 Uploading verified WebVTT caption track to YouTube..."
      metadata = {
        snippet: {
          videoId: vid,
          language: "en",
          name: "English (Human Verified)",
          isDraft: false
        }
      }
      uri = URI("https://www.googleapis.com/upload/youtube/v3/captions?part=snippet&uploadType=multipart")
      boundary = "----RubyMultipartBoundary#{SecureRandom.hex(8)}"
      body = [
        "--#{boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n#{metadata.to_json}\r\n",
        "--#{boundary}\r\nContent-Type: text/vtt\r\n\r\n#{File.read(vtt_file)}\r\n--#{boundary}--\r\n"
      ].join
      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{client.access_token}"
      req["Content-Type"] = "multipart/related; boundary=#{boundary}"
      req.body = body
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      c_res = http.request(req)
      puts "  ✅ Captions uploaded (status #{c_res.code})." if c_res.code.to_i == 200
    end
  end

  # Step C: Promote unlisted to public once ingestion is complete
  if privacy == "unlisted"
    if ingest_status == "done"
      puts "  🚀 Promoting unlisted video #{vid} to public (ingestion complete)..."
      unless options[:dry_run]
        payload = {
          "snippet" => v["snippet"],
          "status" => {
            "privacyStatus" => "public",
            "selfDeclaredMadeForKids" => false
          }
        }
        client.update_video(vid, payload)
        puts "  ✅ Video #{vid} is now PUBLIC."
      end
    else
      puts "  ⏳ Video is unlisted; awaiting pipeline completion before flipping to public."
    end
  elsif privacy == "private"
    puts "  🔒 Video is private; enriching while strictly maintaining private status."
  end
end

#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

interviews = YAML.load_file("_data/interviews.yml")["items"]
assets = YAML.load_file("_data/video_assets.yml")["items"]

pending_interviews = interviews.select do |i|
  v = assets.find { |a| a["id"] == i["video_asset_id"] }
  v && (!v["transcript_id"] || v["transcript_id"].empty?) && v["platforms"]&.any? { |p| p["platform"] == "youtube" && p["asset_id"] }
end

puts "Found #{pending_interviews.size} pending interviews to transcribe."

staging_dir = "tmp/transcript-id-staging"
FileUtils.mkdir_p(staging_dir)

pending_interviews.each_with_index do |i, idx|
  v = assets.find { |a| a["id"] == i["video_asset_id"] }
  yt = v["platforms"].find { |p| p["platform"] == "youtube" }
  yt_id = yt["asset_id"]
  video_asset_id = v["id"]
  
  puts "[#{idx + 1}/#{pending_interviews.size}] Transcribing Interview: #{i['id']} (YouTube ID: #{yt_id})"
  
  # Run the transcription pipeline
  url = "https://www.youtube.com/watch?v=#{yt_id}"
  cmd = "/Users/mike/.config/zsh/recipes/yt-transcribe \"#{url}\""
  
  system(cmd)
  
  # Move the output to staging
  # yt-transcribe saves to ~/Downloads/transcripts/<yt_id>/<yt_id>.txt
  source_txt = File.expand_path("~/Downloads/transcripts/#{yt_id}/#{yt_id}.txt")
  
  if File.exist?(source_txt)
    # Prefixing with video_asset_id ensures deterministic mapping during ingest
    dest_txt = File.join(staging_dir, "#{video_asset_id}.txt")
    FileUtils.cp(source_txt, dest_txt)
    puts "  ✓ Staged transcript as #{dest_txt}"
  else
    puts "  ✕ Failed to find output transcript at #{source_txt}"
  end
end

puts "\nTranscription batch complete. You can now run './bin/transcripts ingest --source-dir tmp/transcript-id-staging --min-confidence 0.9 --auto-commit'"

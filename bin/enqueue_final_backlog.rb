#!/usr/bin/env ruby
require 'yaml'

assets = YAML.load_file("_data/video_assets.yml")["items"]
interviews = YAML.load_file("_data/interviews.yml")["items"]
scmc = YAML.load_file("_data/scmc_videos.yml")["items"]
oneoffs = YAML.load_file("_data/oneoff_videos.yml")["items"]
transcripts_dir = "_data/transcripts"

all_items = interviews + scmc + oneoffs
missing = all_items.select do |v|
  a = assets.find { |a| a["id"] == v["video_asset_id"] }
  !(a && a["transcript_id"] && File.exist?(File.join(transcripts_dir, "#{a["transcript_id"]}.yml")))
end

puts "Found #{missing.size} items missing transcripts."

missing.each_with_index do |v, idx|
  video_asset_id = v["video_asset_id"]
  asset = assets.find { |a| a["id"] == video_asset_id }
  
  unless asset
    puts "[#{idx + 1}/#{missing.size}] Skip: Asset not found: #{video_asset_id}"
    next
  end

  # Find YouTube ID
  yt = asset["platforms"]&.find { |p| p["platform"] == "youtube" }
  yt_id = yt ? yt["asset_id"] : nil
  
  # Fallback to Vimeo if no YouTube
  unless yt_id
    vim = asset["platforms"]&.find { |p| p["platform"] == "vimeo" }
    yt_id = vim ? vim["asset_id"] : nil
    platform = "vimeo"
  else
    platform = "youtube"
  end

  unless yt_id
    puts "[#{idx + 1}/#{missing.size}] Skip: No video ID for asset: #{video_asset_id}"
    next
  end

  url = platform == "youtube" ? "https://www.youtube.com/watch?v=#{yt_id}" : "https://vimeo.com/#{yt_id}"
  
  puts "[#{idx + 1}/#{missing.size}] Enqueuing #{v["collection"] || "Archive"}: #{video_asset_id} (#{url})"
  
  payload = %Q{{"url": "#{url}", "video_asset_id": "#{video_asset_id}"}}
  cmd = "zdots-ctx enqueue transcription '#{payload}'"
  
  system(cmd)
end

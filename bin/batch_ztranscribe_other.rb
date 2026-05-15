#!/usr/bin/env ruby
require 'yaml'

interviews = YAML.load_file("_data/interviews.yml")["items"].map { |i| i["video_asset_id"] }
assets = YAML.load_file("_data/video_assets.yml")["items"]

other_pending = assets.select do |v|
  !interviews.include?(v["id"]) && 
  (!v["transcript_id"] || v["transcript_id"].empty?) && 
  v["platforms"]&.any? { |p| p["platform"] == "youtube" && p["asset_id"] }
end

puts "Found #{other_pending.size} other videos to transcribe."

other_pending.each_with_index do |v, idx|
  yt = v["platforms"].find { |p| p["platform"] == "youtube" }
  yt_id = yt["asset_id"]
  video_asset_id = v["id"]
  
  puts "[#{idx + 1}/#{other_pending.size}] Enqueuing Archive Video: #{video_asset_id} (YouTube ID: #{yt_id})"
  
  url = "https://www.youtube.com/watch?v=#{yt_id}"
  payload = %Q{{"url": "#{url}", "video_asset_id": "#{video_asset_id}"}}
  cmd = "zdots-ctx enqueue transcription '#{payload}'"
  
  system(cmd)
end

puts "\nEnqueuing complete."
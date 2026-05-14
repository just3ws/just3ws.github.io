#!/usr/bin/env ruby
require 'yaml'

interviews = YAML.load_file("_data/interviews.yml")["items"]
assets = YAML.load_file("_data/video_assets.yml")["items"]

pending_interviews = interviews.select do |i|
  v = assets.find { |a| a["id"] == i["video_asset_id"] }
  v && (!v["transcript_id"] || v["transcript_id"].empty?) && v["platforms"]&.any? { |p| p["platform"] == "youtube" && p["asset_id"] }
end

puts "Found #{pending_interviews.size} pending interviews to transcribe."

pending_interviews.each_with_index do |i, idx|
  v = assets.find { |a| a["id"] == i["video_asset_id"] }
  yt = v["platforms"].find { |p| p["platform"] == "youtube" }
  yt_id = yt["asset_id"]
  video_asset_id = v["id"]
  
  puts "[#{idx + 1}/#{pending_interviews.size}] Enqueuing Interview: #{i['id']} (YouTube ID: #{yt_id})"
  
  url = "https://www.youtube.com/watch?v=#{yt_id}"
  payload = %Q{{"url": "#{url}", "video_asset_id": "#{video_asset_id}"}}
  cmd = "zdots-ctx enqueue transcription '#{payload}'"
  
  system(cmd)
end

puts "\nEnqueuing complete. Run 'zdots-ctx worker --type transcription' to process the queue."

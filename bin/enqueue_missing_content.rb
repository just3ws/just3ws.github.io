#!/usr/bin/env ruby
require 'yaml'

assets = YAML.load_file("_data/video_assets.yml")["items"]
missing = assets.select do |a| 
  t_id = a["transcript_id"]
  next false if t_id.nil? || t_id.empty?
  path = "_data/transcripts/#{t_id}.yml"
  !File.exist?(path) || (YAML.load_file(path)["content"] || "").strip.empty?
end

puts "Found #{missing.size} assets with missing transcript content."

missing.each_with_index do |v, idx|
  yt = v["platforms"]&.find { |p| p["platform"] == "youtube" }
  unless yt && yt["asset_id"]
    puts "[#{idx + 1}/#{missing.size}] Skip: No YouTube ID for asset: #{v['id']}"
    next
  end

  yt_id = yt["asset_id"]
  video_asset_id = v["id"]
  
  # Check if already in queue
  exists = system(%Q{psql "${DATABASE_URL}" -X -t -A -q -c "SELECT 1 FROM jobs WHERE payload::text LIKE '%#{video_asset_id}%' LIMIT 1;" | grep 1})
  if exists
    puts "[#{idx + 1}/#{missing.size}] Skip: Already enqueued: #{video_asset_id}"
    next
  end

  puts "[#{idx + 1}/#{missing.size}] Enqueuing Missing Content: #{video_asset_id} (YouTube ID: #{yt_id})"
  
  url = "https://www.youtube.com/watch?v=#{yt_id}"
  payload = %Q{{"url": "#{url}", "video_asset_id": "#{video_asset_id}"}}
  cmd = "zdots-ctx enqueue transcription '#{payload}'"
  
  system(cmd)
end

#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

assets = YAML.load_file("_data/video_assets.yml")["items"]
staging_dir = "tmp/transcript-id-staging"
FileUtils.mkdir_p(staging_dir)

staged_count = 0
Dir.glob(File.expand_path("~/Downloads/transcripts/*/*.txt")).each do |txt_file|
  yt_id = File.basename(txt_file, ".txt")
  
  # Find the corresponding video_asset_id
  asset = assets.find do |a|
    a["platforms"]&.any? { |p| p["platform"] == "youtube" && p["asset_id"] == yt_id }
  end
  
  if asset
    video_asset_id = asset["id"]
    dest_txt = File.join(staging_dir, "#{video_asset_id}.txt")
    
    unless File.exist?(dest_txt)
      FileUtils.cp(txt_file, dest_txt)
      puts "Staged: #{yt_id} -> #{video_asset_id}.txt"
      staged_count += 1
    end
  end
end

puts "Staged #{staged_count} new transcripts."

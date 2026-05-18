#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

assets = YAML.load_file("_data/video_assets.yml")["items"]
staging_dir = "tmp/transcript-id-staging"
FileUtils.mkdir_p(staging_dir)

staged_count = 0
Dir.glob(File.expand_path("~/Downloads/transcripts/*/*.txt")).each do |txt_file|
  video_id = File.basename(txt_file, ".txt")
  
  # Find the corresponding video_asset_id (check both YouTube and Vimeo)
  asset = assets.find do |a|
    a["platforms"]&.any? { |p| (p["platform"] == "youtube" || p["platform"] == "vimeo") && p["asset_id"] == video_id }
  end
  
  if asset
    video_asset_id = asset["id"]
    dest_txt = File.join(staging_dir, "#{video_asset_id}.txt")
    
    unless File.exist?(dest_txt)
      FileUtils.cp(txt_file, dest_txt)
      puts "Staged: #{video_id} -> #{video_asset_id}.txt"
      staged_count += 1
    end
  else
    # Fallback: check if the filename itself is a video_asset_id
    asset_by_id = assets.find { |a| a["id"] == video_id }
    if asset_by_id
        dest_txt = File.join(staging_dir, "#{video_id}.txt")
        unless File.exist?(dest_txt)
          FileUtils.cp(txt_file, dest_txt)
          puts "Staged by ID: #{video_id}"
          staged_count += 1
        end
    end
  end
end

puts "Staged #{staged_count} new transcripts."

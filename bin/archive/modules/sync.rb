#!/usr/bin/env ruby
require 'yaml'
require 'time'

# --- SYNC MODULE (Load) ---
# Syncs transcript-level metadata back to global site data files.

id = ARGV[0]
path = "_data/transcripts/#{id}.yml"

unless File.exist?(path)
  puts "ERROR: File not found #{path}"
  exit 1
end

data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue nil
unless data
  puts "ERROR: YAML parse error for #{id}"
  exit 1
end

# Check for required fields before syncing
unless data["summary"]
  puts "ERROR: Item not enriched (missing summary)"
  exit 1
end

# 1. Update _data/interviews.yml
interviews_path = "_data/interviews.yml"
interviews = YAML.load_file(interviews_path)
item = interviews["items"].find { |i| i["id"] == id }

if item
  # Update topic/tags if enriched topics exist
  if data["topics"] && data["topics"].any?
     item["tags"] = (item["tags"] + data["topics"]).uniq.first(10)
  end
  
  # We could also sync summary here if we had a summary field in interviews.yml
  # item["summary"] = data["summary"] 
  
  File.write(interviews_path, interviews.to_yaml)
end

# 2. Update _data/video_assets.yml
assets_path = "_data/video_assets.yml"
assets = YAML.load_file(assets_path)
asset = assets["items"].find { |a| a["id"] == id || a["interview_id"] == id }

if asset
  # Use AI summary for video description if it was empty or legacy
  if asset["description"].nil? || asset["description"].length < 50
    asset["description"] = data["summary"]
  end
  
  File.write(assets_path, assets.to_yaml)
end

puts "SUCCESS"

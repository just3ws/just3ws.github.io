#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'time'
require 'shellwords'
require 'tempfile'

# --- INDEX MODULE (Load/Transform) ---
# Indexes enriched transcripts into the zdots-ctx vector database.

id = ARGV[0]
force = ARGV.include?("--force")
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

# Check for idempotency: skip if already indexed and not forced
if data["indexed_at"] && !force
  puts "SKIPPED"
  exit 0
end

unless data["summary"] && data["insights"]
  puts "ERROR: Item not enriched (missing summary/insights)"
  exit 1
end

# Prepare Lesson Data
content = data["summary"].to_s
content << "\n\nCRITICAL INSIGHTS:\n"
data["insights"].each do |insight|
  content << "- #{insight['statement']}\n"
end

# Get Context
interviews = YAML.load_file("_data/interviews.yml")["items"]
metadata = interviews.find { |i| i["id"] == id } || {}
context = "Technical Interview: #{metadata['title']}"

# Prepare Tags
tags_arr = ["interview", "archive"]
tags_arr << (metadata["conference"] || "general").downcase.gsub(/\s+/, "-")
tags_arr << (Array(metadata["interviewees"]).first || "guest").downcase.gsub(/\s+/, "-")
tags_arr += Array(data["topics"]).first(3)
tags = tags_arr.uniq.join(" ")

# --- 1. Add Lesson ---
add_cmd = "zdots-ctx add-lesson #{Shellwords.escape(content)} #{Shellwords.escape(context)} #{Shellwords.escape(tags)}"
output = `export DATABASE_URL=postgresql:///my && export PSQLRC=/dev/null && #{add_cmd} 2>&1`

if $?.success?
  # --- 2. Get the new lesson ID ---
  lesson_id = `export DATABASE_URL=postgresql:///my && export PSQLRC=/dev/null && psql -d my -t -A -c "SELECT id FROM lessons ORDER BY created_at DESC LIMIT 1"`.strip
  
  if lesson_id && !lesson_id.empty?
    # --- 3. Enqueue Embedding ---
    embed_payload = {
      table: "lessons",
      id: lesson_id,
      text: content
    }.to_json
    
    enqueue_cmd = "zdots-ctx enqueue embed #{Shellwords.escape(embed_payload)} 10"
    output = `export DATABASE_URL=postgresql:///my && export PSQLRC=/dev/null && #{enqueue_cmd} 2>&1`
    
    if $?.success?
      data["indexed_at"] = Time.now.iso8601
      data["zdots_lesson_id"] = lesson_id
      File.write(path, data.to_yaml)
      puts "SUCCESS"
    else
      puts "ERROR: Embedding enqueue failed: #{output.strip}"
      exit 1
    end
  else
    puts "ERROR: Could not retrieve lesson ID"
    exit 1
  end
else
  puts "ERROR: add-lesson failed: #{output.strip}"
  exit 1
end

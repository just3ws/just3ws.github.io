#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'time'
require 'open3'

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

def run_zdots_ctx(*args)
  env = {
    "PATH" => "#{File.expand_path('~/.local/share/mise/shims')}:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin",
    "HOME" => ENV["HOME"] || File.expand_path("~"),
    "ZDOTDIR" => File.expand_path("~/.config/zsh"),
    "DATABASE_URL" => "postgresql:///my",
    "PSQLRC" => "/dev/null"
  }
  zsh_dir = File.expand_path("~/.config/zsh")
  
  output, status = Open3.capture2e(env, "bundle", "exec", "./bin/zdots-ctx", *args, chdir: zsh_dir)
  [status.success?, output]
end

# --- 1. Add Lesson ---
success, output = run_zdots_ctx("add-lesson", content, context, tags)

if success
  # --- 2. Get the new lesson ID ---
  lesson_id = `export DATABASE_URL=postgresql:///my && export PSQLRC=/dev/null && psql -d my -t -A -c "SELECT id FROM lessons ORDER BY created_at DESC LIMIT 1"`.strip
  
  if lesson_id && !lesson_id.empty?
    # --- 3. Enqueue Embedding ---
    embed_payload = {
      table: "lessons",
      id: lesson_id,
      text: content
    }.to_json
    
    enqueue_success, enqueue_output = run_zdots_ctx("enqueue", "embed", embed_payload, "10")
    
    if enqueue_success
      data["indexed_at"] = Time.now.iso8601
      data["zdots_lesson_id"] = lesson_id
      File.write(path, data.to_yaml)
      puts "SUCCESS"
    else
      puts "ERROR: Embedding enqueue failed: #{enqueue_output.strip}"
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

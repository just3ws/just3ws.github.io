#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

# This script generates a single prompt for copy-pasting into ChatGPT/Codex
# and saves it to backlog/audit/outbox/<slug>.md

slug = ARGV[0]
if slug.nil?
  puts "Usage: ruby bin/prepare_audit_prompt.rb <slug>"
  exit 1
end

# 1. Load Data
interview = YAML.safe_load(File.read('_data/interviews.yml'), permitted_classes: [Date, Time], aliases: true)['items'].find { |i| i['id'] == slug }
unless interview
  puts "Error: Interview not found: #{slug}"
  exit 1
end

video_asset = YAML.safe_load(File.read('_data/video_assets.yml'), permitted_classes: [Date, Time], aliases: true)['items'].find { |v| v['id'] == interview['video_asset_id'] }
unless video_asset
  puts "Error: Video asset not found for: #{slug}"
  exit 1
end

transcript_id = video_asset['transcript_id']
transcript_path = "_data/transcripts/#{transcript_id}.yml"
unless File.exist?(transcript_path)
  puts "Error: Transcript file not found: #{transcript_path}"
  exit 1
end

transcript_payload = YAML.safe_load(File.read(transcript_path), permitted_classes: [Date, Time], aliases: true)
content = transcript_payload['content']

# 2. Load Forensic Prompt
processor_file = 'src/generators/transcript_processor.rb'
unless File.exist?(processor_file)
  puts "Error: Processor file not found: #{processor_file}"
  exit 1
end
system_prompt = File.read(processor_file).match(/SYSTEM_PROMPT = <<~PROMPT\n(.*?)\n\s+PROMPT/m)[1]

# 3. Construct Output
out_path = "backlog/audit/outbox/#{slug}.md"
File.open(out_path, 'w') do |f|
  f.puts "### SYSTEM ROLE & INSTRUCTIONS"
  f.puts system_prompt
  f.puts "\n### INTERVIEW METADATA"
  f.puts interview.to_yaml
  f.puts "\n### RAW TRANSCRIPT"
  f.puts content
end

puts "Prompt generated for #{slug} at #{out_path}"

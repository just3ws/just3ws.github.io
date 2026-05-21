#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

# --- INGEST MODULE ---
# Checks for raw text files in staging and creates the initial YAML.

id = ARGV[0]
force = ARGV.include?("--force")
dest_path = "_data/transcripts/#{id}.yml"

if File.exist?(dest_path) && !force
  puts "SKIPPED"
  exit 0
end

# Find source file in staging
source_dir = "tmp/transcript-id-staging"
source_file = Dir.glob("#{source_dir}/#{id}*").first

unless source_file
  puts "ERROR: No staged source found for #{id}"
  exit 1
end

content = File.read(source_file)
# Minimal YAML structure
data = {
  "content" => content,
  "ingested_at" => Time.now.iso8601
}

File.write(dest_path, data.to_yaml)
puts "SUCCESS"

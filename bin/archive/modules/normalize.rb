#!/usr/bin/env ruby
require 'yaml'

# --- NORMALIZE MODULE ---
# Handles spelling, branding, and text cleanup.

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

# Check for idempotency: if already normalized and not forced, skip.
if data["normalized_at"] && !force
  puts "SKIPPED"
  exit 0
end

# Apply the rules (This module uses the existing rule engine)
RULES_SCRIPT = "bin/apply_perfect_transcript_rules.rb"
`ruby #{RULES_SCRIPT} #{path}`

if $?.success?
  # Mark as normalized
  data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)
  data["normalized_at"] = Time.now.iso8601
  File.write(path, data.to_yaml)
  puts "SUCCESS"
else
  puts "ERROR: Normalization failed"
  exit 1
end

#!/usr/bin/env ruby
require 'yaml'

# --- STRUCTURE MODULE ---
# Handles back-and-forth dialogue detection and turns.

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

# Check for idempotency: if already structured (more than 1 turn) and not forced, skip.
if data["turns"] && data["turns"].size > 1 && !force
  puts "SKIPPED"
  exit 0
end

# Apply the structure (Uses the heuristic engine)
STRUCT_SCRIPT = "bin/structure_transcript_heuristics.rb"
# Note: For high-fidelity, we might call forensic_restructure.rb instead,
# but heuristics is safer for bulk batch processing.
`ruby #{STRUCT_SCRIPT} #{path}`

if $?.success?
  puts "SUCCESS"
else
  puts "ERROR: Structuring failed"
  exit 1
end

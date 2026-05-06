require 'yaml'
require 'fileutils'

slug = ARGV[0]
tmp_file = ARGV[1]

if slug.nil? || tmp_file.nil?
  puts "Usage: ruby bin/ingest_audit.rb <slug> <tmp_file_path>"
  exit 1
end

unless File.exist?(tmp_file)
  puts "Error: Temp file not found: #{tmp_file}"
  exit 1
end

# 1. Load Interview & Asset metadata
interviews = YAML.safe_load(File.read('_data/interviews.yml'), permitted_classes: [Date, Time], aliases: true)
interview = interviews['items'].find { |i| i['id'] == slug }
unless interview
  puts "Error: Interview not found: #{slug}"
  exit 1
end

video_assets = YAML.safe_load(File.read('_data/video_assets.yml'), permitted_classes: [Date, Time], aliases: true)
video_asset = video_assets['items'].find { |v| v['id'] == interview['video_asset_id'] }
unless video_asset
  puts "Error: Video asset not found for: #{slug}"
  exit 1
end

transcript_id = video_asset['transcript_id']
transcript_path = "_data/transcripts/#{transcript_id}.yml"

# 2. Load audit data (manual fix for common issues)
raw = File.read(tmp_file)
raw.gsub!('“', '"')
raw.gsub!('”', '"')
raw.gsub!('‘', "'")
raw.gsub!('’', "'")
# Convert markdown bullets (* ) to YAML list items (- )
raw.gsub!(/^(\s*)\* /, "\\1- ")

begin
  audit_data = YAML.safe_load(raw)
rescue => e
  puts "YAML Parse Error: #{e.message}"
  exit 1
end

# 3. Save
transcript_payload = YAML.safe_load(File.read(transcript_path), permitted_classes: [Date, Time], aliases: true)
transcript_payload['speaker_map'] = audit_data['speaker_map']
transcript_payload['turns'] = audit_data['turns']
transcript_payload['insights'] = audit_data['insights']
transcript_payload['youtube'] = audit_data['youtube']

File.write(transcript_path, transcript_payload.to_yaml)
puts "Successfully ingested audit for #{slug} into #{transcript_path}"

# 4. Final Cleanup
archive_dir = "backlog/audit/archive"
FileUtils.mkdir_p(archive_dir)
# Archive both the original and the fixed version if it exists
FileUtils.mv(tmp_file, File.join(archive_dir, "#{slug}-#{Time.now.to_i}.yml"))

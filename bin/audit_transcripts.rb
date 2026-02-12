#!/usr/bin/env ruby
require "yaml"
require "date"
require "set"

ROOT = File.expand_path("..", __dir__)
ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")

def load_assets(path)
  data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
  data["items"] || []
end

def load_transcript(transcript_id)
  path = File.join(TRANSCRIPTS_DIR, "#{transcript_id}.yml")
  return [nil, path] unless File.exist?(path)

  parsed = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
  [parsed, path]
end

def blank?(value)
  value.nil? || value.to_s.strip.empty?
end

assets = load_assets(ASSETS_PATH)
transcript_files = Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort
transcript_ids_from_files = transcript_files.map { |p| File.basename(p, ".yml") }.to_set

assets_with_transcript_id = assets.select { |a| !blank?(a["transcript_id"]) }
used_transcript_ids = assets_with_transcript_id.map { |a| a["transcript_id"].to_s.strip }.to_set

missing_files = []
missing_content = []
invalid_files = []

assets_with_transcript_id.each do |asset|
  asset_id = asset["id"] || "<missing-id>"
  transcript_id = asset["transcript_id"].to_s.strip
  transcript, transcript_path = load_transcript(transcript_id)

  if transcript.nil?
    missing_files << [asset_id, transcript_id, transcript_path]
    next
  end

  unless transcript.is_a?(Hash)
    invalid_files << [asset_id, transcript_id, transcript_path, "invalid YAML structure"]
    next
  end

  if blank?(transcript["content"])
    missing_content << [asset_id, transcript_id, transcript_path]
  end
end

orphan_files = (transcript_ids_from_files - used_transcript_ids).to_a.sort
duplicate_usage = assets_with_transcript_id
  .group_by { |a| a["transcript_id"].to_s.strip }
  .select { |transcript_id, rows| !blank?(transcript_id) && rows.size > 1 }

puts "Transcript Audit"
puts "assets_total=#{assets.size}"
puts "assets_with_transcript_id=#{assets_with_transcript_id.size}"
puts "unique_transcript_ids_used=#{used_transcript_ids.size}"
puts "transcript_files=#{transcript_ids_from_files.size}"
puts "missing_transcript_files=#{missing_files.size}"
puts "missing_transcript_content=#{missing_content.size}"
puts "invalid_transcript_files=#{invalid_files.size}"
puts "orphan_transcript_files=#{orphan_files.size}"
puts "duplicate_transcript_id_usage=#{duplicate_usage.size}"

unless missing_files.empty?
  puts "\nMissing transcript files:"
  missing_files.each do |asset_id, transcript_id, transcript_path|
    puts "  - asset=#{asset_id} transcript_id=#{transcript_id} expected=#{transcript_path}"
  end
end

unless missing_content.empty?
  puts "\nTranscript files missing content:"
  missing_content.each do |asset_id, transcript_id, transcript_path|
    puts "  - asset=#{asset_id} transcript_id=#{transcript_id} file=#{transcript_path}"
  end
end

unless invalid_files.empty?
  puts "\nInvalid transcript files:"
  invalid_files.each do |asset_id, transcript_id, transcript_path, message|
    puts "  - asset=#{asset_id} transcript_id=#{transcript_id} file=#{transcript_path} error=#{message}"
  end
end

unless orphan_files.empty?
  puts "\nOrphan transcript files (not referenced by any asset):"
  orphan_files.each do |transcript_id|
    puts "  - #{transcript_id}"
  end
end

unless duplicate_usage.empty?
  puts "\nDuplicate transcript usage (shared transcript_id across assets):"
  duplicate_usage.each do |transcript_id, rows|
    asset_ids = rows.map { |r| r["id"] }.compact.sort
    puts "  - transcript_id=#{transcript_id} assets=#{asset_ids.join(',')}"
  end
end

if missing_files.empty? && missing_content.empty? && invalid_files.empty?
  puts "\nTranscript audit passed."
  exit 0
end

warn "\nTranscript audit failed."
exit 1

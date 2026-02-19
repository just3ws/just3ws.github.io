#!/usr/bin/env ruby
require "yaml"
require "json"
require "fileutils"
require "optparse"
require "open3"
require "time"
require "date"

ROOT = File.expand_path("..", __dir__)
IMPORTER = File.join(ROOT, "bin", "import_transcripts_from_outbox.rb")
ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
DEFAULT_SOURCE_DIR = "/Volumes/Dock_1TB/vimeo/outbox"
DEFAULT_OUTPUT_DIR = File.join(ROOT, "tmp", "transcript-id-staging")
DEFAULT_REPORT_DIR = File.join(ROOT, "tmp")

options = {
  source_dir: DEFAULT_SOURCE_DIR,
  output_dir: DEFAULT_OUTPUT_DIR,
  report_dir: DEFAULT_REPORT_DIR,
  min_confidence: 0.8,
  clean_output: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby ./bin/prepare_transcript_id_staging.rb [options]"
  opts.on("--source-dir PATH", "Directory containing transcript files (default: #{DEFAULT_SOURCE_DIR})") { |v| options[:source_dir] = v }
  opts.on("--output-dir PATH", "Directory to write ID-suffixed staged files (default: #{DEFAULT_OUTPUT_DIR})") { |v| options[:output_dir] = v }
  opts.on("--report-dir PATH", "Directory for intermediate report output (default: #{DEFAULT_REPORT_DIR})") { |v| options[:report_dir] = v }
  opts.on("--min-confidence FLOAT", Float, "Only stage mapped files at or above confidence (default: 0.8)") { |v| options[:min_confidence] = v }
  opts.on("--clean-output", "Delete files in output directory before staging") { options[:clean_output] = true }
end.parse!

unless Dir.exist?(options[:source_dir])
  warn "Source directory does not exist: #{options[:source_dir]}"
  exit 1
end

import_cmd = [
  IMPORTER,
  "--source-dir", options[:source_dir],
  "--report-dir", options[:report_dir],
  "--min-confidence", options[:min_confidence].to_s
]

stdout_str, stderr_str, status = Open3.capture3(*import_cmd)
$stdout.print(stdout_str)
$stderr.print(stderr_str)
unless status.success?
  warn "Failed to generate transcript mapping report"
  exit status.exitstatus || 1
end

report_path = File.join(options[:report_dir], "transcript-import-report.json")
unless File.exist?(report_path)
  warn "Expected report file not found: #{report_path}"
  exit 1
end

report = JSON.parse(File.read(report_path))
assets_data = YAML.safe_load(File.read(ASSETS_PATH), permitted_classes: [Date, Time], aliases: true) || {}
assets = assets_data["items"] || []
assets_by_id = assets.each_with_object({}) { |asset, memo| memo[asset["id"]] = asset }

FileUtils.mkdir_p(options[:output_dir])
if options[:clean_output]
  Dir.glob(File.join(options[:output_dir], "*"), File::FNM_DOTMATCH).each do |path|
    next if [".", ".."].include?(File.basename(path))

    FileUtils.rm_rf(path)
  end
end

def choose_platform_id(asset, mapped)
  details = mapped["details"] || {}
  explicit_platform = details["platform"].to_s
  explicit_asset_id = details["asset_id"].to_s
  if !explicit_platform.empty? && !explicit_asset_id.empty?
    return [explicit_platform, explicit_asset_id]
  end

  platforms = Array(asset["platforms"])

  vimeo = platforms.find do |platform|
    platform["platform"].to_s == "vimeo" && platform["asset_id"].to_s.match?(/\A\d{6,12}\z/)
  end
  return ["vimeo", vimeo["asset_id"].to_s] if vimeo

  youtube = platforms.find do |platform|
    platform["platform"].to_s == "youtube" && platform["asset_id"].to_s.match?(/\A[A-Za-z0-9_-]{11}\z/)
  end
  return ["youtube", youtube["asset_id"].to_s] if youtube

  first = platforms.find { |platform| !platform["asset_id"].to_s.strip.empty? }
  return [first["platform"].to_s, first["asset_id"].to_s] if first

  ["", ""]
end

def safe_ext(path)
  ext = File.extname(path).downcase
  return ".txt" if ext.empty?

  ext
end

min_confidence = options[:min_confidence].to_f
entries = Array(report["mapped"])
selected = entries.select do |entry|
  entry["confidence"].to_f >= min_confidence
end

selected.sort_by! do |entry|
  [-entry["confidence"].to_f, -entry["content_length"].to_i, File.basename(entry["file"].to_s)]
end

manifest = []
used_dest = {}
skipped_missing_asset = 0
skipped_missing_source = 0

selected.each do |entry|
  source_file = entry["file"].to_s
  asset_id = entry["asset_id"].to_s
  asset = assets_by_id[asset_id]

  unless asset
    skipped_missing_asset += 1
    next
  end

  unless File.exist?(source_file)
    skipped_missing_source += 1
    next
  end

  platform_name, platform_asset_id = choose_platform_id(asset, entry)
  ext = safe_ext(source_file)

  base_name = if platform_asset_id.empty?
    asset_id
  else
    "#{asset_id}___#{platform_asset_id}"
  end

  dest_name = "#{base_name}#{ext}"
  next if used_dest.key?(dest_name)

  dest_path = File.join(options[:output_dir], dest_name)
  FileUtils.cp(source_file, dest_path)
  used_dest[dest_name] = true

  manifest << {
    "source_file" => source_file,
    "dest_file" => dest_path,
    "dest_name" => dest_name,
    "asset_id" => asset_id,
    "platform" => platform_name,
    "platform_asset_id" => platform_asset_id,
    "confidence" => entry["confidence"],
    "reason" => entry["reason"]
  }
end

manifest_path = File.join(options[:output_dir], "manifest.json")
File.write(manifest_path, JSON.pretty_generate({
  "generated_at" => Time.now.utc.iso8601,
  "source_dir" => options[:source_dir],
  "output_dir" => options[:output_dir],
  "min_confidence" => min_confidence,
  "mapped_candidates" => entries.size,
  "selected_candidates" => selected.size,
  "staged_files" => manifest.size,
  "skipped_missing_asset" => skipped_missing_asset,
  "skipped_missing_source" => skipped_missing_source,
  "items" => manifest
}))

puts "Staging complete"
puts "Output dir: #{options[:output_dir]}"
puts "Staged files: #{manifest.size}"
puts "Manifest: #{manifest_path}"

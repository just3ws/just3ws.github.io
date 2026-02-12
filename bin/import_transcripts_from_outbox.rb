#!/usr/bin/env ruby
require "yaml"
require "date"
require "time"
require "json"
require "fileutils"
require "optparse"
require "set"

ROOT = File.expand_path("..", __dir__)
ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")

DEFAULT_SOURCE_DIR = "/Volumes/Dock_1TB/vimeo/outbox"
DEFAULT_REPORT_DIR = File.join(ROOT, "tmp")

SUPPORTED_EXTENSIONS = %w[.txt .md .srt .vtt]
EXTENSION_PRIORITY = {
  ".txt" => 0,
  ".md" => 1,
  ".vtt" => 2,
  ".srt" => 3
}.freeze

def normalize_text(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, " ").strip
end

def normalize_slug(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
end

def tokenize(value)
  normalize_text(value).split(/\s+/).reject(&:empty?)
end

def jaccard(tokens_a, tokens_b)
  a = tokens_a.to_set
  b = tokens_b.to_set
  return 0.0 if a.empty? || b.empty?

  (a & b).size.to_f / (a | b).size.to_f
end

def blank?(value)
  value.nil? || value.to_s.strip.empty?
end

def load_yaml(path, key:)
  parsed = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
  parsed[key] || []
end

def extract_text(path)
  ext = File.extname(path).downcase
  raw = File.read(path)
  lines = raw.lines.map(&:chomp)

  case ext
  when ".srt"
    cleaned = []
    lines.each do |line|
      next if line.strip.match?(/\A\d+\z/)
      next if line.include?("-->")
      cleaned << line
    end
    cleaned.join("\n").gsub(/\n{3,}/, "\n\n").strip
  when ".vtt"
    cleaned = []
    lines.each_with_index do |line, idx|
      next if idx.zero? && line.strip.start_with?("WEBVTT")
      next if line.strip.match?(/\A\d+\z/)
      next if line.include?("-->")
      next if line.strip.start_with?("NOTE", "STYLE", "REGION")
      cleaned << line
    end
    cleaned.join("\n").gsub(/\n{3,}/, "\n\n").strip
  when ".md", ".txt"
    raw.strip
  else
    ""
  end
end

def extract_explicit_ids(filename)
  base = File.basename(filename, File.extname(filename))
  ids = {
    "vimeo" => [],
    "youtube" => []
  }

  if base =~ /___(\d{6,12})\z/
    ids["vimeo"] << Regexp.last_match(1)
  end
  if base =~ /___([A-Za-z0-9_-]{11})\z/
    ids["youtube"] << Regexp.last_match(1)
  end
  if base =~ /(?:^|[_-])(\d{6,12})\z/
    ids["vimeo"] << Regexp.last_match(1)
  end
  if base =~ /(?:^|[_-])([A-Za-z0-9_-]{11})\z/
    ids["youtube"] << Regexp.last_match(1)
  end

  base.scan(/vimeo[^\d]*(\d{6,12})/i) { |m| ids["vimeo"] << m.first }
  base.scan(/(?:youtube|yt|youtu)[^A-Za-z0-9_-]*([A-Za-z0-9_-]{11})/i) { |m| ids["youtube"] << m.first }
  base.scan(/\bv=([A-Za-z0-9_-]{11})\b/i) { |m| ids["youtube"] << m.first }
  base.scan(/\b(\d{6,12})\b/) { |m| ids["vimeo"] << m.first }
  base.scan(/\b([A-Za-z0-9_-]{11})\b/) do |m|
    token = m.first
    # Keep strict for likely YouTube IDs to avoid over-matching random words.
    next unless token.match?(/[A-Z]/) || token.match?(/[0-9]/)

    ids["youtube"] << token
  end

  ids.transform_values { |v| v.uniq }
end

def first_nonempty(*values)
  values.each do |value|
    return value unless blank?(value)
  end
  nil
end

def map_transcript_file(file_path:, file_text:, assets:, assets_by_id:, interviews_by_id:, platform_index:)
  file_name = File.basename(file_path)
  base_name = File.basename(file_path, File.extname(file_path))
  base_slug = normalize_slug(base_name.tr("_", "-"))
  ids = extract_explicit_ids(file_name)

  # 1) Explicit platform id match
  ids.each do |platform, candidates|
    candidates.each do |platform_asset_id|
      hit = platform_index.dig(platform, platform_asset_id)
      next unless hit

      return {
        "asset_id" => hit["id"],
        "confidence" => 1.0,
        "reason" => "platform_id_match_exact",
        "details" => { "platform" => platform, "asset_id" => platform_asset_id }
      }
    end
  end

  # 2) Exact slug/id match
  if assets_by_id.key?(base_slug)
    return {
      "asset_id" => base_slug,
      "confidence" => 0.98,
      "reason" => "asset_id_slug_match_exact",
      "details" => { "slug" => base_slug }
    }
  end

  # 3) Token similarity match (title/topic/interviewee)
  file_tokens = tokenize(base_name.tr("_", " "))
  return nil if file_tokens.empty?

  scored = assets.map do |asset|
    interview = interviews_by_id[asset["interview_id"].to_s] || {}
    label_text = [
      asset["id"],
      asset["title"],
      asset["topic"],
      interview["title"],
      Array(interview["interviewees"]).join(" ")
    ].join(" ")

    score = jaccard(file_tokens, tokenize(label_text))
    {
      "asset" => asset,
      "score" => score
    }
  end

  best = scored.max_by { |row| row["score"] }
  return nil unless best

  sorted = scored.sort_by { |row| -row["score"] }
  second_score = sorted[1] ? sorted[1]["score"] : 0.0
  margin = best["score"] - second_score

  confidence = if best["score"] >= 0.9
                 0.97
               elsif best["score"] >= 0.8
                 0.9
               elsif best["score"] >= 0.65 && margin >= 0.2
                 0.8
               elsif best["score"] >= 0.55 && margin >= 0.1
                 0.65
               else
                 0.4
               end

  {
    "asset_id" => best["asset"]["id"],
    "confidence" => confidence,
    "reason" => "title_interviewee_similarity",
    "details" => {
      "score" => best["score"].round(4),
      "runner_up_score" => second_score.round(4),
      "margin" => margin.round(4)
    }
  }
end

options = {
  source_dir: DEFAULT_SOURCE_DIR,
  report_dir: DEFAULT_REPORT_DIR,
  apply: false,
  force: false,
  min_confidence: 0.8
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby ./bin/import_transcripts_from_outbox.rb [options]"
  opts.on("--source-dir PATH", "Directory containing transcript files (default: #{DEFAULT_SOURCE_DIR})") { |v| options[:source_dir] = v }
  opts.on("--report-dir PATH", "Directory for import report output (default: #{DEFAULT_REPORT_DIR})") { |v| options[:report_dir] = v }
  opts.on("--apply", "Write transcript files and update _data/video_assets.yml") { options[:apply] = true }
  opts.on("--force", "Overwrite existing transcript files when applying") { options[:force] = true }
  opts.on("--min-confidence FLOAT", Float, "Minimum confidence for auto-apply (default: 0.8)") { |v| options[:min_confidence] = v }
end.parse!

unless Dir.exist?(options[:source_dir])
  warn "Source directory does not exist: #{options[:source_dir]}"
  exit 1
end

assets = load_yaml(ASSETS_PATH, key: "items")
interviews = load_yaml(INTERVIEWS_PATH, key: "items")
assets_by_id = assets.each_with_object({}) { |asset, memo| memo[asset["id"]] = asset }
interviews_by_id = interviews.each_with_object({}) { |interview, memo| memo[interview["id"]] = interview }

platform_index = Hash.new { |h, k| h[k] = {} }
assets.each do |asset|
  Array(asset["platforms"]).each do |platform|
    platform_name = platform["platform"].to_s
    platform_asset_id = platform["asset_id"].to_s
    next if blank?(platform_name) || blank?(platform_asset_id)
    next if platform_index[platform_name].key?(platform_asset_id)

    platform_index[platform_name][platform_asset_id] = asset
  end
end

transcript_paths = Dir.glob(File.join(options[:source_dir], "**", "*"))
  .select { |path| File.file?(path) && SUPPORTED_EXTENSIONS.include?(File.extname(path).downcase) }
  .sort

transcript_paths_by_stem = transcript_paths.group_by { |path| path.sub(/\.[^.]+\z/, "") }
selected_transcript_paths = transcript_paths_by_stem.values.map do |paths|
  paths.min_by do |path|
    ext = File.extname(path).downcase
    [EXTENSION_PRIORITY.fetch(ext, 99), path]
  end
end.sort
duplicate_variant_files = transcript_paths.size - selected_transcript_paths.size

report = {
  "generated_at" => Time.now.utc.iso8601,
  "source_dir" => options[:source_dir],
  "mode" => options[:apply] ? "apply" : "dry-run",
  "min_confidence" => options[:min_confidence],
  "stats" => {
    "discovered_files" => transcript_paths.size,
    "input_files" => selected_transcript_paths.size,
    "duplicate_variant_files" => duplicate_variant_files,
    "mapped" => 0,
    "high_confidence" => 0,
    "low_confidence" => 0,
    "unmapped" => 0,
    "collisions" => 0,
    "written_transcripts" => 0,
    "updated_assets" => 0,
    "skipped_existing_transcript" => 0
  },
  "mapped" => [],
  "low_confidence" => [],
  "unmapped" => [],
  "collisions" => []
}

candidate_mappings = []
transcripts_by_asset = Hash.new { |h, k| h[k] = [] }

selected_transcript_paths.each do |path|
  text = extract_text(path)
  if blank?(text)
    report["unmapped"] << { "file" => path, "reason" => "empty_or_unsupported_content" }
    next
  end

  mapping = map_transcript_file(
    file_path: path,
    file_text: text,
    assets: assets,
    assets_by_id: assets_by_id,
    interviews_by_id: interviews_by_id,
    platform_index: platform_index
  )

  unless mapping
    report["unmapped"] << { "file" => path, "reason" => "no_candidate_match" }
    next
  end

  row = {
    "file" => path,
    "asset_id" => mapping["asset_id"],
    "confidence" => mapping["confidence"],
    "reason" => mapping["reason"],
    "details" => mapping["details"],
    "content_length" => text.length
  }
  candidate_mappings << row
  transcripts_by_asset[mapping["asset_id"]] << row
end

transcripts_by_asset.each do |asset_id, rows|
  next unless rows.size > 1

  sorted = rows.sort_by { |row| [-row["confidence"], row["file"]] }
  winner = sorted.first
  losers = sorted[1..] || []
  report["collisions"] << {
    "asset_id" => asset_id,
    "winner" => winner,
    "losers" => losers
  }
end

collision_losers = report["collisions"].flat_map { |c| c["losers"] }.map { |row| row["file"] }.to_set
selected = candidate_mappings.reject { |row| collision_losers.include?(row["file"]) }

selected.each do |row|
  if row["confidence"] >= options[:min_confidence]
    report["mapped"] << row
  else
    report["low_confidence"] << row
  end
end

report["stats"]["mapped"] = report["mapped"].size
report["stats"]["high_confidence"] = report["mapped"].size
report["stats"]["low_confidence"] = report["low_confidence"].size
report["stats"]["unmapped"] = report["unmapped"].size
report["stats"]["collisions"] = report["collisions"].size

if options[:apply]
  report["mapped"].each do |row|
    file_path = row["file"]
    asset = assets_by_id[row["asset_id"]]
    next unless asset

    text = extract_text(file_path)
    next if blank?(text)

    transcript_id = first_nonempty(asset["transcript_id"], asset["id"])
    transcript_path = File.join(TRANSCRIPTS_DIR, "#{transcript_id}.yml")
    transcript_exists = File.exist?(transcript_path)

    if transcript_exists && !options[:force]
      report["stats"]["skipped_existing_transcript"] += 1
    else
      File.write(transcript_path, { "content" => text }.to_yaml)
      report["stats"]["written_transcripts"] += 1
    end

    if asset["transcript_id"].to_s != transcript_id
      asset["transcript_id"] = transcript_id
      report["stats"]["updated_assets"] += 1
    end
  end

  File.write(ASSETS_PATH, { "items" => assets }.to_yaml)
end

FileUtils.mkdir_p(options[:report_dir])
json_report_path = File.join(options[:report_dir], "transcript-import-report.json")
md_report_path = File.join(options[:report_dir], "transcript-import-report.md")

File.write(json_report_path, JSON.pretty_generate(report))

md_lines = []
md_lines << "# Transcript Import Report"
md_lines << ""
md_lines << "- Generated at: #{report['generated_at']}"
md_lines << "- Source dir: `#{report['source_dir']}`"
md_lines << "- Mode: `#{report['mode']}`"
md_lines << "- Min confidence: `#{report['min_confidence']}`"
md_lines << ""
md_lines << "## Stats"
md_lines << ""
report["stats"].each do |key, value|
  md_lines << "- #{key}: #{value}"
end

md_lines << ""
md_lines << "## High-confidence Mappings"
md_lines << ""
if report["mapped"].empty?
  md_lines << "- None"
else
  report["mapped"].sort_by { |row| [-row["confidence"], row["asset_id"]] }.each do |row|
    md_lines << "- `#{File.basename(row['file'])}` -> `#{row['asset_id']}` (#{row['confidence']}, #{row['reason']})"
  end
end

md_lines << ""
md_lines << "## Low-confidence Mappings (Review Required)"
md_lines << ""
if report["low_confidence"].empty?
  md_lines << "- None"
else
  report["low_confidence"].sort_by { |row| [-row["confidence"], row["asset_id"]] }.each do |row|
    md_lines << "- `#{File.basename(row['file'])}` -> `#{row['asset_id']}` (#{row['confidence']}, #{row['reason']})"
  end
end

md_lines << ""
md_lines << "## Unmapped Files"
md_lines << ""
if report["unmapped"].empty?
  md_lines << "- None"
else
  report["unmapped"].each do |row|
    md_lines << "- `#{File.basename(row['file'])}` (#{row['reason']})"
  end
end

md_lines << ""
md_lines << "## Collisions"
md_lines << ""
if report["collisions"].empty?
  md_lines << "- None"
else
  report["collisions"].each do |collision|
    winner = collision["winner"]
    md_lines << "- asset `#{collision['asset_id']}` winner: `#{File.basename(winner['file'])}` (#{winner['confidence']})"
    collision["losers"].each do |loser|
      md_lines << "  - skipped: `#{File.basename(loser['file'])}` (#{loser['confidence']})"
    end
  end
end

File.write(md_report_path, md_lines.join("\n") + "\n")

puts "Wrote #{json_report_path}"
puts "Wrote #{md_report_path}"
puts "Mode: #{report['mode']}"
puts "Mapped: #{report['stats']['mapped']}, Low-confidence: #{report['stats']['low_confidence']}, Unmapped: #{report['stats']['unmapped']}, Collisions: #{report['stats']['collisions']}"
if options[:apply]
  puts "Applied: written_transcripts=#{report['stats']['written_transcripts']} updated_assets=#{report['stats']['updated_assets']} skipped_existing_transcript=#{report['stats']['skipped_existing_transcript']}"
end

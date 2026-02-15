#!/usr/bin/env ruby

require "yaml"
require "date"
require "optparse"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")

options = { apply: false, verbose: false }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby bin/merge_duplicate_interview_publications.rb [--apply] [--verbose]"
  parser.on("--apply", "Write merged results to canonical YAML files") { options[:apply] = true }
  parser.on("--verbose", "Print each merge decision") { options[:verbose] = true }
end.parse!

MAX_DURATION_DELTA_SECONDS = 5

def normalize(value)
  value.to_s.gsub(/\s+/, " ").strip
end

def present?(value)
  !normalize(value).empty?
end

def interviewee_key(interview)
  names = Array(interview["interviewees"]).map { |name| normalize(name).downcase }.reject(&:empty?).sort
  names.join("|")
end

def general_interview?(interview)
  normalize(interview["community"]).casecmp("General").zero? &&
    normalize(interview["conference"]).empty? &&
    normalize(interview["conference_year"]).empty?
end

def loser_interview?(interview, asset)
  id = normalize(interview["id"])
  return false unless id.start_with?("interview-with-")
  return false unless id.end_with?("-general")
  return false unless asset
  return false if present?(asset["transcript_id"])

  true
end

def platform_fingerprint(platform_entry)
  [
    normalize(platform_entry["platform"]).downcase,
    normalize(platform_entry["asset_id"]),
    normalize(platform_entry["url"])
  ].join("|")
end

def numeric_duration(value)
  return nil if value.nil?
  number = value.to_i
  number.positive? ? number : nil
end

def asset_duration_seconds(asset)
  direct = numeric_duration(asset["duration_seconds"])
  return direct if direct

  platform_durations = Array(asset["platforms"]).map { |platform| numeric_duration(platform["duration_seconds"]) }.compact
  platform_durations.max
end

def duration_compatible?(winner_asset, loser_asset)
  winner_duration = asset_duration_seconds(winner_asset)
  loser_duration = asset_duration_seconds(loser_asset)
  return true if winner_duration.nil? || loser_duration.nil?

  (winner_duration - loser_duration).abs <= MAX_DURATION_DELTA_SECONDS
end

def platform_quality_score(platform_entry, canonical_duration)
  score = 0
  score += 2 if present?(platform_entry["url"])
  score += 1 if present?(platform_entry["embed_url"])
  score += 1 if present?(platform_entry["title_on_platform"])
  score += 1 if present?(platform_entry["thumbnail"])
  score += 1 if present?(platform_entry["description"])

  duration = numeric_duration(platform_entry["duration_seconds"])
  if canonical_duration && duration
    delta = (duration - canonical_duration).abs
    score += 5 if delta <= MAX_DURATION_DELTA_SECONDS
    score -= delta
  elsif duration
    score += 1
  end

  score
end

def dedupe_platforms_by_host!(asset)
  platforms = Array(asset["platforms"])
  return if platforms.empty?

  canonical_duration = asset_duration_seconds(asset)
  grouped = platforms.group_by { |platform| normalize(platform["platform"]).downcase }
  deduped = []

  grouped.each_value do |entries|
    best = entries.max_by { |entry| platform_quality_score(entry, canonical_duration) }
    deduped << best if best
  end

  deduped.sort_by! { |entry| [normalize(entry["platform"]).downcase, normalize(entry["asset_id"]), normalize(entry["url"])] }
  asset["platforms"] = deduped
end

def platform_names(asset)
  Array(asset["platforms"]).map { |platform| normalize(platform["platform"]).downcase }.reject(&:empty?).uniq
end

def strict_duration_match?(asset_a, asset_b)
  duration_a = asset_duration_seconds(asset_a)
  duration_b = asset_duration_seconds(asset_b)
  return false if duration_a.nil? || duration_b.nil?

  (duration_a - duration_b).abs <= MAX_DURATION_DELTA_SECONDS
end

def merge_records!(winner_interview:, winner_asset:, loser_interview:, loser_asset:, interviews:, assets:, metrics:)
  existing_fingerprints = {}
  Array(winner_asset["platforms"]).each do |platform|
    existing_fingerprints[platform_fingerprint(platform)] = true
  end

  Array(loser_asset["platforms"]).each do |platform|
    fingerprint = platform_fingerprint(platform)
    next if existing_fingerprints[fingerprint]

    winner_asset["platforms"] ||= []
    winner_asset["platforms"] << platform
    existing_fingerprints[fingerprint] = true
    metrics[:platforms_appended] += 1
  end

  dedupe_platforms_by_host!(winner_asset)

  %w[source published_date thumbnail thumbnail_local duration_seconds duration_minutes description topic title primary_platform].each do |field|
    metrics[:winner_asset_fields_filled] += 1 if maybe_fill!(winner_asset, field, loser_asset[field])
  end

  winner_asset["tags"] = merge_tags(winner_asset["tags"], loser_asset["tags"])
  winner_asset["transcript_id"] = loser_asset["transcript_id"] if !present?(winner_asset["transcript_id"]) && present?(loser_asset["transcript_id"])

  %w[topic conference conference_year community recorded_date interviewer].each do |field|
    metrics[:winner_interview_fields_filled] += 1 if maybe_fill!(winner_interview, field, loser_interview[field])
  end
  winner_interview["tags"] = merge_tags(winner_interview["tags"], loser_interview["tags"])

  interviews.each do |interview|
    next unless interview["video_asset_id"] == loser_asset["id"]

    interview["video_asset_id"] = winner_asset["id"]
    metrics[:interview_links_repointed] += 1
  end

  assets.each do |asset|
    next unless asset["interview_id"] == loser_interview["id"]

    asset["interview_id"] = winner_interview["id"]
  end
end

def merge_tags(winner_tags, loser_tags)
  merged = []
  Array(winner_tags).each do |tag|
    norm = normalize(tag)
    merged << norm unless norm.empty? || merged.include?(norm)
  end
  Array(loser_tags).each do |tag|
    norm = normalize(tag)
    merged << norm unless norm.empty? || merged.include?(norm)
  end
  merged
end

def maybe_fill!(record, key, value)
  return false unless present?(value)
  return false if present?(record[key])

  record[key] = value
  true
end

def choose_winner(candidates, loser_interview)
  return nil if candidates.empty?
  return candidates.first if candidates.size == 1

  losers_conf = normalize(loser_interview["conference"])
  losers_year = normalize(loser_interview["conference_year"])
  losers_comm = normalize(loser_interview["community"])

  ranked = candidates.sort_by do |entry|
    interview = entry[:interview]
    asset = entry[:asset]
    conf = normalize(interview["conference"])
    year = normalize(interview["conference_year"])
    comm = normalize(interview["community"])

    transcript_pref = present?(asset["transcript_id"]) ? 0 : 1
    conference_match = (!losers_conf.empty? && conf == losers_conf && year == losers_year) ? 0 : 1
    community_match = (!losers_comm.empty? && losers_comm.casecmp("General") != 0 && comm == losers_comm) ? 0 : 1
    general_pref = general_interview?(interview) ? 0 : 1
    interview_with_penalty = normalize(interview["id"]).start_with?("interview-with-") ? 1 : 0

    [transcript_pref, conference_match, community_match, general_pref, interview_with_penalty, normalize(interview["id"])]
  end

  best = ranked.first
  ambiguous = ranked.length > 1 && ranked[0][0..4] == ranked[1][0..4]
  return nil if ambiguous

  best
end

assets_data = Generators::Core::YamlIo.load(ASSETS_PATH)
interviews_data = Generators::Core::YamlIo.load(INTERVIEWS_PATH)
assets = assets_data["items"] || []
interviews = interviews_data["items"] || []

asset_by_id = assets.each_with_object({}) { |asset, memo| memo[asset["id"]] = asset }
interview_by_id = interviews.each_with_object({}) { |interview, memo| memo[interview["id"]] = interview }

winner_pool_by_key = Hash.new { |h, k| h[k] = [] }
interviews.each do |interview|
  asset = asset_by_id[interview["video_asset_id"]]
  next unless asset
  next unless present?(asset["transcript_id"])

  key = interviewee_key(interview)
  next if key.empty?

  winner_pool_by_key[key] << { interview: interview, asset: asset }
end

metrics = {
  candidates: 0,
  merged: 0,
  skipped_no_winner: 0,
  skipped_ambiguous: 0,
  skipped_duration_mismatch: 0,
  strict_candidates: 0,
  strict_merged: 0,
  strict_skipped_no_platform_pair: 0,
  strict_skipped_duration: 0,
  platforms_appended: 0,
  loser_assets_removed: 0,
  loser_interviews_removed: 0,
  interview_links_repointed: 0,
  winner_asset_fields_filled: 0,
  winner_interview_fields_filled: 0
}

loser_asset_ids = []
loser_interview_ids = []

interviews.each do |loser_interview|
  loser_asset = asset_by_id[loser_interview["video_asset_id"]]
  next unless loser_interview?(loser_interview, loser_asset)

  key = interviewee_key(loser_interview)
  next if key.empty?

  metrics[:candidates] += 1
  candidates = winner_pool_by_key[key].reject { |entry| entry[:interview]["id"] == loser_interview["id"] }

  if candidates.empty?
    metrics[:skipped_no_winner] += 1
    next
  end

  winner_entry = choose_winner(candidates, loser_interview)
  if winner_entry.nil?
    metrics[:skipped_ambiguous] += 1
    next
  end

  winner_interview = winner_entry[:interview]
  winner_asset = winner_entry[:asset]

  unless duration_compatible?(winner_asset, loser_asset)
    metrics[:skipped_duration_mismatch] += 1
    next
  end

  merge_records!(
    winner_interview: winner_interview,
    winner_asset: winner_asset,
    loser_interview: loser_interview,
    loser_asset: loser_asset,
    interviews: interviews,
    assets: assets,
    metrics: metrics
  )

  loser_asset_ids << loser_asset["id"]
  loser_interview_ids << loser_interview["id"]
  metrics[:merged] += 1

  if options[:verbose]
    puts "merge: loser=#{loser_interview['id']} (#{loser_asset['id']}) -> winner=#{winner_interview['id']} (#{winner_asset['id']})"
  end
end

# Strict second pass: same person + same conference/year + strict duration match + cross-published pair.
pair_seen = {}
interview_groups = Hash.new { |h, k| h[k] = [] }
interviews.each do |interview|
  asset = asset_by_id[interview["video_asset_id"]]
  next unless asset

  names = interviewee_key(interview)
  conf = normalize(interview["conference"])
  year = normalize(interview["conference_year"])
  next if names.empty? || conf.empty? || year.empty?

  interview_groups[[names, conf, year]] << { interview: interview, asset: asset }
end

interview_groups.each_value do |group|
  next unless group.size > 1

  group.combination(2) do |left, right|
    left_interview = left[:interview]
    right_interview = right[:interview]
    left_asset = left[:asset]
    right_asset = right[:asset]

    next if loser_interview_ids.include?(left_interview["id"]) || loser_interview_ids.include?(right_interview["id"])
    next if loser_asset_ids.include?(left_asset["id"]) || loser_asset_ids.include?(right_asset["id"])

    pair_key = [normalize(left_interview["id"]), normalize(right_interview["id"])].sort.join("|")
    next if pair_seen[pair_key]
    pair_seen[pair_key] = true

    metrics[:strict_candidates] += 1

    left_platforms = platform_names(left_asset)
    right_platforms = platform_names(right_asset)
    unless (left_platforms.include?("youtube") && right_platforms.include?("vimeo")) ||
           (left_platforms.include?("vimeo") && right_platforms.include?("youtube"))
      metrics[:strict_skipped_no_platform_pair] += 1
      next
    end

    unless strict_duration_match?(left_asset, right_asset)
      metrics[:strict_skipped_duration] += 1
      next
    end

    if present?(left_asset["transcript_id"]) && !present?(right_asset["transcript_id"])
      winner_interview = left_interview
      winner_asset = left_asset
      loser_interview = right_interview
      loser_asset = right_asset
    elsif present?(right_asset["transcript_id"]) && !present?(left_asset["transcript_id"])
      winner_interview = right_interview
      winner_asset = right_asset
      loser_interview = left_interview
      loser_asset = left_asset
    else
      left_score = [
        normalize(left_interview["id"]).start_with?("interview-with-") ? 1 : 0,
        present?(left_asset["description"]) ? 0 : 1,
        present?(left_asset["topic"]) ? 0 : 1,
        -Array(left_asset["platforms"]).size,
        normalize(left_interview["id"])
      ]
      right_score = [
        normalize(right_interview["id"]).start_with?("interview-with-") ? 1 : 0,
        present?(right_asset["description"]) ? 0 : 1,
        present?(right_asset["topic"]) ? 0 : 1,
        -Array(right_asset["platforms"]).size,
        normalize(right_interview["id"])
      ]

      if left_score <= right_score
        winner_interview = left_interview
        winner_asset = left_asset
        loser_interview = right_interview
        loser_asset = right_asset
      else
        winner_interview = right_interview
        winner_asset = right_asset
        loser_interview = left_interview
        loser_asset = left_asset
      end
    end

    merge_records!(
      winner_interview: winner_interview,
      winner_asset: winner_asset,
      loser_interview: loser_interview,
      loser_asset: loser_asset,
      interviews: interviews,
      assets: assets,
      metrics: metrics
    )

    loser_asset_ids << loser_asset["id"]
    loser_interview_ids << loser_interview["id"]
    metrics[:merged] += 1
    metrics[:strict_merged] += 1

    if options[:verbose]
      puts "strict-merge: loser=#{loser_interview['id']} (#{loser_asset['id']}) -> winner=#{winner_interview['id']} (#{winner_asset['id']})"
    end
  end
end

loser_asset_ids.uniq!
loser_interview_ids.uniq!

if loser_asset_ids.any?
  assets.reject! { |asset| loser_asset_ids.include?(asset["id"]) }
  metrics[:loser_assets_removed] = loser_asset_ids.size
end

if loser_interview_ids.any?
  interviews.reject! { |interview| loser_interview_ids.include?(interview["id"]) }
  metrics[:loser_interviews_removed] = loser_interview_ids.size
end

# Enforce one publication record per platform per canonical asset.
assets.each { |asset| dedupe_platforms_by_host!(asset) }

if options[:apply]
  Generators::Core::YamlIo.dump(ASSETS_PATH, assets_data)
  Generators::Core::YamlIo.dump(INTERVIEWS_PATH, interviews_data)
  puts "Applied publication merges."
else
  puts "Dry-run only. Re-run with --apply to persist changes."
end

metrics.each { |key, value| puts "#{key}=#{value}" }
puts "loser_asset_ids=#{loser_asset_ids.join(',')}" if options[:verbose] && loser_asset_ids.any?
puts "loser_interview_ids=#{loser_interview_ids.join(',')}" if options[:verbose] && loser_interview_ids.any?

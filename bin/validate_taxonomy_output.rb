#!/usr/bin/env ruby

require "yaml"
require "json"
require "date"
require "fileutils"
require "set"

ROOT = File.expand_path("..", __dir__)
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
VIDEO_ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
TAXONOMY_PATH = File.join(ROOT, "_data", "taxonomy.yml")
REPORT_PATH = File.join(ROOT, "tmp", "taxonomy-quality-report.json")

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
end

def normalize(value)
  value.to_s.gsub(/\s+/, " ").strip
end

interviews = load_yaml(INTERVIEWS_PATH).fetch("items", [])
video_assets = load_yaml(VIDEO_ASSETS_PATH).fetch("items", [])
taxonomy = load_yaml(TAXONOMY_PATH)

canonical_topics = Array(taxonomy["canonical_topics"]).map { |value| normalize(value) }.reject(&:empty?).to_set
canonical_communities = Array(taxonomy["canonical_communities"]).map { |value| normalize(value) }.reject(&:empty?).to_set
canonical_conferences = Array(taxonomy["canonical_conference_series"]).map { |value| normalize(value) }.reject(&:empty?).to_set
allowed_topic_patterns = Array(taxonomy["allowed_topic_patterns"]).map { |value| Regexp.new(value) }

unknown_topics = Hash.new { |hash, key| hash[key] = [] }
unknown_communities = Hash.new { |hash, key| hash[key] = [] }
unknown_conferences = Hash.new { |hash, key| hash[key] = [] }

topic_occurrences = Hash.new(0)

interviews.each do |interview|
  id = interview["id"].to_s
  topic = normalize(interview["topic"])
  unless topic.empty?
    topic_occurrences[topic] += 1
    next if canonical_topics.include?(topic)
    next if allowed_topic_patterns.any? { |pattern| pattern.match?(topic) }

    unknown_topics[topic] << "interview:#{id}"
  end

  community = normalize(interview["community"])
  unless community.empty? || canonical_communities.include?(community)
    unknown_communities[community] << "interview:#{id}"
  end

  conference = normalize(interview["conference"])
  unless conference.empty? || canonical_conferences.include?(conference)
    unknown_conferences[conference] << "interview:#{id}"
  end
end

video_assets.each do |asset|
  id = asset["id"].to_s
  topic = normalize(asset["topic"])
  next if topic.empty?

  topic_occurrences[topic] += 1
  next if canonical_topics.include?(topic)
  next if allowed_topic_patterns.any? { |pattern| pattern.match?(topic) }

  unknown_topics[topic] << "asset:#{id}"
end

report = {
  generated_at: Time.now.utc.iso8601,
  canonical_topics_count: canonical_topics.size,
  canonical_communities_count: canonical_communities.size,
  canonical_conference_series_count: canonical_conferences.size,
  unique_topics_seen: topic_occurrences.size,
  unknown_topics_count: unknown_topics.size,
  unknown_communities_count: unknown_communities.size,
  unknown_conferences_count: unknown_conferences.size,
  unknown_topics: unknown_topics.sort.to_h.transform_values { |refs| refs.uniq.first(20) },
  unknown_communities: unknown_communities.sort.to_h.transform_values { |refs| refs.uniq.first(20) },
  unknown_conferences: unknown_conferences.sort.to_h.transform_values { |refs| refs.uniq.first(20) },
  top_topics: topic_occurrences.sort_by { |topic, count| [-count, topic] }.first(20).to_h
}

FileUtils.mkdir_p(File.dirname(REPORT_PATH))
File.write(REPORT_PATH, JSON.pretty_generate(report) + "\n")

max_unknown_topics = ENV.fetch("TAXONOMY_MAX_UNKNOWN_TOPICS", "9999").to_i
max_unknown_communities = ENV.fetch("TAXONOMY_MAX_UNKNOWN_COMMUNITIES", "0").to_i
max_unknown_conferences = ENV.fetch("TAXONOMY_MAX_UNKNOWN_CONFERENCES", "0").to_i

failures = []
if report[:unknown_topics_count] > max_unknown_topics
  failures << "unknown topics #{report[:unknown_topics_count]} > #{max_unknown_topics}"
end
if report[:unknown_communities_count] > max_unknown_communities
  failures << "unknown communities #{report[:unknown_communities_count]} > #{max_unknown_communities}"
end
if report[:unknown_conferences_count] > max_unknown_conferences
  failures << "unknown conferences #{report[:unknown_conferences_count]} > #{max_unknown_conferences}"
end

if failures.empty?
  puts "Taxonomy validation passed."
  puts "Report: #{REPORT_PATH}"
  exit 0
end

warn "Taxonomy validation failed: #{failures.join('; ')}"
warn "Report: #{REPORT_PATH}"
exit 1

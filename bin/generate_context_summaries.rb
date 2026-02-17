#!/usr/bin/env ruby
require "set"
require "time"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)

INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
CONFERENCES_PATH = File.join(ROOT, "_data", "interview_conferences.yml")
COMMUNITIES_PATH = File.join(ROOT, "_data", "interview_communities.yml")
ONEOFFS_PATH = File.join(ROOT, "_data", "oneoff_videos.yml")
SCMC_PATH = File.join(ROOT, "_data", "scmc_videos.yml")
TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")
INDEX_SUMMARIES_PATH = File.join(ROOT, "_data", "index_summaries.yml")

def normalize_space(text)
  text.to_s.gsub(/\s+/, " ").strip
end

def valid_text?(value)
  text = normalize_space(value)
  return false if text.empty?
  return false if text == "[]"
  return false if text.casecmp("n/a").zero?
  return false if text.casecmp("none").zero?

  true
end

def pluralize(count, singular, plural = nil)
  return "#{count} #{singular}" if count == 1

  "#{count} #{plural || "#{singular}s"}"
end

def readable_list(values, max_items: 5)
  items = values.compact.map { |v| normalize_space(v) }.select { |v| valid_text?(v) }.uniq.first(max_items)
  return "" if items.empty?
  return items.first if items.length == 1
  return "#{items[0]} and #{items[1]}" if items.length == 2

  "#{items[0..-2].join(', ')}, and #{items[-1]}"
end

def year_phrase(years)
  sorted = years.compact.map(&:to_i).uniq.sort
  return nil if sorted.empty?
  return sorted.first.to_s if sorted.length == 1

  "#{sorted.first} to #{sorted.last}"
end

def top_values(values, max_items: 5)
  counts = Hash.new(0)
  values.each do |v|
    key = normalize_space(v)
    next unless valid_text?(key)

    counts[key] += 1
  end
  counts.sort_by { |name, count| [-count, name] }.first(max_items).map(&:first)
end

def normalize_topic(value)
  normalized = normalize_space(value)
  return "" unless valid_text?(normalized)

  normalized = normalized.sub(/\AInterview with\s+/i, "")
  normalized = normalized.sub(/\AInterview\s*[-:]\s+/i, "")
  normalized = normalized.tr("_", " ")
  normalized = normalized.tr("-", " ") if normalized.match?(/\A[a-z0-9-]+\z/)
  compact = normalized.gsub(/[\s_-]+/, "")
  return "" if compact.match?(/\Agopr\d+\z/i)
  return "" if normalized.length < 3

  canonical_map = {
    "community building and user group organizing" => "community building and user-group organizing",
    "community building and user-group organizing" => "community building and user-group organizing",
    "developer community and conference conversations" => "developer community and conference conversations",
    "conference av production and audio best practices" => "conference AV production and audio best practices",
    "ruby and rails practice" => "Ruby and Rails practice",
    "clojure and functional programming" => "Clojure and functional programming",
    "developer tools and architecture" => "developer tools and architecture",
    "conference speaking and presentation skills" => "conference speaking and presentation skills"
  }
  key = normalized.downcase
  return canonical_map[key] if canonical_map.key?(key)

  normalized
end

def transcript_excerpt(content, max_words: 22)
  clean = content.to_s
               .gsub(/\*\*/, "")
               .gsub(/\A[-*]\s+/, "")
               .gsub(/`/, "")
  clean = normalize_space(clean)
  return nil if clean.empty?

  words = clean.split(/\s+/)
  excerpt = words.first(max_words).join(" ")
  return nil if excerpt.length < 40

  "#{excerpt}…"
end

def build_entity_summary(label:, interviews:, assets_by_id:, transcripts_by_id:)
  count = interviews.size
  years = interviews.map { |i| i["conference_year"] }.compact.uniq.sort
  people = top_values(interviews.flat_map { |i| i["interviewees"] || [] }, max_items: 6)

  topics = []
  interviews.each do |interview|
    topics << normalize_topic(interview["topic"])
    asset = assets_by_id[interview["video_asset_id"]]
    topics << normalize_topic(asset && asset["topic"])
  end
  top_topics = top_values(topics, max_items: 6)

  year_span = year_phrase(years)
  summary_parts = []
  summary_parts << if year_span
                     "#{label} brings together #{pluralize(count, 'interview')} from #{year_span}."
                   else
                     "#{label} brings together #{pluralize(count, 'interview')}."
                   end
  summary_parts << "Recurring themes include #{readable_list(top_topics, max_items: 3)}." unless top_topics.empty?
  summary_parts << "Featured interviewees include #{readable_list(people, max_items: 4)}." unless people.empty?

  friendly_highlights = []
  friendly_highlights << "Coverage: #{pluralize(count, 'interview')}#{year_span ? " from #{year_span}" : ""}."
  friendly_highlights << "Featured interviewees: #{readable_list(people, max_items: 5)}." unless people.empty?
  friendly_highlights << "Common themes: #{readable_list(top_topics, max_items: 5)}." unless top_topics.empty?

  {
    "summary" => summary_parts.join(" "),
    "highlights" => friendly_highlights.first(4),
    "sample_people" => people.first(8),
    "sample_topics" => top_topics.first(8),
    "sample_interview_ids" => interviews.map { |i| i["id"] }.first(10),
    "years_active" => years
  }
end

interviews = Generators::Core::YamlIo.load(INTERVIEWS_PATH, key: "items")
assets = Generators::Core::YamlIo.load(ASSETS_PATH, key: "items")
conferences_data = Generators::Core::YamlIo.load(CONFERENCES_PATH)
communities_data = Generators::Core::YamlIo.load(COMMUNITIES_PATH)
oneoffs = Generators::Core::YamlIo.load(ONEOFFS_PATH, key: "items")
scmc_items = Generators::Core::YamlIo.load(SCMC_PATH, key: "items")

assets_by_id = assets.each_with_object({}) { |asset, h| h[asset["id"]] = asset }
transcripts_by_id = {}
Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort.each do |path|
  transcript_id = File.basename(path, ".yml")
  transcripts_by_id[transcript_id] = Generators::Core::YamlIo.load(path)
end

conferences = conferences_data["conferences"] || []
conferences.each do |conf|
  conf_name = conf["conference"] || conf["name"]
  conf_year = conf["year"]
  matching = interviews.select do |i|
    i["conference"] == conf_name && (!conf_year || i["conference_year"] == conf_year)
  end
  generated = build_entity_summary(
    label: conf["name"].to_s,
    interviews: matching,
    assets_by_id: assets_by_id,
    transcripts_by_id: transcripts_by_id
  )
  conf["summary"] = generated["summary"]
  conf["highlights"] = generated["highlights"]
  conf["sample_people"] = generated["sample_people"]
  conf["sample_topics"] = generated["sample_topics"]
  conf["sample_interview_ids"] = generated["sample_interview_ids"]
  conf["years_active"] = generated["years_active"]
end
Generators::Core::YamlIo.dump(CONFERENCES_PATH, conferences_data)

communities = communities_data["communities"] || []
communities.each do |community|
  matching = interviews.select { |i| i["community"] == community["name"] }
  generated = build_entity_summary(
    label: community["name"].to_s,
    interviews: matching,
    assets_by_id: assets_by_id,
    transcripts_by_id: transcripts_by_id
  )
  community["summary"] = generated["summary"]
  community["highlights"] = generated["highlights"]
  community["sample_people"] = generated["sample_people"]
  community["sample_topics"] = generated["sample_topics"]
  community["sample_interview_ids"] = generated["sample_interview_ids"]
end
Generators::Core::YamlIo.dump(COMMUNITIES_PATH, communities_data)

conference_series = conferences.group_by { |c| c["conference"] || c["name"] }
series_fragments = conference_series.sort_by { |name, _| name.to_s }.map do |series_name, items|
  years = items.map { |i| i["year"] }.compact.uniq.sort
  next series_name.to_s if years.empty?

  "#{series_name} (#{years.join(', ')})"
end

interviewees = top_values(interviews.flat_map { |i| i["interviewees"] || [] }, max_items: 8)
all_topics = top_values(
  interviews.flat_map do |i|
    asset = assets_by_id[i["video_asset_id"]]
    [normalize_topic(i["topic"]), normalize_topic(asset && asset["topic"])]
  end,
  max_items: 8
)

assets_with_transcripts = assets.count { |a| !normalize_space(a["transcript_id"]).empty? }
platforms = top_values(assets.flat_map { |a| (a["platforms"] || []).map { |p| p["platform"] } }, max_items: 6)
oneoff_topics = top_values(oneoffs.flat_map { |item| Array(item["topic"]) + Array(item["tags"]) }, max_items: 8)
scmc_speakers = top_values(scmc_items.flat_map { |item| Array(item["speakers"]) }, max_items: 8)
scmc_topics = top_values(scmc_items.flat_map { |item| Array(item["topic"]) + Array(item["tags"]) }, max_items: 8)

index_summaries = {
  "generated_at" => Time.now.utc.iso8601,
  "source_policy" => "repository-only",
  "pages" => {
    "interviews" => {
    "summary" => "Interview archive with #{pluralize(interviews.size, 'record')} connected to canonical video assets. Interviewees include #{readable_list(interviewees)}. Topics include #{readable_list(all_topics)}.",
      "highlights" => [
        "#{assets_with_transcripts} linked video assets currently include transcripts.",
        "Interview pages are grouped by conference and community indexes for discovery."
      ]
    },
    "interviews_conferences" => {
      "summary" => "Browse conference interviews by event and year. This index covers #{pluralize(conferences.size, 'conference edition')} across #{pluralize(conference_series.size, 'conference series', 'conference series')}, with each page summarizing key voices and themes.",
      "highlights" => [
        "Each conference card includes interview count and date range when available.",
        "Conference pages surface friendly summary text, featured interviewees, and recurring themes."
      ]
    },
    "interviews_communities" => {
      "summary" => "Community index containing #{pluralize(communities.size, 'community', 'communities')}. Community coverage includes #{readable_list(communities.map { |c| c['name'] }, max_items: 7)}.",
      "highlights" => [
        "Community pages include interviewee and topic samples derived from canonical records."
      ]
    },
    "videos" => {
      "summary" => "Canonical video index with #{pluralize(assets.size, 'asset')} across #{readable_list(platforms)} publishing platforms.",
      "highlights" => [
        "#{assets_with_transcripts} assets currently have transcript content attached.",
        "Video detail pages preserve stable IDs and platform-specific watch links."
      ]
    },
    "oneoffs" => {
      "summary" => "One-off index covering standalone talks and recordings linked to canonical video assets.",
      "highlights" => [
        "Frequent one-off topics include #{readable_list(oneoff_topics, max_items: 6)}."
      ]
    },
    "scmc" => {
      "summary" => "Software Craftsmanship McHenry County archive with #{pluralize(scmc_items.size, 'indexed talk')}.",
      "highlights" => [
        "Sample SCMC speakers include #{readable_list(scmc_speakers, max_items: 6)}.",
        "Common SCMC topics include #{readable_list(scmc_topics, max_items: 6)}."
      ]
    }
  }
}

Generators::Core::YamlIo.dump(INDEX_SUMMARIES_PATH, index_summaries)
puts "Generated context summaries for #{conferences.size} conferences, #{communities.size} communities, and 6 index pages."

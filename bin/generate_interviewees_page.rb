#!/usr/bin/env ruby

require "time"
require "set"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
RELATED_VIDEOS_PATH = File.join(ROOT, "_data", "interview_related_videos.yml")
OUT_DATA_PATH = File.join(ROOT, "_data", "interviewees_index.yml")

def slugify(value)
  value.to_s.downcase
       .gsub(/[^a-z0-9]+/, "-")
       .gsub(/\A-+|-+\z/, "")
end

def normalized_name(name)
  name.to_s.gsub(/\s+/, " ").strip
end

interviews = Generators::Core::YamlIo.load(INTERVIEWS_PATH, key: "items")
related_videos_data = Generators::Core::YamlIo.load(RELATED_VIDEOS_PATH)
related_by_interview = {}

Array(related_videos_data["items"]).each do |entry|
  related_by_interview[entry["interview_id"].to_s] = Array(entry["links"])
end

people = Hash.new { |hash, key| hash[key] = [] }
interviews.each do |interview|
  names = Array(interview["interviewees"]).map { |name| normalized_name(name) }.reject(&:empty?)
  names.each { |name| people[name] << interview }
end

items = people.map do |name, rows|
  sorted_rows = rows.sort_by { |row| row["recorded_date"].to_s }.reverse
  bio_links = []
  presentation_links = []
  bio_summaries = []

  appearances = sorted_rows.map do |row|
    interview_id = row["id"].to_s
    links = related_by_interview.fetch(interview_id, [])
    person_links = links.select { |link| link["kind"].to_s.start_with?("conference-") || link["kind"].to_s == "official-playlist" }

    person_links.each do |link|
      kind = link["kind"].to_s
      normalized = {
        "label" => link["label"].to_s,
        "kind" => kind,
        "url" => link["url"].to_s,
        "embed_url" => link["embed_url"].to_s,
        "description" => link["description"].to_s
      }
      if kind == "conference-bio"
        bio_links << normalized
        bio_summaries << normalized["description"] unless normalized["description"].strip.empty?
      elsif kind == "conference-presentation-page" || kind == "conference-presentation-video"
        presentation_links << normalized
      end
    end

    {
      "id" => interview_id,
      "title" => row["title"].to_s,
      "recorded_date" => row["recorded_date"].to_s,
      "conference" => row["conference"].to_s,
      "conference_year" => row["conference_year"].to_s,
      "community" => row["community"].to_s,
      "topic" => row["topic"].to_s,
      "url" => "/interviews/#{interview_id}/",
      "related_links" => person_links.map do |link|
        {
          "label" => link["label"].to_s,
          "kind" => link["kind"].to_s,
          "url" => link["url"].to_s,
          "embed_url" => link["embed_url"].to_s,
          "description" => link["description"].to_s
        }
      end
    }
  end

  unique_by_key = lambda do |arr|
    seen = Set.new
    arr.each_with_object([]) do |item, memo|
      key = [item["kind"], item["url"], item["label"]].join("|")
      next if key.strip.empty? || seen.include?(key)
      seen << key
      memo << item
    end
  end

  {
    "slug" => slugify(name),
    "name" => name,
    "count" => sorted_rows.size,
    "sample_interview_ids" => sorted_rows.first(5).map { |row| row["id"] },
    "interview_ids" => sorted_rows.map { |row| row["id"] },
    "profile_summary" => bio_summaries.max_by { |summary| summary.length }.to_s,
    "bio_links" => unique_by_key.call(bio_links),
    "presentation_links" => unique_by_key.call(presentation_links),
    "appearances" => appearances
  }
end

items.sort_by! { |item| [-item["count"], item["name"]] }

out_data = {
  "generated_at" => Time.now.utc.iso8601,
  "summary" => {
    "total_people" => items.size,
    "people_with_multiple_interviews" => items.count { |item| item["count"] > 1 }
  },
  "items" => items
}
Generators::Core::YamlIo.dump(OUT_DATA_PATH, out_data, preserve_generated_at: true)

puts "Generated interviewees index data (people=#{items.size})."

#!/usr/bin/env ruby

require "time"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")
OUTPUT_PATH = File.join(ROOT, "_data", "video_metadata_completeness.yml")

def normalize(value)
  value.to_s.gsub(/\s+/, " ").strip
end

def present_text?(value)
  !normalize(value).empty?
end

def status_entry(status, score, reason)
  {
    "status" => status,
    "score" => score,
    "reason" => reason
  }
end

assets = Generators::Core::YamlIo.load(ASSETS_PATH, key: "items")
interviews = Generators::Core::YamlIo.load(INTERVIEWS_PATH, key: "items")
interview_by_id = interviews.each_with_object({}) { |item, memo| memo[item["id"]] = item }

rows = assets.map do |asset|
  interview = interview_by_id[asset["interview_id"]]
  transcript_id = normalize(asset["transcript_id"])
  transcript_path = transcript_id.empty? ? nil : File.join(TRANSCRIPTS_DIR, "#{transcript_id}.yml")
  transcript_data = transcript_path && File.exist?(transcript_path) ? Generators::Core::YamlIo.load(transcript_path) : nil
  transcript_content = normalize(transcript_data && transcript_data["content"])

  ratings = {}

  title_text = normalize(asset["title"])
  ratings["title"] =
    if title_text.empty?
      status_entry("missing", 0, "empty title")
    elsif title_text.length < 8
      status_entry("partial", 1, "very short title")
    else
      status_entry("complete", 2, "title present")
    end

  description_text = normalize(asset["description"])
  ratings["description"] =
    if description_text.empty?
      status_entry("missing", 0, "empty description")
    elsif description_text.length < 80
      status_entry("partial", 1, "short description")
    else
      status_entry("complete", 2, "description present")
    end

  asset_topic = normalize(asset["topic"])
  interview_topic = normalize(interview && interview["topic"])
  ratings["topic"] =
    if present_text?(asset_topic)
      status_entry("complete", 2, "asset topic present")
    elsif present_text?(interview_topic)
      status_entry("partial", 1, "fallback interview topic present")
    else
      status_entry("missing", 0, "missing topic")
    end

  ratings["transcript"] =
    if transcript_id.empty?
      status_entry("missing", 0, "no transcript_id on asset")
    elsif transcript_data.nil?
      status_entry("partial", 1, "transcript_id set but transcript file missing")
    elsif transcript_content.empty?
      status_entry("partial", 1, "transcript file exists but content empty")
    elsif transcript_content.length < 200
      status_entry("partial", 1, "transcript content very short")
    else
      status_entry("complete", 2, "transcript content present")
    end

  if interview
    interviewees = Array(interview["interviewees"]).map { |item| normalize(item) }.reject(&:empty?)
    ratings["interviewees"] =
      if interviewees.empty?
        status_entry("missing", 0, "linked interview has no interviewees")
      else
        status_entry("complete", 2, "#{interviewees.length} interviewee(s)")
      end

    community = normalize(interview["community"])
    ratings["community"] =
      if community.empty?
        status_entry("missing", 0, "linked interview missing community")
      elsif community == "General"
        status_entry("partial", 1, "community is General")
      else
        status_entry("complete", 2, "community set")
      end

    conference = normalize(interview["conference"])
    conference_year = interview["conference_year"]
    ratings["conference"] =
      if !conference.empty? && !conference_year.nil?
        status_entry("complete", 2, "conference and year set")
      elsif !conference.empty? || !conference_year.nil?
        status_entry("partial", 1, "conference or year partially set")
      else
        status_entry("missing", 0, "conference/year missing")
      end
  else
    ratings["interviewees"] = status_entry("n/a", nil, "no linked interview")
    ratings["community"] = status_entry("n/a", nil, "no linked interview")
    ratings["conference"] = status_entry("n/a", nil, "no linked interview")
  end

  scored_entries = ratings.values.select { |entry| entry["score"].is_a?(Numeric) }
  max_score = scored_entries.length * 2
  earned_score = scored_entries.sum { |entry| entry["score"] }
  overall = max_score.zero? ? 0 : ((earned_score.to_f / max_score) * 100).round

  missing_fields = ratings.select { |_key, value| %w[missing partial].include?(value["status"]) }.keys

  {
    "id" => asset["id"],
    "title" => asset["title"],
    "page_url" => "/videos/#{asset['id']}/",
    "interview_url" => interview ? "/interviews/#{interview['id']}/" : nil,
    "primary_platform" => asset["primary_platform"],
    "transcript_id" => transcript_id.empty? ? nil : transcript_id,
    "overall_score" => overall,
    "ratings" => ratings,
    "missing_or_partial_fields" => missing_fields
  }
end

summary = {
  "total_videos" => rows.length,
  "score_90_plus" => rows.count { |item| item["overall_score"] >= 90 },
  "score_70_to_89" => rows.count { |item| item["overall_score"] >= 70 && item["overall_score"] < 90 },
  "score_below_70" => rows.count { |item| item["overall_score"] < 70 },
  "with_transcript_complete" => rows.count { |item| item.dig("ratings", "transcript", "status") == "complete" }
}

report = {
  "generated_at" => Time.now.utc.iso8601,
  "summary" => summary,
  "items" => rows.sort_by { |item| [item["overall_score"], item["id"]] }
}

Generators::Core::YamlIo.dump(OUTPUT_PATH, report)
puts "Video metadata completeness generated (videos=#{rows.length})."

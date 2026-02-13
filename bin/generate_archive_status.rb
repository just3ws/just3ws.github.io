#!/usr/bin/env ruby

require "yaml"
require "date"
require "time"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
VIDEO_ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
COMPLETENESS_PATH = File.join(ROOT, "_data", "video_metadata_completeness.yml")
RETRANSCRIBE_QUEUE_PATH = File.join(ROOT, "_data", "transcript_retranscribe_queue.yml")
OUT_PATH = File.join(ROOT, "_data", "archive_status.yml")

def load_yaml(path)
  return {} unless File.file?(path)

  YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
end

interviews = Generators::Core::YamlIo.load(INTERVIEWS_PATH, key: "items")
assets = Generators::Core::YamlIo.load(VIDEO_ASSETS_PATH, key: "items")
completeness = load_yaml(COMPLETENESS_PATH)
queue = load_yaml(RETRANSCRIBE_QUEUE_PATH).fetch("items", [])

transcripts_with_content = 0
assets.each do |asset|
  transcript_id = asset["transcript_id"].to_s.strip
  next if transcript_id.empty?

  transcript_path = File.join(ROOT, "_data", "transcripts", "#{transcript_id}.yml")
  next unless File.file?(transcript_path)

  transcript = load_yaml(transcript_path)
  next if transcript["content"].to_s.strip.empty?

  transcripts_with_content += 1
end

queue_counts = {
  "high" => queue.count { |item| item["severity"].to_s == "high" },
  "medium" => queue.count { |item| item["severity"].to_s == "medium" },
  "low" => queue.count { |item| item["severity"].to_s == "low" }
}

out = {
  "generated_at" => Time.now.utc.iso8601,
  "summary" => {
    "interviews_total" => interviews.size,
    "video_assets_total" => assets.size,
    "assets_with_transcript_content" => transcripts_with_content,
    "metadata_score_90_plus" => completeness.dig("summary", "score_90_plus").to_i,
    "metadata_score_70_to_89" => completeness.dig("summary", "score_70_to_89").to_i,
    "metadata_score_below_70" => completeness.dig("summary", "score_below_70").to_i
  },
  "transcript_retranscribe_queue" => {
    "total" => queue.size,
    "high" => queue_counts["high"],
    "medium" => queue_counts["medium"],
    "low" => queue_counts["low"],
    "top_candidates" => queue.first(10).map do |item|
      {
        "transcript_id" => item["transcript_id"],
        "severity" => item["severity"],
        "score" => item["score"],
        "reason" => item["reason"]
      }
    end
  }
}

Generators::Core::YamlIo.dump(OUT_PATH, out)
puts "Generated archive status data (interviews=#{interviews.size}, assets=#{assets.size})."

#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"
require "time"
require_relative "../src/generators/core/yaml_io"

ROOT = Pathname(__dir__).join("..").expand_path
ASSETS_PATH = ROOT.join("_data", "video_assets.yml")
INTERVIEWS_PATH = ROOT.join("_data", "interviews.yml")
WITC_METADATA_DIR = Pathname("/Volumes/Dock_1TB/WITC/_output/metadata")

MISSING_IDS = %w[
  PeyzIoZh6tw
  FQCDazouHKk
  D8KqeuEBhvc
  J8iOl7g8az8
  RaCRLFLgbR4
  aCUPJbziujI
  -RpPLgSF0kQ
  KZQW9oL9Gfo
  5umGKgZlqIw
].freeze

INTERVIEW_MAP = {
  "PeyzIoZh6tw" => "amitai-schlair-software-craftsmanship-north-america-2013",
  "FQCDazouHKk" => "interview-with-angelique-martin-general",
  "D8KqeuEBhvc" => "bill-scott-general",
  "J8iOl7g8az8" => "interview-with-chet-hendrickson-ron-jefferies-general",
  "RaCRLFLgbR4" => "interview-with-dave-thomas-general",
  "-RpPLgSF0kQ" => "interview-with-michael-ficarra-general",
  "KZQW9oL9Gfo" => "sandro-mancuso-general",
  "5umGKgZlqIw" => "interview-with-sarah-allen-and-desi-mcadam-general"
}.freeze

def normalize(text)
  text.to_s.gsub(/\s+/, " ").strip
end

def youtube_id_from_url(url)
  match = url.to_s.match(%r{youtube\.com/watch\?v=([A-Za-z0-9_-]+)})
  match && match[1]
end

def slugify(value)
  normalize(value).downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
end

unless WITC_METADATA_DIR.exist?
  warn "Metadata dir not found: #{WITC_METADATA_DIR}"
  exit 1
end

assets_data = Generators::Core::YamlIo.load(ASSETS_PATH.to_s)
interviews_data = Generators::Core::YamlIo.load(INTERVIEWS_PATH.to_s)
assets = assets_data["items"] || []
interviews = interviews_data["items"] || []

existing_platform_ids = {}
assets.each do |asset|
  Array(asset["platforms"]).each do |platform|
    key = [platform["platform"].to_s, platform["asset_id"].to_s]
    existing_platform_ids[key] = asset["id"]
  end
end

existing_asset_ids = assets.map { |a| a["id"] }.to_set
existing_interview_ids = interviews.map { |i| i["id"] }.to_set

created_assets = []
created_interviews = []
skipped = []

MISSING_IDS.each do |youtube_id|
  if existing_platform_ids.key?(["youtube", youtube_id])
    skipped << [youtube_id, "already-present", existing_platform_ids[["youtube", youtube_id]]]
    next
  end

  metadata_file = Dir[WITC_METADATA_DIR.join("*___#{youtube_id}.json").to_s].first
  unless metadata_file
    skipped << [youtube_id, "metadata-missing", ""]
    next
  end

  metadata = JSON.parse(File.read(metadata_file))
  title = normalize(metadata["title"])
  url = metadata["url"].to_s
  upload_date = metadata["uploadDate"].to_s
  upload_date = Time.parse(metadata["creationDate"].to_s).strftime("%Y-%m-%d") if upload_date.empty? && !metadata["creationDate"].to_s.empty?
  published_date = upload_date.empty? ? nil : upload_date
  thumbnail = metadata["previewImageURL"].to_s
  description = normalize(metadata["description"])
  description = "Recovered from WITC metadata archive (#{File.basename(metadata_file)})." if description.empty?

  interview_id = INTERVIEW_MAP[youtube_id]
  if youtube_id == "aCUPJbziujI"
    interview_id = "interview-with-greg-baugues-railsconf-2014"
    unless existing_interview_ids.include?(interview_id)
      interviews << {
        "id" => interview_id,
        "title" => "Interview with Greg Baugues at RailsConf 2014",
        "interviewees" => ["Greg Baugues"],
        "interviewer" => "Mike Hall",
        "topic" => "developer community and conference conversations",
        "conference" => "RailsConf",
        "conference_year" => 2014,
        "community" => "",
        "recorded_date" => published_date || "2014-01-01",
        "tags" => [],
        "video_asset_id" => "youtube-#{youtube_id}"
      }
      existing_interview_ids << interview_id
      created_interviews << interview_id
    end
  end

  asset_id = "youtube-#{youtube_id}"
  if existing_asset_ids.include?(asset_id)
    skipped << [youtube_id, "asset-id-exists", asset_id]
    next
  end

  asset = {
    "id" => asset_id,
    "interview_id" => interview_id,
    "title" => title.empty? ? "Interview #{youtube_id}" : title,
    "primary_platform" => "youtube",
    "source" => "witc",
    "published_date" => published_date,
    "thumbnail" => thumbnail,
    "duration_seconds" => nil,
    "duration_minutes" => nil,
    "description" => description,
    "topic" => "developer-community-and-conference-conversations",
    "tags" => ["youtube", "recovered", "witc"],
    "platforms" => [
      {
        "platform" => "youtube",
        "asset_id" => youtube_id,
        "url" => url,
        "embed_url" => "https://www.youtube.com/embed/#{youtube_id}",
        "title_on_platform" => title,
        "published_date" => published_date,
        "thumbnail" => thumbnail,
        "description" => normalize(metadata["description"]),
        "playlist" => metadata["playlist"].is_a?(Hash) ? metadata["playlist"]["name"] : nil
      }.compact
    ]
  }

  assets << asset
  existing_asset_ids << asset_id
  existing_platform_ids[["youtube", youtube_id]] = asset_id
  created_assets << asset_id
end

assets_data["items"] = assets
interviews_data["items"] = interviews

Generators::Core::YamlIo.dump(ASSETS_PATH.to_s, assets_data)
Generators::Core::YamlIo.dump(INTERVIEWS_PATH.to_s, interviews_data)

puts "Created assets: #{created_assets.size}"
created_assets.each { |id| puts "- #{id}" }
puts "Created interviews: #{created_interviews.size}"
created_interviews.each { |id| puts "- #{id}" }
puts "Skipped: #{skipped.size}"
skipped.each { |row| puts "- #{row[0]} #{row[1]} #{row[2]}".strip }

#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_youtube_metadata.rb
# Generates 1:1 parity metadata for YouTube and local site video pages:
# 1. Enriches _data/video_assets.yml with canonical titles, descriptions, chapters, and tags.
# 2. Generates _data/youtube_metadata_staged.json for YouTube Data API v3 upload.

require 'json'
require 'yaml'
require 'fileutils'
require 'optparse'
require_relative '../src/generators/core/yaml_io'

class YouTubeMetadataGenerator
  MANIFEST_FILE = "_data/youtube_captions_manifest.json"
  VIDEO_ASSETS_FILE = "_data/video_assets.yml"
  OUTPUT_STAGING_FILE = "_data/youtube_metadata_staged.json"
  TRANSCRIPTS_DIR = "_data/transcripts"
  RESEARCH_DIR = "_data/research"

  def initialize(options = {})
    @options = options
  end

  def run
    puts "🎬 [1:1 Parity] YouTube & Site Video Metadata Generator"
    puts "=========================================================="

    unless File.exist?(MANIFEST_FILE) && File.exist?(VIDEO_ASSETS_FILE)
      puts "❌ Error: Required data files missing."
      exit 1
    end

    manifest = JSON.parse(File.read(MANIFEST_FILE))
    manifest_items = manifest["items"] || []
    manifest_by_video_id = manifest_items.each_with_object({}) { |i, h| h[i["youtube_video_id"]] = i }
    manifest_by_transcript_id = manifest_items.each_with_object({}) { |i, h| h[i["transcript_id"]] = i }

    video_assets_data = Generators::Core::YamlIo.load(VIDEO_ASSETS_FILE) || {}
    assets = video_assets_data["items"] || []

    staged_records = []
    updated_assets_count = 0

    assets.each do |asset|
      t_id = asset["transcript_id"] || asset["interview_id"] || asset["id"]
      yt_platform = (asset["platforms"] || []).find { |p| p["platform"] == "youtube" }
      v_id = yt_platform ? yt_platform["asset_id"] : nil

      # If video ID wasn't in platforms, check manifest
      if v_id.nil? && manifest_by_transcript_id[t_id]
        v_id = manifest_by_transcript_id[t_id]["youtube_video_id"]
      end

      next unless t_id

      t_file = File.join(TRANSCRIPTS_DIR, "#{t_id}.yml")
      r_file = File.join(RESEARCH_DIR, "#{t_id}.json")

      t_data = File.exist?(t_file) ? (Generators::Core::YamlIo.load(t_file) || {}) : {}
      r_data = File.exist?(r_file) ? (JSON.parse(File.read(r_file)) || {}) : {}

      # Generate 1:1 standard metadata
      package = generate_video_package(t_id, v_id, asset, t_data, r_data)

      # 1. Update the canonical video_assets.yml object
      asset["title"] = package[:title]
      asset["description"] = package[:description]
      asset["tags"] = package[:tags]
      asset["chapters"] = package[:chapters] if package[:chapters].any?

      if yt_platform
        yt_platform["title_on_platform"] = package[:title]
        yt_platform["description"] = package[:description]
      end

      updated_assets_count += 1

      if v_id
        staged_records << package
      end
    end

    # Write enriched video_assets.yml
    Generators::Core::YamlIo.dump(VIDEO_ASSETS_FILE, video_assets_data)
    puts "✅ Updated #{updated_assets_count} video asset records in #{VIDEO_ASSETS_FILE} (1:1 Parity)"

    # Write staged YouTube payload
    File.write(OUTPUT_STAGING_FILE, JSON.pretty_generate(staged_records))
    puts "✅ Staged #{staged_records.size} YouTube API upload packages in #{OUTPUT_STAGING_FILE}"
    puts "=========================================================="
    puts "🎉 Video pages on just3ws.com and YouTube payloads are now in 100% metadata parity!"
  end

  private

  def generate_video_package(transcript_id, video_id, asset, transcript_data, research_data)
    speaker_map = transcript_data["speaker_map"] || {}
    primary_speaker = speaker_map.values.find { |s| s["role"] != "Interviewer, UGtastic" && s["name"] != "Mike Hall" }
    guest_name = primary_speaker ? primary_speaker["name"] : extract_guest_from_title(asset["title"])

    raw_summary = transcript_data["summary"] || asset["description"] || ""
    summary = clean_summary(raw_summary)
    turns = transcript_data["turns"] || []

    dimensions = research_data["dimensions"] || {}
    topics = dimensions["topics"] || []
    context = dimensions["historical_context_at_recording"] || ""

    # Standardized Title (Under 100 chars)
    main_topic = topics.first || asset["topic"] || "Software Craftsmanship"
    main_topic = main_topic.to_s.split('-').map(&:capitalize).join(' ') if main_topic.include?('-')

    title = "#{guest_name} on #{main_topic} | Technical Conversation Archive"
    title = title[0...99] if title.length > 100

    # Chapters from dialogue turns
    chapters = extract_chapters(turns)

    # 1:1 Canonical Description
    description = build_description(guest_name, summary, context, transcript_id, chapters, topics)

    # Clean Tags
    tags = (["Software Craftsmanship", "Programming", "Architecture", guest_name] + topics).uniq.take(15)

    {
      transcript_id: transcript_id,
      youtube_video_id: video_id,
      title: title,
      description: description,
      chapters: chapters,
      tags: tags,
      generated_at: Time.now.utc.iso8601
    }
  end

  def extract_guest_from_title(title)
    return "Technical Conversation" if title.nil?
    if title =~ /Interviews ([^|]+)/
      $1.strip
    elsif title =~ /w\/([^(]+)/
      $1.strip
    else
      title.split(':').first.strip
    end
  end

  def clean_summary(text)
    return "" if text.nil?
    text.to_s.gsub(/CRITICAL INSIGHTS:.*$/m, '').strip
  end

  def extract_chapters(turns)
    chapters = []
    chapters << { "time" => "00:00", "title" => "Introduction & Context" }

    current_interval = 180 # Every 3 minutes
    last_seconds = 0

    turns.each do |turn|
      time_str = turn["time"] || turn["timestamp"]
      next unless time_str

      seconds = parse_time_to_seconds(time_str)
      if seconds && seconds - last_seconds >= current_interval
        speaker_name = turn["speaker_name"] || "Discussion"
        preview_text = clean_chapter_text(turn["text"])
        chapters << {
          "time" => format_seconds_to_timestamp(seconds),
          "title" => "#{speaker_name}: #{preview_text}"
        }
        last_seconds = seconds
      end
    end

    chapters
  end

  def build_description(guest_name, summary, context, transcript_id, chapters, topics)
    lines = []
    lines << summary unless summary.empty?
    lines << ""
    lines << "Recorded as part of the Technical Conversation Archive and UGtastic historical movement."
    lines << context unless context.empty?
    lines << ""
    lines << "📖 Interactive Transcript & Notes: https://www.just3ws.com/interviews/#{transcript_id}/"
    lines << ""
    lines << "⏱️ CHAPTERS:"
    chapters.each do |ch|
      lines << "#{ch['time']} - #{ch['title']}"
    end
    lines << ""
    lines << "🏷️ TOPICS: #{topics.join(', ')}" unless topics.empty?
    lines << ""
    lines << "Curated and restored by Mike Hall (https://www.just3ws.com)"
    lines.join("\n")
  end

  def parse_time_to_seconds(str)
    parts = str.to_s.split(':').map(&:to_i)
    case parts.size
    when 2 then parts[0] * 60 + parts[1]
    when 3 then parts[0] * 3600 + parts[1] * 60 + parts[2]
    else nil
    end
  end

  def format_seconds_to_timestamp(secs)
    mins = secs / 60
    rem_secs = secs % 60
    format("%02d:%02d", mins, rem_secs)
  end

  def clean_chapter_text(text)
    return "Core Discussion" if text.nil? || text.strip.empty?
    cleaned = text.gsub(/[\n\r]/, ' ').strip
    cleaned = cleaned[0...40].strip + "..." if cleaned.length > 40
    cleaned
  end
end

YouTubeMetadataGenerator.new.run

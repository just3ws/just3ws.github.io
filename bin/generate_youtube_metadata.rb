#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_youtube_metadata.rb
# Generates humane, high-signal YouTube video titles, descriptions, chapters,
# and tags from canonical transcript YAML and research JSON data.

require 'json'
require 'yaml'
require 'fileutils'
require 'optparse'

class YouTubeMetadataGenerator
  MANIFEST_FILE = "_data/youtube_captions_manifest.json"
  OUTPUT_STAGING_FILE = "_data/youtube_metadata_staged.json"
  TRANSCRIPTS_DIR = "_data/transcripts"
  RESEARCH_DIR = "_data/research"

  def initialize(options = {})
    @options = options
  end

  def run
    puts "🎬 YouTube Metadata & Chapter Generator (Humane Voice)"
    puts "=========================================================="

    unless File.exist?(MANIFEST_FILE)
      puts "❌ Error: #{MANIFEST_FILE} not found."
      exit 1
    end

    manifest = JSON.parse(File.read(MANIFEST_FILE))
    items = manifest["items"] || []

    if @options[:video_id]
      items = items.select { |i| i["youtube_video_id"] == @options[:video_id] }
    end

    if @options[:limit] && @options[:limit] > 0
      items = items.first(@options[:limit])
    end

    puts "Total Candidates: #{items.size}"
    staged_records = []

    items.each_with_index do |item, idx|
      t_id = item["transcript_id"]
      v_id = item["youtube_video_id"]

      t_file = File.join(TRANSCRIPTS_DIR, "#{t_id}.yml")
      r_file = File.join(RESEARCH_DIR, "#{t_id}.json")

      next unless File.exist?(t_file)

      t_data = YAML.safe_load(File.read(t_file)) || {}
      r_data = File.exist?(r_file) ? (JSON.parse(File.read(r_file)) || {}) : {}

      record = generate_video_package(t_id, v_id, t_data, r_data)
      staged_records << record

      puts "[#{idx + 1}/#{items.size}] #{record[:title]} (#{record[:chapters].size} chapters)"
    end

    File.write(OUTPUT_STAGING_FILE, JSON.pretty_generate(staged_records))
    puts "=========================================================="
    puts "✅ Staged #{staged_records.size} video packages in #{OUTPUT_STAGING_FILE}"
    puts "💡 Run with `--preview` or review #{OUTPUT_STAGING_FILE} directly."
  end

  private

  def generate_video_package(transcript_id, video_id, transcript_data, research_data)
    speaker_map = transcript_data["speaker_map"] || {}
    primary_speaker = speaker_map.values.find { |s| s["role"] != "Interviewer, UGtastic" && s["name"] != "Mike Hall" }
    guest_name = primary_speaker ? primary_speaker["name"] : "Technical Conversation"

    summary = transcript_data["summary"] || ""
    turns = transcript_data["turns"] || []

    dimensions = research_data["dimensions"] || {}
    topics = dimensions["topics"] || []
    context = dimensions["historical_context_at_recording"] || ""

    # 1. Humane Title Generation (Clean, zero clickbait)
    main_topic = topics.first || "Software Architecture"
    title = "#{guest_name} on #{main_topic} | Technical Conversation Archive"
    title = title[0...99] if title.length > 100

    # 2. Chapters Generation from Timestamps
    chapters = extract_chapters(turns)

    # 3. Grounded Description
    description = build_description(guest_name, summary, context, transcript_id, chapters, topics)

    # 4. Tags
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

  def extract_chapters(turns)
    chapters = []
    # YouTube requires first chapter at 00:00
    chapters << { time: "00:00", title: "Introduction & Context" }

    current_interval = 180 # Every 3 minutes or topic shift
    last_seconds = 0

    turns.each do |turn|
      time_str = turn["time"] || turn["timestamp"]
      next unless time_str

      seconds = parse_time_to_seconds(time_str)
      if seconds && seconds - last_seconds >= current_interval
        speaker_name = turn["speaker_name"] || "Discussion"
        preview_text = clean_chapter_text(turn["text"])
        chapters << {
          time: format_seconds_to_timestamp(seconds),
          title: "#{speaker_name}: #{preview_text}"
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
      lines << "#{ch[:time]} - #{ch[:title]}"
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

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/generate_youtube_metadata.rb [options]"
  opts.on("--limit N", Integer, "Limit number of videos processed") { |v| options[:limit] = v }
  opts.on("--video-id ID", String, "Target specific YouTube Video ID") { |v| options[:video_id] = v }
  opts.on("--preview", "Print preview of generated packages") { options[:preview] = true }
end.parse!

YouTubeMetadataGenerator.new(options).run

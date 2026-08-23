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
      asset["description"] = package[:site_description]
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

  def generate_video_package(transcript_id, video_id, asset, transcript_data, _research_data)
    speaker_map = transcript_data["speaker_map"] || {}
    primary_speaker = speaker_map.values.find { |s| s["role"] != "Interviewer, UGtastic" && s["name"] != "Mike Hall" }
    guest_name = primary_speaker ? primary_speaker["name"] : extract_guest_from_title(asset["title"])
    guest_role = primary_speaker ? primary_speaker["role"] : nil

    raw_summary = transcript_data["summary"] || asset["description"] || ""
    summary = clean_summary(raw_summary)
    turns = transcript_data["turns"] || []

    year = extract_year(transcript_id) || extract_year(asset["published_date"]) || 2013
    event_label = determine_event_label([], transcript_id, year)
    
    # Topic strictly from guest role, asset topic, or transcript turns
    main_topic = if guest_role && !guest_role.empty? && guest_role.length <= 60
                   guest_role.split(' ').map { |w| %w[and or of in on with for at the to].include?(w.downcase) ? w.downcase : w.capitalize }.join(' ')
                 elsif asset["topic"]
                   asset["topic"].to_s.split('-').map(&:capitalize).join(' ')
                 else
                   "Software Craftsmanship"
                 end

    title = "#{guest_name} on #{main_topic} | #{event_label}"
    title = title[0...99] if title.length > 100

    # Chapters from dialogue turns
    chapters = extract_chapters(turns)

    # Clean Tags
    tags = ["Software Craftsmanship", "Programming", "Architecture", guest_name, event_label.split.first].compact.uniq.take(15)

    mike_key = speaker_map.find { |_k, v| v["name"] == "Mike Hall" || v["role"] == "Interviewer, UGtastic" }&.first || "M1"
    first_mike_turn = turns.find { |t| t["speaker"] == mike_key }

    # 1:1 Canonical Description in Mike Hall with UGtastic authentic voice
    description = build_description(guest_name, guest_role, summary, event_label, transcript_id, chapters, tags, first_mike_turn ? first_mike_turn["text"] : nil)
    site_description = summary.empty? ? clean_spoken_intro(first_mike_turn ? first_mike_turn["text"] : nil, guest_name, event_label, guest_role) : summary

    {
      transcript_id: transcript_id,
      youtube_video_id: video_id,
      title: title,
      description: description,
      site_description: site_description,
      chapters: chapters,
      tags: tags,
      generated_at: Time.now.utc.iso8601
    }
  end

  def determine_event_label(_communities, transcript_id, year)
    slug = transcript_id.to_s.downcase

    conf_name = if slug.include?("software-craftsmanship-north-america") || slug.include?("scna")
                  "SCNA"
                elsif slug.include?("railsconf")
                  "RailsConf"
                elsif slug.include?("windycityrails")
                  "WindyCityRails"
                elsif slug.include?("chicagowebconf")
                  "ChicagoWebConf"
                elsif slug.include?("chicago-code-camp")
                  "Chicago Code Camp"
                elsif slug.include?("goto")
                  "GOTO"
                elsif slug.include?("webvisions")
                  "WebVisions"
                elsif slug.include?("pechakucha")
                  "PechaKucha"
                else
                  nil
                end

    if conf_name && year
      "#{conf_name} #{year}"
    elsif conf_name
      conf_name
    else
      "UGtastic Archive"
    end
  end

  def extract_year(str)
    if str.to_s =~ /(20\d{2})/
      $1.to_i
    else
      nil
    end
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

  def build_description(guest_name, guest_role, summary, event_label, transcript_id, chapters, tags, spoken_intro = nil)
    lines = []
    
    # Historical archive banner
    lines << "📼 FROM THE UGTASTIC ARCHIVE (Recorded on-site at #{event_label})"
    lines << ""

    # Authentic Mike Hall spoken opening from the recording
    opening_hook = clean_spoken_intro(spoken_intro, guest_name, event_label, guest_role)
    lines << "\"#{opening_hook}\""
    lines << ""

    # Historical discussion summary & era context
    if !summary.empty? && !summary.start_with?("Hi,") && !summary.start_with?("Hi ") && summary != opening_hook
      lines << summary
      lines << ""
    end
    lines << "Recorded during the 2009–2015 software craftsmanship and developer community movements, this archival interview captures early ideas, debates, and community organizing in real time."
    lines << ""

    lines << "---"
    lines << "🏛️ ORAL HISTORY RECORD:"
    lines << "• Series: UGtastic Technical Conversation Archive (2009–2015)"
    lines << "• Recorded: #{event_label}"
    lines << "• Guest: #{guest_name}#{guest_role && !guest_role.empty? ? " (#{guest_role})" : ""}"
    lines << "• Interviewer: Mike Hall (UGtastic / https://www.just3ws.com)"
    lines << ""
    lines << "⏱️ CHAPTERS:"
    chapters.each do |ch|
      lines << "#{ch['time']} - #{ch['title']}"
    end
    lines << ""
    lines << "📖 FULL TRANSCRIPT & RESTORATION:"
    lines << "https://www.just3ws.com/interviews/#{transcript_id}/"
    lines << ""
    lines << "🏷️ TOPICS: #{tags.join(', ')}" unless tags.empty?
    lines << ""
    lines << "Restored and preserved by Mike Hall (https://www.just3ws.com)"
    lines.join("\n")
  end

  def clean_spoken_intro(text, guest_name, event_label, guest_role)
    if text
      cleaned = text.gsub(/\[.*?\]/, '').gsub(/\s+/, ' ').strip
      cleaned = cleaned.gsub(/\b(?:Utesc|Ute\s*TASC|Hugtastic|Ugtastic)\b/i, 'UGtastic')
      cleaned = cleaned.gsub(/\bBoggess\b/i, 'Baugues')
      if cleaned =~ /\A(?:Hi|Hello|Hey|Good\s+(?:morning|afternoon|evening)|I\x27m\s+Mike|Welcome\s+to)/i
        sentences = cleaned.split(/(?<=[.!?])\s+/)
        intro = sentences.take(2).join(' ').strip
        if intro.length > 220
          intro = intro[0...200].sub(/\s+\S*\z/, '') + '.'
        end
        return intro if intro.length >= 25 && !intro.downcase.include?('testing')
      end
    end

    role_phrase = (guest_role && !guest_role.empty?) ? " to discuss #{guest_role}" : ""
    "Hi, it's Mike with UGtastic. In this conversation recorded on-site at #{event_label}, I sit down with #{guest_name}#{role_phrase}."
  end

  def clean_summary(text)
    return "" if text.nil?
    # Strip metadata blocks and previous generation markers
    cleaned = text.to_s.split('---').first.to_s
    cleaned = cleaned.gsub(/📼\s*FROM THE UGTASTIC ARCHIVE.*/m, '')
    cleaned = cleaned.gsub(/Recovered from WITC metadata archive.*/m, '')
    cleaned = cleaned.gsub(/CRITICAL INSIGHTS:.*$/m, '')
    cleaned = cleaned.gsub(/SPEAKERS:.*$/m, '')
    cleaned = cleaned.gsub(/HISTORICAL CONTEXT:.*$/m, '')
    cleaned = cleaned.gsub(/CHAPTERS:.*$/m, '')
    cleaned = cleaned.gsub(/[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/, '')
    cleaned = cleaned.gsub(/#\w+/, '') # Remove hashtags
    cleaned = cleaned.gsub(/\bBoggess\b/i, 'Baugues')
    cleaned = cleaned.gsub(/Recorded as part of the Technical Conversation Archive.*/m, '') # Remove duplicates
    cleaned = cleaned.gsub(/Don't miss this!/i, '')
    cleaned = cleaned.gsub(/Check it out!/i, '')
    cleaned = cleaned.gsub(/\s+/, ' ').strip
    cleaned
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

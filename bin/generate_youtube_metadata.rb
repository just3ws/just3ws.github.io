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
    single_mike_presenter = speaker_map.values.any? && speaker_map.values.all? { |s| s["name"] == "Mike Hall" }
    presentation_mode = if asset["content_type"]
                          asset["content_type"] == "presentation"
                        else
                          speaker_map.values.any? do |s|
                            role = s["role"].to_s
                            role.include?("Presenter") || role.include?("Speaker")
                          end
                        end
    primary_speaker = speaker_map.values.find { |s| s["role"] != "Interviewer, UGtastic" && s["name"] != "Mike Hall" }
    guest_name = primary_speaker ? primary_speaker["name"] : (speaker_map.values.first&.dig("name") || "Mike Hall")
    guest_role = if single_mike_presenter
                   "Presenter"
                 else
                   primary_speaker ? primary_speaker["role"] : (speaker_map.values.first&.dig("role") || "Skateboarding")
                 end

    raw_summary = transcript_data["summary"] || asset["description"] || ""
    summary = clean_summary(raw_summary)
    turns = transcript_data["turns"] || []

    year = extract_year(transcript_id) || extract_year(asset["published_date"]) || 2013
    event_label = determine_event_label([], transcript_id, year)
    
    # Topic strictly from guest role, asset topic, or transcript turns
    main_topic = if guest_role && !guest_role.empty? && guest_role.length <= 60
                   guest_role.split(' ').map do |w|
                     if w =~ /[a-z][A-Z]/
                       w
                     elsif %w[and or of in on with for at the to].include?(w.downcase)
                       w.downcase
                     elsif %w[scna scmc goto api aws ci cd].include?(w.downcase)
                       w.upcase
                     else
                       w.capitalize
                     end
                   end.join(' ')
                 elsif asset["topic"]
                   asset["topic"].to_s.split('-').map do |w|
                     if w =~ /[a-z][A-Z]/
                       w
                     elsif %w[and or of in on with for at the to].include?(w.downcase)
                       w.downcase
                     elsif %w[scna scmc goto api aws ci cd].include?(w.downcase)
                       w.upcase
                     else
                       w.capitalize
                     end
                   end.join(' ')
                 else
                   "Software Craftsmanship"
                 end

    presentation_title = (asset["platforms"] || []).map { |p| p["title_on_platform"] }.compact.find { |t| t.to_s.strip != "" }
    title = if single_mike_presenter && asset["title"].to_s.strip != "" && asset["title"] !~ /\bon\s+(Interviewer|Host|Guest|Speaker)\b/i
              asset["title"].to_s.strip
            elsif single_mike_presenter && presentation_title
              presentation_topic = presentation_title.sub(/\s+w\/.*\z/i, '').strip
              "Mike Hall | #{presentation_topic} | #{event_label}"
            elsif presentation_mode && primary_speaker && presentation_title
              presentation_topic = presentation_title.sub(/\s+w\/.*\z/i, '').strip
              "#{guest_name} | #{presentation_topic} | #{event_label}"
            else
              "#{guest_name} on #{main_topic} | #{event_label}"
            end
    title = title[0...99] if title.length > 100

    # Chapters from dialogue turns or curated recording chapters
    chapters = extract_chapters(transcript_data)

    # Clean Tags
    tags = ["Software Craftsmanship", "Programming", "Architecture", guest_name, event_label.split.first].compact.uniq.take(15)

    mike_key = speaker_map.find { |_k, v| v["name"] == "Mike Hall" || v["role"] == "Interviewer, UGtastic" }&.first || "M1"
    first_mike_turn = turns.find { |t| t["speaker"] == mike_key }

    # 1:1 Canonical Description in Mike Hall with UGtastic authentic voice
    description = build_description(guest_name, guest_role, summary, event_label, transcript_id, chapters, tags, first_mike_turn ? first_mike_turn["text"] : nil, single_mike_presenter, presentation_mode)
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

  def extract_chapters(transcript_data)
    curated_chapters = transcript_data.dig("recording", "chapters")
    if curated_chapters && curated_chapters.is_a?(Array) && !curated_chapters.empty?
      return curated_chapters.map.with_index do |ch, idx|
        start_sec = (ch["start_sec"] || 0).to_i
        start_sec = 0 if idx.zero? # YouTube requirement: first chapter must start at 00:00
        {
          "time" => format_seconds_to_timestamp(start_sec),
          "title" => ch["title"]
        }
      end
    end

    turns = transcript_data["turns"] || []
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

  def build_description(guest_name, guest_role, summary, event_label, transcript_id, chapters, tags, spoken_intro = nil, single_mike_presenter = false, presentation_mode = false)
    lines = []

    # 1. Warm, friendly greeting in Mike Hall's authentic UGtastic voice
    lines << generate_warm_opener(guest_name, guest_role, event_label, summary, single_mike_presenter, presentation_mode)
    lines << ""

    # 2. Discussion context & what was important to the guest
    body = clean_summary_body(summary, guest_name)
    if body && !body.empty?
      lines << body
      lines << ""
    end

    # 3. Archival era context
    lines << "Recorded during the 2009–2015 software craftsmanship and developer community movements, this archival interview captures early ideas, debates, and community organizing in real time."
    lines << ""

    # 4. Structured Oral History Record
    lines << "---"
    lines << "🏛️ ORAL HISTORY RECORD:"
    lines << "• Series: UGtastic Technical Conversation Archive (2009–2015)"
    lines << "• Location: #{event_label}"
    if single_mike_presenter
      lines << "• Presenter: Mike Hall (UGtastic / https://www.just3ws.com)"
    elsif presentation_mode
      lines << "• Presenter: #{guest_name}#{guest_role && !guest_role.empty? ? " (#{guest_role})" : ""}"
      lines << "• Organizer: Mike Hall (SCMC / UGtastic)"
    else
      lines << "• Guest: #{guest_name}#{guest_role && !guest_role.empty? ? " (#{guest_role})" : ""}"
      lines << "• Interviewer: Mike Hall (UGtastic / https://www.just3ws.com)"
    end
    lines << ""
    lines << "⏱️ CHAPTERS:"
    chapters.each do |ch|
      lines << "#{ch['time']} - #{ch['title']}"
    end
    lines << ""
    lines << "📖 FULL INTERACTIVE TRANSCRIPT & AUDIO:"
    lines << "https://www.just3ws.com/interviews/#{transcript_id}/"
    lines << ""
    lines << "🏷️ TOPICS: #{tags.join(', ')}" unless tags.empty?
    lines << ""
    lines << "Restored and preserved by Mike Hall (https://www.just3ws.com)"

    lines.join("\n")
  end

  def generate_warm_opener(guest_name, guest_role, event_label, summary, single_mike_presenter = false, presentation_mode = false)
    location_phrase = if event_label && event_label != "UGtastic Archive"
                        "on-site at #{event_label}"
                      else
                        "in the community"
                      end

    topic_phrase = if guest_role && !guest_role.empty?
                     "to discuss #{guest_role}"
                   else
                     "to talk about their engineering work and what is important to them"
                   end

    if single_mike_presenter
      "Hi, it's Mike with UGtastic! In this presentation, I'm sharing what I learned about #{guest_role.downcase}."
    elsif presentation_mode
      "Hi, it's Mike with UGtastic! This presentation captures #{guest_name} sharing #{guest_role.downcase}."
    elsif guest_name == "Mike Hall"
      "Hi, it's Mike with UGtastic! In this archival clip recorded #{location_phrase}, I'm sharing some fun skateboarding footage from the archive."
    else
      "Hi, it's Mike with UGtastic! In this conversation recorded #{location_phrase}, I sit down with #{guest_name} #{topic_phrase}."
    end
  end

  def clean_spoken_intro(spoken_text, guest_name, event_label, guest_role)
    if spoken_text && !spoken_text.empty?
      clean = spoken_text.gsub(/(?:Hi|Hello|Hey),?\s*(?:it's|I'm)?\s*Mike\b[^.!?]*[.!?]/i, '')
      clean = clean.gsub(/I'm\s+(?:standing|sitting)\s+here\s+with\s+[^.!?]*[.!?]/i, '')
      clean = clean.gsub(/I'm\s+(?:here|sitting\s+down)\s+(?:at|with)\s+[^.!?]*[.!?]/i, '')
      clean = clean.gsub(/\s+/, ' ').strip
      return clean unless clean.empty? || clean.length < 15
    end
    "Mike Hall sits down with #{guest_name} on-site at #{event_label} to discuss #{guest_role} and software craftsmanship."
  end

  def clean_summary_body(summary, guest_name)
    return nil if summary.nil? || summary.empty?
    cleaned = clean_summary(summary)
    return nil if cleaned.empty?

    # Remove all duplicated spoken opening fragments
    cleaned = cleaned.gsub(/(?:Hi|Hello|Hey),?\s*(?:it's|I'm)?\s*Mike\b[^.!?]*[.!?]/i, '')
    cleaned = cleaned.gsub(/I'm\s+(?:standing|sitting)\s+here\s+with\s+[^.!?]*[.!?]/i, '')
    cleaned = cleaned.gsub(/I'm\s+(?:here|sitting\s+down)\s+(?:at|with)\s+[^.!?]*[.!?]/i, '')
    cleaned = cleaned.gsub(/\A(?:In this video|In this interview)\s+[^.!?]*[.!?]/i, '')
    cleaned = cleaned.gsub(/\s+/, ' ').strip

    return nil if cleaned.empty? || cleaned.length < 20
    cleaned
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
    cleaned = cleaned.gsub(/Don't miss out!/i, '')
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

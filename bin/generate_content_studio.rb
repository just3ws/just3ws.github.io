#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_content_studio.rb — Content Engine, Supercuts, Shorts & YouTube Data API Generator
#
# Processes the 207 transcript canon into derivative content formats:
# 1. Shorts / Reels (30–60 sec video clip candidates with YouTube Data API payloads)
# 2. Quotable Soundbites (by theme with timestamp markers)
# 3. Supercut Compilation Playlists (with transition delays & segment overlays)
# 4. Article & Blog Post Concepts

require 'yaml'
require 'json'
require 'fileutils'

class ContentStudioGenerator
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  ASSET_MAP_FILE  = "_data/video_assets.yml"
  OUTPUT_DATA     = "_data/editorial_content_studio.json"
  ASSETS_OUTPUT   = "assets/data/editorial_content_studio.json"

  THEMES = {
    "software-craftsmanship" => "Software Craftsmanship & Professionalism",
    "tdd-and-testing"        => "TDD, BDD & Software Testing",
    "continuous-delivery"   => "Continuous Delivery & DevOps",
    "architecture"          => "Software Architecture & Monoliths",
    "empathy-and-culture"    => "Empathy, Leadership & Engineering Culture",
    "open-source"           => "Open Source Maintenance & Community"
  }.freeze

  def run
    puts "🎬 Generating Content Studio: Shorts, YouTube API Payloads, Supercuts & Quotes..."

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    interview_map = interviews.map { |i| [i["id"], i] }.to_h

    video_assets = YAML.load_file(ASSET_MAP_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    asset_map = video_assets.map { |a| [a["id"], a] }.to_h

    shorts_candidates = []
    quotes_by_theme = Hash.new { |h, k| h[k] = [] }
    playlists_map = Hash.new { |h, k| h[k] = [] }

    Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort.each do |path|
      t_id = File.basename(path, ".yml")
      iv = interview_map[t_id] || {}
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
      turns = data["turns"] || []

      title = iv["title"] || t_id
      conf = iv["conference"] || "UGtastic Archive"
      year = iv["conference_year"] || 2014
      asset_id = iv["video_asset_id"] || t_id
      asset = asset_map[asset_id] || {}
      
      # Determine preferred video embed URL
      embed_url = nil
      if asset["platforms"].is_a?(Array)
        yt_platform = asset["platforms"].find { |p| p["platform"] == "youtube" } || asset["platforms"].first
        embed_url = yt_platform["embed_url"] if yt_platform
      end

      turns.each_with_index do |turn, idx|
        text = turn["text"].to_s.strip
        speaker_id = turn["speaker"]
        s_info = data.dig("speaker_map", speaker_id)
        s_name = s_info.is_a?(Hash) ? (s_info["name"] || speaker_id) : (s_info || speaker_id)

        next if s_name == "Mike Hall" # Focus on guest wisdom for shorts
        next if text.size < 80 || text.size > 800

        # Estimate start_sec & end_sec if not explicit
        start_sec = turn["start_sec"] || turn["start"] || (idx * 22)
        est_duration = [ (text.split.size / 2.5).round, 25 ].max
        end_sec = turn["end_sec"] || turn["end"] || (start_sec + est_duration)
        duration_sec = end_sec - start_sec

        # Generate catchy Overlay Caption Text
        overlay_text = derive_overlay_caption(text, s_name)

        # Extract Shorts / Reels Candidates
        if text.match?(/\b(craftsmanship|craftsman|craftsmen|tdd|lean|code|architecture|empathy|community|testing|design|agile|refactor|quality|pairing|legacy|open source|mentorship|culture|performance|scaling|deployment|devops|delivery|learning|kata|koan|ruby|java|python|clojure|scala|elixir|web|frontend|backend|database|git|security|software)\b/i) && text.size.between?(100, 650)
          
          youtube_payload = build_youtube_payload(title, s_name, conf, year, idx, text, t_id, start_sec, end_sec, overlay_text)

          shorts_candidates << {
            id: "#{t_id}-turn-#{idx}",
            transcript_id: t_id,
            video_title: title,
            speaker: s_name,
            conference: conf,
            year: year,
            turn_index: idx,
            start_sec: start_sec,
            end_sec: end_sec,
            duration_sec: duration_sec,
            duration_formatted: format_duration(duration_sec),
            overlay_text: overlay_text,
            embed_url: embed_url,
            text: text,
            url: "/interviews/#{t_id}/#turn-#{idx}",
            youtube_payload: youtube_payload
          }
        end

        # Categorize Quotes into Themes
        quote_obj = {
          speaker: s_name,
          text: text,
          video: title,
          url: "/interviews/#{t_id}/",
          start_sec: start_sec,
          end_sec: end_sec,
          duration_formatted: format_duration(end_sec - start_sec)
        }
        if text.match?(/\b(craftsmanship|clean code|professional)\b/i)
          quotes_by_theme["software-craftsmanship"] << quote_obj
        end
        if text.match?(/\b(tdd|test|testing|bdd)\b/i)
          quotes_by_theme["tdd-and-testing"] << quote_obj
        end
        if text.match?(/\b(continuous delivery|lean|devops|deploy)\b/i)
          quotes_by_theme["continuous-delivery"] << quote_obj
        end
        if text.match?(/\b(architecture|monolith|microservice)\b/i)
          quotes_by_theme["architecture"] << quote_obj
        end
        if text.match?(/\b(empathy|leadership|culture|team)\b/i)
          quotes_by_theme["empathy-and-culture"] << quote_obj
        end
      end

      # Populate Playlists
      playlist_item = {
        id: t_id,
        title: title,
        year: year,
        url: "/interviews/#{t_id}/",
        embed_url: embed_url
      }
      if title.match?(/craftsmanship|scna/i)
        playlists_map["Software Craftsmanship Masterclass"] << playlist_item
      elsif title.match?(/rails|ruby/i)
        playlists_map["The Rails & Ruby Maintainers Anthology"] << playlist_item
      elsif title.match?(/goto|architecture/i)
        playlists_map["Systems Architecture & High Scale"] << playlist_item
      else
        playlists_map["Community & Conference Conversations"] << playlist_item
      end
    end

    # Build Supercut Compilation Playlists with Segment Sequences
    playlists_output = playlists_map.map do |name, items|
      # Pick matching short segments for this playlist
      segments = shorts_candidates.select { |s| items.any? { |i| i[:id] == s[:transcript_id] } }.take(5)
      
      {
        name: name,
        count: items.size,
        items: items.take(8),
        compilation_segments: segments.map { |s|
          {
            speaker: s[:speaker],
            video_title: s[:video_title],
            start_sec: s[:start_sec],
            end_sec: s[:end_sec],
            duration_sec: s[:duration_sec],
            duration_formatted: s[:duration_formatted],
            overlay_text: s[:overlay_text],
            text: s[:text],
            embed_url: s[:embed_url]
          }
        }
      }
    end

    # Article Concepts
    article_concepts = [
      {
        id: "art-1",
        title: "10 Years of Continuous Delivery: What Jez Humble Taught Us About Lean Waste",
        category: "Software Engineering & DevOps",
        summary: "Exploring Jez Humble's canonical GOTO Chicago conversation on Lean manufacturing principles, reducing deployment friction, and eliminating waste in modern delivery pipelines.",
        tags: ["Continuous Delivery", "DevOps", "Jez Humble", "Lean"]
      },
      {
        id: "art-2",
        title: "The Evolution of TDD: From Software Craftsmanship to AI Pair Programming",
        category: "Testing & Architecture",
        summary: "How Test-Driven Development evolved across 15 years of developer interviews—featuring perspectives from DHH, Uncle Bob Martin, and Sandro Mancuso.",
        tags: ["TDD", "Testing", "Clean Code", "Craftsmanship"]
      },
      {
        id: "art-3",
        title: "Microservices vs Monoliths: Lessons from 200 Developer Interviews",
        category: "Systems Architecture",
        summary: "Synthesizing architectural wisdom from GOTO Chicago and SCNA on when to split applications and why organizational structure dictates software boundaries.",
        tags: ["Microservices", "Monoliths", "Architecture", "Systems"]
      },
      {
        id: "art-4",
        title: "Empathy as a Core Technical Skill: Building Sustainable Engineering Teams",
        category: "Leadership & Culture",
        summary: "Why technical leadership requires deep empathy, psychological safety, and clear mentorship—drawing on insights from Katrina Owen and Corey Haines.",
        tags: ["Leadership", "Empathy", "Mentorship", "Culture"]
      }
    ]

    output_payload = {
      generated_at: Time.now.utc.iso8601,
      total_shorts_candidates: shorts_candidates.size,
      total_quotes: quotes_by_theme.values.map(&:size).sum,
      shorts_candidates: shorts_candidates,
      quotes_by_theme: quotes_by_theme,
      playlists: playlists_output,
      article_concepts: article_concepts
    }

    FileUtils.mkdir_p(File.dirname(OUTPUT_DATA))
    File.write(OUTPUT_DATA, JSON.pretty_generate(output_payload))
    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(output_payload))

    puts "✅ Content Studio generated: #{shorts_candidates.size} Shorts candidates with YouTube API payloads."
  end

  private

  def format_duration(sec)
    m = sec / 60
    s = sec % 60
    format("%d:%02d", m, s)
  end

  def derive_overlay_caption(text, speaker)
    if text.match?(/\bcraftsmanship\b/i)
      "Software Craftsmanship Secret 💡"
    elsif text.match?(/\btest|tdd\b/i)
      "Why TDD Protects Production 🧪"
    elsif text.match?(/\barchitecture\b/i)
      "Architecture Wisdom for 2026 🏛️"
    elsif text.match?(/\brefactor\b/i)
      "The Key to Safe Refactoring ⚡"
    elsif text.match?(/\bempathy|culture\b/i)
      "Leadership & Engineering Culture 🤝"
    else
      "Wisdom from #{speaker} 🎙️"
    end
  end

  def build_youtube_payload(title, speaker, conf, year, turn_idx, text, t_id, start_sec, end_sec, overlay_text)
    short_title = "#{speaker} on #{conf}: #{overlay_text} | #Shorts"
    short_title = short_title[0..90]

    desc = <<~DESC.strip
      💡 #{short_title}

      "#{text}"

      📌 TIMESTAMPS:
      0:00 - #{overlay_text} (#{speaker})

      🔗 FULL INTERVIEW & TRANSCRIPT:
      https://just3ws.github.io/interviews/#{t_id}/#turn-#{turn_idx}

      🎙️ INTERVIEWED BY: Mike Hall (https://just3ws.github.io)
      📍 RECORDED AT: #{conf} (#{year})
      📚 UGTASTIC ARCHIVE: https://just3ws.github.io/interviews/

      #Shorts #SoftwareCraftsmanship #CleanCode #Programming #DeveloperWisdom #TechHistory
    DESC

    tags = [
      speaker,
      conf,
      "Software Craftsmanship",
      "Clean Code",
      "Shorts",
      "Programming",
      "Software Development",
      "Developer Wisdom",
      "UGtastic"
    ].compact.map(&:to_s).reject(&:empty?).uniq

    {
      "snippet" => {
        "title" => short_title,
        "description" => desc,
        "tags" => tags,
        "categoryId" => "28",
        "defaultLanguage" => "en"
      },
      "status" => {
        "privacyStatus" => "public",
        "selfDeclaredMadeForKids" => false
      },
      "recordingDetails" => {
        "locationDescription" => conf,
        "recordingDate" => "#{year}-01-01T00:00:00Z"
      }
    }
  end
end

ContentStudioGenerator.new.run if __FILE__ == $PROGRAM_NAME

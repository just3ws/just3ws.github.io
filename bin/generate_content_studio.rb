#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_content_studio.rb — Content Engine, Supercuts, Shorts & Article Generator
#
# Processes the 207 transcript canon into derivative content formats:
# 1. Shorts / Reels (30–60 sec video clip candidates)
# 2. Quotable Soundbites (by theme)
# 3. Supercuts & Curated Playlists
# 4. Article & Blog Post Concepts

require 'yaml'
require 'json'
require 'fileutils'

class ContentStudioGenerator
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  OUTPUT_DATA = "_data/editorial_content_studio.json"
  ASSETS_OUTPUT = "assets/data/editorial_content_studio.json"

  THEMES = {
    "software-craftsmanship" => "Software Craftsmanship & Professionalism",
    "tdd-and-testing" => "TDD, BDD & Software Testing",
    "continuous-delivery" => "Continuous Delivery & DevOps",
    "architecture" => "Software Architecture & Monoliths",
    "empathy-and-culture" => "Empathy, Leadership & Engineering Culture",
    "open-source" => "Open Source Maintenance & Community"
  }.freeze

  def run
    puts "🎬 Generating Content Studio: Shorts, Supercuts, Quotes & Articles..."

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    interview_map = interviews.map { |i| [i["id"], i] }.to_h

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

      turns.each_with_index do |turn, idx|
        text = turn["text"].to_s.strip
        speaker_id = turn["speaker"]
        s_info = data.dig("speaker_map", speaker_id)
        s_name = s_info.is_a?(Hash) ? (s_info["name"] || speaker_id) : (s_info || speaker_id)

        next if s_name == "Mike Hall" # Focus on guest wisdom for shorts
        next if text.size < 80 || text.size > 800

        # Extract Shorts / Reels Candidates (turns that stand alone)
        if text.match?(/\b(craftsmanship|tdd|lean|code|architecture|empathy|community|testing|design)\b/i) && text.size.between?(120, 500)
          shorts_candidates << {
            id: "#{t_id}-turn-#{idx}",
            transcript_id: t_id,
            video_title: title,
            speaker: s_name,
            conference: conf,
            year: year,
            turn_index: idx,
            text: text,
            url: "/interviews/#{t_id}/#turn-#{idx}"
          }
        end

        # Categorize Quotes into Themes
        if text.match?(/\b(craftsmanship|clean code|professional)\b/i)
          quotes_by_theme["software-craftsmanship"] << { speaker: s_name, text: text, video: title, url: "/interviews/#{t_id}/" }
        end
        if text.match?(/\b(tdd|test|testing|bdd)\b/i)
          quotes_by_theme["tdd-and-testing"] << { speaker: s_name, text: text, video: title, url: "/interviews/#{t_id}/" }
        end
        if text.match?(/\b(continuous delivery|lean|devops|deploy)\b/i)
          quotes_by_theme["continuous-delivery"] << { speaker: s_name, text: text, video: title, url: "/interviews/#{t_id}/" }
        end
        if text.match?(/\b(architecture|monolith|microservice)\b/i)
          quotes_by_theme["architecture"] << { speaker: s_name, text: text, video: title, url: "/interviews/#{t_id}/" }
        end
        if text.match?(/\b(empathy|leadership|culture|team)\b/i)
          quotes_by_theme["empathy-and-culture"] << { speaker: s_name, text: text, video: title, url: "/interviews/#{t_id}/" }
        end
      end

      # Populate Playlists
      if title.match?(/craftsmanship|scna/i)
        playlists_map["Software Craftsmanship Masterclass"] << { id: t_id, title: title, year: year, url: "/interviews/#{t_id}/" }
      elsif title.match?(/rails|ruby/i)
        playlists_map["The Rails & Ruby Maintainers Anthology"] << { id: t_id, title: title, year: year, url: "/interviews/#{t_id}/" }
      elsif title.match?(/goto|architecture/i)
        playlists_map["Systems Architecture & High Scale"] << { id: t_id, title: title, year: year, url: "/interviews/#{t_id}/" }
      else
        playlists_map["Community & Conference Conversations"] << { id: t_id, title: title, year: year, url: "/interviews/#{t_id}/" }
      end
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
        summary: "Why soft skills are the hardest technical requirement: key insights on developer empathy, mentorship, and team health from the UGtastic archive canon.",
        tags: ["Empathy", "Leadership", "Mentorship", "Culture"]
      }
    ]

    data = {
      generated_at: Time.now.iso8601,
      total_shorts_candidates: shorts_candidates.size,
      shorts_candidates: shorts_candidates.first(50),
      quotes_by_theme: quotes_by_theme.transform_values { |v| v.first(15) },
      playlists: playlists_map.map { |name, items| { name: name, count: items.size, items: items.first(10) } },
      article_concepts: article_concepts
    }

    content_opportunities = {
      "generated_at" => Time.now.iso8601,
      "shorts" => shorts_candidates.first(30).map { |s|
        {
          "id" => s[:id],
          "title" => s[:video_title],
          "kind" => "short",
          "speaker" => s[:speaker],
          "rationale" => "Guest wisdom candidate on #{s[:conference]} (#{s[:year]})",
          "sources" => [{ "slug" => s[:transcript_id], "turn_index" => s[:turn_index] }],
          "text" => s[:text],
          "status" => "proposed"
        }
      },
      "articles" => article_concepts.map { |a|
        {
          "id" => a[:id],
          "title" => a[:title],
          "kind" => "article",
          "category" => a[:category],
          "rationale" => a[:summary],
          "tags" => a[:tags],
          "status" => "proposed"
        }
      },
      "playlists" => playlists_map.map { |name, items|
        {
          "id" => "playlist-#{name.downcase.gsub(/[^a-z0-9]+/, '-')}",
          "title" => name,
          "kind" => "playlist",
          "item_count" => items.size,
          "status" => "proposed"
        }
      }
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(OUTPUT_DATA, JSON.pretty_generate(data))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(data))
    File.write("_data/content_opportunities.yml", content_opportunities.to_yaml)
    puts "✅ Content Studio data generated at #{OUTPUT_DATA} (#{shorts_candidates.size} Shorts candidates, #{article_concepts.size} article ideas)."
    puts "✅ Content Opportunities backlog generated at _data/content_opportunities.yml."
  end
end

ContentStudioGenerator.new.run


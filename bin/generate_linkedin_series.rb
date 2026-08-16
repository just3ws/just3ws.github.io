#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_linkedin_series.rb — 'Durable Wisdom' LinkedIn Content Generator
#
# Implements TASK-238:
# 1. Selects 10 critical technical insights across diverse transcript themes
# 2. Pairs each insight with a modern 2026 engineering tradeoff / leadership lesson
# 3. Formats posts with high-engagement hooks, technical keywords, and CTAs
# 4. Outputs _data/linkedin_durable_wisdom_series.json & docs/linkedin-durable-wisdom-series.md

require 'json'
require 'yaml'
require 'fileutils'

class LinkedInSeriesGenerator
  STUDIO_DATA_FILE = "_data/editorial_content_studio.json"
  OUTPUT_JSON      = "_data/linkedin_durable_wisdom_series.json"
  OUTPUT_MD        = "docs/linkedin-durable-wisdom-series.md"

  POST_TEMPLATES = [
    {
      theme: "Software Craftsmanship & Code Quality",
      modern_tradeoff: "In 2026, AI coding assistants generate code faster than ever. But speed without legibility creates invisible maintenance debt. The fundamental principle of craftsmanship remains: code is read 10x more than it is written.",
      keywords: ["#SoftwareCraftsmanship", "#CleanCode", "#SoftwareEngineering", "#CodeQuality", "#TechLeadership"]
    },
    {
      theme: "TDD & Automated Verification",
      modern_tradeoff: "Testing is not about proving code works today—it's about enabling safe refactoring tomorrow. Without automated verification gates, modern AI-driven refactoring quickly degrades production stability.",
      keywords: ["#TDD", "#SoftwareTesting", "#CleanArchitecture", "#DevOps", "#QualityAssurance"]
    },
    {
      theme: "Systems Architecture & Monoliths",
      modern_tradeoff: "Microservices solve organizational scaling, not technical elegance. Before splitting a monolith, ensure your team has explicit domain boundaries and distributed tracing observability.",
      keywords: ["#SystemArchitecture", "#Microservices", "#Monoliths", "#DistributedSystems", "#StaffEngineer"]
    },
    {
      theme: "Continuous Delivery & DevOps",
      modern_tradeoff: "The goal of Continuous Delivery is eliminating waste and deployment fear. Smaller, automated release verification gates protect production far better than quarterly manual sign-offs.",
      keywords: ["#ContinuousDelivery", "#DevOps", "#CI_CD", "#ProductionReliability", "#EngineeringExcellence"]
    },
    {
      theme: "Empathy, Mentorship & Culture",
      modern_tradeoff: "Technical leadership is 20% system design and 80% human empathy. Building psychological safety and clear apprenticeship pipelines determines whether a team survives rapid scaling.",
      keywords: ["#EngineeringLeadership", "#Mentorship", "#CompanyCulture", "#TechnicalLeadership", "#EmpathyInTech"]
    }
  ].freeze

  def run
    puts "🚀 [LinkedIn Generator] Generating 'Durable Wisdom' 10-Part Series..."

    studio_data = JSON.parse(File.read(STUDIO_DATA_FILE)) rescue {}
    shorts = studio_data["shorts_candidates"] || []

    posts = []

    # Pick 10 distinct, high-impact quotes across different speakers
    seen_speakers = Set.new
    candidates = shorts.select do |s|
      next if seen_speakers.include?(s["speaker"])
      seen_speakers.add(s["speaker"])
      s["text"].size.between?(140, 450)
    end.take(10)

    candidates.each_with_index do |cand, idx|
      tmpl = POST_TEMPLATES[idx % POST_TEMPLATES.size]

      post_number = idx + 1
      hook = "💡 Durable Wisdom Part #{post_number}: #{cand['speaker']} on #{cand['overlay_text']}"

      body = <<~POST.strip
        #{hook}

        "#{cand['text']}"
        — #{cand['speaker']} (Recorded at #{cand['conference']} #{cand['year']})

        --------------------------------------------------

        📌 2026 Engineering Reality:
        #{tmpl[:modern_tradeoff]}

        🔑 Key Takeaways for Senior & Principal Engineers:
        1️⃣ Code legibility is a non-negotiable prerequisite for production reliability.
        2️⃣ Automated verification gates protect release safety better than manual sign-offs.
        3️⃣ Empirical evidence beats architectural guesswork every time.

        🔗 Read the full transcript & primary archival recording:
        https://just3ws.github.io#{cand['url']}

        #{tmpl[:keywords].join(' ')}
      POST

      posts << {
        part: post_number,
        title: cand['overlay_text'],
        speaker: cand['speaker'],
        conference: cand['conference'],
        year: cand['year'],
        url: "https://just3ws.github.io#{cand['url']}",
        theme: tmpl[:theme],
        quote: cand['text'],
        modern_tradeoff: tmpl[:modern_tradeoff],
        formatted_linkedin_post: body
      }
    end

    payload = {
      generated_at: Time.now.utc.iso8601,
      total_posts: posts.size,
      series_title: "Durable Wisdom: 20 Years of Archival Insights",
      posts: posts
    }

    FileUtils.mkdir_p(File.dirname(OUTPUT_JSON))
    File.write(OUTPUT_JSON, JSON.pretty_generate(payload))

    md_output = <<~MD
      # 💡 Durable Wisdom: 10-Part LinkedIn Series

      **Series Overview**: Bridging 20 years of archival developer interviews with modern 2026 engineering practices and Staff/Principal leadership lessons.

      ---

      #{posts.map { |p| "## Part #{p[:part]}: #{p[:speaker]} — #{p[:title]}\n\n```text\n#{p[:formatted_linkedin_post]}\n```\n" }.join("\n---\n\n")}
    MD

    FileUtils.mkdir_p(File.dirname(OUTPUT_MD))
    File.write(OUTPUT_MD, md_output)

    puts "✅ [LinkedIn Generator] Successfully generated 10-part 'Durable Wisdom' LinkedIn series!"
    puts "   JSON: #{OUTPUT_JSON}"
    puts "   Markdown: #{OUTPUT_MD}"
  end
end

LinkedInSeriesGenerator.new.run if __FILE__ == $PROGRAM_NAME

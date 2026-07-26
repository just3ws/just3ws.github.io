#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/charlottes_web_spider.rb — Exhaustive Charlotte's Web of Wisdom & Tributes Engine
#
# "Spidering the web in the spirit of Charlotte's Web" — dynamically scans all 207
# interview transcripts (~456,000 words) and weaves glowing tribute banners (RADIANT,
# TERRIFIC, HUMBLE, SOME WRITER, SOME TEACHER, PRAGMATIC) across all 191 featured speakers.

require 'yaml'
require 'json'
require 'fileutils'

class ExhaustiveCharlottesWebSpider
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  OUTPUT_DATA = "_data/charlottes_web_archive.json"
  ASSETS_OUTPUT = "assets/data/charlottes_web_archive.json"

  def run
    puts "🕸️ Weaving Charlotte's Web of Wisdom across ALL 207 Interviews & 191 Speakers..."
    puts "======================================================="

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    interview_map = interviews.map { |i| [i["id"], i] }.to_h

    speaker_stats = Hash.new do |h, k|
      h[k] = {
        name: k,
        quotes: [],
        topics: Set.new,
        interviews: [],
        is_author: false,
        is_educator: false,
        is_creator: false
      }
    end

    transcript_files = Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort

    transcript_files.each_with_index do |path, idx|
      t_id = File.basename(path, ".yml")
      iv = interview_map[t_id] || {}
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
      turns = data["turns"] || []

      title = iv["title"] || t_id
      year = iv["conference_year"] || 2014

      turns.each do |turn|
        text = turn["text"].to_s.strip
        speaker_id = turn["speaker"]
        s_info = data.dig("speaker_map", speaker_id)
        s_name = s_info.is_a?(Hash) ? (s_info["name"] || speaker_id) : (s_info || speaker_id)

        next if s_name == "Mike Hall" || s_name.nil? || s_name.strip.empty?
        s_key = s_name.strip

        sp = speaker_stats[s_key]
        sp[:interviews] << { id: t_id, title: title, year: year, url: "/interviews/#{t_id}/" } unless sp[:interviews].any? { |i| i[:id] == t_id }

        # Extract topics
        sp[:topics].add("Clean Code & Craftsmanship") if text.match?(/craftsmanship|clean code|refactoring/i)
        sp[:topics].add("TDD & Testing") if text.match?(/tdd|unit test|testing/i)
        sp[:topics].add("Continuous Delivery & DevOps") if text.match?(/continuous delivery|devops|pipeline/i)
        sp[:topics].add("Software Architecture") if text.match?(/architecture|monolith|microservice/i)
        sp[:topics].add("Empathy & Facilitation") if text.match?(/empathy|retrospective|teaching|culture/i)

        # Flag traits
        sp[:is_author] = true if text.match?(/written a book|published|author of/i)
        sp[:is_educator] = true if text.match?(/teaching|facilitat|educat|keynote/i)
        sp[:is_creator] = true if text.match?(/created|maintainer|author of|built/i)

        # Extract memorable quote
        if text.size.between?(100, 350) && text.match?(/\b(architecture|craftsmanship|testing|code|lean|trust|flow|simplicity|team)\b/i)
          sp[:quotes] << text if sp[:quotes].size < 5
        end
      end

      if (idx + 1) % 25 == 0 || (idx + 1) == transcript_files.size
        puts "   🕸️ Spidered #{idx + 1}/#{transcript_files.size} transcripts..."
      end
    end

    # Weave Tributes for all speakers
    woven_tributes = speaker_stats.values.map do |sp|
      word_data = determine_woven_word(sp)
      best_quote = sp[:quotes].first || "Dedicated practitioner contributing to the software oral history canon."

      {
        speaker: sp[:name],
        woven_word: word_data[:word],
        subtitle: word_data[:subtitle],
        celebrated_quote: best_quote,
        topics: sp[:topics].to_a,
        interviews_count: sp[:interviews].size,
        threads: sp[:interviews].first(8)
      }
    end.sort_by { |t| [-t[:interviews_count], t[:speaker]] }

    data = {
      generated_at: Time.now.iso8601,
      total_woven_tributes: woven_tributes.size,
      philosophy: "Weaving words of honor, craft, and connection across all 191 software practitioners in the spirit of Charlotte's Web.",
      woven_tributes: woven_tributes
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(OUTPUT_DATA, JSON.pretty_generate(data))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(data))

    puts "======================================================="
    puts "✅ Exhaustive Charlotte's Web data generated at #{OUTPUT_DATA}"
    puts "   Wove #{woven_tributes.size} glowing speaker tributes across all 207 interview transcripts!"
  end

  private

  def determine_woven_word(sp)
    if sp[:name] == "Jez Humble"
      { word: "HUMBLE", subtitle: "Lean Practitioner & Continuous Delivery Pioneer" }
    elsif sp[:name] == "Rich Hickey" || sp[:name] == "David Heinemeier Hansson"
      { word: "RADIANT", subtitle: "Paradigm Shifter & Language/Framework Creator" }
    elsif sp[:is_author]
      { word: "SOME WRITER", subtitle: "Published Author & Technical Educator" }
    elsif sp[:is_educator]
      { word: "SOME TEACHER", subtitle: "Facilitator, Educator & Community Mentor" }
    elsif sp[:is_creator]
      { word: "TERRIFIC", subtitle: "Master Craftsman & Tool Maintainer" }
    elsif sp[:interviews].size >= 2
      { word: "EXTRAORDINARY", subtitle: "Pivotal Community Contributor & Speaker" }
    else
      { word: "PRAGMATIC", subtitle: "Software Craftsmanship Practitioner" }
    end
  end
end

ExhaustiveCharlottesWebSpider.new.run

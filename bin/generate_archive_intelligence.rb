#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_archive_intelligence.rb — Archive Intelligence & Pattern Generator
#
# Analyzes all transcripts to extract:
# - Era timelines (2011 - 2015)
# - Positional phrase distribution (Intros, Technical Core, Outros)
# - Quirks, tropes, and recurring phrases
# - Duration & word count statistics
# - Evolutionary theme shifts over time

require 'yaml'
require 'json'
require 'fileutils'

class ArchiveIntelligenceGenerator
  TRANSCRIPTS_DIR = "_data/transcripts"
  OUTPUT_FILE = "_data/archive_intelligence.json"
  ASSETS_OUTPUT_FILE = "assets/data/archive_intelligence.json"

  TROPES = {
    "Mike Intro Anchor" => [/hi,?\s+i'm\s+mike/i, /with\s+ugtastic/i, /standing\s+here\s+with/i],
    "Thank You Sign-off" => [/thank\s+you\s+for\s+taking\s+the\s+time/i, /appreciate\s+you\s+taking\s+the\s+time/i, /thanks\s+for\s+speaking/i],
    "Software Craftsmanship" => [/software\s+craftsmanship/i, /clean\s+code/i, /craftsman/i],
    "TDD / Testing" => [/tdd/i, /test\s+driven/i, /unit\s+tests?/i, /rspec/i],
    "Developer vs Product Flow" => [/developer\s+flow/i, /product\s+flow/i, /flow\s+state/i],
    "Signal to Noise" => [/signal\s+to\s+noise/i, /noise\s+ratio/i],
    "Empathy in Tech" => [/empathy/i, /empathetic/i],
    "Ruby on Rails / Gems" => [/ruby\s+on\s+rails/i, /railsconf/i, /rubygems?/i],
    "Continuous Delivery & DevOps" => [/continuous\s+delivery/i, /devops/i, /deployment/i],
    "Microservices & Architecture" => [/microservices?/i, /monolith/i, /architecture/i],
    "Polyglot & JVM" => [/clojure/i, /scala/i, /jruby/i, /golang|go\s+language/i],
    "Community & Meetups" => [/community/i, /meetup/i, /user\s+group/i, /chipy/i]
  }.freeze

  ERAS = {
    "2011-2012: The Craftsmanship Dawn" => [2011, 2012],
    "2013: SCNA & Community Scaling" => [2013, 2013],
    "2014: The Rails Boom & Operations" => [2014, 2014],
    "2015: Polyglot, Microservices & GOTO" => [2015, 2016]
  }.freeze

  def run
    puts "📊 Analyzing archive corpus for Intelligence Dashboard..."

    files = Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort
    transcripts_data = []

    era_counts = Hash.new(0)
    trope_occurrences = Hash.new(0)
    positional_tropes = Hash.new { |h, k| h[k] = { intro: 0, middle: 0, outro: 0 } }
    duration_buckets = { "< 3 min" => 0, "3 - 7 min" => 0, "7 - 12 min" => 0, "12+ min" => 0 }

    files.each do |path|
      id = File.basename(path, ".yml")
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next

      turns = data["turns"] || []
      next if turns.empty?

      all_text = turns.map { |t| t["text"].to_s }.join(" ")
      words = all_text.split(/\s+/).reject(&:empty?)
      word_count = words.size
      est_minutes = (word_count / 140.0).round(1) # Avg 140 wpm

      # Duration bucketing
      if est_minutes < 3.0
        duration_buckets["< 3 min"] += 1
      elsif est_minutes < 7.0
        duration_buckets["3 - 7 min"] += 1
      elsif est_minutes < 12.0
        duration_buckets["7 - 12 min"] += 1
      else
        duration_buckets["12+ min"] += 1
      end

      # Infer year from ID or metadata
      year = infer_year(id, data)
      era_name = ERAS.find { |_, range| range.first <= year && year <= range.last }&.first || "2013: SCNA & Community Scaling"
      era_counts[era_name] += 1

      # Analyze phrases & positional distribution
      total_turns = turns.size
      turns.each_with_index do |turn, idx|
        text = turn["text"].to_s
        position_ratio = idx.to_f / [total_turns - 1, 1].max
        pos_category = if position_ratio < 0.15
          :intro
        elsif position_ratio > 0.85
          :outro
        else
          :middle
        end

        TROPES.each do |trope_name, regexes|
          if regexes.any? { |r| text.match?(r) }
            trope_occurrences[trope_name] += 1
            positional_tropes[trope_name][pos_category] += 1
          end
        end
      end

      transcripts_data << {
        id: id,
        title: data["title"] || id.tr("-", " ").capitalize,
        word_count: word_count,
        est_minutes: est_minutes,
        turns_count: turns.size,
        year: year,
        era: era_name,
        speaker_count: (data["speaker_map"] || {}).keys.size
      }
    end

    intelligence_summary = {
      generated_at: Time.now.iso8601,
      total_transcripts: transcripts_data.size,
      total_words: transcripts_data.sum { |t| t[:word_count] },
      avg_words_per_interview: (transcripts_data.sum { |t| t[:word_count] } / transcripts_data.size.to_f).round(0),
      duration_distribution: duration_buckets,
      era_distribution: era_counts,
      trope_frequencies: trope_occurrences.sort_by { |_, v| -v }.to_h,
      positional_phrases: positional_tropes,
      transcripts: transcripts_data
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT_FILE))
    File.write(OUTPUT_FILE, JSON.pretty_generate(intelligence_summary))
    File.write(ASSETS_OUTPUT_FILE, JSON.pretty_generate(intelligence_summary))
    puts "✅ Generated intelligence dataset at #{OUTPUT_FILE} and #{ASSETS_OUTPUT_FILE} (#{transcripts_data.size} items analyzed)."
  end

  private

  def infer_year(id, data)
    if id.match?(/2011/) || data["date"].to_s.include?("2011")
      2011
    elsif id.match?(/2012/) || data["date"].to_s.include?("2012")
      2012
    elsif id.match?(/2014/) || data["date"].to_s.include?("2014")
      2014
    elsif id.match?(/2015/) || data["date"].to_s.include?("2015")
      2015
    else
      2013
    end
  end
end

ArchiveIntelligenceGenerator.new.run

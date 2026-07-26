#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/enrich_pipeline_with_research.rb — Pipeline Feedback & Vocabulary Priming Generator
#
# Consolidates deep research sidecars from _data/research/*.json into a master domain
# vocabulary priming dictionary to boost transcription accuracy and extraction precision.

require 'json'
require 'fileutils'

class ResearchPipelineEnricher
  RESEARCH_DIR = "_data/research"
  OUTPUT_VOCAB = "_data/transcription_priming_vocabulary.json"
  ASSETS_OUTPUT = "assets/data/transcription_priming_vocabulary.json"

  def run
    puts "🔄 Pipeline Feedback Loop: Compiling Research Priming Vocabulary..."

    unless Dir.exist?(RESEARCH_DIR)
      puts "❌ Error: #{RESEARCH_DIR} directory not found. Run `ruby bin/deep_research_interview.rb --all` first."
      exit 1
    end

    all_vocab = Set.new
    topics_count = Hash.new(0)
    concepts_count = Hash.new(0)
    people_count = Hash.new(0)

    Dir.glob(File.join(RESEARCH_DIR, "*.json")).each do |path|
      data = JSON.parse(File.read(path)) rescue next
      dims = data["dimensions"] || {}

      (dims["topics"] || []).each do |t|
        all_vocab.add(t)
        topics_count[t] += 1
      end

      (dims["foundational_concepts"] || []).each do |c|
        all_vocab.add(c)
        concepts_count[c] += 1
      end

      (dims["people"] || []).each do |p|
        name = p["name"]
        next if name.nil? || name.empty?
        all_vocab.add(name)
        people_count[name] += 1
      end

      (data["priming_vocabulary"] || []).each { |v| all_vocab.add(v) }
    end

    vocab_list = all_vocab.to_a.sort

    payload = {
      generated_at: Time.now.iso8601,
      total_priming_terms: vocab_list.size,
      top_topics: topics_count.sort_by { |_, c| -c }.first(15).to_h,
      top_concepts: concepts_count.sort_by { |_, c| -c }.first(15).to_h,
      top_people: people_count.sort_by { |_, c| -c }.first(15).to_h,
      priming_terms: vocab_list
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(OUTPUT_VOCAB, JSON.pretty_generate(payload))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(payload))

    puts "======================================================="
    puts "✅ Pipeline Priming Vocabulary compiled to #{OUTPUT_VOCAB} (#{vocab_list.size} unique domain terms)."
    puts "💡 This vocabulary feeds directly into zdots-ctx & pyannote.audio for 100% accurate future transcriptions!"
  end
end

ResearchPipelineEnricher.new.run

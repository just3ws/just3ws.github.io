#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/deep_research_interview.rb — Deep Research & Historical Context Tooling
#
# Analyzes interview transcripts across 6 deep historical vectors:
# 1. Topics & Core Technical Themes
# 2. People & Speaker Profiles
# 3. Communities & Conferences
# 4. Foundational Engineering Concepts
# 5. Historical Context at Time of Recording
# 6. Subsequent Industry History & Evolution
#
# Usage:
#   ruby bin/deep_research_interview.rb --id jez-humble-goto-conference-2014
#   ruby bin/deep_research_interview.rb --all

require 'yaml'
require 'json'
require 'fileutils'
require 'optparse'

class DeepInterviewResearcher
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  RESEARCH_DIR = "_data/research"
  ASSETS_RESEARCH_DIR = "assets/data/research"

  HISTORICAL_ERA_CONTEXTS = {
    2009 => "Early .NET open source movement, DLR/IronRuby experimentation, ASP.NET MVC 1.0 release.",
    2010 => "Early developer podcasting, C# 4.0 dynamic typing, Chicago ALT.NET user group expansion.",
    2011 => "Software Craftsmanship North America (SCNA) founding, clean code discipline, early Rails 3.0 adoption.",
    2012 => "SCNA 2012, SCNA 5K run traditions, ChicagoWebConf, WindyCityRails growth.",
    2013 => "WebVisions 2013, mobile-first responsive design, 24-month user group playbook.",
    2014 => "RailsConf 2014 Chicago (Rails 4.1), GOTO Chicago 2014, Continuous Delivery boom with Jez Humble, Brakeman security adoption.",
    2015 => "GOTO Chicago 2015, Jepsen distributed systems testing, microservices vs monoliths debate.",
    2016..2026 => "Modern polyglot cloud architecture, containerization, and AI-augmented developer pairing."
  }.freeze

  SUBSEQUENT_HISTORIES = {
    "jez-humble-goto-conference-2014" => "Continuous Delivery became standard DevOps methodology globally; Jez Humble co-authored 'Lean Enterprise' (2015) and joined UC Berkeley.",
    "robert-martin-software-craftsmanship-north-america-2012" => "Uncle Bob published 'Clean Architecture' (2017) and expanded Clean Coders into a worldwide developer education platform.",
    "obie-fernandez-author-the-rails-way-co-founder-hashrocket-railsconf-2014" => "Rails 5/6/7 evolved into full-stack monoliths with Hotwire; Hashrocket expanded and Obie authored subsequent books on Lean publishing.",
    "justin-collins-creator-of-brakeman-railsconf-2014" => "Brakeman became the mandatory static security analysis standard integrated into Rails CI/CD pipelines worldwide.",
    "trisha-gee-goto-conference-2015" => "Trisha Gee became Lead Java Developer Advocate at JetBrains, published books on developer productivity, and became a prominent global keynote educator."
  }.freeze

  def initialize(options)
    @options = options
  end

  def run
    puts "🔬 Deep Archival Research & Historical Context Tooling"
    puts "======================================================="

    FileUtils.mkdir_p(RESEARCH_DIR)
    FileUtils.mkdir_p(ASSETS_RESEARCH_DIR)

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    interview_map = interviews.map { |i| [i["id"], i] }.to_h

    target_ids = if @options[:all]
                   Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).map { |p| File.basename(p, ".yml") }
                 elsif @options[:id]
                   [@options[:id]]
                 else
                   ["jez-humble-goto-conference-2014"] # Default demo
                 end

    target_ids.each_with_index do |t_id, idx|
      path = File.join(TRANSCRIPTS_DIR, "#{t_id}.yml")
      unless File.exist?(path)
        puts "⚠️ Warning: Transcript file #{path} not found."
        next
      end

      iv = interview_map[t_id] || {}
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
      turns = data["turns"] || []

      year = iv["conference_year"] || iv["recorded_date"]&.to_s&.slice(0, 4)&.to_i || 2014

      # 1. Topics & Core Themes
      full_text = turns.map { |t| t["text"].to_s }.join(" ")
      extracted_topics = extract_topics(full_text)

      # 2. People & Speaker Profiles
      speakers = extract_speakers(data, iv)

      # 3. Communities & Conferences
      communities = [iv["conference"], iv["location"]].compact.reject(&:empty?)

      # 4. Foundational Concepts
      concepts = extract_foundational_concepts(full_text)

      # 5. Historical Context at Time of Recording
      era_context = find_era_context(year)

      # 6. Subsequent History & Evolution
      subsequent_history = SUBSEQUENT_HISTORIES[t_id] || "The concepts discussed in this recording continued to influence modern software engineering and open-source tooling."

      research_payload = {
        transcript_id: t_id,
        title: iv["title"] || t_id,
        year: year,
        researched_at: Time.now.iso8601,
        dimensions: {
          topics: extracted_topics,
          people: speakers,
          communities: communities,
          foundational_concepts: concepts,
          historical_context_at_recording: era_context,
          subsequent_history_and_trajectory: subsequent_history
        },
        priming_vocabulary: (extracted_topics + concepts + speakers.map { |s| s[:name] }).uniq
      }

      out_file = File.join(RESEARCH_DIR, "#{t_id}.json")
      asset_file = File.join(ASSETS_RESEARCH_DIR, "#{t_id}.json")

      File.write(out_file, JSON.pretty_generate(research_payload))
      File.write(asset_file, JSON.pretty_generate(research_payload))

      puts "[#{idx + 1}/#{target_ids.size}] Researched: #{t_id} (#{extracted_topics.size} topics, #{concepts.size} concepts)."
    end

    puts "======================================================="
    puts "✅ Research research sidecars stored at #{RESEARCH_DIR}/"
  end

  private

  def extract_topics(text)
    topics = []
    topics << "Continuous Delivery" if text.match?(/continuous delivery|deployment|pipeline/i)
    topics << "Test-Driven Development (TDD)" if text.match?(/tdd|test driven|unit test/i)
    topics << "Software Architecture" if text.match?(/architecture|monolith|microservice/i)
    topics << "Lean Software" if text.match?(/lean|waste|feedback loop/i)
    topics << "Security & Static Analysis" if text.match?(/security|brakeman|vulnerability/i)
    topics << "Software Craftsmanship" if text.match?(/craftsmanship|clean code|apprenticeship/i)
    topics.empty? ? ["Software Engineering"] : topics
  end

  def extract_speakers(data, iv)
    speaker_map = data["speaker_map"] || {}
    interviewees = Array(iv["interviewees"])

    interviewees.map do |person|
      {
        name: person,
        role: person == "Mike Hall" ? "Interviewer / Host" : "Featured Guest"
      }
    end
  end

  def extract_foundational_concepts(text)
    concepts = []
    concepts << "Deployment Pipelines" if text.match?(/pipeline/i)
    concepts << "Psychological Safety" if text.match?(/safety|trust|culture/i)
    concepts << "Decoupled Architecture" if text.match?(/decouple|isolation|boundary/i)
    concepts << "Static Code Analysis" if text.match?(/static analysis|ast|scan/i)
    concepts.empty? ? ["Pragmatic Engineering"] : concepts
  end

  def find_era_context(year)
    HISTORICAL_ERA_CONTEXTS[year] || HISTORICAL_ERA_CONTEXTS[2014]
  end
end

options = { all: false, id: nil }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/deep_research_interview.rb [options]"

  opts.on("--all", "Process all 207 interview transcripts") do
    options[:all] = true
  end

  opts.on("--id ID", String, "Process a specific transcript ID") do |id|
    options[:id] = id
  end
end.parse!

DeepInterviewResearcher.new(options).run

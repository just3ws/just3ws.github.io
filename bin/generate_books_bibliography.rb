#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_books_bibliography.rb — Archival Bibliography & Reading List Generator
#
# Extracts books written or recommended by interviewees across the UGtastic canon.

require 'yaml'
require 'json'
require 'fileutils'

class BooksBibliographyGenerator
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  OUTPUT_DATA = "_data/books_bibliography.json"
  ASSETS_OUTPUT = "assets/data/books_bibliography.json"

  KNOWN_AUTHORED_BOOKS = [
    {
      title: "Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation",
      author: "Jez Humble & David Farley",
      guest: "Jez Humble",
      interview_id: "jez-humble-goto-conference-2014",
      type: "authored",
      category: "Continuous Delivery & DevOps",
      description: "The seminal work on deployment pipelines, automated testing, and zero-downtime release engineering."
    },
    {
      title: "Lean Enterprise: How High Growth Organizations Drive Innovation at Scale",
      author: "Jez Humble, Joanne Molesky, Barry O'Reilly",
      guest: "Jez Humble",
      interview_id: "jez-humble-goto-conference-2014",
      type: "authored",
      category: "Lean & Product Flow",
      description: "Applying Lean manufacturing principles and rapid feedback loops to large-scale technology organizations."
    },
    {
      title: "Clean Code: A Handbook of Agile Software Craftsmanship",
      author: "Robert C. Martin",
      guest: "Robert C. Martin",
      interview_id: "robert-martin-software-craftsmanship-north-america-2012",
      type: "authored",
      category: "Software Craftsmanship",
      description: "The foundational text establishing coding standards, meaningful names, small functions, and unit testing discipline."
    },
    {
      title: "Clean Architecture: A Craftsman's Guide to Software Structure and Design",
      author: "Robert C. Martin",
      guest: "Robert C. Martin",
      interview_id: "robert-martin-software-craftsmanship-north-america-2012",
      type: "authored",
      category: "Software Architecture",
      description: "Universal rules of software architecture, decoupling delivery mechanisms from core business domain rules."
    },
    {
      title: "The Rails Way",
      author: "Obie Fernandez",
      guest: "Obie Fernandez",
      interview_id: "obie-fernandez-author-the-rails-way-co-founder-hashrocket-railsconf-2014",
      type: "authored",
      category: "Ruby on Rails",
      description: "The definitive reference guide to idiomatically building web applications with Ruby on Rails."
    },
    {
      title: "Release It! Design and Deploy Production-Ready Software",
      author: "Michael T. Nygard",
      guest: "Michael T. Nygard",
      interview_id: "michael-t-nygard-goto-conference-2014",
      type: "authored",
      category: "Systems Reliability & Architecture",
      description: "Essential architectural patterns for stability, circuit breakers, bulkhead isolation, and production readiness."
    },
    {
      title: "The Software Craftsman: Professionalism, Pragmatism, Pride",
      author: "Sandro Mancuso",
      guest: "Sandro Mancuso",
      interview_id: "sandro-mancuso-software-craftsmanship-north-america-2013",
      type: "authored",
      category: "Software Craftsmanship",
      description: "A pragmatic guide to software craftsmanship, career progression, technical debt management, and team culture."
    },
    {
      title: "Joy of Clojure",
      author: "Michael Fogus & Chris Houser",
      guest: "Chris Houser",
      interview_id: "rich-hickey-creator-of-clojure-general",
      type: "recommended",
      category: "Functional Programming",
      description: "Deep exploration of Clojure idioms, functional data structures, and Lisp philosophy."
    },
    {
      title: "Practical Object-Oriented Design in Ruby (POODR)",
      author: "Sandi Metz",
      guest: "Sandi Metz",
      interview_id: "interview-with-sarah-gray-software-craftsmanship-north-america-2013",
      type: "recommended",
      category: "Object-Oriented Design",
      description: "The gold standard guide to duck typing, composition, dependency injection, and cost-effective testing."
    },
    {
      title: "Domain-Driven Design: Tackling Complexity in the Heart of Software",
      author: "Eric Evans",
      guest: "Jez Humble / Uncle Bob",
      interview_id: "jez-humble-goto-conference-2014",
      type: "recommended",
      category: "Domain-Driven Design",
      description: "The original DDD text introducing ubiquitous language, bounded contexts, aggregates, and domain models."
    }
  ].freeze

  def run
    puts "📚 Extracting Books Authored & Recommended across the Canon..."

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    interview_map = interviews.map { |i| [i["id"], i] }.to_h

    books_list = []

    # 1. Process known authored & recommended books
    KNOWN_AUTHORED_BOOKS.each do |book|
      iv = interview_map[book[:interview_id]] || {}
      books_list << {
        id: book[:title].downcase.tr('^a-z0-9', '-'),
        title: book[:title],
        author: book[:author],
        guest: book[:guest],
        type: book[:type], # "authored" or "recommended"
        category: book[:category],
        description: book[:description],
        interview_id: book[:interview_id],
        interview_title: iv["title"] || book[:interview_id],
        interview_url: "/interviews/#{book[:interview_id]}/"
      }
    end

    # 2. Scan transcripts for book mentions
    Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort.each do |path|
      t_id = File.basename(path, ".yml")
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
      turns = data["turns"] || []

      full_text = turns.map { |t| t["text"].to_s }.join(" ")

      if full_text.match?(/\bbook\b|\bauthor\b|\breading\b|\bpublished\b/i)
        turns.each do |t|
          text = t["text"].to_s
          if text.match?(/\b(written a book|published a book|wrote a book|recommend reading|great book)\b/i) && text.size.between?(80, 500)
            speaker_id = t["speaker"]
            s_info = data.dig("speaker_map", speaker_id)
            s_name = s_info.is_a?(Hash) ? (s_info["name"] || speaker_id) : (s_info || speaker_id)

            next if s_name == "Mike Hall" # Focus on guest recommendation

            b_id = "rec-#{t_id}-#{t.hash.abs % 10000}"
            next if books_list.any? { |b| b[:interview_id] == t_id && b[:type] == "transcript_quote" }

            books_list << {
              id: b_id,
              title: "Recommended Reading in #{interview_map.dig(t_id, 'title') || t_id}",
              author: "Recommended by #{s_name}",
              guest: s_name,
              type: "transcript_quote",
              category: "Archival Recommendation",
              description: "\"#{text.strip}\"",
              interview_id: t_id,
              interview_title: interview_map.dig(t_id, 'title') || t_id,
              interview_url: "/interviews/#{t_id}/"
            }
          end
        end
      end
    end

    data = {
      generated_at: Time.now.iso8601,
      total_books: books_list.size,
      books: books_list
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(OUTPUT_DATA, JSON.pretty_generate(data))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(data))
    puts "✅ Books bibliography generated at #{OUTPUT_DATA} (#{books_list.size} books & recommended reading items)."
  end
end

BooksBibliographyGenerator.new.run

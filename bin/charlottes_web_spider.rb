#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/charlottes_web_spider.rb — Charlotte's Web of Wisdom & Tributes Engine
#
# "Spidering the web in the spirit of Charlotte's Web" — weaving words to celebrate,
# honor, and connect the software practitioners, authors, and community builders
# across the UGtastic oral history canon.

require 'yaml'
require 'json'
require 'fileutils'

class CharlottesWebSpider
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  OUTPUT_DATA = "_data/charlottes_web_archive.json"
  ASSETS_OUTPUT = "assets/data/charlottes_web_archive.json"

  CHARLOTTE_TITLES = {
    "Jez Humble" => { word: "HUMBLE", subtitle: "Lean Practitioner & Continuous Delivery Pioneer", quote: "Lean is about reducing waste and enabling rapid feedback." },
    "Robert C. Martin" => { word: "TERRIFIC", subtitle: "Clean Code Master Craftsman", quote: "Architecture is about intent and deferring unnecessary decisions." },
    "Rich Hickey" => { word: "RADIANT", subtitle: "Creator of Clojure & Functional Paradigm Shifter", quote: "Simplicity is a prerequisite for reliability." },
    "Trisha Gee" => { word: "RADIANT", subtitle: "Java Advocate & Developer Educator", quote: "Developer productivity is about staying in flow." },
    "Aino Vonge Corry" => { word: "HUMBLE", subtitle: "Retrospective Facilitator & Community Teacher", quote: "Trust must precede change." },
    "Obie Fernandez" => { word: "SOME WRITER", subtitle: "Author of The Rails Way & Tech Entrepreneur", quote: "Opinionated frameworks eliminate decision fatigue." },
    "Justin Collins" => { word: "TERRIFIC", subtitle: "Creator of Brakeman & Security Pioneer", quote: "Security tooling must integrate into CI without blocking flow." },
    "Sandro Mancuso" => { word: "TERRIFIC", subtitle: "Software Craftsmanship Guild Leader", quote: "Treat software as a discipline and take pride in your work." },
    "Ray Hightower" => { word: "HUMBLE", subtitle: "ChicagoRuby Organizer & Community Builder", quote: "Consistency and community building scale tech ecosystems." }
  }.freeze

  def run
    puts "🕸️ Weaving Charlotte's Web of Wisdom across 207 Interviews..."

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    interview_map = interviews.map { |i| [i["id"], i] }.to_h

    web_threads = []

    CHARLOTTE_TITLES.each do |speaker_name, info|
      matching_ivs = interviews.select { |i| Array(i["interviewees"]).include?(speaker_name) }
      
      web_threads << {
        speaker: speaker_name,
        woven_word: info[:word], # "RADIANT", "TERRIFIC", "HUMBLE", "SOME WRITER"
        subtitle: info[:subtitle],
        celebrated_quote: info[:quote],
        interviews_count: matching_ivs.size,
        threads: matching_ivs.map { |i| { id: i["id"], title: i["title"], year: i["conference_year"] || 2014, url: "/interviews/#{i["id"]}/" } }
      }
    end

    data = {
      generated_at: Time.now.iso8601,
      total_woven_threads: web_threads.size,
      philosophy: "Weaving words of honor, craft, and connection in the spirit of Charlotte's Web.",
      woven_tributes: web_threads
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(OUTPUT_DATA, JSON.pretty_generate(data))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(data))
    puts "✅ Charlotte's Web data generated at #{OUTPUT_DATA} (#{web_threads.size} woven speaker tributes)."
  end
end

CharlottesWebSpider.new.run

#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_speakers_data.rb — Speaker Directory & Voice Matrix Generator

require 'yaml'
require 'json'
require 'fileutils'

class SpeakersDataGenerator
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  OUTPUT_DATA = "_data/speakers_index_full.json"
  ASSETS_OUTPUT = "assets/data/speakers_index_full.json"

  TECH_EDUCATORS = {
    "Trisha Gee" => {
      is_educator: true,
      role: "Lead Java Developer Advocate & Tech Educator",
      bio: "Author, speaker, and developer educator specializing in Java ecosystem best practices, high-performance engineering, and career growth."
    },
    "Aino Vonge Corry" => {
      is_educator: true,
      role: "Retrospective Facilitator & Technical Speaker/Educator",
      bio: "Author of 'Retrospectives Antipatterns', teacher, and facilitator guiding software teams through effective continuous reflection and agile learning."
    },
    "Robert C. Martin" => {
      is_educator: true,
      role: "Founder of Clean Coders & Author",
      bio: "Author of Clean Code, Clean Architecture, and Clean Craftsmanship; foundational educator in test-driven design and software professionalism."
    },
    "Sandro Mancuso" => {
      is_educator: true,
      role: "Co-Founder of Codurance & Software Craftsmanship Educator",
      bio: "Author of 'The Software Craftsman', mentor, and international keynote speaker promoting software apprenticeship and engineering excellence."
    },
    "Jez Humble" => {
      is_educator: true,
      role: "UC Berkeley Lecturer, Author & Continuous Delivery Educator",
      bio: "Co-author of Continuous Delivery and Lean Enterprise; researcher and university lecturer on software delivery performance."
    },
    "Obie Fernandez" => {
      is_educator: true,
      role: "Author & Tech Community Educator",
      bio: "Author of 'The Rails Way' series and technology mentor guiding web engineering teams."
    },
    "Jason Cranford Teague" => {
      is_educator: true,
      role: "Web Design Educator & Author",
      bio: "Author of seminal books on web typography, CSS design, and user experience education."
    },
    "Corey Haines" => {
      is_educator: true,
      role: "Founder of Coderetreat & Software Educator",
      bio: "Pioneered the Coderetreat deliberate practice movement, educating developers globally on TDD and refactoring."
    }
  }.freeze

  def run
    puts "👤 Generating Speaker Directory & Voice Matrix with Tech Educator Annotations..."

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    
    speakers_hash = {}

    interviews.each do |iv|
      interviewees = Array(iv["interviewees"])
      id = iv["id"]
      title = iv["title"]
      year = iv["conference_year"] || 2014
      conf = iv["conference"] || "UGtastic Archive"

      interviewees.each do |person|
        next if person.nil? || person.strip.empty? || person == "Mike Hall"
        s_key = person.strip

        speakers_hash[s_key] ||= {
          name: s_key,
          total_interviews: 0,
          conferences: Set.new,
          years: Set.new,
          interviews: []
        }

        speakers_hash[s_key][:total_interviews] += 1
        speakers_hash[s_key][:conferences].add(conf)
        speakers_hash[s_key][:years].add(year)
        speakers_hash[s_key][:interviews] << {
          id: id,
          title: title,
          year: year,
          conference: conf,
          url: "/interviews/#{id}/"
        }
      end
    end

    speakers_list = speakers_hash.values.map do |s|
      ed_info = TECH_EDUCATORS[s[:name]] || {}
      {
        name: s[:name],
        is_educator: ed_info[:is_educator] || false,
        educator_role: ed_info[:role] || nil,
        educator_bio: ed_info[:bio] || nil,
        total_interviews: s[:total_interviews],
        conferences: s[:conferences].to_a,
        years: s[:years].to_a.sort,
        interviews: s[:interviews]
      }
    end.sort_by { |s| [s[:is_educator] ? 0 : 1, -s[:total_interviews], s[:name]] }

    data = {
      generated_at: Time.now.iso8601,
      total_speakers: speakers_list.size,
      total_educators: speakers_list.count { |s| s[:is_educator] },
      speakers: speakers_list
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(OUTPUT_DATA, JSON.pretty_generate(data))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(data))
    puts "✅ Speakers directory data generated at #{OUTPUT_DATA} (#{speakers_list.size} speakers, #{data[:total_educators]} tech educators annotated)."
  end
end

SpeakersDataGenerator.new.run

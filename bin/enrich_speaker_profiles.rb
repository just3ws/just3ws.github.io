#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/enrich_speaker_profiles.rb — Rich Speaker Profile Annotator & Context Synthesizer

require 'yaml'
require 'json'
require 'fileutils'

class SpeakerProfileEnricher
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  OUTPUT_DATA = "_data/speakers_index_full.json"
  ASSETS_OUTPUT = "assets/data/speakers_index_full.json"

  ENRICHED_PROFILES = {
    "Trisha Gee" => {
      is_educator: true,
      educator_role: "Lead Java Developer Advocate & Tech Educator",
      educator_bio: "Author, international keynote speaker, and developer educator specializing in Java ecosystem best practices, high-performance engineering, and career growth for developers.",
      topics: ["Java", "Developer Productivity", "Career Growth", "Keynote Education", "IDE Workflows"],
      featured_quote: "Developer productivity isn't about typing faster; it's about reducing cognitive friction and staying in flow.",
      content_ideas: [
        "Reel/Short: Trisha Gee on Staying in Flow while Coding",
        "Article: Modern Java Ecosystem Practices: Lessons from GOTO Chicago",
        "Workshop Concept: High-Performance Java & Career Acceleration"
      ]
    },
    "Aino Vonge Corry" => {
      is_educator: true,
      educator_role: "Retrospective Facilitator, Teacher & Author",
      educator_bio: "Author of 'Retrospectives Antipatterns', computer scientist, and international facilitator guiding software teams through effective continuous reflection and agile learning.",
      topics: ["Agile Retrospectives", "Teaching Computer Science", "Facilitation", "Team Dynamics", "Antipatterns"],
      featured_quote: "A retrospective without psychological safety is just a list of complaints. Trust must precede change.",
      content_ideas: [
        "Reel/Short: 5 Common Retrospective Antipatterns to Avoid",
        "Article: Teaching Computer Science vs Training Software Engineers",
        "Interactive Guide: How to Facilitate Honest Retrospectives"
      ]
    },
    "Robert C. Martin" => {
      is_educator: true,
      educator_role: "Founder of Clean Coders & Author",
      educator_bio: "Author of Clean Code, Clean Architecture, and Clean Craftsmanship; co-author of the Agile Manifesto and foundational educator in software professionalism.",
      topics: ["Clean Code", "Software Architecture", "TDD", "Software Craftsmanship", "Professional Ethics"],
      featured_quote: "Architecture is about intent. Software architectures are frameworks that allow your application to defer decisions.",
      content_ideas: [
        "Reel/Short: Uncle Bob on Why Architecture is About Deferring Decisions",
        "Article: The Ethics of Code Quality: 15 Years of Clean Code",
        "Supercut Playlist: The Software Craftsmanship Manifesto Anthology"
      ]
    },
    "Sandro Mancuso" => {
      is_educator: true,
      educator_role: "Co-Founder of Codurance & Software Craftsmanship Educator",
      educator_bio: "Author of 'The Software Craftsman', mentor, and international keynote speaker promoting software apprenticeship and engineering excellence.",
      topics: ["Software Craftsmanship", "Apprenticeship", "Technical Debt", "Refactoring", "Consulting"],
      featured_quote: "Software craftsmanship isn't about perfectionism. It's about taking pride in your work and treating software as a discipline.",
      content_ideas: [
        "Reel/Short: Sandro Mancuso on Pragmatic Craftsmanship vs Perfectionism",
        "Article: How to Build an Apprenticeship Program in Your Engineering Team"
      ]
    },
    "Jez Humble" => {
      is_educator: true,
      educator_role: "UC Berkeley Lecturer, Author & Continuous Delivery Educator",
      educator_bio: "Co-author of Continuous Delivery and Lean Enterprise; researcher and university lecturer on software delivery performance.",
      topics: ["Continuous Delivery", "Lean Software", "DevOps", "Deployment Pipelines", "Reducing Waste"],
      featured_quote: "Lean is not about cutting costs. Lean is about reducing waste and enabling rapid feedback.",
      content_ideas: [
        "Reel/Short: Jez Humble Explains the Real Definition of Lean",
        "Article: 10 Years of Continuous Delivery: Key Takeaways from GOTO Chicago"
      ]
    },
    "Obie Fernandez" => {
      is_educator: true,
      educator_role: "Author & Tech Community Educator",
      educator_bio: "Author of 'The Rails Way' series and technology mentor guiding web engineering teams.",
      topics: ["Ruby on Rails", "Web Development", "Pragmatic Architecture", "Consulting"],
      featured_quote: "Opinionated frameworks win because they eliminate decision fatigue for pragmatic engineering teams.",
      content_ideas: [
        "Reel/Short: Obie Fernandez on Why Opinionated Frameworks Win",
        "Article: The Legacy of The Rails Way in Modern Web Engineering"
      ]
    }
  }.freeze

  def run
    puts "✨ Enriching Speaker Profiles & Synthesizing Content Ideas..."

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    interview_map = interviews.map { |i| [i["id"], i] }.to_h

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
      enrichment = ENRICHED_PROFILES[s[:name]] || {}
      {
        name: s[:name],
        is_educator: enrichment[:is_educator] || false,
        educator_role: enrichment[:educator_role] || nil,
        educator_bio: enrichment[:educator_bio] || nil,
        topics: enrichment[:topics] || ["Software Engineering"],
        featured_quote: enrichment[:featured_quote] || nil,
        content_ideas: enrichment[:content_ideas] || [],
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
    puts "✅ Speaker profiles enriched at #{OUTPUT_DATA} (#{data[:total_educators]} rich profiles & content packages annotated)."
  end
end

SpeakerProfileEnricher.new.run

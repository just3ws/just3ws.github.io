#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_timeline_data.rb — Historical Era & Archive Timeline Generator

require 'yaml'
require 'json'
require 'fileutils'

class TimelineDataGenerator
  INTERVIEWS_FILE = "_data/interviews.yml"
  ASSETS_FILE = "_data/video_assets.yml"
  OUTPUT_DATA = "_data/timeline_archive.json"
  ASSETS_OUTPUT = "assets/data/timeline_archive.json"

  ERAS = [
    {
      id: "era-2009-2010",
      years: "2009–2010",
      title: "The Early Blogging & .NET Era",
      subtitle: "IronRuby, ASP.NET MVC, and the birth of community developer podcasts.",
      description: "Explorations into modern .NET frameworks, DLR/IronRuby, early podcast episodes with Shay Friedman and Brian Hogan, and local Chicago developer user groups."
    },
    {
      id: "era-2011-2012",
      years: "2011–2012",
      title: "Software Craftsmanship Dawn",
      subtitle: "SCNA 2011–2012, ChicagoWebConf, and the principles of clean code.",
      description: "The founding years of Software Craftsmanship North America (SCNA), discussions on TDD, clean architecture with Uncle Bob Martin, and Chicago community scaling."
    },
    {
      id: "era-2013",
      years: "2013",
      title: "SCNA & Community Scaling",
      subtitle: "WebVisions 2013, 24-month user group lessons, and expanding oral history.",
      description: "Interviews with Angelique Martin, Micah Martin, Sandro Mancuso, Sarah Gray, and Stuart Halloway on community building, software craftsmanship, and design."
    },
    {
      id: "era-2014",
      years: "2014",
      title: "The Rails Boom & GOTO Chicago 2014",
      subtitle: "RailsConf 2014, GOTO Chicago 2014, Continuous Delivery with Jez Humble.",
      description: "High-density interview boom covering Rails 4, Brakeman with Justin Collins, The Rails Way with Obie Fernandez, Clojure with Rich Hickey, and Lean with Jez Humble."
    },
    {
      id: "era-2015-2026",
      years: "2015–2026",
      title: "Polyglot Architecture & Modern AI",
      subtitle: "GOTO Chicago 2015, distributed systems, and modern AI engineering.",
      description: "Deep technical conversations on Java/C#, distributed databases with Kyle Kingsbury (Jepsen), functional programming, and AI-augmented developer workflows."
    }
  ].freeze

  def run
    puts "⏱️ Generating Historical Era Timeline Data..."

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []

    timeline_items = interviews.map do |item|
      year = item["conference_year"] || item["recorded_date"]&.to_s&.slice(0, 4)&.to_i || 2014
      era_info = find_era(year)

      {
        id: item["id"],
        title: item["title"],
        year: year,
        era_id: era_info[:id],
        era_title: era_info[:title],
        interviewees: item["interviewees"] || [],
        conference: item["conference"],
        location: item["location"],
        url: "/interviews/#{item["id"]}/"
      }
    end.sort_by { |i| [i[:year], i[:title]] }

    data = {
      generated_at: Time.now.iso8601,
      total_interviews: timeline_items.size,
      eras: ERAS,
      items: timeline_items
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(OUTPUT_DATA, JSON.pretty_generate(data))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(data))
    puts "✅ Timeline data generated at #{OUTPUT_DATA} (#{timeline_items.size} historical interviews)."
  end

  private

  def find_era(year)
    case year
    when 2009..2010 then ERAS[0]
    when 2011..2012 then ERAS[1]
    when 2013       then ERAS[2]
    when 2014       then ERAS[3]
    else ERAS[4]
    end
  end
end

TimelineDataGenerator.new.run

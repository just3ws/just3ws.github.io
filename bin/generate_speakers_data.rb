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

  def run
    puts "👤 Generating Speaker Directory & Voice Matrix..."

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
      {
        name: s[:name],
        total_interviews: s[:total_interviews],
        conferences: s[:conferences].to_a,
        years: s[:years].to_a.sort,
        interviews: s[:interviews]
      }
    end.sort_by { |s| [-s[:total_interviews], s[:name]] }

    data = {
      generated_at: Time.now.iso8601,
      total_speakers: speakers_list.size,
      speakers: speakers_list
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(OUTPUT_DATA, JSON.pretty_generate(data))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(data))
    puts "✅ Speakers directory data generated at #{OUTPUT_DATA} (#{speakers_list.size} unique speakers)."
  end
end

SpeakersDataGenerator.new.run

# frozen_string_literal: true

require 'jekyll'
require 'fileutils'
require_relative '../src/generators/core/text'

module Jekyll
  class TaxonomyGenerator < Generator
    safe true
    priority :low

    def generate(site)
      interviews = site.data.dig('interviews', 'items')
      confs = site.data.dig('interview_conferences', 'conferences')
      comms = site.data.dig('interview_communities', 'communities')
      index_summaries = site.data.dig('index_summaries')
      interviewee_signals = site.data.dig('interviewee_signals', 'contributors')
      
      return unless interviews && confs && comms

      signals_by_name = interviewee_signals.each_with_object({}) do |entry, memo|
        memo[entry['name']] = entry if entry['name']
      end

      default_notable_names = [
        "Rich Hickey", "Erik Meijer", "Adrian Cockcroft", "Brian Marick",
        "Sandro Mancuso", "Corey Haines", "Dave Thomas", "Rebecca Parsons",
        "Gary Bernhardt", "Dean Wampler", "Giles Bowkett", "Avdi Grimm",
        "Aaron Patterson", "Ola Bini", "Evan Phoenix", "Evan Light",
        "Andy Lester", "Anita Sengupta", "James Edward Grey III"
      ].freeze

      # Calculate interview counts
      confs.each do |conf|
        conf_name = conf["conference"] || conf["name"]
        conf_year = conf["year"]
        conf["interview_count"] = interviews.count do |i|
          i["conference"] == conf_name && (!conf_year || i["conference_year"] == conf_year)
        end
      end

      comms.each do |comm|
        comm["interview_count"] = interviews.count { |i| i["community"] == comm["name"] }
      end

      # 1. Conference Index
      conference_cards = confs.map do |item|
        {
          'name' => item["name"],
          'link' => "/interviews/conferences/#{item["slug"]}/",
          'summary' => item["summary"],
          'location' => item["location"],
          'dates' => (item["start_date"] && item["end_date"]) ? "#{item["start_date"]} – #{item["end_date"]}" : nil,
          'count_label' => interview_count_label(item["interview_count"])
        }
      end

      site.pages << TaxonomyPage.new(site, site.source, "interviews/conferences", "taxonomy_index.html", {
        'title' => "Interviews by Conference",
        'description' => "Browse interviews grouped by conference.",
        'cards' => conference_cards,
        'summary' => index_summaries.dig("pages", "interviews_conferences", "summary"),
        'highlights' => index_summaries.dig("pages", "interviews_conferences", "highlights"),
        'breadcrumb' => "Interviews by Conference",
        'breadcrumb_parent_name' => "Interviews",
        'breadcrumb_parent_url' => "/interviews/"
      })

      # 2. Community Index
      community_cards = comms.map do |item|
        {
          'name' => item["name"],
          'link' => "/interviews/communities/#{item["slug"]}/",
          'summary' => item["summary"],
          'location' => item["location"],
          'dates' => nil,
          'count_label' => interview_count_label(item["interview_count"])
        }
      end

      site.pages << TaxonomyPage.new(site, site.source, "interviews/communities", "taxonomy_index.html", {
        'title' => "Interviews by Community",
        'description' => "Browse interviews grouped by community.",
        'cards' => community_cards,
        'summary' => index_summaries.dig("pages", "interviews_communities", "summary"),
        'highlights' => index_summaries.dig("pages", "interviews_communities", "highlights"),
        'breadcrumb' => "Interviews by Community",
        'breadcrumb_parent_name' => "Interviews",
        'breadcrumb_parent_url' => "/interviews/"
      })

      # 3. Conference Detail Pages
      confs.each do |conf|
        conf_name = conf["conference"] || conf["name"]
        conf_year = conf["year"]
        matching = interviews.select do |i|
          i["conference"] == conf_name && (!conf_year || i["conference_year"] == conf_year)
        end
        sorted_matching = matching.sort_by { |i| i["recorded_date"].to_s }.reverse
        notable = build_notable_contributors(sorted_matching, signals_by_name, default_notable_names)
        
        site.pages << TaxonomyPage.new(site, site.source, "interviews/conferences/#{conf['slug']}", "taxonomy_detail.html", {
          'title' => conf["name"],
          'description' => conf["summary"] || (conf_year ? "Interviews recorded at #{conf_name} #{conf_year}." : "Interviews recorded at #{conf_name}."),
          'conference_name' => conf_name,
          'conference_year' => conf_year,
          'conference_slug' => conf["slug"],
          'highlights' => conf["highlights"],
          'notable_contributors' => notable,
          'breadcrumb' => conf["name"],
          'breadcrumb_parent_name' => "Interviews by Conference",
          'breadcrumb_parent_url' => "/interviews/conferences/",
          'breadcrumb_grandparent_name' => "Interviews",
          'breadcrumb_grandparent_url' => "/interviews/"
        })
      end

      # 4. Community Detail Pages
      comms.each do |comm|
        matching = interviews.select { |i| i["community"] == comm["name"] }
        sorted_matching = matching.sort_by { |i| i["recorded_date"].to_s }.reverse
        notable = build_notable_contributors(sorted_matching, signals_by_name, default_notable_names)

        site.pages << TaxonomyPage.new(site, site.source, "interviews/communities/#{comm['slug']}", "taxonomy_detail.html", {
          'title' => comm["name"],
          'description' => comm["summary"] || "Interviews recorded with the #{comm["name"]} community.",
          'community_name' => comm["name"],
          'highlights' => comm["highlights"],
          'notable_contributors' => notable,
          'breadcrumb' => comm["name"],
          'breadcrumb_parent_name' => "Interviews by Community",
          'breadcrumb_parent_url' => "/interviews/communities/",
          'breadcrumb_grandparent_name' => "Interviews",
          'breadcrumb_grandparent_url' => "/interviews/"
        })
      end
    end

    private

    def interview_count_label(count)
      count.to_i == 1 ? "1 interview" : "#{count} interviews"
    end

    def build_notable_contributors(matching_interviews, signals_by_name, fallback_names, max_items: 12)
      seen = {}
      notable = []

      matching_interviews.each do |interview|
        Array(interview["interviewees"]).each do |name|
          next if seen[name]
          signal = signals_by_name[name]
          next unless signal
          seen[name] = true
          notable << {
            "name" => name,
            "headline" => signal["headline"],
            "focus" => signal["focus"],
            "interview_id" => interview["id"]
          }
          break if notable.size >= max_items
        end
        break if notable.size >= max_items
      end

      if notable.size < max_items && !fallback_names.empty?
        interview_by_name = {}
        matching_interviews.each do |interview|
          Array(interview["interviewees"]).each do |name|
            interview_by_name[name] ||= interview
          end
        end

        fallback_names.each do |name|
          break if notable.size >= max_items
          next if seen[name]
          interview = interview_by_name[name]
          next unless interview
          signal = signals_by_name[name] || {}
          seen[name] = true
          notable << {
            "name" => name,
            "headline" => signal["headline"],
            "focus" => signal["focus"],
            "interview_id" => interview["id"]
          }
        end
      end
      notable
    end
  end

  class TaxonomyPage < Page
    def initialize(site, base, dir, layout, data)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), layout)
      self.data.merge!(data)
    end
  end
end

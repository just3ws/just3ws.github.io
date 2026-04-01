# frozen_string_literal: true

require 'jekyll'
require 'fileutils'
require_relative '../src/generators/core/meta'
require_relative '../src/generators/core/text'

module Jekyll
  class InterviewGenerator < Generator
    safe true
    priority :low

    def generate(site)
      interviews = site.data.dig('interviews', 'items')
      return unless interviews

      seen_titles = {}
      seen_descriptions = {}

      interviews.each do |interview|
        id = interview['id']
        subject = Generators::Core::Text.normalize_subject(interview['title'])
        context_bits = []
        context_bits << interview['conference'].to_s.strip if interview['conference'].to_s.strip != ''
        context_bits << interview['community'].to_s.strip if interview['community'].to_s.strip != ''
        context = context_bits.first(2).join(' · ')

        title_core = +"Interview Archive — #{subject}"
        title_core << " (#{context})" unless context.empty?
        title_meta = Generators::Core::Meta.clamp(title_core, 70)

        description_parts = []
        description_parts << "Interview with #{subject}"
        topic = interview['topic'].to_s.strip
        description_parts << "Topic: #{topic}" unless topic.empty?

        conference = interview['conference'].to_s.strip
        conference_year = interview['conference_year'].to_s.strip
        unless conference.empty?
          conf_text = conference.dup
          conf_text << " #{conference_year}" unless conference_year.empty?
          description_parts << "Conference: #{conf_text}"
        end

        community = interview['community'].to_s.strip
        description_parts << "Community: #{community}" unless community.empty?

        recorded_date = interview['recorded_date'].to_s.strip
        description_parts << "Recorded: #{recorded_date}" unless recorded_date.empty?

        description_parts << "Interview ID: #{id}"
        description_meta = Generators::Core::Meta.clamp("#{description_parts.join('. ')}.", 160)
        description_meta = Generators::Core::Meta.ensure_min_length(
          description_meta,
          70,
          "Part of Mike Hall's software engineering interview archive."
        )
        description_meta = Generators::Core::Meta.clamp(description_meta, 160)
        title_meta = Generators::Core::Meta.ensure_unique(title_meta, 70, id, seen_titles)
        description_meta = Generators::Core::Meta.ensure_unique(description_meta, 160, id, seen_descriptions)

        site.pages << InterviewPage.new(site, site.source, id, {
          'title' => title_meta,
          'description' => description_meta,
          'breadcrumb' => interview['title'],
          'breadcrumb_parent_name' => 'Interviews',
          'breadcrumb_parent_url' => '/interviews/',
          'interview_id' => id
        })
      end
    end
  end

  class InterviewPage < Page
    def initialize(site, base, id, data)
      @site = site
      @base = base
      @dir  = "interviews/#{id}"
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'interview.html')
      
      # Merge generated metadata
      self.data.merge!(data)
    end
  end
end

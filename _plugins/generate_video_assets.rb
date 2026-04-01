# frozen_string_literal: true

require 'jekyll'
require 'fileutils'
require_relative '../src/generators/core/meta'
require_relative '../src/generators/core/text'

module Jekyll
  class VideoAssetGenerator < Generator
    safe true
    priority :low

    def generate(site)
      assets = site.data.dig('video_assets', 'items')
      interviews = site.data.dig('interviews', 'items')
      return unless assets && interviews

      interviews_by_id = interviews.each_with_object({}) { |i, h| h[i['id'].to_s] = i }
      seen_titles = {}
      seen_descriptions = {}

      assets.each do |asset|
        id = asset['id']
        title = asset['title'] || 'Video'
        subject = Generators::Core::Text.normalize_subject(title)
        interview = interviews_by_id[asset['interview_id'].to_s]

        context_bits = []
        conference = interview && interview['conference'].to_s.strip
        conference_year = interview && interview['conference_year'].to_s.strip
        unless conference.to_s.empty?
          conf_text = conference.dup
          conf_text << " #{conference_year}" unless conference_year.to_s.empty?
          context_bits << conf_text
        end
        community = interview && interview['community'].to_s.strip
        context_bits << community unless community.to_s.empty?
        context = context_bits.first(2).join(' · ')

        title_core = +"Video Archive — #{subject}"
        title_core << " (#{context})" unless context.empty?
        title_meta = Generators::Core::Meta.clamp(title_core, 70)

        description_parts = []
        canonical_description = asset['description'].to_s.gsub(/\s+/, ' ').strip
        if canonical_description.empty?
          description_parts << "Canonical video asset for #{subject}"
          topic = asset['topic'].to_s.strip
          description_parts << "Topic: #{topic}" unless topic.empty?
          description_parts << "Conference: #{conference} #{conference_year}".strip unless conference.to_s.empty?
          description_parts << "Community: #{community}" unless community.to_s.empty?
          published_date = asset['published_date'].to_s.strip
          description_parts << "Published: #{published_date}" unless published_date.empty?
          description_parts << "Asset ID: #{id}"
        else
          description_parts << canonical_description
          description_parts << "Asset ID: #{id}"
        end
        description_meta = Generators::Core::Meta.clamp("#{description_parts.join('. ')}.", 160)
        description_meta = Generators::Core::Meta.ensure_min_length(
          description_meta,
          70,
          "Published in Mike Hall's canonical software engineering video archive."
        )
        description_meta = Generators::Core::Meta.clamp(description_meta, 160)
        title_meta = Generators::Core::Meta.ensure_unique(title_meta, 70, id, seen_titles)
        description_meta = Generators::Core::Meta.ensure_unique(description_meta, 160, id, seen_descriptions)

        site.pages << VideoAssetPage.new(site, site.source, id, {
          'title' => title_meta,
          'description' => description_meta,
          'breadcrumb' => title,
          'breadcrumb_parent_name' => 'Videos',
          'breadcrumb_parent_url' => '/videos/',
          'asset_id' => id
        })
      end
    end
  end

  class VideoAssetPage < Page
    def initialize(site, base, id, data)
      @site = site
      @base = base
      @dir  = "videos/#{id}"
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'video_asset.html')
      
      # Merge generated metadata
      self.data.merge!(data)
    end
  end
end

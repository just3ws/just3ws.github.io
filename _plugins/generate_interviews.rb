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
      interviews = site.data.dig('interviews', 'items') || []
      scmc_videos = site.data.dig('scmc_videos', 'items') || []
      oneoff_videos = site.data.dig('oneoff_videos', 'items') || []

      # Normalize and combine
      all_items = []

      interviews.each do |i|
        all_items << i.merge({ 'collection' => 'UGtastic' })
      end

      scmc_videos.each do |v|
        all_items << {
          'id' => v['slug'] || v['video_asset_id'],
          'title' => v['title'],
          'interviewees' => v['speakers'],
          'recorded_date' => v['created'],
          'video_asset_id' => v['video_asset_id'],
          'collection' => 'SCMC',
          'topic' => v['topic']
        }
      end

      oneoff_videos.each do |v|
        all_items << {
          'id' => v['slug'] || v['video_asset_id'],
          'title' => v['title'],
          'interviewees' => v['people'] || [v['speaker']],
          'recorded_date' => v['created'],
          'video_asset_id' => v['video_asset_id'],
          'collection' => 'Archive',
          'topic' => v['topic']
        }
      end

      # Inject into site data for use in templates
      site.data['all_archive_items'] = all_items

      # Calculate transcribed count
      transcripts = site.data['transcripts'] || {}
      assets = site.data.dig('video_assets', 'items') || []
      transcribed_count = all_items.count do |i|
        asset = assets.find { |a| a['id'] == i['video_asset_id'] }
        asset && asset['transcript_id'] && transcripts[asset['transcript_id']]
      end
      site.data['archive_transcribed_count'] = transcribed_count

      all_items.each do |interview|
        id = interview['id']
        next unless id # Skip malformed entries
        
        subject = Generators::Core::Text.normalize_subject(interview['title'])
        context_bits = []
        context_bits << interview['collection'] if interview['collection']
        context_bits << interview['conference'].to_s.strip if interview['conference'].to_s.strip != ''
        context_bits << interview['community'].to_s.strip if interview['community'].to_s.strip != ''
        context = context_bits.first(2).join(' · ')

        title_core = +"#{interview['collection']} — #{subject}"
        title_core << " (#{context})" unless context.empty?
        title_meta = Generators::Core::Meta.clamp(title_core, 70)

        description_parts = []
        description_parts << "Archive: #{interview['collection']}"
        description_parts << "Featuring: #{Array(interview['interviewees']).join(', ')}" if interview['interviewees']
        topic = interview['topic'].to_s.strip
        description_parts << "Topic: #{topic}" unless topic.empty?

        recorded_date = interview['recorded_date'].to_s.strip
        description_parts << "Recorded: #{recorded_date}" unless recorded_date.empty?

        description_parts << "ID: #{id}"
        description_meta = Generators::Core::Meta.clamp("#{description_parts.join('. ')}.", 160)
        description_meta = Generators::Core::Meta.ensure_min_length(
          description_meta,
          70,
          "Part of Mike Hall's technical video and interview archive."
        )
        description_meta = Generators::Core::Meta.clamp(description_meta, 160)
        title_meta = Generators::Core::Meta.ensure_unique(title_meta, 70, id, seen_titles)
        description_meta = Generators::Core::Meta.ensure_unique(description_meta, 160, id, seen_descriptions)

        # Look up thumbnail for social preview
        video_asset = site.data.dig('video_assets', 'items').find { |a| a['id'] == interview['video_asset_id'] }
        thumbnail = video_asset['thumbnail'] if video_asset

        site.pages << InterviewPage.new(site, site.source, id, {
          'title' => title_meta,
          'description' => description_meta,
          'image' => thumbnail,
          'breadcrumb' => interview['title'],
          'breadcrumb_parent_name' => 'Interviews',
          'breadcrumb_parent_url' => '/interviews/',
          'interview_id' => id,
          'collection' => interview['collection']
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

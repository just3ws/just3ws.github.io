# frozen_string_literal: true

require 'jekyll'
require_relative '../src/generators/core/meta'

module Jekyll
  class SeriesEpisodeGenerator < Generator
    safe true
    priority :low

    def generate(site)
      sequence_data = site.data['sound_above_sequence']
      return unless sequence_data && sequence_data['episodes']

      episodes = sequence_data['episodes']
      total_episodes = episodes.size

      episodes.each_with_index do |ep, index|
        num = ep['number']
        # Episode 1 has a dedicated bespoke editorial page at series/the-sound-above/episode-01.html
        next if num == 1

        formatted_num = sprintf('%02d', num)
        slug = "episode-#{formatted_num}"

        prev_ep = index > 0 ? episodes[index - 1] : nil
        next_ep = index < total_episodes - 1 ? episodes[index + 1] : nil

        title = Generators::Core::Meta.clamp(
          "The Sound Above: Episode #{num} · #{ep['interviewee']} on #{ep['conference']}",
          70
        )
        description = Generators::Core::Meta.clamp(
          "Rewatch and commentary with #{ep['interviewee']} (#{ep['title']}). Recorded at #{ep['conference']} (#{ep['year']}). #{ep['sound_above_inquiry']}",
          160
        )

        site.pages << SeriesEpisodePage.new(site, site.source, slug, {
          'title' => title,
          'description' => description,
          'breadcrumb' => "Episode #{formatted_num}",
          'breadcrumb_parent_name' => 'The Sound Above',
          'breadcrumb_parent_url' => '/series/the-sound-above/',
          'episode' => ep,
          'episode_number_formatted' => formatted_num,
          'prev_episode' => prev_ep,
          'next_episode' => next_ep,
          'total_episodes' => total_episodes
        })
      end
    end
  end

  class SeriesEpisodePage < Page
    def initialize(site, base, dir_slug, custom_data)
      @site = site
      @base = base
      @dir = File.join('series', 'the-sound-above', dir_slug)
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'series_episode.html')
      data.merge!(custom_data)
      data['permalink'] = "/series/the-sound-above/#{dir_slug}/"
    end
  end
end

# frozen_string_literal: true

require 'jekyll'
require_relative '../src/validators/ramblin_aimblin_episode_contract'
require_relative '../src/validators/ramblin_aimblin_rendered_article_contract'

# Jekyll plugin classes for the Ramblin' & AImblin' site.
module Jekyll
  # Generates an episode page only after its public release record passes contract checks.
  class RamblinAimblinEpisodeGenerator < Generator
    safe true
    priority :low

    def generate(site)
      episodes = site.data.fetch('ramblin_aimblin_episodes', [])
      RamblinAimblinEpisodeContract.validate_registry!(episodes)
      episodes.each do |episode|
        site.pages << RamblinAimblinEpisodePage.new(site, site.source, episode.fetch('slug'), episode)
      end
    end
  end

  # Generates a noindex episode page from an already released public record.
  class RamblinAimblinEpisodePage < PageWithoutAFile
    def initialize(site, base, slug, episode)
      directory = File.join('series', 'ramblin-aimblin', 'episodes', slug)
      super(site, base, directory, 'index.html')
      data.merge!(episode)
      data['layout'] = 'minimal'
      data['permalink'] = "/series/ramblin-aimblin/episodes/#{slug}/"
      data['robots'] = 'noindex,follow'
      data['sitemap'] = false
      self.content = '{% include ramblin_aimblin_episode.html %}'
    end
  end

  Hooks.register :site, :post_write do |site|
    RamblinAimblinRenderedArticleContract.validate!(site)
  end
end

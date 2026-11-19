# frozen_string_literal: true

require 'jekyll'
require 'cgi'
require 'nokogiri'
require_relative 'ramblin_aimblin_episode_contract'

# Checks the rendered article after Jekyll writes the public site.
class RamblinAimblinRenderedArticleContract
  class << self
    def validate!(site)
      Array(site.data.fetch('ramblin_aimblin_episodes', [])).each do |episode|
        validate_article!(site.dest, episode)
        validate_episode_page!(site.dest, episode)
      end
    rescue Errno::ENOENT, KeyError
      fail_build!
    end

    private

    def validate_article!(destination, episode)
      fail_build! unless valid_article?(destination, episode)
    end

    def validate_episode_page!(destination, episode)
      fail_episode_page! unless valid_episode_page?(destination, episode)
    end

    def valid_article?(destination, episode)
      path = File.join(destination, episode.fetch('article_path').delete_prefix('/'), 'index.html')
      return false unless File.file?(path)

      raw_html = File.read(path, encoding: 'UTF-8')
      html = CGI.unescapeHTML(raw_html)
      urls = [
        episode.fetch('anchor_url'),
        RamblinAimblinEpisodeContract::PLAYLIST_URL,
        "#{RamblinAimblinEpisodeContract::CANONICAL_HOST}/series/ramblin-aimblin/episodes/#{episode.fetch('slug')}/",
        *source_urls(episode),
        *short_urls(episode)
      ]
      urls.all? { |url| html.include?(url) } &&
        normalized_text(raw_html).include?(normalized_text(episode.fetch('ai_disclosure')))
    end

    def valid_episode_page?(destination, episode)
      path = File.join(destination, 'series/ramblin-aimblin/episodes', episode.fetch('slug'), 'index.html')
      return false unless File.file?(path)

      raw_html = File.read(path, encoding: 'UTF-8')
      html = CGI.unescapeHTML(raw_html)
      page = Nokogiri::HTML(html)
      urls = [episode.fetch('anchor_url'), episode.fetch('article_url'),
        RamblinAimblinEpisodeContract::PLAYLIST_URL, *source_urls(episode), *short_urls(episode)]
      robots = page.at_css('meta[name="robots"]')&.[]('content')
      urls.all? { |url| html.include?(url) } && robots == 'noindex,follow' &&
        page.at_css('h1')&.text.to_s.strip == episode.fetch('title') &&
        normalized_text(raw_html).include?(normalized_text(episode.fetch('ai_disclosure')))
    end

    def normalized_text(value)
      Nokogiri::HTML(CGI.unescapeHTML(value)).text.tr('’‘', "''").gsub(/\s+/, ' ')
    end

    def source_urls(episode)
      episode.fetch('source_links').map { |source| source.fetch('url') }
    end

    def short_urls(episode)
      episode.fetch('shorts').map { |short| short.fetch('url') }
    end

    def fail_build!
      raise Jekyll::Errors::FatalException, 'Ramblin episode article is missing required links or disclosure.'
    end

    def fail_episode_page!
      raise Jekyll::Errors::FatalException, 'Ramblin generated episode page is missing required content or links.'
    end
  end
end

# frozen_string_literal: true

require 'uri'
require 'jekyll'

# Validates the public-facing reciprocal links for a released Ramblin' & AImblin' episode.
class RamblinAimblinEpisodeContract
  PLAYLIST_ID = 'PLBL0frEzrqqQ'
  PLAYLIST_URL = "https://www.youtube.com/playlist?list=#{PLAYLIST_ID}".freeze
  CANONICAL_HOST = 'https://www.just3ws.com'
  VIDEO_ID_PATTERN = /\A[A-Za-z0-9_-]{11}\z/
  SLUG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  class << self
    def validate_registry!(episodes)
      fail_record! unless episodes.is_a?(Array)
      episodes.each { |episode| validate_record!(episode) }
      ids = episodes.map { |episode| episode['episode_id'] }
      slugs = episodes.map { |episode| episode['slug'] }
      fail_record! unless ids.uniq == ids && slugs.uniq == slugs
    end

    private

    def validate_record!(episode)
      fail_record! unless episode.is_a?(Hash)
      validate_approval!(episode)
      validate_article!(episode)
      validate_anchor!(episode)
      validate_sources!(episode)
      validate_shorts!(episode)
    end

    def validate_approval!(episode)
      fail_record! unless episode['status'] == 'released'
      fail_record! unless episode['release_checks'] == 'passed'
    end

    def validate_article!(episode)
      fail_record! unless valid_article_identity?(episode) && valid_article_location?(episode)
    end

    def valid_article_identity?(episode)
      episode['episode_id'] == episode['slug'] && episode['episode_id'].to_s.match?(SLUG_PATTERN) &&
        nonempty_string?(episode['title']) && nonempty_string?(episode['article_title']) &&
        episode['playlist_id'] == PLAYLIST_ID
    end

    def valid_article_location?(episode)
      path = episode['article_path'].to_s
      path == "/ai/series/ramblin-aimblin/#{episode['slug']}/" &&
        episode['article_url'] == "#{CANONICAL_HOST}#{path}"
    end

    def validate_anchor!(episode)
      fail_record! unless valid_anchor_identity?(episode) && valid_anchor_description?(episode)
    end

    def valid_anchor_identity?(episode)
      episode['anchor_video_id'].to_s.match?(VIDEO_ID_PATTERN) &&
        episode['anchor_url'] == "https://www.youtube.com/watch?v=#{episode['anchor_video_id']}"
    end

    def valid_anchor_description?(episode)
      disclosure = episode['ai_disclosure'].to_s
      return false unless disclosure.match?(/AI[- ](?:generated|created)/i)

      description = episode['anchor_description'].to_s
      description.include?(episode['article_url']) && description.include?(PLAYLIST_URL) &&
        description.include?(disclosure)
    end

    def validate_sources!(episode)
      sources = episode['source_links']
      fail_record! unless sources.is_a?(Array) && !sources.empty?
      fail_record! unless sources.all? { |source| valid_source?(source) }
    end

    def validate_shorts!(episode)
      shorts = episode['shorts']
      fail_record! unless shorts.is_a?(Array)
      fail_record! unless shorts.all? { |short| valid_short?(short, episode['anchor_video_id']) }
    end

    def valid_source?(source)
      source.is_a?(Hash) && valid_https_url?(source['url']) && nonempty_string?(source['label'])
    end

    def valid_short?(short, anchor_video_id)
      short.is_a?(Hash) && short['video_id'].to_s.match?(VIDEO_ID_PATTERN) &&
        short['url'] == "https://www.youtube.com/shorts/#{short['video_id']}" &&
        short['related_video_id'] == anchor_video_id && short['related_video_confirmed'] == true
    end

    def valid_https_url?(value)
      uri = URI.parse(value.to_s)
      uri.is_a?(URI::HTTPS) && !uri.host.to_s.empty?
    rescue URI::InvalidURIError
      false
    end

    def nonempty_string?(value)
      value.is_a?(String) && !value.strip.empty?
    end

    def fail_record!
      raise Jekyll::Errors::FatalException, 'Ramblin episode record failed its public release contract.'
    end
  end
end

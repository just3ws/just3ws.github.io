# frozen_string_literal: true

# bin/lib/youtube_client.rb — YouTube Data API v3 Client & OAuth Auth Module
#
# Provides OAuth token refresh, YouTube API v3 endpoints wrapping (videos, playlists, channels),
# quota budgeting, and two-phase dry-run / fingerprint safety verification.

require 'json'
require 'fileutils'
require 'digest'
require 'net/http'
require 'uri'
require 'signet/oauth_2/client'

class YouTubeClient
  API_BASE = "https://www.googleapis.com/youtube/v3"
  CREDENTIALS_PATH = ".credentials/youtube_oauth.json"
  SCOPES = [
    "https://www.googleapis.com/auth/youtube.force-ssl",
    "https://www.googleapis.com/auth/youtube.upload"
  ].freeze

  attr_reader :client_id, :client_secret, :refresh_token, :access_token

  def initialize(opts = {})
    load_credentials(opts)
  end

  def authenticated?
    !@refresh_token.nil? && !@refresh_token.empty?
  end

  # Perform OAuth token refresh
  def fetch_access_token!
    raise "Missing YouTube OAuth refresh token. Configure YT_REFRESH_TOKEN in .env or .credentials/youtube_oauth.json" unless authenticated?

    client = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://oauth2.googleapis.com/token',
      client_id: @client_id,
      client_secret: @client_secret,
      refresh_token: @refresh_token,
      scope: SCOPES
    )
    client.fetch_access_token!
    @access_token = client.access_token
  end

  # Quota & Authenticated Read Check
  def get_channel_info
    fetch_access_token! if @access_token.nil?

    uri = URI("#{API_BASE}/channels?part=snippet,contentDetails,statistics&mine=true")
    res = make_request(uri)
    
    if res.is_a?(Net::HTTPSuccess)
      data = JSON.parse(res.body)
      items = data["items"] || []
      return items.first if items.any?
      raise "No YouTube channel found for authenticated account."
    else
      raise "YouTube API Error (#{res.code}): #{res.body}"
    end
  end

  # Fetch Live Video Snippet
  def get_video(video_id)
    fetch_access_token! if @access_token.nil?

    uri = URI("#{API_BASE}/videos?part=snippet,status&id=#{video_id}")
    res = make_request(uri)

    if res.is_a?(Net::HTTPSuccess)
      data = JSON.parse(res.body)
      items = data["items"] || []
      items.first
    else
      raise "YouTube API Error getting video #{video_id} (#{res.code}): #{res.body}"
    end
  end

  # Update Live Video Snippet
  def update_video(video_id, snippet_payload)
    fetch_access_token! if @access_token.nil?

    uri = URI("#{API_BASE}/videos?part=snippet,status")
    payload = {
      "id" => video_id,
      "snippet" => snippet_payload["snippet"],
      "status" => snippet_payload["status"]
    }

    res = make_request(uri, method: :put, body: payload)

    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    else
      raise "YouTube API Error updating video #{video_id} (#{res.code}): #{res.body}"
    end
  end

  # Create Playlist
  def create_playlist(title, description, privacy_status = "public")
    fetch_access_token! if @access_token.nil?

    uri = URI("#{API_BASE}/playlists?part=snippet,status")
    payload = {
      "snippet" => {
        "title" => title,
        "description" => description,
        "defaultLanguage" => "en"
      },
      "status" => {
        "privacyStatus" => privacy_status
      }
    }

    res = make_request(uri, method: :post, body: payload)
    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    else
      raise "YouTube API Error creating playlist (#{res.code}): #{res.body}"
    end
  end

  # Update Playlist Snippet & Metadata
  def update_playlist(playlist_id, title, description, privacy_status = "public")
    fetch_access_token! if @access_token.nil?

    uri = URI("#{API_BASE}/playlists?part=snippet,status")
    payload = {
      "id" => playlist_id,
      "snippet" => {
        "title" => title,
        "description" => description,
        "defaultLanguage" => "en"
      },
      "status" => {
        "privacyStatus" => privacy_status
      }
    }

    res = make_request(uri, method: :put, body: payload)
    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    else
      raise "YouTube API Error updating playlist #{playlist_id} (#{res.code}): #{res.body}"
    end
  end

  # Fetch all Playlists on Channel
  def get_channel_playlists
    fetch_access_token! if @access_token.nil?

    playlists = []
    page_token = nil

    loop do
      url = "#{API_BASE}/playlists?part=snippet,contentDetails&mine=true&maxResults=50"
      url += "&pageToken=#{page_token}" if page_token
      uri = URI(url)
      res = make_request(uri)

      if res.is_a?(Net::HTTPSuccess)
        data = JSON.parse(res.body)
        playlists.concat(data["items"] || [])
        page_token = data["nextPageToken"]
        break unless page_token
      else
        break
      end
    end

    playlists
  end

  # Fetch all video IDs in a playlist
  def get_playlist_video_ids(playlist_id)
    fetch_access_token! if @access_token.nil?

    video_ids = []
    page_token = nil

    loop do
      url = "#{API_BASE}/playlistItems?part=snippet,contentDetails&playlistId=#{playlist_id}&maxResults=50"
      url += "&pageToken=#{page_token}" if page_token
      uri = URI(url)
      res = make_request(uri)

      if res.is_a?(Net::HTTPSuccess)
        data = JSON.parse(res.body)
        (data["items"] || []).each do |item|
          v_id = item.dig("contentDetails", "videoId") || item.dig("snippet", "resourceId", "videoId")
          video_ids << v_id if v_id
        end
        page_token = data["nextPageToken"]
        break unless page_token
      else
        break
      end
    end

    video_ids.uniq
  end

  # Add Video / Short to Playlist
  def add_playlist_item(playlist_id, video_id)
    fetch_access_token! if @access_token.nil?

    uri = URI("#{API_BASE}/playlistItems?part=snippet")
    payload = {
      "snippet" => {
        "playlistId" => playlist_id,
        "resourceId" => {
          "kind" => "youtube#video",
          "videoId" => video_id
        }
      }
    }

    res = make_request(uri, method: :post, body: payload)
    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    else
      raise "YouTube API Error adding item to playlist #{playlist_id} (#{res.code}): #{res.body}"
    end
  end

  # Delete an item from a playlist by playlistItemId
  def delete_playlist_item(playlist_item_id)
    fetch_access_token! if @access_token.nil?

    uri = URI("#{API_BASE}/playlistItems?id=#{playlist_item_id}")
    res = make_request(uri, method: :delete)
    if res.is_a?(Net::HTTPSuccess) || res.code.to_i == 204
      true
    else
      raise "YouTube API Error deleting playlist item #{playlist_item_id} (#{res.code}): #{res.body}"
    end
  end

  # Generate Fingerprint for Fingerprint-Idempotent Diff Safety
  def self.fingerprint(snippet)
    return "" unless snippet
    raw = [
      snippet["title"].to_s.strip,
      snippet["description"].to_s.strip,
      (snippet["tags"] || []).sort.join(",")
    ].join("||")
    Digest::SHA256.hexdigest(raw)
  end

  private

  def load_credentials(opts)
    @client_id = opts[:client_id] || ENV['YT_CLIENT_ID']
    @client_secret = opts[:client_secret] || ENV['YT_CLIENT_SECRET']
    @refresh_token = opts[:refresh_token] || ENV['YT_REFRESH_TOKEN']

    # Fallback to local gitignored credentials file
    if (!@refresh_token || @refresh_token.empty?) && File.exist?(CREDENTIALS_PATH)
      data = JSON.parse(File.read(CREDENTIALS_PATH)) rescue {}
      @client_id ||= data["client_id"]
      @client_secret ||= data["client_secret"]
      @refresh_token ||= data["refresh_token"]
    end
  end

  def make_request(uri, method: :get, body: nil)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = case method
          when :post
            Net::HTTP::Post.new(uri)
          when :put
            Net::HTTP::Put.new(uri)
          when :delete
            Net::HTTP::Delete.new(uri)
          else
            Net::HTTP::Get.new(uri)
          end

    req["Authorization"] = "Bearer #{@access_token}" if @access_token
    req["Content-Type"] = "application/json"
    req.body = JSON.generate(body) if body

    http.request(req)
  end
end

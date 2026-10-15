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
        "defaultLanguage" => "en-US"
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
        "defaultLanguage" => "en-US"
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

  # Resumable Video Upload
  def upload_video(file_path, payload, content_type: nil)
    fetch_access_token! if @access_token.nil?
    raise "File not found: #{file_path}" unless File.exist?(file_path)

    file_size = File.size(file_path)
    ct = content_type || (file_path.end_with?('.mov') ? 'video/quicktime' : 'video/mp4')

    init_uri = URI("https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=snippet,status")
    http = Net::HTTP.new(init_uri.host, init_uri.port)
    http.use_ssl = true

    init_req = Net::HTTP::Post.new(init_uri)
    init_req["Authorization"] = "Bearer #{@access_token}"
    init_req["Content-Type"] = "application/json; charset=UTF-8"
    init_req["X-Upload-Content-Length"] = file_size.to_s
    init_req["X-Upload-Content-Type"] = ct
    init_req.body = JSON.generate(payload)

    init_res = http.request(init_req)
    unless init_res.is_a?(Net::HTTPSuccess) || init_res.code == "200" || init_res.code == "201"
      raise "Failed to initialize YouTube upload session (#{init_res.code}): #{init_res.body}"
    end

    location = init_res["Location"]
    raise "No upload location returned by YouTube" unless location

    upload_uri = URI(location)
    upload_http = Net::HTTP.new(upload_uri.host, upload_uri.port)
    upload_http.use_ssl = true
    upload_http.open_timeout = 60
    upload_http.read_timeout = 3600

    upload_req = Net::HTTP::Put.new(upload_uri)
    upload_req["Content-Type"] = ct
    upload_req["Content-Length"] = file_size.to_s

    File.open(file_path, 'rb') do |file|
      upload_req.body_stream = file
      upload_res = upload_http.request(upload_req)
      if upload_res.is_a?(Net::HTTPSuccess) || upload_res.code == "200" || upload_res.code == "201"
        return JSON.parse(upload_res.body)
      else
        raise "Failed streaming video payload (#{upload_res.code}): #{upload_res.body}"
      end
    end
  end

  # Upload Caption Track (WebVTT)
  def upload_caption(video_id, vtt_content, language: "en", name: "English (Human Verified)")
    fetch_access_token! if @access_token.nil?
    require 'securerandom'

    metadata = {
      snippet: {
        videoId: video_id,
        language: language,
        name: name,
        isDraft: false
      }
    }

    uri = URI("https://www.googleapis.com/upload/youtube/v3/captions?part=snippet&uploadType=multipart")
    boundary = "----RubyMultipartBoundary#{SecureRandom.hex(8)}"
    body = [
      "--#{boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n#{metadata.to_json}\r\n",
      "--#{boundary}\r\nContent-Type: text/vtt\r\n\r\n#{vtt_content}\r\n--#{boundary}--\r\n"
    ].join

    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{@access_token}"
    req["Content-Type"] = "multipart/related; boundary=#{boundary}"
    req.body = body

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)
    if res.is_a?(Net::HTTPSuccess) || res.code.to_i == 200
      JSON.parse(res.body) rescue {}
    else
      raise "Failed uploading caption (#{res.code}): #{res.body}"
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

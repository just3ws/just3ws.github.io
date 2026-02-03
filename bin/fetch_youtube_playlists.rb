#!/usr/bin/env ruby
require 'json'
require 'yaml'
require 'net/http'
require 'uri'
require 'date'

root = File.expand_path('..', __dir__)
sources_path = File.join(root, '_data', 'youtube_sources.yml')
playlists_path = File.join(root, '_data', 'youtube_playlists.yml')
videos_path = File.join(root, '_data', 'youtube_videos.yml')

api_key = ENV['YOUTUBE_API_KEY']
abort 'YOUTUBE_API_KEY is not set.' unless api_key && !api_key.strip.empty?

sources = YAML.safe_load(File.read(sources_path))
playlist_ids = Array(sources['playlist_ids']).compact

API_BASE = 'https://www.googleapis.com/youtube/v3'.freeze


def get_json(url)
  uri = URI(url)
  res = Net::HTTP.get_response(uri)
  raise "Request failed: #{res.code} #{res.message} #{url}" unless res.is_a?(Net::HTTPSuccess)
  JSON.parse(res.body)
end

def pick_thumbnail(thumbnails)
  return nil unless thumbnails
  thumbnails['maxres'] || thumbnails['high'] || thumbnails['standard'] || thumbnails['medium'] || thumbnails['default']
end

def slugify(text)
  text.to_s.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/(^-|-$)/, '')
end

def classify_playlist(title)
  if (m = title.match(/\A(.+?)\s+(\d{4})\s+Interviews\z/i))
    { category: 'conference', conference_name: m[1], conference_year: m[2].to_i }
  elsif title.match(/community interviews/i)
    { category: 'community' }
  else
    { category: 'general' }
  end
end

def extract_title_parts(title, conference_name, conference_year)
  raw = title.to_s.strip
  return {} if raw.empty?

  # Normalize "Interview w/ Person" to "Interview with Person"
  normalized = raw.gsub(/\binterview\s+w\/\s*/i, 'Interview with ')

  # Remove conference suffix from title if present
  conf_suffix = nil
  if conference_name && conference_year
    conf_suffix = "#{conference_name} #{conference_year}"
  end
  stripped = if conf_suffix
               normalized.gsub(/\s+at\s+#{Regexp.escape(conf_suffix)}\s*$/i, '')
             else
               normalized
             end

  interviewees = []
  topic = nil

  if (m = stripped.match(/\AInterview with\s+(.+?)\s+on\s+(.+)\z/i))
    interviewees = m[1]
    topic = m[2]
  elsif (m = stripped.match(/\AInterview with\s+(.+?)\s+at\s+(.+)\z/i))
    interviewees = m[1]
    topic = nil
  elsif (m = stripped.match(/\AInterview with\s+(.+)\z/i))
    interviewees = m[1]
  else
    topic = stripped
  end

  interviewee_list = interviewees.to_s.split(/\s*(?:,|&|and)\s*/i).map(&:strip).reject(&:empty?)

  {
    'topic' => topic&.strip,
    'interviewees' => interviewee_list
  }
end

playlists = []
videos = []

playlist_ids.each do |playlist_id|
  plist_url = "#{API_BASE}/playlists?part=snippet,contentDetails&id=#{playlist_id}&key=#{api_key}"
  plist = get_json(plist_url)
  item = plist['items']&.first
  next unless item

  snippet = item['snippet'] || {}
  content = item['contentDetails'] || {}
  info = classify_playlist(snippet['title'].to_s)

  playlist = {
    'id' => item['id'],
    'title' => snippet['title'],
    'slug' => slugify(snippet['title']),
    'description' => snippet['description'],
    'published' => snippet['publishedAt'],
    'channel_title' => snippet['channelTitle'],
    'item_count' => content['itemCount'],
    'category' => info[:category],
    'conference_name' => info[:conference_name],
    'conference_year' => info[:conference_year]
  }

  thumb = pick_thumbnail(snippet['thumbnails'])
  playlist['thumbnail'] = thumb['url'] if thumb && thumb['url']

  playlists << playlist

  page_token = nil
  loop do
    params = {
      'part' => 'snippet,contentDetails',
      'playlistId' => playlist_id,
      'maxResults' => 50,
      'key' => api_key
    }
    params['pageToken'] = page_token if page_token
    query = URI.encode_www_form(params)
    items_url = "#{API_BASE}/playlistItems?#{query}"
    data = get_json(items_url)

    (data['items'] || []).each do |pi|
      sn = pi['snippet'] || {}
      cd = pi['contentDetails'] || {}
      video_id = cd['videoId']
      next unless video_id

      vthumb = pick_thumbnail(sn['thumbnails'])

      parts = extract_title_parts(sn['title'], playlist['conference_name'], playlist['conference_year'])

      videos << {
        'id' => video_id,
        'playlist_id' => playlist_id,
        'playlist_slug' => playlist['slug'],
        'title' => sn['title'],
        'topic' => parts['topic'],
        'interviewees' => parts['interviewees'],
        'interviewer' => 'Mike Hall',
        'description' => sn['description'],
        'published' => sn['publishedAt'],
        'position' => sn['position'],
        'channel_title' => sn['channelTitle'],
        'thumbnail' => vthumb && vthumb['url'],
        'link' => "https://www.youtube.com/watch?v=#{video_id}&list=#{playlist_id}",
        'embed_url' => "https://www.youtube.com/embed/#{video_id}"
      }
    end

    page_token = data['nextPageToken']
    break unless page_token
  end
end

playlists.sort_by! { |p| p['title'].to_s }
videos.sort_by! { |v| [v['playlist_slug'].to_s, v['position'].to_i] }

File.write(playlists_path, { 'playlists' => playlists }.to_yaml)
File.write(videos_path, { 'items' => videos }.to_yaml)

puts "Fetched #{playlists.size} playlists and #{videos.size} videos"

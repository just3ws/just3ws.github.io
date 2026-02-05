#!/usr/bin/env ruby
require 'json'
require 'yaml'
require 'net/http'
require 'uri'
require 'date'
require 'set'

root = File.expand_path('..', __dir__)
sources_path = File.join(root, '_data', 'youtube_sources.yml')
assets_path = File.join(root, '_data', 'video_assets.yml')
interviews_path = File.join(root, '_data', 'interviews.yml')
conf_path = File.join(root, '_data', 'interview_conferences.yml')
oneoffs_path = File.join(root, '_data', 'oneoff_videos.yml')

api_key = ENV['YOUTUBE_API_KEY']
abort 'YOUTUBE_API_KEY is not set.' unless api_key && !api_key.strip.empty?

sources = YAML.safe_load(File.read(sources_path))
playlist_ids = Array(sources['playlist_ids']).compact
channel_handles = Array(sources['channel_handles']).compact
channel_ids = Array(sources['channel_ids']).compact

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
    topic = topic.gsub(/\A(his|her|their)\s+/i, '')
  elsif (m = stripped.match(/\AInterview with\s+(.+?)\s+(?:a|an)\s+(.+)\z/i))
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

  interviewee_list = if interviewees.to_s.strip.empty?
                       []
                     elsif interviewees.to_s.include?('&') || interviewees.to_s.match?(/\s+and\s+/i) || interviewees.to_s.include?(',')
                       interviewees.to_s.split(/\s*(?:,|&|and)\s*/i).map(&:strip).reject(&:empty?)
                     else
                       [interviewees.to_s.strip]
                     end

  {
    'topic' => topic&.strip,
    'interviewees' => interviewee_list
  }
end

playlists = []
videos = []
video_playlists = Hash.new { |h, k| h[k] = [] }
processed_video_ids = Set.new

assets_data = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true) || {}
assets = assets_data['items'] || []
assets_by_id = assets.each_with_object({}) { |a, h| h[a['id']] = a }

interviews_data = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true) || {}
interviews = interviews_data['items'] || []
interviews_by_id = interviews.each_with_object({}) { |i, h| h[i['id']] = i }

confs = YAML.safe_load(File.read(conf_path), permitted_classes: [Date], aliases: true)['conferences'] || []
confs_by_name = confs.each_with_object({}) { |c, h| h[c['name']] = c }

oneoffs_data = if File.exist?(oneoffs_path)
                 YAML.safe_load(File.read(oneoffs_path), permitted_classes: [Date, Time], aliases: true) || {}
               else
                 {}
               end
oneoffs = oneoffs_data['items'] || []
oneoff_asset_ids = oneoffs.map { |o| o['video_asset_id'] }.compact.to_set

platform_lookup = Hash.new { |h, k| h[k] = {} }
assets.each do |asset|
  (asset['platforms'] || []).each do |platform|
    next unless platform['platform'] && platform['asset_id']
    platform_lookup[platform['platform']][platform['asset_id'].to_s] = asset
  end
end

def normalize_people(list)
  Array(list).map { |name| name.to_s.strip.downcase }.reject(&:empty?).sort
end

def find_interview_match(interviews, conf_name, conf_year, interviewees, title)
  target_people = normalize_people(interviewees)
  normalized_title = title.to_s.strip.downcase

  candidates = interviews
  if conf_name
    candidates = candidates.select { |i| i['conference'].to_s.downcase == conf_name.to_s.downcase }
  end
  if conf_year
    candidates = candidates.select { |i| i['conference_year'].to_i == conf_year.to_i }
  end

  if target_people.any?
    candidates.find do |i|
      normalize_people(i['interviewees']) == target_people
    end || candidates.find do |i|
      (target_people - normalize_people(i['interviewees'])).empty?
    end
  elsif !normalized_title.empty?
    candidates.find { |i| i['title'].to_s.strip.downcase == normalized_title }
  end
end

def build_asset_id(base, suffix, existing)
  candidate = [base, suffix].compact.join(' ').strip
  slug = candidate.empty? ? nil : slugify(candidate)
  slug = 'video' if slug.to_s.empty?
  final = slug
  counter = 2
  while existing.key?(final)
    final = "#{slug}-#{counter}"
    counter += 1
  end
  final
end

def fetch_uploads_playlist_id(api_key, handle: nil, channel_id: nil)
  params = { 'part' => 'contentDetails', 'key' => api_key }
  params['forHandle'] = handle if handle
  params['id'] = channel_id if channel_id
  url = "#{API_BASE}/channels?#{URI.encode_www_form(params)}"
  data = get_json(url)
  item = data['items']&.first
  item && item.dig('contentDetails', 'relatedPlaylists', 'uploads')
end

def fetch_playlist_items(api_key, playlist_id)
  items = []
  page_token = nil
  loop do
    params = {
      'part' => 'snippet,contentDetails',
      'playlistId' => playlist_id,
      'maxResults' => 50,
      'key' => api_key
    }
    params['pageToken'] = page_token if page_token
    data = get_json("#{API_BASE}/playlistItems?#{URI.encode_www_form(params)}")
    items.concat(data['items'] || [])
    page_token = data['nextPageToken']
    break unless page_token
  end
  items
end

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

  fetch_playlist_items(api_key, playlist_id).each do |pi|
      sn = pi['snippet'] || {}
      cd = pi['contentDetails'] || {}
      video_id = cd['videoId']
      next unless video_id

      vthumb = pick_thumbnail(sn['thumbnails'])

      parts = extract_title_parts(sn['title'], playlist['conference_name'], playlist['conference_year'])

      video_entry = {
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
      videos << video_entry
      video_playlists[video_id] << playlist
      processed_video_ids << video_id
    end
end

playlists.sort_by! { |p| p['title'].to_s }
videos.sort_by! { |v| [v['playlist_slug'].to_s, v['position'].to_i] }

channel_handles.each do |handle|
  uploads_id = fetch_uploads_playlist_id(api_key, handle: handle)
  next unless uploads_id
  fetch_playlist_items(api_key, uploads_id).each do |pi|
    sn = pi['snippet'] || {}
    cd = pi['contentDetails'] || {}
    video_id = cd['videoId']
    next unless video_id
    next if processed_video_ids.include?(video_id)

    vthumb = pick_thumbnail(sn['thumbnails'])
    videos << {
      'id' => video_id,
      'playlist_id' => nil,
      'playlist_slug' => nil,
      'title' => sn['title'],
      'topic' => nil,
      'interviewees' => [],
      'interviewer' => 'Mike Hall',
      'description' => sn['description'],
      'published' => sn['publishedAt'],
      'position' => sn['position'],
      'channel_title' => sn['channelTitle'],
      'thumbnail' => vthumb && vthumb['url'],
      'link' => "https://www.youtube.com/watch?v=#{video_id}",
      'embed_url' => "https://www.youtube.com/embed/#{video_id}"
    }
  end
end

channel_ids.each do |channel_id|
  uploads_id = fetch_uploads_playlist_id(api_key, channel_id: channel_id)
  next unless uploads_id
  fetch_playlist_items(api_key, uploads_id).each do |pi|
    sn = pi['snippet'] || {}
    cd = pi['contentDetails'] || {}
    video_id = cd['videoId']
    next unless video_id
    next if processed_video_ids.include?(video_id)

    vthumb = pick_thumbnail(sn['thumbnails'])
    videos << {
      'id' => video_id,
      'playlist_id' => nil,
      'playlist_slug' => nil,
      'title' => sn['title'],
      'topic' => nil,
      'interviewees' => [],
      'interviewer' => 'Mike Hall',
      'description' => sn['description'],
      'published' => sn['publishedAt'],
      'position' => sn['position'],
      'channel_title' => sn['channelTitle'],
      'thumbnail' => vthumb && vthumb['url'],
      'link' => "https://www.youtube.com/watch?v=#{video_id}",
      'embed_url' => "https://www.youtube.com/embed/#{video_id}"
    }
  end
end

videos.each do |video|
  video_id = video['id']
  playlist = playlists.find { |p| p['id'] == video['playlist_id'] }
  playlist_matches = video_playlists[video_id]
  conf_match = (playlist_matches || []).find { |p| p['category'] == 'conference' }
  conf_name = conf_match && conf_match['conference_name'] || (playlist && playlist['conference_name'])
  conf_year = conf_match && conf_match['conference_year'] || (playlist && playlist['conference_year'])
  is_skate = video['title'].to_s.downcase.include?('skate')

  asset = platform_lookup['youtube'][video_id]
  interview = nil

  if asset && asset['interview_id']
    interview = interviews_by_id[asset['interview_id']]
  end

  unless asset
    interview = find_interview_match(interviews, conf_name, conf_year, video['interviewees'], video['title'])
    if interview
      asset = assets_by_id[interview['video_asset_id']]
    end
  end

  unless asset
    base_name = if Array(video['interviewees']).any?
                  video['interviewees'].join(' ')
                else
                  video['title']
                end

    suffix = nil
    if conf_name && confs_by_name[conf_name]
      suffix = confs_by_name[conf_name]['slug']
    else
      suffix = 'general'
    end

    asset_id = build_asset_id(base_name, suffix, assets_by_id)
    asset = {
      'id' => asset_id,
      'interview_id' => nil,
      'title' => video['title'],
      'primary_platform' => 'youtube',
      'source' => nil,
      'published_date' => video['published']&.to_s&.slice(0, 10),
      'thumbnail' => video['thumbnail'],
      'thumbnail_local' => nil,
      'duration_seconds' => nil,
      'duration_minutes' => nil,
      'description' => video['description'],
      'tags' => [],
      'transcript_id' => nil,
      'platforms' => []
    }
    assets << asset
    assets_by_id[asset_id] = asset
  end

  interview ||= if asset['interview_id']
                  interviews_by_id[asset['interview_id']]
                else
                  nil
                end

  unless interview || is_skate
    interview_id = asset['interview_id'] || asset['id']
    interview = {
      'id' => interview_id,
      'title' => video['title'],
      'interviewees' => Array(video['interviewees']),
      'interviewer' => 'Mike Hall',
      'topic' => video['topic'],
      'conference' => conf_name,
      'conference_year' => conf_year,
      'community' => conf_name ? nil : 'General',
      'recorded_date' => video['published']&.to_s&.slice(0, 10),
      'tags' => [],
      'video_asset_id' => asset['id']
    }
    interviews << interview
    interviews_by_id[interview_id] = interview
    asset['interview_id'] = interview_id
  end

  if interview
    interview['conference'] ||= conf_name
    interview['conference_year'] ||= conf_year
    interview['community'] ||= conf_name ? nil : 'General'
    interview['interviewees'] = Array(video['interviewees']) if Array(interview['interviewees']).empty?
    interview['topic'] ||= video['topic']
    interview['video_asset_id'] ||= asset['id']
    asset['interview_id'] ||= interview['id']
  end

  asset['title'] = video['title'] if asset['title'].to_s.strip.empty?
  asset['published_date'] ||= video['published']&.to_s&.slice(0, 10)
  asset['thumbnail'] ||= video['thumbnail']
  asset['description'] ||= video['description']
  asset['primary_platform'] ||= 'youtube'

  platforms = asset['platforms'] || []
  platform_entry = platforms.find { |p| p['platform'] == 'youtube' && p['asset_id'].to_s == video_id.to_s }
  unless platform_entry
    platform_entry = { 'platform' => 'youtube', 'asset_id' => video_id.to_s }
    platforms << platform_entry
  end
  platform_entry['url'] ||= video['link']
  platform_entry['embed_url'] ||= video['embed_url']
  platform_entry['title_on_platform'] ||= video['title']
  platform_entry['published_date'] ||= video['published']&.to_s&.slice(0, 10)
  platform_entry['thumbnail'] ||= video['thumbnail']
  platform_entry['description'] ||= video['description']
  platform_entry['playlist'] ||= playlist && playlist['title']

  asset['platforms'] = platforms
  platform_lookup['youtube'][video_id.to_s] = asset

  if is_skate && !oneoff_asset_ids.include?(asset['id'])
    oneoffs << { 'video_asset_id' => asset['id'] }
    oneoff_asset_ids << asset['id']
  end
end

assets_data['items'] = assets
interviews_data['items'] = interviews
oneoffs_data['items'] = oneoffs

File.write(assets_path, assets_data.to_yaml)
File.write(interviews_path, interviews_data.to_yaml)
File.write(oneoffs_path, oneoffs_data.to_yaml)

puts "Fetched #{playlists.size} playlists and #{videos.size} videos"

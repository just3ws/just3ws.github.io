#!/usr/bin/env ruby
require 'yaml'
require 'date'
require 'fileutils'

root = File.expand_path('..', __dir__)
interviews_path = File.join(root, '_data', 'interviews.yml')
assets_path = File.join(root, '_data', 'video_assets.yml')
transcripts_path = File.join(root, '_data', 'transcripts.yml')

ugtastic_confs_path = File.join(root, '_data', 'interview_conferences.yml')
ugtastic_comms_path = File.join(root, '_data', 'interview_communities.yml')

youtube_videos_path = File.join(root, '_data', 'youtube_videos.yml')
youtube_playlists_path = File.join(root, '_data', 'youtube_playlists.yml')

vimeo_videos_path = File.join(root, '_data', 'vimeo_videos.yml')


def slugify(text)
  text.to_s.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/(^-|-$)/, '')
end

interviews = []
assets = []
index = {}

if File.exist?(interviews_path)
  interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
end
if File.exist?(assets_path)
  assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
end

index = interviews.each_with_object({}) { |i, h| h[i['id']] = i }
asset_index = assets.each_with_object({}) do |asset, h|
  key = "#{asset['platform']}:#{asset['asset_id']}"
  h[key] = asset
end

confs = YAML.safe_load(File.read(ugtastic_confs_path), permitted_classes: [Date, Time], aliases: true)['conferences'] || []
comms = YAML.safe_load(File.read(ugtastic_comms_path), permitted_classes: [Date, Time], aliases: true)['communities'] || []
conf_map = confs.each_with_object({}) { |c, h| h[c['slug']] = c }
comm_map = comms.each_with_object({}) { |c, h| h[c['slug']] = c }

# YouTube interviews
if File.exist?(youtube_videos_path) && File.exist?(youtube_playlists_path)
  yt_videos = YAML.safe_load(File.read(youtube_videos_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
  yt_playlists = YAML.safe_load(File.read(youtube_playlists_path), permitted_classes: [Date, Time], aliases: true)['playlists'] || []
  yt_playlist_map = yt_playlists.each_with_object({}) { |p, h| h[p['slug']] = p }

  yt_videos.each do |video|
    playlist = yt_playlist_map[video['playlist_slug']]
    conf_name = playlist && playlist['conference_name']
    conf_year = playlist && playlist['conference_year']

    interviewees = video['interviewees'] || []
    topic = video['topic']

    key_parts = [interviewees.join('-'), topic, conf_name, conf_year].reject { |v| v.nil? || v.to_s.empty? }
    key = slugify(key_parts.join(' '))

    interview = index[key]
    unless interview
      interview = {
        'id' => key,
        'title' => if topic && !interviewees.empty?
                    "#{interviewees.join(' & ')} — #{topic}"
                  elsif !interviewees.empty?
                    interviewees.join(' & ')
                  else
                    video['title'] || 'Interview'
                  end,
        'interviewees' => interviewees,
        'interviewer' => video['interviewer'] || 'Mike Hall',
        'topic' => topic,
        'conference' => conf_name,
        'conference_year' => conf_year,
        'community' => nil,
        'recorded_date' => video['published'] && video['published'].to_s[0, 10],
        'tags' => []
      }
      index[key] = interview
      interviews << interview
    end

    asset = {
      'interview_id' => key,
      'platform' => 'youtube',
      'asset_id' => video['id'].to_s,
      'playlist' => playlist && playlist['title'],
      'url' => video['link'],
      'embed_url' => video['embed_url'],
      'title_on_platform' => video['title'],
      'published_date' => video['published'] && video['published'].to_s[0, 10],
      'thumbnail' => video['thumbnail'],
      'description' => video['description'],
      'transcript' => video['transcript'],
      'tags' => video['tags'] || []
    }
    asset_key = "#{asset['platform']}:#{asset['asset_id']}"
    if asset_index.key?(asset_key)
      asset_index[asset_key].merge!(asset)
    else
      assets << asset
      asset_index[asset_key] = asset
    end
  end
end

# Vimeo one-offs (non-UGtastic)
if File.exist?(vimeo_videos_path)
  vimeo = YAML.safe_load(File.read(vimeo_videos_path), permitted_classes: [Date, Time], aliases: true)
  (vimeo['items'] || []).each do |item|
    next if item['category'] == 'scmc'

    interviewees = item['people'] || []
    topic = item['topic']

    key_parts = [interviewees.join('-'), topic].reject { |v| v.nil? || v.to_s.empty? }
    key = slugify(key_parts.join(' '))

    interview = index[key]
    unless interview
      interview = {
        'id' => key,
        'title' => if topic && !interviewees.empty?
                    "#{interviewees.join(' & ')} — #{topic}"
                  elsif !interviewees.empty?
                    interviewees.join(' & ')
                  else
                    item['title'] || 'Interview'
                  end,
        'interviewees' => interviewees,
        'interviewer' => 'Mike Hall',
        'topic' => topic,
        'conference' => nil,
        'conference_year' => nil,
        'community' => nil,
        'recorded_date' => item['created'] && item['created'].to_s[0, 10],
        'tags' => item['tags'] || []
      }
      index[key] = interview
      interviews << interview
    end

    asset = {
      'interview_id' => key,
      'platform' => 'vimeo',
      'asset_id' => item['id'].to_s,
      'url' => item['link'],
      'embed_url' => "https://player.vimeo.com/video/#{item['id']}",
      'title_on_platform' => item['title'],
      'published_date' => item['created'] && item['created'].to_s[0, 10],
      'thumbnail' => item['thumbnail'],
      'thumbnail_local' => item['thumbnail_local'],
      'duration_seconds' => item['duration_seconds'],
      'duration_minutes' => item['duration_minutes'],
      'description' => item['description'],
      'transcript' => item['transcript'],
      'tags' => item['tags'] || []
    }
    asset_key = "#{asset['platform']}:#{asset['asset_id']}"
    if asset_index.key?(asset_key)
      asset_index[asset_key].merge!(asset)
    else
      assets << asset
      asset_index[asset_key] = asset
    end
  end
end

assets_by_interview = Hash.new { |h, k| h[k] = [] }
assets.each do |asset|
  assets_by_interview[asset['interview_id']] << {
    'platform' => asset['platform'],
    'asset_id' => asset['asset_id']
  }
end

interviews.each do |interview|
  interview['video_assets'] = assets_by_interview[interview['id']] || []
end

interviews.sort_by! { |i| [i['conference_year'] || 0, i['conference'] || '', i['title']] }
assets.sort_by! { |a| [a['platform'], a['interview_id']] }

File.write(interviews_path, { 'items' => interviews }.to_yaml)
File.write(assets_path, { 'items' => assets }.to_yaml)
File.write(transcripts_path, { 'items' => [] }.to_yaml) unless File.exist?(transcripts_path)

puts "Built #{interviews.size} interviews and #{assets.size} assets"

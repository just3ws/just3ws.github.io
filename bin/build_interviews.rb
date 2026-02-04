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

def make_unique_id(base, used)
  id = base
  i = 2
  while used[id]
    id = "#{base}-#{i}"
    i += 1
  end
  used[id] = true
  id
end

def upsert_platform(asset, platform_entry)
  asset['platforms'] ||= []
  existing = asset['platforms'].find { |p| p['platform'] == platform_entry['platform'] }
  if existing
    platform_entry.each do |k, v|
      existing[k] = v if existing[k].nil? || existing[k].to_s.strip.empty?
    end
  else
    asset['platforms'] << platform_entry
  end
end

interviews = []
assets = []

if File.exist?(interviews_path)
  interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
end
if File.exist?(assets_path)
  assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
end

index = interviews.each_with_object({}) { |i, h| h[i['id']] = i }
used_ids = assets.each_with_object({}) { |a, h| h[a['id']] = true }
asset_index = {}
assets.each do |asset|
  (asset['platforms'] || []).each do |platform|
    key = "#{platform['platform']}:#{platform['asset_id']}"
    asset_index[key] = asset
  end
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

    platform_entry = {
      'platform' => 'youtube',
      'asset_id' => video['id'].to_s,
      'playlist' => playlist && playlist['title'],
      'url' => video['link'],
      'embed_url' => video['embed_url'],
      'title_on_platform' => video['title'],
      'published_date' => video['published'] && video['published'].to_s[0, 10],
      'thumbnail' => video['thumbnail'],
      'description' => video['description']
    }.compact

    asset_key = "#{platform_entry['platform']}:#{platform_entry['asset_id']}"
    if asset_index.key?(asset_key)
      asset = asset_index[asset_key]
      upsert_platform(asset, platform_entry)
      asset['interview_id'] ||= key
      asset['title'] ||= video['title']
      asset['published_date'] ||= platform_entry['published_date']
      asset['thumbnail'] ||= platform_entry['thumbnail']
      asset['description'] ||= platform_entry['description']
    else
      base = key.empty? ? "youtube-#{platform_entry['asset_id']}" : key
      new_id = make_unique_id(base, used_ids)
      asset = {
        'id' => new_id,
        'interview_id' => key,
        'title' => video['title'],
        'primary_platform' => 'youtube',
        'source' => nil,
        'published_date' => platform_entry['published_date'],
        'thumbnail' => platform_entry['thumbnail'],
        'duration_seconds' => nil,
        'duration_minutes' => nil,
        'description' => platform_entry['description'],
        'tags' => video['tags'] || [],
        'transcript_id' => nil,
        'platforms' => [platform_entry]
      }
      assets << asset
      asset_index[asset_key] = asset
    end
  end
end

# Vimeo (including SCMC; interviews only for non-SCMC)
if File.exist?(vimeo_videos_path)
  vimeo = YAML.safe_load(File.read(vimeo_videos_path), permitted_classes: [Date, Time], aliases: true)
  (vimeo['items'] || []).each do |item|
    create_interview = item['category'] != 'scmc'

    interviewees = item['people'] || []
    topic = item['topic']

    key = nil
    if create_interview
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
    end

    platform_entry = {
      'platform' => 'vimeo',
      'asset_id' => item['id'].to_s,
      'url' => item['link'],
      'embed_url' => item['embed_url'] || "https://player.vimeo.com/video/#{item['id']}",
      'title_on_platform' => item['title'],
      'published_date' => item['created'] && item['created'].to_s[0, 10],
      'thumbnail' => item['thumbnail'],
      'thumbnail_local' => item['thumbnail_local'],
      'duration_seconds' => item['duration_seconds'],
      'duration_minutes' => item['duration_minutes'],
      'description' => item['description'],
      'source' => item['source']
    }.compact

    asset_key = "#{platform_entry['platform']}:#{platform_entry['asset_id']}"
    if asset_index.key?(asset_key)
      asset = asset_index[asset_key]
      upsert_platform(asset, platform_entry)
      asset['interview_id'] ||= key if key
      asset['title'] ||= item['title']
      asset['published_date'] ||= platform_entry['published_date']
      asset['thumbnail'] ||= platform_entry['thumbnail']
      asset['duration_seconds'] ||= platform_entry['duration_seconds']
      asset['duration_minutes'] ||= platform_entry['duration_minutes']
      asset['description'] ||= platform_entry['description']
      asset['tags'] = (asset['tags'] || []) | (item['tags'] || [])
    else
      base = key && !key.empty? ? key : "vimeo-#{platform_entry['asset_id']}"
      new_id = make_unique_id(base, used_ids)
      asset = {
        'id' => new_id,
        'interview_id' => key,
        'title' => item['title'],
        'primary_platform' => 'vimeo',
        'source' => item['source'],
        'published_date' => platform_entry['published_date'],
        'thumbnail' => platform_entry['thumbnail'],
        'duration_seconds' => platform_entry['duration_seconds'],
        'duration_minutes' => platform_entry['duration_minutes'],
        'description' => platform_entry['description'],
        'tags' => item['tags'] || [],
        'transcript_id' => nil,
        'platforms' => [platform_entry]
      }
      assets << asset
      asset_index[asset_key] = asset
    end
  end
end

assets_by_interview = Hash.new { |h, k| h[k] = [] }
assets.each do |asset|
  next unless asset['interview_id']
  assets_by_interview[asset['interview_id']] << asset['id']
end

interviews.each do |interview|
  list = assets_by_interview[interview['id']] || []
  interview['video_asset_id'] = list.first
  interview.delete('video_assets')
end

interviews.sort_by! { |i| [i['conference_year'] || 0, i['conference'] || '', i['title']] }
assets.sort_by! { |a| [a['primary_platform'] || '', a['id']] }

File.write(interviews_path, { 'items' => interviews }.to_yaml)
File.write(assets_path, { 'items' => assets }.to_yaml)
File.write(transcripts_path, { 'items' => [] }.to_yaml) unless File.exist?(transcripts_path)

puts "Built #{interviews.size} interviews and #{assets.size} assets"

#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

root = File.expand_path('..', __dir__)
playlists_path = File.join(root, '_data', 'youtube_playlists.yml')
videos_path = File.join(root, '_data', 'youtube_videos.yml')

playlists = YAML.safe_load(File.read(playlists_path), permitted_classes: [Date, Time], aliases: true)['playlists'] || []
videos = YAML.safe_load(File.read(videos_path), permitted_classes: [Date, Time], aliases: true)['items'] || []

playlists_dir = File.join(root, 'youtube', 'playlists')
videos_dir = File.join(root, 'youtube', 'videos')
FileUtils.mkdir_p(playlists_dir)
FileUtils.mkdir_p(videos_dir)

videos_by_playlist = videos.group_by { |v| v['playlist_slug'] }

playlists.each do |playlist|
  slug = playlist['slug']
  dir = File.join(playlists_dir, slug)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: YouTube — #{playlist['title']}"
    f.puts "description: YouTube playlist #{playlist['title']}."
    f.puts "breadcrumb: #{playlist['title']}"
    f.puts 'breadcrumb_parent_name: YouTube'
    f.puts 'breadcrumb_parent_url: /youtube/'
    f.puts '---'
    f.puts ''
    f.puts '<article class="page">'
    f.puts '  {% include breadcrumbs.html %}'
    f.puts '  <header>'
    f.puts "    <h1>#{playlist['title']}</h1>"
    f.puts '  </header>'
    f.puts ''
    f.puts "  {% assign playlist = site.data.youtube_playlists.playlists | where: \"slug\", \"#{slug}\" | first %}"
    f.puts '  {% if playlist %}'
    f.puts '    <div class="video-meta">'
    f.puts '      {% if playlist.category == "conference" %}Conference: {{ playlist.conference_name }} {{ playlist.conference_year }}{% elsif playlist.category == "community" %}Community Interviews{% endif %}'
    f.puts '      {% if playlist.published %} · Published: {{ playlist.published | date: "%b %d, %Y" }}{% endif %}'
    f.puts '    </div>'
    f.puts '    {% if playlist.description and playlist.description != "" %}'
    f.puts '      <p class="intro">{{ playlist.description }}</p>'
    f.puts '    {% endif %}'
    f.puts '  {% endif %}'
    f.puts ''
    f.puts "  {% assign items = site.data.youtube_videos.items | where: \"playlist_slug\", \"#{slug}\" | sort: \"position\" %}"
    f.puts '  {% for item in items %}'
    f.puts '    {% assign asset = site.data.video_assets.items | where: "id", item.video_asset_id | first %}'
    f.puts '    {% include video-asset-card.html asset=asset %}'
    f.puts '  {% endfor %}'
    f.puts '</article>'
  end
end

videos.each do |video|
  id = video['id']
  dir = File.join(videos_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: YouTube — #{video['title']}"
    f.puts "description: YouTube video #{video['title']}."
    f.puts "breadcrumb: #{video['title']}"
    f.puts 'breadcrumb_parent_name: YouTube'
    f.puts 'breadcrumb_parent_url: /youtube/'
    f.puts '---'
    f.puts ''
    f.puts '<article class="page">'
    f.puts '  {% include breadcrumbs.html %}'
    f.puts "  {% assign item = site.data.youtube_videos.items | where: \"id\", \"#{id}\" | first %}"
    f.puts '  {% if item %}'
    f.puts '    {% assign asset = site.data.video_assets.items | where: "id", item.video_asset_id | first %}'
    f.puts '    <header>'
    f.puts '      <h1>{{ item.topic | default: item.title }}</h1>'
    f.puts '    </header>'
    f.puts ''
    f.puts '    {% include video-asset-player.html asset=asset embed_id="youtube-embed" %}'
    f.puts '  {% endif %}'
    f.puts '</article>'
  end
end

puts "Generated #{playlists.size} YouTube playlist pages and #{videos.size} video pages."

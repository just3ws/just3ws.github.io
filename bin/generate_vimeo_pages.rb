#!/usr/bin/env ruby
require 'yaml'
require 'date'
require 'fileutils'

root = File.expand_path('..', __dir__)
path = File.join(root, '_data', 'vimeo_videos.yml')

vimeo = YAML.safe_load(File.read(path), permitted_classes: [Time, Date], aliases: true)
items = vimeo['items'] || []

base_dir = File.join(root, 'vimeo', 'videos')
FileUtils.mkdir_p(base_dir)

items.each do |item|
  id = item['id'].to_s
  title = item['title'] || 'Vimeo Video'
  topic = item['topic'] || title
  parent_name = nil
  parent_url = nil
  if item['category'] == 'scmc'
    parent_name = 'SCMC'
    parent_url = '/vimeo/scmc/'
  elsif item['category']
    parent_name = 'Vimeo'
    parent_url = '/vimeo/'
  end
  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  page = File.join(dir, 'index.html')

  File.open(page, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: Vimeo — #{title}"
    f.puts "description: Vimeo video #{title}."
    f.puts "breadcrumb: #{topic}"
    f.puts "breadcrumb_parent_name: #{parent_name}" if parent_name
    f.puts "breadcrumb_parent_url: #{parent_url}" if parent_url
    f.puts '---'
    f.puts ''
    f.puts '<article class="page">'
    f.puts '  {% include breadcrumbs.html %}'
    f.puts "  <header><h1>#{title}</h1></header>"
    f.puts ''
    f.puts "  {% assign item = site.data.vimeo_videos.items | where: \"id\", \"#{id}\" | first %}"
    f.puts "  {% assign asset = item and site.data.video_assets.items | where: \"id\", item.video_asset_id | first %}"
    f.puts "  {% assign platform = asset and asset.platforms | where: \"platform\", \"vimeo\" | first %}"
    f.puts '  {% if item %}'
    f.puts '    <div class="video video-detail">'
    f.puts '      {% if platform and platform.embed_url %}'
    f.puts '        <div class="video-embed">'
    f.puts '          <iframe src="{{ platform.embed_url }}" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share" referrerpolicy="strict-origin-when-cross-origin" title="{{ item.title }}"></iframe>'
    f.puts '        </div>'
    f.puts '      {% endif %}'
    f.puts '      <div class="video-body">'
    f.puts '        <div class="video-title">{{ item.topic | default: item.title }}</div>'
    f.puts '        {% if item.speakers and item.speakers.size > 0 %}'
    f.puts '          <div class="video-subtitle">{% if item.speakers.size == 1 %}Speaker{% else %}Speakers{% endif %}: {{ item.speakers | join: ", " }}</div>'
    f.puts '        {% elsif item.people and item.people.size > 0 %}'
    f.puts '          <div class="video-subtitle">{% if item.people.size == 1 %}Person{% else %}People{% endif %}: {{ item.people | join: ", " }}</div>'
    f.puts '        {% endif %}'
    f.puts '        <div class="video-meta">{% if platform and platform.duration_minutes %}Duration: {{ platform.duration_minutes | round }} min · {% endif %}Uploaded: {{ item.created | date: "%b %d, %Y" }}</div>'
    f.puts '        <div class="video-actions">{% if platform and platform.url %}<a class="video-button" href="{{ platform.url }}">Watch on Vimeo</a>{% endif %}</div>'
    f.puts '        {% if item.tags and item.tags.size > 0 %}'
    f.puts '          <div class="video-tags">'
    f.puts '            {% for tag in item.tags %}<span class="tag">{{ tag }}</span>{% endfor %}'
    f.puts '          </div>'
    f.puts '        {% endif %}'
    f.puts '        {% if item.description %}'
    f.puts '          <div class="video-description"><span class="video-description-label">Vimeo description:</span> {{ item.description }}</div>'
    f.puts '        {% endif %}'
    f.puts '      </div>'
    f.puts '    </div>'
    f.puts '    <section class="transcript">'
    f.puts '      <h2>Transcript</h2>'
    f.puts '      {% assign transcript = nil %}'
    f.puts '      {% if asset and asset.transcript_id %}'
    f.puts '        {% assign transcript_entry = site.data.transcripts.items | where: "id", asset.transcript_id | first %}'
    f.puts '        {% if transcript_entry %}{% assign transcript = transcript_entry.content %}{% endif %}'
    f.puts '      {% endif %}'
    f.puts '      {% if transcript %}'
    f.puts '        <div class="video-transcript">{{ transcript }}</div>'
    f.puts '      {% else %}'
    f.puts '        <p>Transcript coming soon.</p>'
    f.puts '      {% endif %}'
    f.puts '    </section>'
    f.puts '  {% endif %}'
    f.puts '</article>'
  end
end

puts "Generated #{items.size} Vimeo pages in #{base_dir}"

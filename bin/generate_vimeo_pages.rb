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
  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  page = File.join(dir, 'index.html')

  File.open(page, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: Vimeo — #{title}"
    f.puts "description: Vimeo video #{title}."
    f.puts "breadcrumb: #{title}"
    f.puts '---'
    f.puts ''
    f.puts '<article class="page">'
    f.puts '  {% include breadcrumbs.html %}'
    f.puts "  <header><h1>#{title}</h1></header>"
    f.puts ''
    f.puts "  {% assign item = site.data.vimeo_videos.items | where: \"id\", \"#{id}\" | first %}"
    f.puts '  {% if item %}'
    f.puts '    <div class="video video-detail">'
    f.puts '      {% if item.embed_url %}'
    f.puts '        <div class="video-embed">'
    f.puts '          <iframe src="{{ item.embed_url }}" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share" referrerpolicy="strict-origin-when-cross-origin" title="{{ item.title }}"></iframe>'
    f.puts '        </div>'
    f.puts '      {% endif %}'
    f.puts '      <div class="video-body">'
    f.puts '        <div class="video-title">{{ item.title }}</div>'
    f.puts '        <div class="video-meta">{% if item.duration_minutes %}Duration: {{ item.duration_minutes | round }} min · {% endif %}Uploaded: {{ item.created | date: "%b %d, %Y" }}</div>'
    f.puts '        <div class="video-actions"><a class="video-button" href="{{ item.link }}">Watch on Vimeo</a></div>'
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
    f.puts '      {% if item.transcript %}'
    f.puts '        <div class="video-transcript">{{ item.transcript }}</div>'
    f.puts '      {% else %}'
    f.puts '        <p>Transcript coming soon.</p>'
    f.puts '      {% endif %}'
    f.puts '    </section>'
    f.puts '  {% endif %}'
    f.puts '</article>'
  end
end

puts "Generated #{items.size} Vimeo pages in #{base_dir}"

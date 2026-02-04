#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

root = File.expand_path('..', __dir__)
interviews_path = File.join(root, '_data', 'interviews.yml')
assets_path = File.join(root, '_data', 'video_assets.yml')

interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
assets_by_id = assets.each_with_object({}) { |a, h| h[a['id']] = a }

base_dir = File.join(root, 'interviews')
FileUtils.mkdir_p(base_dir)

interviews.each do |interview|
  id = interview['id']
  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: Interview — #{interview['title']}"
    f.puts "description: Interview with #{interview['title']}."
    f.puts "breadcrumb: #{interview['title']}"
    f.puts 'breadcrumb_parent_name: Interviews'
    f.puts 'breadcrumb_parent_url: /interviews/'
    f.puts '---'
    f.puts ''
    f.puts '<article class="page">'
    f.puts '  {% include breadcrumbs.html %}'
    f.puts "  {% assign interview = site.data.interviews.items | where: \"id\", \"#{id}\" | first %}"
    f.puts '  {% if interview %}'
    f.puts '    <header>'
    f.puts '      <h1>{{ interview.title }}</h1>'
    f.puts '    </header>'
    f.puts '    {% if interview.interviewees and interview.interviewees.size > 0 %}'
    f.puts '      <div class="video-subtitle">Interviewee{% if interview.interviewees.size > 1 %}s{% endif %}: {{ interview.interviewees | join: ", " }}</div>'
    f.puts '    {% endif %}'
    f.puts '    {% if interview.topic %}'
    f.puts '      <div class="video-subtitle">Topic: {{ interview.topic }}</div>'
    f.puts '    {% endif %}'
    f.puts '    <div class="video-meta">'
    f.puts '      {% if interview.conference %}Conference: {{ interview.conference }}{% if interview.conference_year %} {{ interview.conference_year }}{% endif %}{% endif %}'
    f.puts '      {% if interview.community %}{% if interview.conference %} · {% endif %}Community: {{ interview.community }}{% endif %}'
    f.puts '    </div>'
    f.puts ''
    f.puts "    {% assign asset = site.data.video_assets.items | where: \"id\", interview.video_asset_id | first %}"
    f.puts "    {% include video-asset-player.html asset=asset embed_id=\"interview-embed\" %}"
    f.puts '  {% endif %}'
    f.puts '</article>'
  end
end

puts "Generated #{interviews.size} interview pages in #{base_dir}"

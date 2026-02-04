#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

root = File.expand_path('..', __dir__)
assets_path = File.join(root, '_data', 'video_assets.yml')
transcripts_path = File.join(root, '_data', 'transcripts.yml')

assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Time, Date], aliases: true)['items'] || []

base_dir = File.join(root, 'videos')
FileUtils.mkdir_p(base_dir)

assets.each do |asset|
  id = asset['id']
  title = asset['title'] || 'Video'
  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: Video — #{title}"
    f.puts "description: Video asset for #{title}."
    f.puts "breadcrumb: #{title}"
    f.puts 'breadcrumb_parent_name: Videos'
    f.puts 'breadcrumb_parent_url: /videos/'
    f.puts '---'
    f.puts ''
    f.puts '<article class="page">'
    f.puts '  {% include breadcrumbs.html %}'
    f.puts "  {% assign asset = site.data.video_assets.items | where: \"id\", \"#{id}\" | first %}"
    f.puts '  {% if asset %}'
    f.puts '    <header>'
    f.puts '      <h1>{{ asset.title }}</h1>'
    f.puts '    </header>'
    f.puts ''
    f.puts '    {% include video-asset-player.html asset=asset embed_id="asset-embed" %}'
    f.puts '  {% endif %}'
    f.puts '</article>'
  end
end

puts "Generated #{assets.size} video asset pages in #{base_dir}"

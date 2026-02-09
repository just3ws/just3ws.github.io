#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

root = File.expand_path('..', __dir__)
assets_path = File.join(root, '_data', 'video_assets.yml')
transcripts_path = File.join(root, '_data', 'transcripts.yml')

assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Time, Date], aliases: true)['items'] || []

def yaml_quote(value)
  str = value.to_s.tr("\n", ' ')
  "\"#{str.gsub('"', '\"')}\""
end

def normalize_asset_subject(value)
  value.to_s.strip
       .sub(/\AInterview with\s+/i, '')
       .sub(/\AInterview\s*[-:]\s+/i, '')
       .gsub(/\s+/, ' ')
       .strip
end

def clamp_meta(text, max_length)
  clean = text.to_s.gsub(/\s+/, ' ').strip
  return clean if clean.length <= max_length

  truncated = clean[0, max_length - 1]
  truncated = truncated.rpartition(' ').first if truncated.include?(' ')
  truncated = clean[0, max_length - 1] if truncated.nil? || truncated.empty?
  "#{truncated}…"
end

base_dir = File.join(root, 'videos')
FileUtils.mkdir_p(base_dir)

assets.each do |asset|
  id = asset['id']
  title = asset['title'] || 'Video'
  subject = normalize_asset_subject(title)
  title_meta = clamp_meta("Video — #{subject}", 70)
  description_meta = clamp_meta("Video asset for #{subject}.", 160)
  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: #{yaml_quote(title_meta)}"
    f.puts "description: #{yaml_quote(description_meta)}"
    f.puts "sitemap: false"
    f.puts "breadcrumb: #{yaml_quote(title)}"
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
    f.puts '    {% include json-ld-video.html asset=asset %}'
    f.puts ''
    f.puts '    {% include video-asset-player.html asset=asset embed_id="asset-embed" %}'
    f.puts '  {% endif %}'
    f.puts '</article>'
  end
end

puts "Generated #{assets.size} video asset pages in #{base_dir}"

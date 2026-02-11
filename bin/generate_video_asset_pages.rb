#!/usr/bin/env ruby
require 'fileutils'
require_relative '../src/generators/core/meta'
require_relative '../src/generators/core/text'
require_relative '../src/generators/core/yaml_io'

root = File.expand_path('..', __dir__)
assets_path = File.join(root, '_data', 'video_assets.yml')
interviews_path = File.join(root, '_data', 'interviews.yml')

assets = Generators::Core::YamlIo.load(assets_path, key: 'items')
interviews = Generators::Core::YamlIo.load(interviews_path, key: 'items')
interviews_by_id = interviews.each_with_object({}) { |i, h| h[i['id']] = i }

base_dir = File.join(root, 'videos')
FileUtils.mkdir_p(base_dir)
seen_titles = {}
seen_descriptions = {}

assets.each do |asset|
  id = asset['id']
  title = asset['title'] || 'Video'
  subject = Generators::Core::Text.normalize_subject(title)
  interview = interviews_by_id[asset['interview_id'].to_s]

  context_bits = []
  conference = interview && interview['conference'].to_s.strip
  conference_year = interview && interview['conference_year'].to_s.strip
  unless conference.to_s.empty?
    conf_text = conference.dup
    conf_text << " #{conference_year}" unless conference_year.to_s.empty?
    context_bits << conf_text
  end
  community = interview && interview['community'].to_s.strip
  context_bits << community unless community.to_s.empty?
  context = context_bits.first(2).join(' · ')

  title_core = +"Video — #{subject}"
  title_core << " (#{context})" unless context.empty?
  title_meta = Generators::Core::Meta.clamp(title_core, 70)

  description_parts = []
  canonical_description = asset['description'].to_s.gsub(/\s+/, ' ').strip
  if canonical_description.empty?
    description_parts << "Canonical video asset for #{subject}"
    topic = asset['topic'].to_s.strip
    description_parts << "Topic: #{topic}" unless topic.empty?
    description_parts << "Conference: #{conference} #{conference_year}".strip unless conference.to_s.empty?
    description_parts << "Community: #{community}" unless community.to_s.empty?
    published_date = asset['published_date'].to_s.strip
    description_parts << "Published: #{published_date}" unless published_date.empty?
    description_parts << "Asset ID: #{id}"
  else
    description_parts << canonical_description
    description_parts << "Asset ID: #{id}"
  end
  description_meta = Generators::Core::Meta.clamp("#{description_parts.join('. ')}.", 160)
  title_meta = Generators::Core::Meta.ensure_unique(title_meta, 70, id, seen_titles)
  description_meta = Generators::Core::Meta.ensure_unique(description_meta, 160, id, seen_descriptions)
  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: #{Generators::Core::Text.yaml_quote(title_meta)}"
    f.puts "description: #{Generators::Core::Text.yaml_quote(description_meta)}"
    f.puts "breadcrumb: #{Generators::Core::Text.yaml_quote(title)}"
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

#!/usr/bin/env ruby
require 'yaml'
require 'date'

root = File.expand_path('..', __dir__)
ugtastic_path = File.join(root, '_data', 'ugtastic.yml')
communities_path = File.join(root, '_data', 'ugtastic_communities.yml')

ugtastic = YAML.safe_load(File.read(ugtastic_path), permitted_classes: [Time, Date], aliases: true)
items = ugtastic['items'] || []

# Extract community name from title when possible
# Examples: "ChicagoRuby w/Ray Hightower", "GOTO Conference and Community w/Dave Thomas"
# Fallback: General

def extract_community_name(title)
  return nil unless title
  patterns = [
    /\s+w\//i,
    /\s+w\s+/i,
    /\s+with\s+/i
  ]
  patterns.each do |pat|
    if title =~ pat
      return title.split(pat).first.strip
    end
  end
  nil
end

def slugify(name)
  name.to_s.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-+|-+$/, '')
end

community_map = {}

items.each do |item|
  next if item['conference']
  name = extract_community_name(item['title'])
  name = 'General' if name.nil? || name.empty?
  slug = slugify(name)
  item['community'] = slug
  community_map[slug] = name
end

communities = community_map.map do |slug, name|
  {
    'slug' => slug,
    'name' => name,
    'description' => "UGtastic community interviews from #{name}."
  }
end.sort_by { |c| c['name'].downcase == 'general' ? 'zzzz' : c['name'].downcase }

File.open(communities_path, 'w') do |f|
  f.puts '---'
  f.puts 'communities:'
  communities.each do |c|
    f.puts "  - slug: #{c['slug']}"
    f.puts "    name: #{c['name']}"
    f.puts "    description: #{c['description']}"
  end
end

# Write updated ugtastic.yml without changing structure too much
File.open(ugtastic_path, 'w') do |f|
  f.puts '---'
  f.puts 'items:'
  items.each do |item|
    f.puts "  - id: #{item['id']}"
    f.puts "    title: #{item['title'].to_s.include?("\"") ? "'" + item['title'].to_s.gsub("'", "''") + "'" : item['title'].to_s.inspect}"
    f.puts "    link: #{item['link']}"
    f.puts "    created: #{item['created']}" if item['created']
    f.puts "    duration_seconds: #{item['duration_seconds']}" if item['duration_seconds']
    f.puts "    duration_minutes: #{item['duration_minutes']}" if item['duration_minutes']
    f.puts "    thumbnail: #{item['thumbnail']}" if item['thumbnail']
    f.puts "    thumbnail_local: #{item['thumbnail_local']}" if item['thumbnail_local']
    f.puts "    kind: #{item['kind']}" if item['kind']
    f.puts "    conference: #{item['conference']}" if item['conference']
    f.puts "    community: #{item['community']}" if item['community']
    if item['tags'] && !item['tags'].empty?
      f.puts '    tags:'
      item['tags'].each { |t| f.puts "      - #{t}" }
    else
      f.puts '    tags: []'
    end
    if item['description']
      f.puts '    description: |'
      item['description'].to_s.split("\n").each { |ln| f.puts "      #{ln}" }
    end
    if item['transcript']
      f.puts '    transcript: |'
      item['transcript'].to_s.split("\n").each { |ln| f.puts "      #{ln}" }
    end
  end
end

puts "Wrote #{communities_path} and updated #{ugtastic_path}"

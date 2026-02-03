#!/usr/bin/env ruby
require 'yaml'
require 'date'
require 'open-uri'
require 'fileutils'

root = File.expand_path('..', __dir__)
ugtastic_path = File.join(root, '_data', 'ugtastic.yml')
thumbnails_dir = File.join(root, 'assets', 'ugtastic', 'thumbs')
FileUtils.mkdir_p(thumbnails_dir)

ugtastic = YAML.safe_load(File.read(ugtastic_path), permitted_classes: [Time, Date], aliases: true)
items = ugtastic['items'] || []

items.each do |item|
  next unless item['thumbnail']
  id = item['id'].to_s
  local_rel = "/assets/ugtastic/thumbs/#{id}.jpg"
  local_path = File.join(thumbnails_dir, "#{id}.jpg")

  if File.exist?(local_path)
    item['thumbnail_local'] = local_rel
    next
  end

  begin
    URI.open(item['thumbnail']) do |io|
      File.open(local_path, 'wb') { |f| f.write(io.read) }
    end
    item['thumbnail_local'] = local_rel
  rescue => e
    warn "Failed to download thumbnail for #{id}: #{e.message}"
  end
end

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

puts "Downloaded thumbnails to #{thumbnails_dir}"

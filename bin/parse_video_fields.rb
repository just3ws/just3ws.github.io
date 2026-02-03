#!/usr/bin/env ruby
require 'yaml'
require 'date'

root = File.expand_path('..', __dir__)

def parse_title(title)
  t = title.to_s.strip
  topic = t
  people = []

  if t.include?(' w/')
    parts = t.split(' w/', 2)
    topic = parts[0].strip
    people = parts[1].split(/\s*(?:,|&|and)\s*/).map(&:strip)
  elsif t.include?(' with ')
    parts = t.split(' with ', 2)
    topic = parts[0].strip
    people = parts[1].split(/\s*(?:,|&|and)\s*/).map(&:strip)
  end

  people = people.map { |p| p.gsub(/[()]/, '').strip }.reject(&:empty?)
  [topic, people]
end

def update_yaml(path)
  data = YAML.safe_load(File.read(path), permitted_classes: [Time, Date], aliases: true) || {}
  items = data['items'] || []
  items.each do |item|
    topic, people = parse_title(item['title'])
    item['topic'] = topic unless topic.to_s.empty?
    item['people'] = people if people.any?
  end
  File.open(path, 'w') do |f|
    f.puts '---'
    f.write(YAML.dump({'items' => items}).sub(/^---\n/, ''))
  end
  puts "Updated #{path}"
end

update_yaml(File.join(root, '_data', 'vimeo_videos.yml'))
update_yaml(File.join(root, '_data', 'ugtastic.yml'))

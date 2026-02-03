#!/usr/bin/env ruby
require 'yaml'
require 'date'

root = File.expand_path('..', __dir__)

# Helpers

def split_people(str)
  return [] unless str
  str.split(/\s*(?:,|&|and)\s*/).map { |p| p.gsub(/[()]/, '').strip }.reject(&:empty?)
end

def parse_title(title)
  t = title.to_s.strip
  topic = t
  people = []

  if t.include?(' w/')
    parts = t.split(' w/', 2)
    topic = parts[0].strip
    people = split_people(parts[1])
  elsif t.include?(' with ')
    parts = t.split(' with ', 2)
    topic = parts[0].strip
    people = split_people(parts[1])
  end

  [topic, people]
end

# Load community/conference name maps for UGtastic
comm_path = File.join(root, '_data', 'ugtastic_communities.yml')
conf_path = File.join(root, '_data', 'ugtastic_conferences.yml')
comm_map = {}
conf_map = {}
if File.exist?(comm_path)
  comms = YAML.safe_load(File.read(comm_path), permitted_classes: [Date], aliases: true)['communities'] || []
  comm_map = comms.each_with_object({}) { |c, h| h[c['slug']] = c['name'] }
end
if File.exist?(conf_path)
  confs = YAML.safe_load(File.read(conf_path), permitted_classes: [Date], aliases: true)['conferences'] || []
  conf_map = confs.each_with_object({}) { |c, h| h[c['slug']] = c['name'] }
end

# Update UGtastic
ugtastic_path = File.join(root, '_data', 'ugtastic.yml')
ugtastic = YAML.safe_load(File.read(ugtastic_path), permitted_classes: [Time, Date], aliases: true) || {}
ugt_items = ugtastic['items'] || []

ugt_items.each do |item|
  topic, people = parse_title(item['title'])
  # For UGtastic, topic is the interview subject (prefix before w/)
  item['topic'] = topic
  item['interviewees'] = people if people.any?
  item.delete('people')
end

File.open(ugtastic_path, 'w') do |f|
  f.puts '---'
  f.write(YAML.dump({'items' => ugt_items}).sub(/^---\n/, ''))
end

# Update Vimeo
vimeo_path = File.join(root, '_data', 'vimeo_videos.yml')
vimeo = YAML.safe_load(File.read(vimeo_path), permitted_classes: [Time, Date], aliases: true) || {}
vim_items = vimeo['items'] || []

vim_items.each do |item|
  topic, people = parse_title(item['title'])
  # For SCMC videos, people are speakers; topic is the talk title
  if item['category'] == 'scmc'
    item['topic'] = topic
    item['speakers'] = people if people.any?
    item.delete('people')
  else
    item['topic'] = topic
    item['people'] = people if people.any?
  end
end

File.open(vimeo_path, 'w') do |f|
  f.puts '---'
  f.write(YAML.dump({'items' => vim_items}).sub(/^---\n/, ''))
end

puts 'Updated UGtastic and Vimeo metadata with topic/people fields'

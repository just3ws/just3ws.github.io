#!/usr/bin/env ruby
require 'yaml'
require 'date'

root = File.expand_path('..', __dir__)
data_path = File.join(root, '_data', 'ugtastic.yml')
conf_path = File.join(root, '_data', 'ugtastic_conferences.yml')
comm_path = File.join(root, '_data', 'ugtastic_communities.yml')
videos_dir = File.join(root, 'ugtastic', 'videos')

ugtastic = YAML.safe_load(File.read(data_path), permitted_classes: [Time, Date], aliases: true)
confs = YAML.safe_load(File.read(conf_path), permitted_classes: [Date], aliases: true)['conferences']
comms = YAML.safe_load(File.read(comm_path), permitted_classes: [Date], aliases: true)['communities']
conf_slugs = confs.map { |c| c['slug'] }
comm_slugs = comms.map { |c| c['slug'] }

errors = []

(ugtastic['items'] || []).each do |item|
  id = item['id']
  errors << "missing id" unless id
  errors << "missing title for #{id}" unless item['title']
  errors << "missing link for #{id}" unless item['link']
  errors << "missing created for #{id}" unless item['created']
  errors << "missing duration_minutes for #{id}" unless item['duration_minutes']

  if item['conference'] && !conf_slugs.include?(item['conference'])
    errors << "unknown conference slug #{item['conference']} for #{id}"
  end
  if item['community'] && !comm_slugs.include?(item['community'])
    errors << "unknown community slug #{item['community']} for #{id}"
  end

  if item['thumbnail_local']
    local = File.join(root, item['thumbnail_local'])
    errors << "missing local thumbnail for #{id}" unless File.exist?(local)
  end

  if id
    page = File.join(videos_dir, id.to_s, 'index.html')
    errors << "missing video page for #{id}" unless File.exist?(page)
  end
end

if errors.any?
  warn errors.join("\n")
  exit 1
else
  puts "UGtastic validation passed"
end

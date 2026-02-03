#!/usr/bin/env ruby
require 'yaml'
require 'date'

root = File.expand_path('..', __dir__)
data_path = File.join(root, '_data', 'ugtastic.yml')
conf_path = File.join(root, '_data', 'ugtastic_conferences.yml')
comm_path = File.join(root, '_data', 'ugtastic_communities.yml')
interviews_path = File.join(root, '_data', 'interviews.yml')
assets_path = File.join(root, '_data', 'interview_assets.yml')
videos_dir = File.join(root, 'ugtastic', 'videos')

ugtastic = YAML.safe_load(File.read(data_path), permitted_classes: [Time, Date], aliases: true)
confs = YAML.safe_load(File.read(conf_path), permitted_classes: [Date], aliases: true)['conferences']
comms = YAML.safe_load(File.read(comm_path), permitted_classes: [Date], aliases: true)['communities']
interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
conf_slugs = confs.map { |c| c['slug'] }
comm_slugs = comms.map { |c| c['slug'] }
interview_ids = interviews.map { |i| i['id'] }
ugtastic_assets = assets.select { |a| a['source'] == 'ugtastic' }

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

  if id
    asset = ugtastic_assets.find { |a| a['asset_id'].to_s == id.to_s }
    if asset.nil?
      errors << "missing interview asset mapping for #{id}"
    elsif !interview_ids.include?(asset['interview_id'])
      errors << "missing interview for asset #{id} (#{asset['interview_id']})"
    end
  end
end

if errors.any?
  warn errors.join("\n")
  exit 1
else
  puts "UGtastic validation passed"
end

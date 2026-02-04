#!/usr/bin/env ruby
require 'yaml'
require 'date'

root = File.expand_path('..', __dir__)
conf_path = File.join(root, '_data', 'interview_conferences.yml')
comm_path = File.join(root, '_data', 'interview_communities.yml')
interviews_path = File.join(root, '_data', 'interviews.yml')
assets_path = File.join(root, '_data', 'video_assets.yml')
videos_dir = File.join(root, 'ugtastic', 'videos')

confs = YAML.safe_load(File.read(conf_path), permitted_classes: [Date], aliases: true)['conferences']
comms = YAML.safe_load(File.read(comm_path), permitted_classes: [Date], aliases: true)['communities']
interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
conf_slugs = confs.map { |c| c['slug'] }
comm_slugs = comms.map { |c| c['slug'] }
conf_names = confs.map { |c| c['name'] }
comm_names = comms.map { |c| c['name'] }
interview_ids = interviews.map { |i| i['id'] }
ugtastic_assets = assets.select { |a| a['source'] == 'ugtastic' }

errors = []

ugtastic_assets.each do |asset|
  errors << "missing id for ugtastic asset" unless asset['id']

  vimeo = (asset['platforms'] || []).find { |p| p['platform'] == 'vimeo' } || (asset['platforms'] || []).first
  vimeo_id = vimeo && vimeo['asset_id']
  errors << "missing vimeo asset_id for #{asset['id']}" unless vimeo_id
  errors << "missing url for #{asset['id']}" unless vimeo && vimeo['url']
  errors << "missing published_date for #{asset['id']}" unless (vimeo && vimeo['published_date']) || asset['published_date']
  errors << "missing duration_minutes for #{asset['id']}" unless (vimeo && vimeo['duration_minutes']) || asset['duration_minutes']

  if vimeo && vimeo['thumbnail_local']
    local = File.join(root, vimeo['thumbnail_local'])
    errors << "missing local thumbnail for #{asset['id']}" unless File.exist?(local)
  end

  if vimeo_id
    page = File.join(videos_dir, vimeo_id.to_s, 'index.html')
    errors << "missing video page for #{vimeo_id}" unless File.exist?(page)
  end

  interview = interviews.find { |i| i['id'] == asset['interview_id'] }
  if interview.nil?
    errors << "missing interview for asset #{asset['id']} (#{asset['interview_id']})"
  else
    if interview['conference'] && !conf_names.include?(interview['conference'])
      errors << "unknown conference name #{interview['conference']} for #{asset['id']}"
    end
    if interview['community'] && !comm_names.include?(interview['community'])
      errors << "unknown community name #{interview['community']} for #{asset['id']}"
    end
  end
end

if errors.any?
  warn errors.join("\n")
  exit 1
else
  puts "UGtastic validation passed"
end

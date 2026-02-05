#!/usr/bin/env ruby
require 'yaml'
require 'date'
require 'fileutils'

root = File.expand_path('..', __dir__)
interviews_path = File.join(root, '_data', 'interviews.yml')
assets_path = File.join(root, '_data', 'video_assets.yml')
transcripts_path = File.join(root, '_data', 'transcripts.yml')

interviews = []
assets = []

if File.exist?(interviews_path)
  interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
end
if File.exist?(assets_path)
  assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
end

assets_by_interview = Hash.new { |h, k| h[k] = [] }
assets.each do |asset|
  next unless asset['interview_id']
  assets_by_interview[asset['interview_id']] << asset['id']
end

interviews.each do |interview|
  list = assets_by_interview[interview['id']] || []
  interview['video_asset_id'] = list.first
  interview.delete('video_assets')
end

interviews.sort_by! { |i| [i['conference_year'] || 0, i['conference'] || '', i['title']] }
assets.sort_by! { |a| [a['primary_platform'] || '', a['id']] }

File.write(interviews_path, { 'items' => interviews }.to_yaml)
File.write(assets_path, { 'items' => assets }.to_yaml)
File.write(transcripts_path, { 'items' => [] }.to_yaml) unless File.exist?(transcripts_path)

puts "Built #{interviews.size} interviews and #{assets.size} assets"

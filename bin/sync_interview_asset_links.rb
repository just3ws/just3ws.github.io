#!/usr/bin/env ruby

# ---
# name: sync_interview_asset_links.rb
# domain: data
# purpose: Sync Interview Asset Links utility for the just3ws platform
# usage: ruby bin/sync_interview_asset_links.rb
# ---

require 'yaml'
require 'date'
require 'fileutils'

root = File.expand_path('..', __dir__)
interviews_path = File.join(root, '_data', 'interviews.yml')
assets_path = File.join(root, '_data', 'video_assets.yml')

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
  key = asset['interview_id'] || asset['id']
  next unless key
  assets_by_interview[key] << asset['id']
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

puts "Built #{interviews.size} interviews and #{assets.size} assets"

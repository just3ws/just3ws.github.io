#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'date'
require_relative '../src/validators/site_schema'

ROOT = File.expand_path('..', __dir__)

def load_yaml(path, key)
  data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
  data[key] || []
end

def validate_collection(items, contract_class, label)
  errors = []
  contract = contract_class.new
  items.each do |item|
    id = item['id'] || item['name'] || '<unknown>'
    result = contract.call(item)
    next if result.success?

    result.errors.to_h.each do |field, messages|
      errors << "#{label} [#{id}] field '#{field}': #{messages.join(', ')}"
    end
  end
  errors
end

errors = []

interviews = load_yaml(File.join(ROOT, '_data', 'interviews.yml'), 'items')
assets = load_yaml(File.join(ROOT, '_data', 'video_assets.yml'), 'items')
confs = load_yaml(File.join(ROOT, '_data', 'interview_conferences.yml'), 'conferences')
comms = load_yaml(File.join(ROOT, '_data', 'interview_communities.yml'), 'communities')

positions = Dir[File.join(ROOT, '_data', 'resume', 'positions', '*.yml')].map do |path|
  YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
end

# 1. Schema Validation
errors.concat(validate_collection(interviews, Validators::InterviewContract, 'Interview'))
errors.concat(validate_collection(assets, Validators::VideoAssetContract, 'VideoAsset'))
errors.concat(validate_collection(confs, Validators::ConferenceContract, 'Conference'))
errors.concat(validate_collection(comms, Validators::CommunityContract, 'Community'))
errors.concat(validate_collection(positions, Validators::ResumePositionContract, 'ResumePosition'))

# 2. Referential Integrity
interview_ids = interviews.map { |i| i['id'].to_s }.to_set
asset_ids = assets.map { |a| a['id'].to_s }.to_set

interviews.each do |i|
  v_id = i['video_asset_id'].to_s
  next if v_id.empty?
  errors << "Interview [#{i['id']}] references missing VideoAsset [#{v_id}]" unless asset_ids.include?(v_id)
end

assets.each do |a|
  i_id = a['interview_id'].to_s
  next if i_id.empty?
  errors << "VideoAsset [#{a['id']}] references missing Interview [#{i_id}]" unless interview_ids.include?(i_id)
end

if errors.empty?
  puts 'Declarative data validation passed.'
  exit 0
end

warn 'Data validation failed:'
errors.each { |error| warn "  - #{error}" }
exit 1

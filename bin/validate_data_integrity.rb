#!/usr/bin/env ruby
require 'yaml'
require 'date'
require 'set'

ROOT = File.expand_path('..', __dir__)

def load_yaml(path, key)
  data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
  data[key] || []
end

def blank?(value)
  value.nil? || (value.respond_to?(:empty?) && value.empty?) || value.to_s.strip.empty?
end

def validate_required_fields(records, label, required_fields)
  errors = []
  records.each do |record|
    record_id = record['id'] || '<missing-id>'
    required_fields.each do |field|
      errors << "#{label} #{record_id} missing required field: #{field}" if blank?(record[field])
    end
  end
  errors
end

errors = []

interviews = load_yaml(File.join(ROOT, '_data', 'interviews.yml'), 'items')
assets = load_yaml(File.join(ROOT, '_data', 'video_assets.yml'), 'items')

errors.concat(validate_required_fields(interviews, 'interview', %w[id title interviewer recorded_date video_asset_id]))
errors.concat(validate_required_fields(assets, 'video asset', %w[id title primary_platform published_date platforms]))

interview_ids = interviews.map { |row| row['id'] }.compact.to_set
asset_ids = assets.map { |row| row['id'] }.compact.to_set

interviews.each do |interview|
  next if blank?(interview['video_asset_id'])
  unless asset_ids.include?(interview['video_asset_id'])
    errors << "interview #{interview['id']} references missing video_asset_id: #{interview['video_asset_id']}"
  end
end

assets.each do |asset|
  next if blank?(asset['interview_id'])
  unless interview_ids.include?(asset['interview_id'])
    errors << "video asset #{asset['id']} references missing interview_id: #{asset['interview_id']}"
  end
end

assets.each do |asset|
  asset_id = asset['id'] || '<missing-id>'
  platforms = asset['platforms']
  if blank?(platforms)
    errors << "video asset #{asset_id} has empty platforms list"
    next
  end

  platforms.each_with_index do |platform, index|
    %w[platform url].each do |field|
      if blank?(platform[field])
        errors << "video asset #{asset_id} platform ##{index} missing required field: #{field}"
      end
    end
  end
end

if errors.empty?
  puts 'Data integrity validation passed.'
  exit 0
end

warn 'Data integrity validation failed:'
errors.each { |error| warn "  - #{error}" }
exit 1

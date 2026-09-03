#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'yaml'

ROOT = File.expand_path('..', __dir__)
POSITIONS_DIR = File.join(ROOT, '_data', 'resume', 'positions')
ISO_DATE = /\A\d{4}-\d{2}-\d{2}\z/.freeze
PRECISIONS = %w[year month day].freeze

errors = []
files = Dir.glob(File.join(POSITIONS_DIR, '*.yml')).sort

files.each do |file|
  relative = file.delete_prefix("#{ROOT}/")
  data = YAML.safe_load(File.read(file), permitted_classes: [Date], aliases: true) || {}

  %w[start_date end_date].each do |field|
    value = data[field]
    next if field == 'end_date' && value.nil?

    unless value.is_a?(String) && value.match?(ISO_DATE)
      errors << "#{relative}: #{field} must be a quoted ISO 8601 date (YYYY-MM-DD) or null"
      next
    end

    Date.iso8601(value)
  rescue ArgumentError
    errors << "#{relative}: #{field} is not a valid calendar date: #{value.inspect}"
  end

  precision = data['date_precision']
  unless precision.is_a?(String) && PRECISIONS.include?(precision)
    errors << "#{relative}: date_precision must be one of #{PRECISIONS.join(', ')}"
  end

  if data['end_date'] && data['start_date'] && data['end_date'] < data['start_date']
    errors << "#{relative}: end_date must not precede start_date"
  end
end

if errors.empty?
  puts "Position date validation passed for #{files.length} files."
  exit 0
end

warn errors.join("\n")
exit 1

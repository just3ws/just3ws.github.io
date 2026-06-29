#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('..', __dir__)
DEFAULT_REPORT_PATH = File.join(ROOT, 'tmp', 'seo-metadata-report.json')
report_path = ENV.fetch('SEO_REPORT_JSON', DEFAULT_REPORT_PATH)

unless File.file?(report_path)
  system({ 'SEO_REPORT_JSON' => report_path }, 'ruby', './bin/report_seo_metadata.rb', chdir: ROOT)
end

unless File.file?(report_path)
  warn "SEO metadata budget check failed: missing #{report_path}"
  exit 1
end

report = JSON.parse(File.read(report_path))

budgets = {
  'title_outliers' => ENV.fetch('SEO_MAX_TITLE_OUTLIERS', '16').to_i,
  'desc_outliers' => ENV.fetch('SEO_MAX_DESC_OUTLIERS', '56').to_i,
  'duplicate_titles' => ENV.fetch('SEO_MAX_DUPLICATE_TITLES', '0').to_i,
  'duplicate_descs' => ENV.fetch('SEO_MAX_DUPLICATE_DESCS', '200').to_i
}
mode = ENV.fetch('SEO_METADATA_BUDGET_MODE', 'error')

issues = budgets.filter_map do |metric, budget|
  actual = report.fetch(metric, 0).to_i
  "#{metric}=#{actual} exceeds budget=#{budget}" if actual > budget
end

puts 'SEO metadata budget'
puts "  report_json=#{report_path}"
budgets.each do |metric, budget|
  puts "  #{metric}=#{report.fetch(metric, 0)} (budget=#{budget})"
end

if issues.empty?
  puts 'SEO metadata budget passed.'
  exit 0
end

if mode == 'error'
  warn 'SEO metadata budget failed:'
  issues.each { |issue| warn "  - #{issue}" }
  exit 1
end

warn 'SEO metadata budget warnings:'
issues.each { |issue| warn "  - #{issue}" }
puts "Continuing because SEO_METADATA_BUDGET_MODE=#{mode}."
exit 0

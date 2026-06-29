#!/usr/bin/env ruby
require 'json'
require 'fileutils'
require 'time'

ROOT = File.expand_path('..', __dir__)
SITE_DIR = File.join(ROOT, '_site')
DEFAULT_REPORT_PATH = File.join(ROOT, 'tmp', 'seo-metadata-report.json')
report_path = ENV.fetch('SEO_REPORT_JSON', DEFAULT_REPORT_PATH)
EXCLUDED_PREFIXES = ['AGENTS.', 'backlog/'].freeze
EXCLUDED_FILES = ['AGENTS.html'].freeze
SAMPLE_LIMIT = 10

title_re = /<title[^>]*>(.*?)<\/title>/im
desc_re = /<meta[^>]*name=["']description["'][^>]*content=["'](.*?)["'][^>]*>/im
noindex_re = /<meta[^>]+name=["']robots["'][^>]+content=["'][^"']*noindex/i

def excluded_path?(relative)
  EXCLUDED_FILES.include?(relative) || EXCLUDED_PREFIXES.any? { |prefix| relative.start_with?(prefix) }
end

def sample_paths(records, limit: SAMPLE_LIMIT)
  records.first(limit).map { |record| record[:path] }
end

def duplicate_samples(records, key)
  grouped = records.group_by { |record| record[key] }
  grouped.each_with_object({}) do |(value, matches), samples|
    next if value.nil? || value.empty? || matches.size < 2

    samples[value] = {
      count: matches.size,
      paths: sample_paths(matches)
    }
  end.sort_by { |_value, data| -data[:count] }.first(SAMPLE_LIMIT).to_h
end

records = []
Dir.glob(File.join(SITE_DIR, '**', '*.html')).each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if excluded_path?(relative)

  html = File.read(path)
  title = html[title_re, 1]&.strip
  desc = html[desc_re, 1]&.strip
  noindex = html.match?(noindex_re)
  records << { path: relative, title: title, desc: desc, noindex: noindex }
end

indexable = records.reject { |r| r[:noindex] }

title_counts = Hash.new(0)
desc_counts = Hash.new(0)
indexable.each do |r|
  title_counts[r[:title]] += 1 if r[:title] && !r[:title].empty?
  desc_counts[r[:desc]] += 1 if r[:desc] && !r[:desc].empty?
end

title_outliers = indexable.select { |r| r[:title].nil? || r[:title].length < 30 || r[:title].length > 70 }
desc_outliers = indexable.select { |r| r[:desc].nil? || r[:desc].length < 70 || r[:desc].length > 160 }

duplicate_titles = title_counts.select { |_k, v| v > 1 }
duplicate_descs = desc_counts.select { |_k, v| v > 1 }
title_outlier_samples = sample_paths(title_outliers)
desc_outlier_samples = sample_paths(desc_outliers)
duplicate_title_samples = duplicate_samples(indexable, :title)
duplicate_desc_samples = duplicate_samples(indexable, :desc)

puts 'SEO metadata report:'
puts "  html_pages=#{records.size}"
puts "  indexable_pages=#{indexable.size}"
puts "  noindex_pages=#{records.size - indexable.size}"
puts "  title_outliers=#{title_outliers.size} (target: 30-70 chars)"
puts "  desc_outliers=#{desc_outliers.size} (target: 70-160 chars)"
puts "  duplicate_titles=#{duplicate_titles.size}"
puts "  duplicate_descs=#{duplicate_descs.size}"

unless duplicate_titles.empty?
  puts '  top_duplicate_titles:'
  duplicate_titles.sort_by { |_k, v| -v }.first(5).each do |title, count|
    puts "    - #{count}x #{title}"
  end
end

unless duplicate_descs.empty?
  puts '  top_duplicate_descriptions:'
  duplicate_descs.sort_by { |_k, v| -v }.first(5).each do |desc, count|
    puts "    - #{count}x #{desc}"
  end
end

report = {
  html_pages: records.size,
  indexable_pages: indexable.size,
  noindex_pages: records.size - indexable.size,
  title_outliers: title_outliers.size,
  desc_outliers: desc_outliers.size,
  duplicate_titles: duplicate_titles.size,
  duplicate_descs: duplicate_descs.size,
  title_outlier_samples: title_outlier_samples,
  desc_outlier_samples: desc_outlier_samples,
  duplicate_title_samples: duplicate_title_samples,
  duplicate_desc_samples: duplicate_desc_samples,
  generated_at: Time.now.utc.iso8601
}

FileUtils.mkdir_p(File.dirname(report_path))
File.write(report_path, JSON.pretty_generate(report) + "\n")
puts "  report_json=#{report_path}"

#!/usr/bin/env ruby
require 'yaml'

interviews = YAML.load_file("_data/interviews.yml")["items"]
assets = YAML.load_file("_data/video_assets.yml")["items"]

results = {
  total: interviews.size,
  optimized_title: [],
  needs_title_hook: [],
  has_chapters: [],
  missing_chapters: [],
  has_cta_link: [],
  missing_cta_link: []
}

interviews.each do |i|
  asset = assets.find { |a| a["id"] == i["video_asset_id"] } || assets.find { |a| a["id"] == i["id"] }
  next unless asset

  title = asset["title"].to_s
  desc = asset["description"].to_s

  # 1. Title Audit (Look for Hook/Context structure, e.g., colon or pipe)
  if title.include?(":") || title.include?("|")
    results[:optimized_title] << i["id"]
  else
    results[:needs_title_hook] << i["id"]
  end

  # 2. Chapters Audit
  if desc.match?(/(?:00:\d{2}:\d{2}|\d{2}:\d{2})\s+-/) || desc.downcase.include?("chapters:")
    results[:has_chapters] << i["id"]
  else
    results[:missing_chapters] << i["id"]
  end

  # 3. CTA Link Audit
  if desc.include?("just3ws.github.io/interviews/") || desc.include?("UGtastic.com")
    results[:has_cta_link] << i["id"]
  else
    results[:missing_cta_link] << i["id"]
  end
end

puts "=== YOUTUBE METADATA SEO AUDIT ==="
puts "Total Interviews: #{results[:total]}"
puts "----------------------------------"
puts "TITLES:"
puts "✅ Optimized (Hook Format): #{results[:optimized_title].size}"
puts "❌ Needs Hook/Optimization: #{results[:needs_title_hook].size}"
puts ""
puts "DESCRIPTIONS (CHAPTERS):"
puts "✅ Has Timestamps/Chapters: #{results[:has_chapters].size}"
puts "❌ Missing Chapters:        #{results[:missing_chapters].size}"
puts ""
puts "DESCRIPTIONS (CTA LINKS):"
puts "✅ Has Site CTA Link:       #{results[:has_cta_link].size}"
puts "❌ Missing Site CTA Link:   #{results[:missing_cta_link].size}"
puts "=================================="

if results[:needs_title_hook].any?
  puts "\nSample of Titles needing hooks:"
  results[:needs_title_hook].first(5).each do |id|
    a = assets.find { |a| a["id"] == id }
    puts " - #{a['title']}" if a
  end
end

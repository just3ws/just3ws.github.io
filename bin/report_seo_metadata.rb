#!/usr/bin/env ruby

ROOT = File.expand_path('..', __dir__)
SITE_DIR = File.join(ROOT, '_site')

title_re = /<title[^>]*>(.*?)<\/title>/im
desc_re = /<meta[^>]*name=["']description["'][^>]*content=["'](.*?)["'][^>]*>/im
noindex_re = /<meta[^>]+name=["']robots["'][^>]+content=["'][^"']*noindex/i

records = []
Dir.glob(File.join(SITE_DIR, '**', '*.html')).each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative.start_with?('AGENTS.')
  next if relative == 'AGENTS.html'

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

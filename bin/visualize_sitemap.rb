#!/usr/bin/env ruby
require 'rexml/document'

ROOT = File.expand_path('..', __dir__)
SITEMAP_PATH = File.join(ROOT, '_site', 'sitemap.xml')

abort('Missing _site/sitemap.xml. Run ./bin/pipeline build first.') unless File.file?(SITEMAP_PATH)

xml = File.read(SITEMAP_PATH)
doc = REXML::Document.new(xml)
urls = []

doc.elements.each('urlset/url/loc') do |node|
  urls << node.text.to_s.strip
end

if urls.empty?
  puts 'Sitemap contains 0 URLs.'
  exit 0
end

paths = urls.map { |u| u.sub(%r{\Ahttps?://[^/]+}, '') }
paths.map! { |p| p.empty? ? '/' : p }
sections = Hash.new(0)

paths.each do |path|
  top = path.split('/').reject(&:empty?).first || '/'
  sections[top] += 1
end

puts "Sitemap URL count: #{urls.size}"
puts
puts 'Sections:'
sections.sort_by { |section, count| [-count, section] }.each do |section, count|
  label = section == '/' ? '/' : "/#{section}/"
  puts "  #{label.ljust(20)} #{count}"
end

puts
puts 'First 50 URLs:'
urls.sort.first(50).each do |url|
  puts "  #{url}"
end

if urls.size > 50
  puts "  ... (#{urls.size - 50} more)"
end

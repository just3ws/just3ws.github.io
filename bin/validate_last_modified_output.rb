#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'time'

ROOT = File.expand_path('..', __dir__)
DATA_PATH = File.join(ROOT, '_data', 'last_modified.yml')
SITE_DIR = File.join(ROOT, '_site')

def load_items(path)
  data = YAML.safe_load(File.read(path), aliases: true) || {}
  items = data['items'] || data
  items.is_a?(Hash) ? items : {}
end

def post_output_path(relative_post_path)
  filename = File.basename(relative_post_path)
  match = filename.match(/\A(\d{4})-(\d{2})-(\d{2})-(.+)\.(md|markdown|html)\z/)
  return nil unless match

  full_path = File.join(ROOT, relative_post_path)
  if File.file?(full_path)
    content = File.read(full_path, encoding: 'UTF-8')
    if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
      fm = (YAML.safe_load(Regexp.last_match(1), permitted_classes: [Date, Time], aliases: true) rescue {}) || {}
      if fm.is_a?(Hash) && fm['permalink']
        perm = fm['permalink'].sub(%r{\A/}, '').sub(%r{/\z}, '')
        dir_idx = File.join(SITE_DIR, perm, 'index.html')
        return dir_idx if File.file?(dir_idx)
        file_html = File.join(SITE_DIR, "#{perm}.html")
        return file_html if File.file?(file_html)
      end
    end
  end

  year, month, day, slug = match.captures
  dir_index = File.join(SITE_DIR, year, month, day, slug, "index.html")
  return dir_index if File.file?(dir_index)
  File.join(SITE_DIR, year, month, day, "#{slug}.html")
end

def parse_iso8601(value)
  Time.parse(value.to_s).iso8601
rescue StandardError
  nil
end

def extract_date_modified(html)
  html[/\"dateModified\":\s*\"([^\"]+)\"/, 1]
end

errors = []
items = load_items(DATA_PATH)
posts = Dir.glob(File.join(ROOT, '_posts', '**', '*.{md,markdown,html}')).sort
relative_posts = posts.map { |path| path.sub("#{ROOT}/", '') }

relative_posts.each do |relative|
  unless items.key?(relative)
    errors << "missing last-modified entry for #{relative}"
    next
  end

  iso = parse_iso8601(items[relative])
  errors << "invalid last-modified timestamp for #{relative}: #{items[relative].inspect}" unless iso

  output_path = post_output_path(relative)
  if output_path.nil?
    errors << "unable to determine output path for #{relative}"
    next
  end
  unless File.file?(output_path)
    errors << "missing built article page for #{relative}: #{output_path}"
    next
  end

  html = File.read(output_path, encoding: 'UTF-8')
  modified = extract_date_modified(html)
  if modified.nil? || modified.strip.empty?
    errors << "missing dateModified in #{output_path}"
    next
  end

  rendered_iso = parse_iso8601(modified)
  unless rendered_iso
    errors << "invalid rendered dateModified in #{output_path}: #{modified.inspect}"
    next
  end

  errors << "dateModified mismatch for #{relative}: expected #{iso}, got #{rendered_iso}" if iso && rendered_iso != iso
end

extra_keys = items.keys - relative_posts
extra_keys.each do |key|
  errors << "unexpected last-modified entry (no matching post): #{key}"
end

if errors.empty?
  puts "Last-modified validation passed (posts=#{relative_posts.size})."
  exit 0
end

warn 'Last-modified validation failed:'
errors.each { |error| warn "  - #{error}" }
exit 1

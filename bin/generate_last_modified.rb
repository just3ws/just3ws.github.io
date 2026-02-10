#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'open3'
require 'fileutils'

ROOT = File.expand_path('..', __dir__)
OUTPUT_PATH = File.join(ROOT, '_data', 'last_modified.yml')

def git_last_modified_iso8601(path)
  out, status = Open3.capture2('git', 'log', '-1', '--format=%cI', '--', path, chdir: ROOT)
  return nil unless status.success?

  value = out.strip
  value.empty? ? nil : value
end

items = {}

Dir.glob(File.join(ROOT, '_posts', '**', '*.{md,markdown,html}')).sort.each do |abs_path|
  relative = abs_path.sub("#{ROOT}/", '')
  modified = git_last_modified_iso8601(relative)
  items[relative] = modified if modified
end

payload = { 'items' => items }

FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
File.write(OUTPUT_PATH, payload.to_yaml)

puts "Last-modified metadata generated (records=#{items.size})."

#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path('..', __dir__)
PUBLIC_LINK_SOURCES = [
  File.join(ROOT, 'timeline', 'index.html'),
  File.join(ROOT, '_layouts', 'base.html')
].freeze

quarantined = PUBLIC_LINK_SOURCES.flat_map do |file|
  source = File.read(file)
  source.scan(%r{(?:url|href)\s*[:=]\s*['"]([^'"]*?/ai/\d{4}/[^'"]*)['"]}).flatten.map { |url| [file.delete_prefix("#{ROOT}/"), url] }
end

if quarantined.empty?
  puts 'Timeline link validation passed: no quarantined /ai/ links found.'
  exit 0
end

warn "Public timeline surface contains quarantined article links:\n#{quarantined.map { |file, url| "#{file}: #{url}" }.join("\n")}"
exit 1

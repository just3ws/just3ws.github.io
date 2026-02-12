#!/usr/bin/env ruby

require "yaml"
require "uri"
require "set"
require "date"

ROOT = File.expand_path("..", __dir__)
RESOURCES_PATH = File.join(ROOT, "_data", "resources.yml")
CONFERENCES_PATH = File.join(ROOT, "_data", "interview_conferences.yml")

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
end

resources = load_yaml(RESOURCES_PATH)
conferences = load_yaml(CONFERENCES_PATH).fetch("conferences", [])
conference_slugs = conferences.map { |entry| entry["slug"].to_s }.reject(&:empty?).to_set

errors = []

conference_sources = resources.fetch("conferences", {})
unless conference_sources.is_a?(Hash)
  errors << "resources.yml conferences must be a map keyed by conference slug"
  conference_sources = {}
end

conference_sources.each do |slug, entries|
  slug_s = slug.to_s
  unless conference_slugs.include?(slug_s)
    # Allow historical source buckets that may not map to active conference index pages.
    next
  end

  unless entries.is_a?(Array)
    errors << "resources.yml conferences.#{slug_s} must be an array"
    next
  end

  entries.each_with_index do |entry, idx|
    url =
      if entry.is_a?(String)
        entry.to_s.strip
      elsif entry.is_a?(Hash)
        entry["url"].to_s.strip
      else
        errors << "resources.yml conferences.#{slug_s}[#{idx}] must be a url string or a map with url"
        next
      end

    if url.empty?
      errors << "resources.yml conferences.#{slug_s}[#{idx}] missing url"
      next
    end

    begin
      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTP) && uri.host
        errors << "resources.yml conferences.#{slug_s}[#{idx}] url must be absolute http(s): #{url}"
      end
    rescue URI::InvalidURIError
      errors << "resources.yml conferences.#{slug_s}[#{idx}] has invalid url: #{url}"
    end
  end
end

if errors.empty?
  puts "Resources validation passed."
  exit 0
end

warn "Resources validation failed:"
errors.each { |msg| warn "  - #{msg}" }
exit 1

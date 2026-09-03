#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "yaml"

ROOT = File.expand_path("..", __dir__)
LAYOUT = File.join(ROOT, "_layouts", "post.html")
POSTS = Dir[File.join(ROOT, "_posts", "*.md")].sort

def frontmatter(path)
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  return {} unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
end

errors = []
layout = File.read(LAYOUT)
unless layout.include?("AI disclosure and provenance") && layout.include?("AI-Augmented Human-Led Article")
  errors << "_layouts/post.html does not contain the required visible disclosure"
end

POSTS.each do |path|
  metadata = frontmatter(path)
  permalink = metadata["permalink"].to_s
  quarantined = metadata["ai_generated"] == true || permalink.start_with?("/ai/")
  flagged = metadata["ai_assisted"] == true || quarantined
  next unless flagged

  label = path.delete_prefix("#{ROOT}/")
  errors << "#{label}: human_led must be true" unless metadata["human_led"] == true
  errors << "#{label}: source_kind must identify AI-augmented human-led provenance" unless metadata["source_kind"] == "ai-augmented-human-led"

  if quarantined
    errors << "#{label}: exploratory AI synthesis must use an /ai/ permalink" unless permalink.start_with?("/ai/")
    errors << "#{label}: exploratory AI synthesis must use noindex,follow" unless metadata["robots"].to_s.split(",").map(&:strip).include?("noindex")
    errors << "#{label}: exploratory AI synthesis must set sitemap: false" unless metadata["sitemap"] == false
  else
    errors << "#{label}: public AI-assisted article must not set ai_generated: true" if metadata["ai_generated"] == true
    errors << "#{label}: public AI-assisted article must remain indexable" if metadata["robots"].to_s.include?("noindex")
  end

  errors << "#{label}: AI must not be listed as author" if metadata["author"].to_s.match?(/\bai\b/i)
end

if errors.empty?
  puts "AI disclosure validation passed: #{POSTS.count { |path| metadata = frontmatter(path); metadata["ai_assisted"] == true || metadata["ai_generated"] == true || metadata["permalink"].to_s.start_with?("/ai/") }} flagged articles"
  exit 0
end

warn "AI disclosure validation failed:"
errors.each { |error| warn "  - #{error}" }
exit 1

#!/usr/bin/env ruby

require "yaml"
require "pathname"

ROOT = File.expand_path("..", __dir__)
CONFIG_PATH = File.join(ROOT, "_data", "repo_hygiene.yml")

def load_config(path)
  YAML.safe_load(File.read(path), aliases: true) || {}
end

def normalize_set(values)
  Array(values).map { |value| value.to_s.strip }.reject(&:empty?).to_set
end

def top_level_entries(root)
  transient_entries = Set.new(%w[.bundle vendor])
  Dir.children(root)
    .reject { |entry| entry == "." || entry == ".." }
    .reject { |entry| transient_entries.include?(entry) }
    .sort
end

def docs_href_patterns(root)
  patterns = Hash.new { |hash, key| hash[key] = [] }
  candidates = Dir.glob(File.join(root, "{*.html,*.md,docs/**/*.html,docs/**/*.md,_includes/**/*.html,home/**/*.html}"))

  href_regex = /href\s*=\s*["']([^"']+)["']/

  candidates.each do |path|
    next unless File.file?(path)

    content = File.read(path)
    content.scan(href_regex).flatten.each do |href|
      next unless href.start_with?("/docs/")
      next if href.start_with?("/docs/#")

      route = href.split("#", 2).first.split("?", 2).first
      next if route == "/docs/"

      style =
        if route.end_with?(".html")
          "html"
        elsif route.end_with?("/")
          "trailing-slash"
        else
          "bare"
        end

      key = route.sub(%r{\.html$}, "").sub(%r{/$}, "")
      patterns[key] << { route: route, style: style, file: path.sub("#{root}/", "") }
    end
  end

  patterns
end

unless File.file?(CONFIG_PATH)
  warn "Repo hygiene validation failed: missing config #{CONFIG_PATH}"
  exit 1
end

require "set"
config = load_config(CONFIG_PATH)
errors = []
warnings = []

top_level = config.fetch("top_level", {})
allowed_files = normalize_set(top_level["allowed_files"])
allowed_directories = normalize_set(top_level["allowed_directories"])

entries = top_level_entries(ROOT)
entries.each do |entry|
  path = File.join(ROOT, entry)
  if File.file?(path)
    errors << "top-level file not allowlisted: #{entry}" unless allowed_files.include?(entry)
  elsif File.directory?(path)
    errors << "top-level directory not allowlisted: #{entry}" unless allowed_directories.include?(entry)
  else
    warnings << "top-level entry has unknown type: #{entry}"
  end
end

deprecated = config.fetch("deprecated_paths", {})
Array(deprecated["files"]).each do |relative|
  next if relative.to_s.strip.empty?
  abs = File.join(ROOT, relative)
  errors << "deprecated path present: #{relative}" if File.exist?(abs)
end

legacy = config.fetch("legacy", {})
Array(legacy["review_required_paths"]).each do |relative|
  next if relative.to_s.strip.empty?
  abs = File.join(ROOT, relative)
  warnings << "legacy path marked review_required is missing: #{relative}" unless File.exist?(abs)
end

docs_policy = config.fetch("docs_route_policy", {})
docs_mode = docs_policy.fetch("mode", "warn")
allowed_styles = normalize_set(docs_policy["allowed_href_styles"])
docs_mixed_style_issues = []

docs_href_patterns(ROOT).each do |key, hits|
  styles = hits.map { |hit| hit[:style] }.uniq
  disallowed = styles.reject { |style| allowed_styles.include?(style) }
  unless disallowed.empty?
    docs_mixed_style_issues << "docs href style not allowed for #{key}: #{disallowed.join(', ')}"
  end
  if styles.include?("html") && styles.include?("trailing-slash")
    sample = hits.first(3).map { |hit| "#{hit[:route]} (#{hit[:file]})" }.join("; ")
    docs_mixed_style_issues << "mixed docs href styles for #{key}: #{sample}"
  end
end

if docs_mode == "error"
  errors.concat(docs_mixed_style_issues)
else
  warnings.concat(docs_mixed_style_issues)
end

if warnings.any?
  puts "Repo hygiene warnings:"
  warnings.each { |warning| puts "  - #{warning}" }
end

if errors.empty?
  puts "Repo hygiene validation passed."
  exit 0
end

warn "Repo hygiene validation failed:"
errors.each { |error| warn "  - #{error}" }
exit 1

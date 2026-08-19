#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require_relative "../src/generators/core/meta"
require_relative "../src/generators/core/text"

root = File.expand_path("..", __dir__)
briefs_dir = File.join(root, "docs", "executive-briefs")
output_dir = File.join(root, "exports", "briefs")

FileUtils.mkdir_p(output_dir)

brief_files = Dir[File.join(briefs_dir, "*.md")].sort

generated_count = 0
brief_files.each do |file_path|
  raw_name = File.basename(file_path, ".md")
  slug = raw_name.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
  content = File.read(file_path)

  # Extract company and role from markdown headers or title
  company = "Target Organization"
  role = "Principal Software Engineer"
  
  if content =~ /^# Executive Pitch Brief:\s*(.+)$/i || content =~ /^# Job Lead Evaluation:\s*(.+)$/i
    company = Regexp.last_match(1).strip
  end

  if content =~ /\*\*Target Role:\*\*\s*(.+)$/i
    role = Regexp.last_match(1).strip.gsub(/<[^>]+>/, "")
  end

  headline = "#{company} — #{role}"
  page_title = Generators::Core::Meta.clamp("Brief: #{headline}", 70)
  description = "Tailored 1-page executive pitch brief for #{role} at #{company}."
  description = Generators::Core::Meta.ensure_min_length(description, 70, " Part of Mike Hall's executive resume archive.")
  description = Generators::Core::Meta.clamp(description, 160)

  dir = File.join(output_dir, slug)
  FileUtils.mkdir_p(dir)
  out_path = File.join(dir, "index.html")

  # Strip top level markdown title to prevent double titles
  body_content = content.sub(/^#\s+Executive Pitch Brief:[^\n]+\n/i, "")
                        .sub(/^#\s+Job Lead Evaluation:[^\n]+\n/i, "")

  File.open(out_path, "w") do |f|
    f.puts "---"
    f.puts "layout: brief"
    f.puts "title: #{Generators::Core::Text.yaml_quote(page_title)}"
    f.puts "description: #{Generators::Core::Text.yaml_quote(description)}"
    f.puts "permalink: /exports/briefs/#{slug}/"
    f.puts "breadcrumb: #{Generators::Core::Text.yaml_quote("#{company} Brief")}"
    f.puts "breadcrumb_parent_name: Exports"
    f.puts "breadcrumb_parent_url: /exports/"
    f.puts "brief_company: #{Generators::Core::Text.yaml_quote(company)}"
    f.puts "brief_role: #{Generators::Core::Text.yaml_quote(role)}"
    f.puts "sitemap: true"
    f.puts "robots: index,follow"
    f.puts "body_class: ats-resume"
    f.puts "---"
    f.puts
    f.puts body_content
  end

  generated_count += 1
end

puts "Generated #{generated_count} executive brief web pages in #{output_dir}"

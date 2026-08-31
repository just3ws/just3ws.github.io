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
briefs_list = []
brief_files.each do |file_path|
  raw_name = File.basename(file_path, ".md")
  slug = raw_name.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
  content = File.read(file_path)

  # Extract company and role from markdown headers or title
  company = "Target Organization"
  role = "Principal Software Engineer"
  
  if content =~ /^# Executive Pitch Brief:\s*(.+)$/i || content =~ /^# Job Lead Evaluation:\s*(.+)$/i
    company = Regexp.last_match(1).strip.gsub(/\s*\(.*?\)$/, "").strip
  end

  if content =~ /\*\*Company:\*\*\s*(.+)$/i
    company = Regexp.last_match(1).strip.gsub(/\s*\(Remote.*?\)/i, "").strip
  end

  if content =~ /\*\*Target Role:\*\*\s*(.+)$/i
    role = Regexp.last_match(1).strip.gsub(/<[^>]+>/, "")
  end

  headline = "#{company} - #{role}"
  page_title = Generators::Core::Meta.clamp("Brief: #{headline}", 70)
  description = "Tailored 1-page executive pitch brief for #{role} at #{company}."
  description = Generators::Core::Meta.ensure_min_length(description, 70, " Part of Mike Hall's executive resume archive.")
  description = Generators::Core::Meta.clamp(description, 160)

  dir = File.join(output_dir, slug)
  FileUtils.mkdir_p(dir)
  out_path = File.join(dir, "index.html")

  # Strip top level markdown title to prevent double titles and sanitize internal lead records
  body_content = content.sub(/^#\s+Executive Pitch Brief:[^\n]+\n/i, "")
                        .sub(/^#\s+Job Lead Evaluation:[^\n]+\n/i, "")
                        .gsub(/^\*\*Lead Record:\*\*.*$\n?/i, "")

  File.open(out_path, "w") do |f|
    f.puts "---"
    f.puts "layout: brief"
    f.puts "localhost_only: true"
    f.puts "title: #{Generators::Core::Text.yaml_quote(page_title)}"
    f.puts "description: #{Generators::Core::Text.yaml_quote(description)}"
    f.puts "permalink: /exports/briefs/#{slug}/"
    f.puts "breadcrumb: #{Generators::Core::Text.yaml_quote("#{company} Brief")}"
    f.puts "breadcrumb_parent_name: Exports"
    f.puts "breadcrumb_parent_url: /exports/"
    f.puts "brief_company: #{Generators::Core::Text.yaml_quote(company)}"
    f.puts "brief_role: #{Generators::Core::Text.yaml_quote(role)}"
    f.puts "sitemap: false"
    f.puts "robots: noindex,nofollow"
    f.puts "body_class: ats-resume"
    f.puts "---"
    f.puts
    f.puts body_content
  end

  briefs_list << {
    slug: slug,
    company: company,
    role: role,
    headline: headline,
    page_title: page_title
  }

  generated_count += 1
end

# Generate Executive Briefs Hub Index Page
hub_title = "Executive Pitch Briefs Hub"
hub_desc = "Tailored 1-page executive pitch briefs and interview calibration scripts for target Staff and Principal roles."
hub_desc = Generators::Core::Meta.ensure_min_length(hub_desc, 70, " Part of Mike Hall's executive resume archive.")
hub_desc = Generators::Core::Meta.clamp(hub_desc, 160)

hub_index_path = File.join(output_dir, "index.html")
File.open(hub_index_path, "w") do |f|
  f.puts "---"
  f.puts "layout: base"
  f.puts "localhost_only: true"
  f.puts "title: #{Generators::Core::Text.yaml_quote(hub_title)}"
  f.puts "description: #{Generators::Core::Text.yaml_quote(hub_desc)}"
  f.puts "permalink: /exports/briefs/"
  f.puts "breadcrumb: 'Executive Briefs'"
  f.puts "breadcrumb_parent_name: 'Exports'"
  f.puts "breadcrumb_parent_url: '/exports/'"
  f.puts "sitemap: false"
  f.puts "robots: noindex,nofollow"
  f.puts "---"
  f.puts
  f.puts "<section class=\"container\" style=\"max-width: 900px; margin: 2rem auto; padding: 0 1.5rem;\">"
  f.puts "  <h1>Executive Pitch Briefs Hub</h1>"
  f.puts "  <p class=\"lead\">Tailored 1-page executive pitch briefs, interview calibration scripts, and downloadable vector PDFs for target leadership roles:</p>"
  f.puts "  <div class=\"briefs-grid\" style=\"display: grid; gap: 1.5rem; margin-top: 2rem;\">"
  briefs_list.each do |b|
    f.puts "    <article style=\"background: var(--color-bg-card, #ffffff); border: 1px solid var(--color-border, #e3dfd7); border-radius: 0.5rem; padding: 1.5rem;\">"
    f.puts "      <h2 style=\"margin-top: 0; font-size: 1.25rem;\"><a href=\"/exports/briefs/#{b[:slug]}/\">#{b[:company]}</a></h2>"
    f.puts "      <p style=\"color: #525866; margin-bottom: 1rem;\"><strong>Target Role:</strong> #{b[:role]}</p>"
    f.puts "      <div style=\"display: flex; gap: 1rem;\">"
    f.puts "        <a href=\"/exports/briefs/#{b[:slug]}/\" class=\"btn btn-sm btn-primary\" style=\"text-decoration: none; font-weight: 600;\">View Web Brief →</a>"
    f.puts "        <a href=\"/exports/briefs/pdfs/#{b[:slug]}-executive-brief-mike-hall.pdf\" class=\"btn btn-sm btn-secondary\" style=\"text-decoration: none; font-weight: 600;\">Download PDF (Vector)</a>"
    f.puts "      </div>"
    f.puts "    </article>"
  end
  f.puts "  </div>"
  f.puts "</section>"
end

puts "Generated #{generated_count} executive brief web pages and hub index in #{output_dir}"

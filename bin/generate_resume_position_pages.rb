#!/usr/bin/env ruby
require "fileutils"
require "json"
require_relative "../src/generators/core/meta"
require_relative "../src/generators/core/text"
require_relative "../src/generators/core/yaml_io"

root = File.expand_path("..", __dir__)
timeline_path = File.join(root, "_data", "resume", "timeline.yml")
positions_dir = File.join(root, "_data", "resume", "positions")
output_dir = File.join(root, "resume", "positions")

timeline = Generators::Core::YamlIo.load(timeline_path)
history = Array(timeline["history"])

positions = {}
Dir[File.join(positions_dir, "*.yml")].sort.each do |path|
  key = File.basename(path, ".yml")
  positions[key] = Generators::Core::YamlIo.load(path)
end

FileUtils.rm_rf(output_dir)
FileUtils.mkdir_p(output_dir)

generated_count = 0
history.uniq.each do |position_id|
  position = positions[position_id]
  next unless position

  title = position["title"].to_s.strip
  company_name = position.dig("company", "name").to_s.strip
  headline = [title, company_name].reject(&:empty?).join(" — ")
  page_title = Generators::Core::Meta.clamp("Resume Position — #{headline}", 70)
  description = position["description"].to_s.strip
  description = "Role details for #{headline}." if description.empty?
  description = Generators::Core::Meta.ensure_min_length(description, 70, " Part of Mike Hall's resume archive.")
  description = Generators::Core::Meta.clamp(description, 160)

  dir = File.join(output_dir, position_id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, "index.html")

  File.open(path, "w") do |f|
    f.puts "---"
    f.puts "layout: resume"
    f.puts "title: #{Generators::Core::Text.yaml_quote(page_title)}"
    f.puts "description: #{Generators::Core::Text.yaml_quote(description)}"
    f.puts "permalink: /resume/positions/#{position_id}/"
    f.puts "breadcrumb: #{Generators::Core::Text.yaml_quote(headline)}"
    f.puts "breadcrumb_parent_name: Resume"
    f.puts "breadcrumb_parent_url: /resume.html"
    f.puts "---"
    f.puts
    f.puts '<nav class="resume-actions no-print" aria-label="Position page actions">'
    f.puts '  <span class="resume-actions-label">Position View</span>'
    f.puts '  <a href="/resume.html">Executive Resume</a>'
    f.puts '  <a href="/history/">Complete Career Timeline</a>'
    f.puts "</nav>"
    f.puts
    f.puts "<article>"
    f.puts "  {% include breadcrumbs.html %}"
    f.puts "  {% include resume/profile-header.html %}"
    f.puts '  <section id="experience">'
    f.puts "    <h2>Experience</h2>"
    f.puts "    {% assign position = site.data.resume.positions[#{position_id.to_json}] %}"
    f.puts "    {% if position %}"
    f.puts "    {% include resume/position-entry.html position=position position_id=#{position_id.to_json} link_title=false %}"
    f.puts "    {% endif %}"
    f.puts "  </section>"
    f.puts "</article>"
  end

  generated_count += 1
end

puts "Generated #{generated_count} resume position pages in #{output_dir}"

#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: build_career_markmap.rb
# domain: data
# purpose: Generate an offline interactive Markmap of Mike Hall's career positions, systems, and case studies
# usage: ruby bin/build_career_markmap.rb
# ---

require "fileutils"
require "open3"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("..", __dir__)
POSITIONS_DIR = File.join(ROOT, "_data", "resume", "positions")
CASE_STUDIES_PATH = File.join(ROOT, "_data", "case_studies.yml")
OUT_HTML = File.join(ROOT, "assets", "diagrams", "career-ecosystem-markmap.html")

FileUtils.mkdir_p(File.dirname(OUT_HTML))

positions = Dir[File.join(POSITIONS_DIR, "*.yml")].map do |p|
  YAML.safe_load_file(p, permitted_classes: [Date, Time])
end.compact.sort_by { |pos| pos["start_date"].to_s }.reverse

case_studies = YAML.safe_load_file(CASE_STUDIES_PATH)["case_studies"] || []

lines = []
lines << "# Mike Hall: Staff Software Engineer & Systems Map"
lines << ""
lines << "## Production Case Studies (#{case_studies.size})"
case_studies.each do |cs|
  lines << "### #{cs['company']}: #{cs['title']}"
  Array(cs["outcomes"]).first(3).each do |outcome|
    short = outcome.to_s.gsub(/\s+/, " ").strip
    short = "#{short[0..105]}..." if short.length > 108
    lines << "- #{short}"
  end
end

lines << ""
lines << "## Career Arc (Recent & Key Roles)"
positions.first(10).each do |pos|
  company = pos.dig("company", "name") || pos["id"]
  title = pos["title"]
  start_y = pos["start_date"].to_s[0..3]
  end_y = pos["end_date"].to_s.empty? ? "Present" : pos["end_date"].to_s[0..3]
  lines << "### #{company} (#{start_y}–#{end_y})"
  lines << "- Role: #{title}"
  Array(pos["skills"]).first(5).each { |s| lines << "- #{s}" }
end

lines << ""
lines << "## Communities & Independent Systems"
lines << "### Enterprise & Regional Communities"
lines << "- Geekfest@OMF (49+ weekly sessions, Nov 2022–Feb 2024)"
lines << "- OpenTelemetry Working Group (1st CoP at OMF, 122 members, handed off Sep 2025)"
lines << "- Software Craftsmanship McHenry County (SCMC, co-founded 2009)"
lines << "- UGtastic / WHOIS Tech Community (200+ oral history interviews)"
lines << "### Independent Platforms"
lines << "- Phalanx Duel (Deterministic TypeScript engine + Go CLI)"
lines << "- Panoramic View Labs / zdots (4D System Cartography & Local Control Plane)"
lines << "- Dehum (345kV EMI 5-Stage Forensic Audio DSP)"

Dir.mktmpdir("just3ws-career-markmap") do |tmp|
  md_path = File.join(tmp, "career.md")
  File.write(md_path, lines.join("\n") + "\n")

  puts "[markmap] _data/resume + case_studies -> assets/diagrams/career-ecosystem-markmap.html"
  stdout, stderr, status = Open3.capture3(
    "npx", "--yes", "markmap-cli", "--no-open", "--offline", md_path, "-o", OUT_HTML
  )
  unless status.success?
    warn "markmap-cli failed:"
    warn stderr unless stderr.empty?
    warn stdout unless stdout.empty?
    exit status.exitstatus
  end
end

puts "Built self-contained Career Ecosystem Markmap at assets/diagrams/career-ecosystem-markmap.html."

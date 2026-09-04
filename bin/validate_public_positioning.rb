#!/usr/bin/env ruby
# frozen_string_literal: true

# Deterministic guard for the reader-facing positioning surface. This is not a
# general prose or privacy auditor. It prevents safe curation decisions from
# regressing when generated resumes, briefs, or machine-readable catalogs are
# rebuilt.

ROOT = File.expand_path("..", __dir__)
TEXT_EXTENSIONS = %w[.html .htm .md .markdown .txt .yml .yaml .json].freeze

PUBLIC_FILES = [
  "llms.txt",
  "_data/resume/archetypes.yml",
  "_data/case_studies.yml",
  "_data/engagements.yml",
  "career_datalake.json",
  "exports/career_datalake.json",
  "resumes",
  "exports/resumes",
  "_site/index.html",
  "_site/llms.txt",
  "_site/exports/resumes"
].freeze

FORBIDDEN_PUBLIC_PHRASES = {
  "Speedfunds" => "use a descriptive instant-disbursement phrase",
  "Bonsai Buckaroos" => "describe the prototype or hackathon context",
  "ACQ Enablement" => "spell out Acquisition Lane enablement",
  "ACQ Technical Architecture Initiatives" => "use a reader-facing description such as Acquisition architecture initiative",
  "Senior Ruby on Rails Contractor" => "use the broad Senior / Lead Software Engineer title",
  "High-Velocity IC" => "describe delivery context without title inflation"
}.freeze

FORBIDDEN_PUBLIC_PATTERNS = {
  /\bACQ\b/ => "spell out Acquisition; do not publish the internal acronym without reader-facing expansion"
}.freeze

REQUIRED_PUBLIC_PHRASES = {
  "_data/resume/archetypes.yml" => ["Senior / Lead Software Engineer, Ruby on Rails"],
  "_posts/2026-08-30-conways-law-in-the-trenches-growth-vs-enablement.md" => [
    "Team Topologies",
    "cognitive load",
    "capability-building"
  ]
}.freeze

def paths_for(entry)
  path = File.join(ROOT, entry)
  return [path] if File.file?(path)
  return [] unless File.directory?(path)

  Dir.glob(File.join(path, "**", "*"), File::FNM_DOTMATCH).select do |candidate|
    File.file?(candidate) &&
      !File.basename(candidate).start_with?(".") &&
      TEXT_EXTENSIONS.include?(File.extname(candidate).downcase)
  end
end

files = PUBLIC_FILES.flat_map { |entry| paths_for(entry) }.uniq
errors = []

files.each do |path|
  relative = path.delete_prefix("#{ROOT}/")
  content = File.read(path, encoding: "UTF-8")

  FORBIDDEN_PUBLIC_PHRASES.each do |phrase, remedy|
    next unless content.match?(Regexp.new(Regexp.escape(phrase), Regexp::IGNORECASE))

    errors << "#{relative}: contains #{phrase.inspect}; #{remedy}"
  end

  FORBIDDEN_PUBLIC_PATTERNS.each do |pattern, remedy|
    errors << "#{relative}: contains an unexplained internal acronym matching #{pattern.inspect}; #{remedy}" if content.match?(pattern)
  end
end

REQUIRED_PUBLIC_PHRASES.each do |relative, phrases|
  path = File.join(ROOT, relative)
  unless File.file?(path)
    errors << "#{relative}: required public source is missing"
    next
  end

  content = File.read(path, encoding: "UTF-8")
  phrases.each do |phrase|
    errors << "#{relative}: missing required reader-facing phrase #{phrase.inspect}" unless content.include?(phrase)
  end
end

if errors.empty?
  puts "Public positioning validation passed."
  exit 0
end

warn "Public positioning validation failed:"
errors.each { |error| warn "  - #{error}" }
exit 1

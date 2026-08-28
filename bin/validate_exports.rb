#!/usr/bin/env ruby
require 'json'
require 'yaml'

SITE_DIR = "_site" # Default Jekyll output
PROFILE_PATH = File.expand_path('../_data/resume/profile.yml', __dir__)
PROFILE_TITLE = YAML.safe_load_file(PROFILE_PATH).fetch('title')

def validate_json_export
  path = File.join(SITE_DIR, "resume.json")
  unless File.exist?(path)
    puts "Skipping JSON validation (not found at #{path})"
    return true
  end

  begin
    data = JSON.parse(File.read(path))
    # Check for critical keys
    errors = []
    errors << "Missing 'profile' in resume.json" unless data['profile']
    errors << "Missing 'positions' in resume.json" unless data['positions']
    
    # Check the current position and public positioning.
    if data['positions'] && data['positions']['emr-bear']
      pos = data['positions']['emr-bear']
      errors << "Current position missing 'title' in JSON" unless pos['title']
      errors << "Current position missing 'company' in JSON" unless pos['company']
    else
      errors << "Missing current position in resume.json"
    end
    errors << "Profile title does not match resume data" unless data.dig('profile', 'title') == PROFILE_TITLE

    if errors.empty?
      puts "JSON export validation passed."
      return true
    else
      warn "JSON export validation failed:"
      errors.each { |e| warn "  - #{e}" }
      return false
    end
  rescue JSON::ParserError => e
    warn "JSON export is invalid: #{e.message}"
    return false
  end
end

def validate_txt_export
  path = File.join(SITE_DIR, "resume.txt")
  unless File.exist?(path)
    puts "Skipping TXT validation (not found at #{path})"
    return true
  end

  content = File.read(path)
  errors = []
  
  errors << "resume.txt missing Name" unless content.include?("MIKE HALL")
  errors << "resume.txt missing EXPERIENCE section" unless content.include?("EXPERIENCE")
  errors << "resume.txt missing current employer" unless content.include?("EMR-Bear")
  errors << "resume.txt missing profile title" unless content.include?(PROFILE_TITLE)
  has_context_action_impact = content.include?("Context:") && content.include?("Action:") && content.include?("Impact:")
  has_outcomes = content.include?("Key Outcomes:")
  errors << "resume.txt missing role detail sections" unless has_context_action_impact || has_outcomes

  if errors.empty?
    puts "TXT export validation passed."
    return true
  else
    warn "TXT export validation failed:"
    errors.each { |e| warn "  - #{e}" }
    return false
  end
end

def validate_markdown_exports
  paths = [
    File.join(SITE_DIR, 'resume.md'),
    File.join(SITE_DIR, 'exports', 'resume.md')
  ]
  errors = []

  paths.each do |path|
    unless File.exist?(path)
      errors << "Missing Markdown export: #{path}"
      next
    end

    content = File.read(path)
    errors << "#{path} missing profile title" unless content.include?(PROFILE_TITLE)
    errors << "#{path} missing skills section" unless content.include?('## Skills') || content.include?('## Core Skills')
    errors << "#{path} contains serialized Ruby hash output" if content.include?('=>') || content.include?('["categories"')
  end

  if errors.empty?
    puts "Markdown export validation passed."
    true
  else
    warn "Markdown export validation failed:"
    errors.each { |error| warn "  - #{error}" }
    false
  end
end

def validate_pdf_export
  paths = [
    File.join(SITE_DIR, 'exports', 'resume.pdf')
  ]
  errors = []

  paths.each do |path|
    unless File.exist?(path)
      errors << "Missing PDF export: #{path}"
      next
    end

    if File.size(path) < 10_000
      errors << "#{path} is smaller than expected (< 10KB)"
    end
  end

  if errors.empty?
    puts "PDF export validation passed."
    true
  else
    warn "PDF export validation failed:"
    errors.each { |error| warn "  - #{error}" }
    false
  end
end

def validate_career_datalake_export
  paths = [
    File.join(SITE_DIR, 'career_datalake.json'),
    File.join(SITE_DIR, 'exports', 'career_datalake.json')
  ]
  errors = []

  paths.each do |path|
    unless File.exist?(path)
      errors << "Missing datalake JSON export: #{path}"
      next
    end

    begin
      data = JSON.parse(File.read(path))
      errors << "#{path} missing 'meta'" unless data['meta']
      errors << "#{path} missing 'positions'" unless data['positions'] && data['positions'].size >= 25
      errors << "#{path} missing 'technology_provenance'" unless data['technology_provenance'] && data['technology_provenance'].size >= 50
      errors << "#{path} missing 'publications_and_writings'" unless data['publications_and_writings'] && data['publications_and_writings'].size >= 100
      errors << "#{path} missing 'oral_history_corpus'" unless data['oral_history_corpus'] && data['oral_history_corpus'].size >= 150
    rescue JSON::ParserError => e
      errors << "#{path} invalid JSON: #{e.message}"
    end
  end

  jsonl_path = File.join(SITE_DIR, 'career_datalake.jsonl')
  if File.exist?(jsonl_path)
    line_count = File.readlines(jsonl_path).size
    errors << "career_datalake.jsonl has fewer than 200 lines (#{line_count})" if line_count < 200
  else
    errors << "Missing datalake JSONL export: #{jsonl_path}"
  end

  if errors.empty?
    puts "Career Datalake export validation passed."
    true
  else
    warn "Career Datalake export validation failed:"
    errors.each { |error| warn "  - #{error}" }
    false
  end
end

success = true
success &= validate_json_export
success &= validate_txt_export
success &= validate_markdown_exports
success &= validate_pdf_export
success &= validate_career_datalake_export

exit(success ? 0 : 1)

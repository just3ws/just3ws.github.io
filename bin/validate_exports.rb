#!/usr/bin/env ruby
require 'json'

SITE_DIR = "_site" # Default Jekyll output

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
    errors << "Profile title is not current" unless data.dig('profile', 'title') == 'Hands-on Director of Engineering'

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
  errors << "resume.txt missing current leadership title" unless content.include?("Hands-on Director of Engineering")
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

success = true
success &= validate_json_export
success &= validate_txt_export

exit(success ? 0 : 1)

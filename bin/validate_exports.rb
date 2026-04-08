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
    
    # Check a sample position
    if data['positions'] && data['positions']['onemain']
      pos = data['positions']['onemain']
      errors << "OneMain position missing 'title' in JSON" unless pos['title']
      errors << "OneMain position missing 'company' in JSON" unless pos['company']
    end

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
  errors << "resume.txt missing OneMain Financial" unless content.include?("OneMain Financial")
  errors << "resume.txt missing context-action-impact tags" unless content.include?("Context:") && content.include?("Action:") && content.include?("Impact:")

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

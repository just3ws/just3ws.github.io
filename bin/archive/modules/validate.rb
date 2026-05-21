#!/usr/bin/env ruby
require 'yaml'

# --- VALIDATE MODULE ---
# Checks for schema integrity, speaker mapping, and common errors.

id = ARGV[0]
path = "_data/transcripts/#{id}.yml"

unless File.exist?(path)
  puts "ERROR: File not found #{path}"
  exit 1
end

begin
  data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)
  
  errors = []
  
  # 1. Check Turns
  if !data["turns"] || data["turns"].empty?
    errors << "No turns found"
  end
  
  # 2. Check Speaker Map
  if data["turns"]
    used_speakers = data["turns"].map { |t| t["speaker"] }.uniq
    map_speakers = data["speaker_map"]&.keys || []
    
    missing_from_map = used_speakers - map_speakers
    if missing_from_map.any?
      errors << "Speakers used in turns but missing from map: #{missing_from_map.join(', ')}"
    end
  end
  
  # 3. Check for Hallucinations (e.g. repeated short strings)
  if data["turns"]
    text_lengths = data["turns"].map { |t| t["text"].to_s.length }
    if text_lengths.any? { |l| l < 5 }
      errors << "Detected very short turns (potential hallucinations)"
    end
  end

  if errors.any?
    puts "ERROR: #{errors.join('; ')}"
    exit 1
  else
    puts "SUCCESS"
  end
  
rescue => e
  puts "ERROR: Validation failed: #{e.message}"
  exit 1
end

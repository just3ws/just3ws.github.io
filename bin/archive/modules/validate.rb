#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'time'

# --- VALIDATE MODULE ---
# Checks for schema integrity, speaker mapping, and "Bork" detection.

id = ARGV[0]
force = ARGV.include?("--force")
path = "_data/transcripts/#{id}.yml"

unless File.exist?(path)
  puts "ERROR: File not found #{path}"
  exit 1
end

def clean_word_count(text)
  return 0 unless text
  # Strip VTT/SRT timestamps and tags
  clean = text.gsub(/\d{2}:\d{2}:\d{2}.\d{3} --> \d{2}:\d{2}:\d{2}.\d{3}/, "")
  clean = clean.gsub(/<[^>]*>/, "")
  clean = clean.gsub(/^\d+$/, "") # Strip line numbers from SRT
  clean.split(/\s+/).reject(&:empty?).size
end

begin
  data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)
  
  if data["validated_at"] && !data["validation_error"] && !force
    puts "SKIPPED"
    exit 0
  end

  errors = []
  
  # 1. Structural Checks
  if !data["turns"] || data["turns"].empty?
    errors << "No turns found"
  end
  
  if data["turns"]
    used_speakers = data["turns"].map { |t| t["speaker"] }.uniq
    map_speakers = data["speaker_map"]&.keys || []
    
    missing_from_map = used_speakers - map_speakers
    if missing_from_map.any?
      errors << "Speakers used in turns but missing from map: #{missing_from_map.join(', ')}"
    end
  end

  # 2. Word Count Drift (Bork Detection)
  source_dir = "tmp/transcript-id-staging"
  source_file = Dir.glob("#{source_dir}/#{id}.txt").first ||
                Dir.glob("#{source_dir}/#{id}*").reject { |f| f.end_with?(".json") }.first
  
  if source_file && data["turns"]
    raw_text = File.read(source_file)
    raw_words = clean_word_count(raw_text)
    yaml_words = clean_word_count(data["turns"].map { |t| t["text"] }.join(" "))
    
    # Tolerance: 15%
    drift = (raw_words - yaml_words).abs.to_f / raw_words
    if drift > 0.15 && raw_words > 100
       errors << "Significant Word Count Drift: Raw=#{raw_words}, YAML=#{yaml_words} (#{(drift*100).round}% difference)"
    end
  end

  # 3. Diarization Balance
  if data["turns"]
    m1_words = data["turns"].select{|t| t["speaker"] == "M1"}.map{|t| clean_word_count(t["text"])}.sum
    total_words = data["turns"].map{|t| clean_word_count(t["text"])}.sum
    
    m1_ratio = m1_words.to_f / total_words
    if m1_ratio > 0.6 && total_words > 200
       errors << "Interviewer Overload: M1 has #{(m1_ratio*100).round}% of words. Check for collapsed guest turns."
    end
  end

  # 4. Continuity & Turn Length
  if data["turns"]
    data["turns"].each_with_index do |turn, i|
       if turn["text"].to_s.length > 5000
          errors << "Turn #{i} is too long (#{turn['text'].length} chars). Needs forensic splitting."
       end
    end
  end

  if errors.any?
    data["validation_error"] = errors.join("; ")
    data["validated_at"] = Time.now.iso8601
    File.write(path, data.to_yaml)
    puts "ERROR: #{data['validation_error']}"
    exit 1
  else
    data.delete("validation_error")
    data["validated_at"] = Time.now.iso8601
    File.write(path, data.to_yaml)
    puts "SUCCESS"
  end
  
rescue => e
  puts "ERROR: Validation failed: #{e.message}"
  exit 1
end

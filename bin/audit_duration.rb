#!/usr/bin/env ruby
require 'yaml'

assets = YAML.load_file("_data/video_assets.yml")["items"]

discrepancies = []
total_analyzed = 0
missing_duration = []

Dir.glob("_data/transcripts/*.yml").each do |path|
  id = File.basename(path, ".yml")
  data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)
  
  # Calculate word count
  words = 0
  if data["turns"]
    words = data["turns"].map { |t| t["text"].to_s }.join(" ").split.size
  elsif data["content"]
    words = data["content"].to_s.split.size
  end
  
  # Find asset
  asset = assets.find { |a| a["transcript_id"] == id || a["id"] == id }
  next unless asset
  
  duration_sec = asset["duration_seconds"].to_i
  
  # If duration_sec is 0, let's check if there's a duration_minutes
  if duration_sec == 0 && asset["duration_minutes"]
    duration_sec = asset["duration_minutes"].to_i * 60
  end
  
  if duration_sec > 0
    duration_min = duration_sec / 60.0
    wpm = (words / duration_min).round
    
    total_analyzed += 1
    
    # Average speaking rate is ~120-160 wpm. 
    # If it's below 60 or above 250, something might be off.
    if wpm < 80 || wpm > 200
      discrepancies << { id: id, wpm: wpm, words: words, minutes: duration_min.round(1) }
    end
  else
    missing_duration << id
  end
end

puts "=== DURATION VS WORDCOUNT AUDIT ==="
puts "Total Analyzed: #{total_analyzed}"
puts "Missing Duration Data: #{missing_duration.size}"
puts "Discrepancies (Suspicious WPM <80 or >200): #{discrepancies.size}"

if discrepancies.any?
  puts "\n--- SUSPICIOUS TRANSCRIPTS ---"
  discrepancies.sort_by { |d| d[:wpm] }.each do |d|
    puts "- #{d[:id]}: #{d[:wpm]} WPM (#{d[:words]} words / #{d[:minutes]} mins)"
  end
end

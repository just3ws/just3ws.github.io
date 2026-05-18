#!/usr/bin/env ruby
require 'yaml'

TRANSCRIPTS_DIR = "_data/transcripts"
files = Dir.glob("#{TRANSCRIPTS_DIR}/*.yml")

results = {
  total: files.size,
  unstructured: [],
  too_short: [],
  no_ending: [],
  perfect: []
}

ENDING_MARKERS = [
  /Thank you (?:very much)?/i,
  /UGtastic/i,
  /Take care/i,
  /Thanks for having me/i,
  /Find out for yourself/i
]

files.each do |path|
  begin
    data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)
    
    # 1. Style Check
    unless data["turns"] && !data["turns"].empty?
      results[:unstructured] << path
      next
    end

    # 2. Length Check (Word Count)
    full_text = data["turns"].map { |t| t["text"] }.join(" ")
    word_count = full_text.split.size
    if word_count < 200 # Very conservative floor
      results[:too_short] << { path: path, count: word_count }
    end

    # 3. Ending Check
    last_turn = data["turns"].last["text"]
    has_ending = ENDING_MARKERS.any? { |m| last_turn =~ m }
    unless has_ending
      results[:no_ending] << path
    end

    if data["turns"] && word_count >= 200 && has_ending
      results[:perfect] << path
    end

  rescue => e
    puts "Error in #{path}: #{e.message}"
  end
end

puts "--- FINAL QUALITY AUDIT ---"
puts "Total Transcripts: #{results[:total]}"
puts "Structured: #{results[:total] - results[:unstructured].size}"
puts "Unstructured: #{results[:unstructured].size}"
puts "Too Short (<200 words): #{results[:too_short].size}"
puts "No Clear Ending: #{results[:no_ending].size}"

if results[:unstructured].any?
  puts "\nUnstructured Files:"
  results[:unstructured].each { |f| puts " - #{f}" }
end

if results[:too_short].any?
  puts "\nShort Files:"
  results[:too_short].each { |f| puts " - #{f[:path]} (#{f[:count]} words)" }
end

if results[:no_ending].any?
  puts "\nFiles with Weak Endings (Last Turn):"
  results[:no_ending].each do |path|
    data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue {}
    last_text = data["turns"]&.last&.dig("text")&.strip&.gsub("\n", " ") || "EMPTY"
    puts " - #{File.basename(path)}: \"#{last_text[0..60]}...\""
  end
end

puts "\nAudit Complete."

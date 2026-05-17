#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

count = 0
Dir.glob("_data/transcripts/*.yml").each do |file|
  begin
    data = YAML.safe_load(File.read(file), permitted_classes: [Date, Time], aliases: true) || {}
    next unless data && data["content"]

    original = data["content"].dup
    
    # 1. Remove leading/trailing spaces from lines
    lines = data["content"].split("\n")
    cleaned_lines = lines.map(&:strip)
    
    # 2. Join lines that don't seem to be intentional paragraph breaks
    # For simplicity, we'll join everything with a space and then collapse multiple spaces.
    # This fixes the erratic line breaks from Whisper.
    full_text = cleaned_lines.join(" ").gsub(/ {2,}/, " ").strip
    
    # 3. Add double breaks before potential speaker changes (Mike's typical intro)
    full_text.gsub!(/(Hi, it's Mike with UGtastic)/, "\n\n\\1")
    full_text.gsub!(/(Thank you for sitting down with me)/, "\n\n\\1")
    full_text.gsub!(/(Thanks for having me)/, "\n\n\\1")
    
    data["content"] = full_text.strip
    
    if data["content"] != original
      File.write(file, data.to_yaml)
      count += 1
    end
  rescue => e
    puts "Error: #{e.message} in #{file}"
  end
end
puts "Cleaned formatting for #{count} transcripts."

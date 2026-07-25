#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/rename_transcript_id.rb — Safely Rename a Transcript / Interview ID across _data/ files

require 'yaml'
require 'fileutils'

if ARGV.size < 2
  puts "Usage: ruby bin/rename_transcript_id.rb <old_id> <new_id>"
  exit 1
end

old_id = ARGV[0]
new_id = ARGV[1]

puts "🔄 Renaming ID: #{old_id}  =>  #{new_id}"

# 1. Rename transcript YAML file if exists
old_file = "_data/transcripts/#{old_id}.yml"
new_file = "_data/transcripts/#{new_id}.yml"

if File.exist?(old_file)
  FileUtils.mv(old_file, new_file)
  puts "   Renamed: #{old_file} -> #{new_file}"
else
  puts "   ⚠️ Transcript file #{old_file} not found, skipping file move."
end

# 2. Files to perform text replacement on
DATA_FILES = [
  "_data/interviews.yml",
  "_data/video_assets.yml",
  "_data/interview_topics.yml",
  "_data/interviewees_index.yml",
  "_data/video_metadata_completeness.yml"
]

DATA_FILES.each do |file_path|
  next unless File.exist?(file_path)
  content = File.read(file_path)
  if content.include?(old_id)
    updated = content.gsub(old_id, new_id)
    File.write(file_path, updated)
    puts "   Updated references in: #{file_path}"
  end
end

puts "\n🧪 Verifying data integrity post-rename..."
system("bundle exec rake validate:data_uniqueness validate:data_integrity")

if $?.success?
  puts "\n✅ ID rename complete & verified!"
else
  puts "\n❌ Data validation failed post-rename!"
  exit 1
end

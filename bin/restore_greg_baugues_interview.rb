#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/restore_greg_baugues_interview.rb
#
# Re-uploads the accidentally deleted RailsConf 2014 interview with Greg Baugues
# from the local master MP4 and registers the new YouTube video ID in the site data.

require 'yaml'
require 'json'
require_relative 'upload_youtube_video'
require_relative 'lib/youtube_client'

$stdout.sync = true

VIDEO_PATH = ENV.fetch("GREG_BAUGUES_VIDEO_PATH", "")

dry_run = ARGV.include?("--dry-run")

puts "🎬 [Restore Greg Baugues RailsConf 2014 Interview]"
puts "================================================================================"

unless File.exist?(VIDEO_PATH)
  puts "❌ Error: Master video file not found at: #{VIDEO_PATH}"
  exit 1
end

size_mb = (File.size(VIDEO_PATH) / (1024.0 * 1024)).round(1)
puts "✓ Located master MP4 on disk: #{size_mb} MB"

payload = {
  "snippet" => {
    "title" => "Interview with Greg Baugues on Mental Health in Tech at RailsConf 2014 | UGtastic Archive",
    "description" => "Hi, it's Mike with UGtastic. In this conversation recorded on-site at RailsConf 2014 in Chicago, I sit down with Greg Baugues to discuss mental health in the software industry, destigmatizing ADHD and depression, and building supportive engineering communities.\n\nSpeaker: Greg Baugues (Table XI / Twilio)\nInterviewer: Mike Hall (UGtastic)\nConference: RailsConf 2014\nLocation: Chicago, IL\nFull Transcript: https://www.just3ws.com/interviews/interview-with-greg-baugues-on-mental-health-in-tech-at-railsconf-2014/",
    "tags" => ["Greg Baugues", "RailsConf 2014", "Mental Health in Tech", "ADHD", "Depression", "Ruby", "Rails", "UGtastic", "Software Craftsmanship"],
    "categoryId" => "28", # Science & Technology
    "defaultLanguage" => "en"
  },
  "status" => {
    "privacyStatus" => "public",
    "selfDeclaredMadeForKids" => false,
    "embeddable" => true
  }
}

if dry_run
  puts "🔍 [Dry Run] Title  : #{payload['snippet']['title']}"
  puts "🔍 [Dry Run] Tags   : #{payload['snippet']['tags'].join(', ')}"
  puts "🔍 [Dry Run] Privacy: #{payload['status']['privacyStatus']}"
  puts "🔍 [Dry Run] Would upload: #{VIDEO_PATH}"
  exit 0
end

uploader = VideoUploader.new
result = uploader.upload(VIDEO_PATH, payload)

new_yt_id = result["id"]
puts "\n🎉 Successfully uploaded to YouTube! New Video ID: #{new_yt_id}"
puts "   Live YouTube URL: https://www.youtube.com/watch?v=#{new_yt_id}"

# Also add to RailsConf 2014 Playlist on YouTube
client = YouTubeClient.new
playlists = client.get_channel_playlists
rails_pl = playlists.find { |p| p.dig("snippet", "title") =~ /RailsConf 2014/i }

if rails_pl
  pl_id = rails_pl["id"]
  puts "➕ Adding to YouTube Playlist: '#{rails_pl.dig('snippet', 'title')}' [#{pl_id}]..."
  client.add_playlist_item(pl_id, new_yt_id)
  puts "✅ Added #{new_yt_id} to RailsConf 2014 playlist!"
end

puts "\n================================================================================"
puts "🏁 Upload and playlist registration complete! (New YT ID: #{new_yt_id})"

#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/sync_scmc_playlist.rb
#
# Creates and populates the Software Craftsmanship McHenry County (SCMC)
# YouTube playlist with all 12 canonical SCMC talks.

require 'yaml'
require 'json'
require_relative 'lib/youtube_client'

$stdout.sync = true

PLAYLIST_TITLE = "Software Craftsmanship McHenry County (SCMC) Archive"
PLAYLIST_DESC = "Historical technical presentations, workshops, and practitioner talks from Software Craftsmanship McHenry County (SCMC / McHenry Cloud Developers Group), founded in late 2009 by Mike Hall, Ryan Gerry, and Jim Suchy."

dry_run = ARGV.include?("--dry-run")

client = YouTubeClient.new
puts "🎬 [SCMC YouTube Playlist Manager]"
puts "================================================================================"

playlists = client.get_channel_playlists
existing_pl = playlists.find { |p| p.dig("snippet", "title") == PLAYLIST_TITLE }

playlist_id = nil

if existing_pl
  playlist_id = existing_pl["id"]
  puts "✓ Found existing SCMC playlist: [#{playlist_id}] #{PLAYLIST_TITLE}"
else
  puts "Creating new public SCMC playlist: '#{PLAYLIST_TITLE}'..."
  if dry_run
    puts "🔍 [Dry Run] Would create playlist: #{PLAYLIST_TITLE}"
    playlist_id = "DRY_RUN_PLAYLIST_ID"
  else
    new_pl = client.create_playlist(PLAYLIST_TITLE, PLAYLIST_DESC, "public")
    playlist_id = new_pl["id"]
    puts "✅ Created playlist: [#{playlist_id}] #{PLAYLIST_TITLE}"
  end
end

# Load SCMC videos
scmc_data = YAML.load_file("_data/scmc_videos.yml")
video_assets = YAML.load_file("_data/video_assets.yml")
vimeo_manifest = YAML.load_file("_data/vimeo_migration_manifest.yml")

items = scmc_data["items"] || []
puts "\nFound #{items.size} canonical SCMC video entries in site data."

existing_video_ids = if playlist_id == "DRY_RUN_PLAYLIST_ID"
                       []
                     else
                       client.get_playlist_video_ids(playlist_id)
                     end

puts "Playlist currently contains #{existing_video_ids.size} video(s)."

added_count = 0

items.each_with_index do |item, idx|
  asset_id = item["video_asset_id"]
  asset = (video_assets["items"] || []).find { |a| a["id"] == asset_id }
  manifest_entry = (vimeo_manifest["items"] || []).find { |m| m["asset_id"] == asset_id }

  # Find YouTube ID
  yt_platform = (asset["platforms"] || []).find { |p| p["platform"] == "youtube" } if asset
  yt_id = yt_platform ? yt_platform["asset_id"] : manifest_entry&.dig("youtube_id")

  title = item["title"]
  speaker = (item["speakers"] || []).join(", ")

  if yt_id.nil? || yt_id.empty?
    puts "[#{idx + 1}/#{items.size}] ⏳ #{title} (#{speaker}) - YouTube upload pending/in-progress."
    next
  end

  if existing_video_ids.include?(yt_id)
    puts "[#{idx + 1}/#{items.size}] ✓ #{title} (#{speaker}) - Already in playlist (YT: #{yt_id})"
  else
    puts "[#{idx + 1}/#{items.size}] ➕ Adding: #{title} (#{speaker}) (YT: #{yt_id})..."
    if dry_run
      puts "  🔍 [Dry Run] Would add #{yt_id} to playlist #{playlist_id}"
    else
      client.add_playlist_item(playlist_id, yt_id)
      puts "  ✅ Added #{yt_id} to playlist!"
      added_count += 1
    end
  end
end

puts "\n================================================================================"
puts "🏁 SCMC Playlist Sync Complete! Added #{added_count} new video(s) to playlist."

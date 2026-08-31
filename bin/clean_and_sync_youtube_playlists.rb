#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/clean_and_sync_youtube_playlists.rb — YouTube Playlist Deduplication & Organization Tool
#
# Audits, deduplicates, and organizes playlists on the live YouTube channel via YouTube Data API v3.
# Supports:
#   --audit                     Audit all playlists for internal duplicate videos and noise
#   --dedupe                    Remove duplicate playlist items across all playlists
#   --sync-community-playlist   Create and populate the dedicated Non-Conference Community Interviews playlist
#   --all                       Run deduplication and sync community playlist
#   --apply                     Execute mutations live (default is dry-run mode)

require 'optparse'
require 'yaml'
require 'json'
require_relative 'lib/youtube_client'

options = {
  mode: :audit,
  apply: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/clean_and_sync_youtube_playlists.rb [options]"

  opts.on("--audit", "Audit all channel playlists for duplicates and structure (default)") do
    options[:mode] = :audit
  end

  opts.on("--dedupe", "Deduplicate all playlists on the YouTube channel") do
    options[:mode] = :dedupe
  end

  opts.on("--sync-community-playlist", "Create/sync dedicated Non-Conference Community Interviews playlist") do
    options[:mode] = :sync_community
  end

  opts.on("--all", "Run deduplication and sync community playlist") do
    options[:mode] = :all
  end

  opts.on("--apply", "Apply changes live via YouTube Data API (default is dry-run)") do
    options[:apply] = true
  end

  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit 0
  end
end.parse!

client = YouTubeClient.new
unless client.authenticated?
  warn "❌ Error: Missing YouTube API credentials. Check .env or .credentials/youtube_oauth.json"
  exit 1
end

puts "=" * 80
puts "🎬 YOUTUBE PLAYLIST AUDIT & CLEANUP TOOL"
puts "   Mode: #{options[:mode].to_s.upcase} | Execution: #{options[:apply] ? '⚡ LIVE APPLY' : '🔍 DRY RUN'}"
puts "=" * 80

def fetch_all_playlist_items(client, playlist_id)
  items = []
  page_token = nil

  loop do
    url = "#{YouTubeClient::API_BASE}/playlistItems?part=snippet,contentDetails&playlistId=#{playlist_id}&maxResults=50"
    url += "&pageToken=#{page_token}" if page_token
    uri = URI(url)
    res = client.send(:make_request, uri)
    data = JSON.parse(res.body) rescue {}
    items.concat(data["items"] || [])
    page_token = data["nextPageToken"]
    break unless page_token
  end

  items
end

playlists = client.get_channel_playlists
puts "Found #{playlists.size} playlists on channel.\n\n"

# ── 1. Audit Playlists ────────────────────────────────────────────────────────
playlist_audits = []

playlists.each do |pl|
  pl_id = pl["id"]
  title = pl.dig("snippet", "title")
  privacy = pl.dig("status", "privacyStatus") || "public"
  
  items = fetch_all_playlist_items(client, pl_id)
  
  by_vid = Hash.new { |h, k| h[k] = [] }
  items.each do |it|
    v_id = it.dig("contentDetails", "videoId") || it.dig("snippet", "resourceId", "videoId")
    by_vid[v_id] << it if v_id
  end
  
  duplicates = by_vid.select { |k, v| v.size > 1 }
  dup_item_count = duplicates.values.map { |v| v.size - 1 }.sum
  
  audit_entry = {
    id: pl_id,
    title: title,
    privacy: privacy,
    total_items: items.size,
    unique_videos: by_vid.size,
    dup_count: dup_item_count,
    duplicate_groups: duplicates,
    items_by_video: by_vid
  }
  playlist_audits << audit_entry

  status_icon = dup_item_count > 0 ? "⚠️" : "✓"
  puts "#{status_icon} [#{pl_id}] \"#{title}\" (#{privacy})"
  puts "   Total items: #{items.size} | Unique videos: #{by_vid.size} | Duplicates: #{dup_item_count}"
  if dup_item_count > 0
    duplicates.each do |vid, dups|
      sample_title = dups.first.dig("snippet", "title")
      puts "   - Duplicate Video #{vid} (#{dups.size}x): #{sample_title}"
    end
  end
  puts
end

# ── 2. Deduplicate Playlists ──────────────────────────────────────────────────
if options[:mode] == :dedupe || options[:mode] == :all
  puts "\n" + "=" * 80
  puts "🧹 DEDUPLICATING PLAYLISTS"
  puts "=" * 80

  total_deleted = 0
  playlist_audits.each do |audit|
    next if audit[:dup_count] == 0

    puts "\nProcessing \"#{audit[:title]}\" (#{audit[:id]}): #{audit[:dup_count]} redundant items to remove..."
    
    audit[:duplicate_groups].each do |vid, dup_list|
      # Keep the first item, delete subsequent duplicates
      to_keep = dup_list.first
      to_delete = dup_list[1..-1]
      
      sample_title = to_keep.dig("snippet", "title")
      puts "  • Video [#{vid}]: #{sample_title}"
      puts "    Keeping item: #{to_keep["id"]} (pos: #{to_keep.dig("snippet", "position")})"
      
      to_delete.each do |del_item|
        del_item_id = del_item["id"]
        puts "    Removing item: #{del_item_id} (pos: #{del_item.dig("snippet", "position")})"
        
        if options[:apply]
          begin
            client.delete_playlist_item(del_item_id)
            total_deleted += 1
            print "      ✓ Deleted live\n"
            sleep 0.1 # quota & rate safety
          rescue => e
            warn "      ❌ Failed to delete item #{del_item_id}: #{e.message}"
          end
        else
          puts "      [DRY RUN] Would delete playlist item #{del_item_id}"
          total_deleted += 1
        end
      end
    end
  end

  puts "\n🎉 Deduplication complete: #{total_deleted} duplicate entries #{options[:apply] ? 'deleted live' : 'identified for deletion'}."
end

# ── 3. Create / Sync Non-Conference Community Interviews Playlist ─────────────
if options[:mode] == :sync_community || options[:mode] == :all
  puts "\n" + "=" * 80
  puts "🌟 NON-CONFERENCE COMMUNITY INTERVIEWS PLAYLIST SYNC"
  puts "=" * 80

  community_playlist_title = "Developer Community, User Groups & Meetup Interviews"
  community_playlist_desc = "One-on-one interviews with developer community organizers, user group leaders, and open-source practitioners from the UGtastic Archive (Chicago Python, McHenry County Meetups, Tribune Tech, 8th Light, and independent community sessions)."

  # Find if community playlist already exists
  existing_community_pl = playlists.find do |p|
    t = p.dig("snippet", "title").to_s
    t.include?("Community, User Groups") || t.include?("Non-Conference") || t == community_playlist_title
  end

  community_pl_id = nil
  if existing_community_pl
    community_pl_id = existing_community_pl["id"]
    puts "Found existing Community Playlist: \"#{existing_community_pl.dig("snippet", "title")}\" (ID: #{community_pl_id})"
  else
    puts "Creating new public playlist: \"#{community_playlist_title}\"..."
    if options[:apply]
      res = client.create_playlist(community_playlist_title, community_playlist_desc, "public")
      community_pl_id = res["id"]
      puts "✓ Created live playlist with ID: #{community_pl_id}"
    else
      puts "[DRY RUN] Would create playlist \"#{community_playlist_title}\""
      community_pl_id = "DRY_RUN_COMMUNITY_PLAYLIST_ID"
    end
  end

  # Identify non-conference community video IDs from video_assets.yml
  video_assets = YAML.load_file(File.expand_path("../_data/video_assets.yml", __dir__)) rescue {}
  items = video_assets["items"] || []
  conference_keywords = ["goto", "railsconf", "windycityrails", "scna", "chicagowebconf", "webvisions", "software craftsmanship north america", "chicago code camp", "kubecon"]

  community_videos = []
  items.each do |it|
    yt_id = nil
    (it["platforms"] || []).each do |p|
      if p["platform"] == "youtube"
        yt_id = p["video_id"] || (p["url"] =~ /v=([a-zA-Z0-9_-]{11})/ && $1)
      end
    end
    next if yt_id.nil? || yt_id.empty?

    title = it["title"].to_s.downcase.strip
    desc = it["description"].to_s.downcase.strip
    conf_slug = it["conference_slug"].to_s.downcase.strip
    event = it["event"].to_s.downcase.strip
    tags = (it["tags"] || []).map(&:downcase)

    is_conf = conference_keywords.any? { |kw| title.include?(kw) || desc.include?(kw) || conf_slug.include?(kw) || event.include?(kw) || tags.any? { |t| t.include?(kw) } }
    
    unless is_conf
      community_videos << it.merge("youtube_id" => yt_id)
    end
  end

  puts "Found #{community_videos.size} non-conference community video assets in archive data."

  # Fetch current videos in community playlist to prevent duplicate additions
  current_vids = []
  if community_pl_id && community_pl_id != "DRY_RUN_COMMUNITY_PLAYLIST_ID"
    current_vids = client.get_playlist_video_ids(community_pl_id)
  end

  added_count = 0
  community_videos.each do |v|
    yt_id = v["youtube_id"]
    if current_vids.include?(yt_id)
      puts "  • [#{yt_id}] Already in playlist: #{v["title"]}"
      next
    end

    puts "  + [#{yt_id}] Adding to Community Playlist: #{v["title"]}"
    if options[:apply] && community_pl_id && community_pl_id != "DRY_RUN_COMMUNITY_PLAYLIST_ID"
      begin
        client.add_playlist_item(community_pl_id, yt_id)
        added_count += 1
        sleep 0.1 # quota safety
      rescue => e
        warn "    ❌ Error adding #{yt_id}: #{e.message}"
      end
    else
      added_count += 1
    end
  end

  puts "\n🎉 Community Playlist Sync Complete: #{added_count} videos #{options[:apply] ? 'added live' : 'staged to add'}."
end

puts "\n" + "=" * 80
puts "✅ DONE"
puts "=" * 80

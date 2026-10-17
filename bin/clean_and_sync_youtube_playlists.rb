#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: clean_and_sync_youtube_playlists.rb
# domain: media
# purpose: YouTube Playlist Deduplication & Organization Tool
# usage: ruby bin/clean_and_sync_youtube_playlists.rb [options]
# ---

# bin/clean_and_sync_youtube_playlists.rb: YouTube Playlist Deduplication & Organization Tool
#
# Audits, deduplicates, and organizes playlists on the live YouTube channel via YouTube Data API v3.
# Supports:
#   --audit                     Audit all playlists for internal duplicate items and duplicate video uploads
#   --target PLAYLIST           Filter audit/deduplication to a specific playlist ID or title substring
#   --dedupe                    Remove duplicate playlist items and redundant video uploads from playlists
#   --retire-duplicates         Mark redundant duplicate video uploads as private on YouTube
#   --delete-duplicates         Permanently delete redundant duplicate videos from YouTube (requires --confirm)
#   --reconcile                 Reconcile local _data/video_assets.yml with canonical video IDs
#   --sync-community-playlist   Create and populate the dedicated Non-Conference Community Interviews playlist
#   --all                       Run deduplication and sync community playlist
#   --apply                     Execute mutations live (default is dry-run mode)
#   --confirm                   Safety confirmation flag required for permanent deletion

require 'optparse'
require 'yaml'
require 'json'
require_relative 'lib/youtube_client'
require_relative 'lib/youtube_deduplicator'

options = {
  mode: :audit,
  apply: false,
  confirm: false,
  target_playlist: nil,
  retire_duplicates: false,
  delete_duplicates: false,
  reconcile: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/clean_and_sync_youtube_playlists.rb [options]"

  opts.on("--audit", "Audit all channel playlists for duplicates and structure (default)") do
    options[:mode] = :audit
  end

  opts.on("--target PLAYLIST", "Filter to specific playlist ID or title keyword (e.g. PLNtb969T2-l0)") do |target|
    options[:target_playlist] = target
  end

  opts.on("--dedupe", "Deduplicate all playlists on the YouTube channel") do
    options[:mode] = :dedupe
  end

  opts.on("--retire-duplicates", "Set redundant duplicate video uploads to private on YouTube") do
    options[:retire_duplicates] = true
  end

  opts.on("--delete-duplicates", "Permanently delete redundant duplicate video uploads from YouTube") do
    options[:delete_duplicates] = true
  end

  opts.on("--confirm", "Confirmation flag required for permanent deletion of videos") do
    options[:confirm] = true
  end

  opts.on("--reconcile", "Reconcile _data/video_assets.yml with canonical video IDs") do
    options[:reconcile] = true
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

deduplicator = YouTubeDeduplicator.new

puts "=" * 80
puts "🎬 YOUTUBE PLAYLIST & VIDEO DEDUPLICATION TOOL"
puts "   Mode: #{options[:mode].to_s.upcase} | Execution: #{options[:apply] ? '⚡ LIVE APPLY' : '🔍 DRY RUN'}"
puts "   Target Filter: #{options[:target_playlist] || 'All Playlists'}"
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
if options[:target_playlist]
  target_kw = options[:target_playlist].downcase
  playlists = playlists.select do |p|
    p["id"].downcase == target_kw || p.dig("snippet", "title").to_s.downcase.include?(target_kw)
  end
end
puts "Inspecting #{playlists.size} playlists.\n\n"

# ── 1. Audit Playlists ────────────────────────────────────────────────────────
playlist_audits = []
all_redundant_vids = []

playlists.each do |pl|
  pl_id = pl["id"]
  title = pl.dig("snippet", "title")
  privacy = pl.dig("status", "privacyStatus") || "public"

  items = fetch_all_playlist_items(client, pl_id)
  audit = deduplicator.audit_playlist_items(items)
  plan = deduplicator.plan_playlist_deletions(audit)

  audit_entry = {
    id: pl_id,
    title: title,
    privacy: privacy,
    total_items: audit[:total_items],
    unique_videos: audit[:unique_videos],
    dup_item_count: audit[:duplicate_item_groups].values.map { |v| v.size - 1 }.sum,
    duplicate_item_groups: audit[:duplicate_item_groups],
    duplicate_video_groups: audit[:duplicate_video_groups],
    deletion_plan: plan
  }
  playlist_audits << audit_entry

  has_dups = plan.any?
  status_icon = has_dups ? "⚠️" : "✓"
  puts "#{status_icon} [#{pl_id}] \"#{title}\" (#{privacy})"
  puts "   Total items: #{audit[:total_items]} | Unique videos: #{audit[:unique_videos]} | Items to remove: #{plan.size}"

  if audit[:duplicate_item_groups].any?
    puts "   📋 Duplicate Playlist Items (same video ID repeated):"
    audit[:duplicate_item_groups].each do |vid, dups|
      sample_title = dups.first.dig("snippet", "title")
      puts "      - Video #{vid} (#{dups.size}x): #{sample_title}"
    end
  end

  if audit[:duplicate_video_groups].any?
    puts "   🎞️ Duplicate Video Uploads (different video IDs with matching topic):"
    audit[:duplicate_video_groups].each do |norm_title, group|
      puts "      • Topic: \"#{group[:title]}\""
      puts "        Canonical Video: #{group[:canonical_id]}"
      puts "        Redundant Video(s): #{group[:redundant_ids].join(', ')}"
      all_redundant_vids.concat(group[:redundant_ids])
    end
  end
  puts
end

all_redundant_vids.uniq!

# ── 2. Deduplicate Playlists ──────────────────────────────────────────────────
if options[:mode] == :dedupe || options[:mode] == :all
  puts "\n" + "=" * 80
  puts "🧹 DEDUPLICATING PLAYLISTS"
  puts "=" * 80

  total_deleted = 0
  playlist_audits.each do |audit|
    plan = audit[:deletion_plan]
    next if plan.empty?

    puts "\nProcessing \"#{audit[:title]}\" (#{audit[:id]}): removing #{plan.size} redundant playlist items..."

    plan.each do |d|
      item_id = d[:playlist_item_id]
      vid = d[:video_id]
      reason = d[:reason] == 'duplicate_playlist_item' ? 'repeat item' : 'redundant duplicate upload'
      puts "  • [#{vid}] (#{reason}) Item: #{item_id} (pos #{d[:position]}): #{d[:title]}"

      if options[:apply]
        begin
          client.delete_playlist_item(item_id)
          total_deleted += 1
          print "    ✓ Deleted live from playlist\n"
          sleep 0.1 # quota & rate safety
        rescue => e
          warn "    ❌ Failed to delete playlist item #{item_id}: #{e.message}"
        end
      else
        puts "    [DRY RUN] Would delete item #{item_id} from playlist"
        total_deleted += 1
      end
    end
  end

  puts "\n🎉 Playlist Deduplication complete: #{total_deleted} items #{options[:apply] ? 'deleted live' : 'identified for deletion'}."
end

# ── 3. Retire / Delete Redundant Duplicate Video Uploads ───────────────────────
if (options[:retire_duplicates] || options[:delete_duplicates]) && all_redundant_vids.any?
  puts "\n" + "=" * 80
  puts "🎥 REDUNDANT VIDEO CLEANUP"
  puts "   Target redundant videos: #{all_redundant_vids.join(', ')}"
  puts "=" * 80

  if options[:delete_duplicates]
    unless options[:confirm]
      warn "❌ Error: --delete-duplicates requires --confirm flag to prevent accidental deletion."
      exit 1
    end

    all_redundant_vids.each do |vid|
      puts "  🛑 Permanently deleting video #{vid}..."
      if options[:apply]
        begin
          client.delete_video(vid)
          puts "    ✓ Video #{vid} deleted live."
        rescue => e
          warn "    ❌ Failed deleting #{vid}: #{e.message}"
        end
      else
        puts "    [DRY RUN] Would delete video #{vid} permanently from YouTube."
      end
    end
  elsif options[:retire_duplicates]
    all_redundant_vids.each do |vid|
      puts "  🔒 Setting video #{vid} to private..."
      if options[:apply]
        begin
          client.set_video_privacy(vid, 'private')
          puts "    ✓ Video #{vid} set to private."
        rescue => e
          warn "    ❌ Failed setting #{vid} to private: #{e.message}"
        end
      else
        puts "    [DRY RUN] Would set video #{vid} to private."
      end
    end
  end
end

# ── 4. Create / Sync Non-Conference Community Interviews Playlist ─────────────
if options[:mode] == :sync_community || options[:mode] == :all
  puts "\n" + "=" * 80
  puts "🌟 NON-CONFERENCE COMMUNITY INTERVIEWS PLAYLIST SYNC"
  puts "=" * 80

  community_playlist_title = "Developer Community, User Groups & Meetup Interviews"
  community_playlist_desc = "One-on-one interviews with developer community organizers, user group leaders, and open-source practitioners from the UGtastic Archive (Chicago Python, McHenry County Meetups, Tribune Tech, 8th Light, and independent community sessions)."

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

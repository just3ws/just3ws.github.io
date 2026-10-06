#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/sync_youtube_rewatch_playlist.rb
#
# Creates or updates the official YouTube playlist for:
# "The Sound Above: UGtastic Oral History Rewatch Series"
#
# Curated by Mike Hall (Software Craftsmanship Signatory #106)
# Connecting the Chicago Software Craftsmanship oral history archive (2009-2026)
# with the modern 2026+ transition into AI and agentic software craftsmanship.

require "json"
require "optparse"
require_relative "lib/youtube_client"

PLAYLIST_TITLE = "The Sound Above: UGtastic Oral History Rewatch (Chicago Software Craftsmanship)"

PLAYLIST_DESCRIPTION = <<~DESC.strip
The Sound Above is an oral history rewatch and commentary series curated by Mike Hall (Software Craftsmanship Manifesto Signatory #106).

This series revisits the UGtastic and WHOIS Tech Community archives (2009-2015), fulfilling the original mission: raising awareness of the people who make technical community possible, one interview at a time.

Now standing in 2026 facing the AI transition, we look back to look forward. How did grassroots developers in Chicago break free from corporate silos, cultivate deliberate practice, mentor apprentices, and build durable local communities before cloud platforms and code synthesis existed? What principles from the Chicago Software Craftsmanship movement (Alt.NET, ChicagoRuby, 8th Light, Obtiva, SCNA, CodeRetreat) will guide us as software engineering evolves into orchestrating autonomous agents?

Archive & Transcripts: https://www.just3ws.com/interviews/
Curator: Mike Hall (https://www.just3ws.com)
DESC

# Mapping manifest episodes to canonical YouTube video IDs
EPISODE_MAPPING = [
  { ep: 1, guest: "Sergio Pereira", video_id: "qOHdZKz1WFw", title: "Chicago Alt.NET w/Sergio Pereira" },
  { ep: 2, guest: "Ray Hightower", video_id: "XZqGbf5C76E", title: "ChicagoRuby w/Ray Hightower" },
  { ep: 3, guest: "Micah Martin", video_id: "GwYGODSJWgM", title: "Micah Martin on 8th Light & Craftsmanship" },
  { ep: 4, guest: "Dave Hoover", video_id: "MytNNjBsBBk", title: "Geekfest w/Dave Hoover (Apprenticeship Patterns)" },
  { ep: 5, guest: "Steve Kim & Jim Suchy", video_id: "P2iQC4VdrAE", title: "Chicago Software Craftsmanship w/Steve Kim and Jim Suchy" },
  { ep: 6, guest: "Corey Haines", video_id: "rh9kzqKgKXA", title: "Corey Haines on CodeRetreat & Deliberate Practice" },
  { ep: 7, guest: "Charley Baker", video_id: "OZKOiXBuAYg", title: "Charley Baker on Developer Community & Watir" },
  { ep: 8, guest: "Tim Ottinger", video_id: "GYpgcyIH_gc", title: "Tim Ottinger on Craftsmanship & Agility" },
  { ep: 9, guest: "Andrea Magnorsky", video_id: "NaFFbjd9umM", title: "Andrea Magnorsky on Community & Game Jams" },
  { ep: 10, guest: "Gary Bernhardt", video_id: "g6gFCr5isGg", title: "Gary Bernhardt on Destroy All Software & SCNA" },
  { ep: 11, guest: "Dan North", video_id: "Bp2lAiqGEMk", title: "Dan North on BDD & Deliberate Discovery" },
  { ep: 12, guest: "Dave 'pragdave' Thomas", video_id: "4Io6gcQcuVQ", title: "Dave Thomas on Craftsmanship Heritage" },
  { ep: 13, guest: "Hadi Hariri", video_id: "pOl23zYt_Nw", title: "Hadi Hariri on Developer Community & Tooling" },
  { ep: 14, guest: "Sarah Gray", video_id: "fvukV80PwLU", title: "Sarah Gray on Community Growth" },
  { ep: 16, guest: "David Heinemeier Hansson (DHH)", video_id: "z94-DGthrfY", title: "DHH on Rails Ecosystem Stewardship" },
  { ep: 18, guest: "Jason Cranford Teague", video_id: "0RBob_r4rGk", title: "Jason Cranford Teague on Web Design & Standards" }
].freeze

def run
  options = { apply: false }
  OptionParser.new do |opts|
    opts.banner = "Usage: bin/sync_youtube_rewatch_playlist.rb [options]"
    opts.on("-a", "--apply", "Apply changes to YouTube (default is dry-run)") do
      options[:apply] = true
    end
    opts.on("-h", "--help", "Show help and usage information") do
      puts opts
      exit 0
    end
  end.parse!

  puts "=================================================================="
  puts " 📺 YOUTUBE REWATCH PLAYLIST SYNC ENGINE"
  puts " Mode: #{options[:apply] ? 'APPLY (LIVE)' : 'DRY RUN (INSPECT ONLY)'}"
  puts "=================================================================="

  client = YouTubeClient.new
  unless client.authenticated?
    puts "❌ Error: YouTube OAuth credentials missing."
    exit 1
  end

  channel = client.get_channel_info
  puts "Channel: #{channel.dig('snippet', 'title')} (#{channel['id']})"

  # Find existing playlist by title
  playlists = client.get_channel_playlists
  existing = playlists.find { |p| p.dig("snippet", "title") == PLAYLIST_TITLE }

  playlist_id = existing&.fetch("id")

  if existing
    puts "Found existing playlist: [#{playlist_id}] #{existing.dig('snippet', 'title')}"
    if options[:apply]
      puts "Updating playlist description & metadata..."
      client.update_playlist(playlist_id, PLAYLIST_TITLE, PLAYLIST_DESCRIPTION, "public")
      puts "Playlist metadata updated successfully."
    else
      puts "Would update metadata for playlist #{playlist_id}."
    end
  else
    puts "Playlist '#{PLAYLIST_TITLE}' does not exist yet."
    if options[:apply]
      puts "Creating public playlist..."
      res = client.create_playlist(PLAYLIST_TITLE, PLAYLIST_DESCRIPTION, "public")
      playlist_id = res["id"]
      puts "Playlist created successfully: [#{playlist_id}]"
    else
      puts "Would create playlist: '#{PLAYLIST_TITLE}'"
    end
  end

  # Check existing videos in playlist
  existing_video_ids = playlist_id ? client.get_playlist_video_ids(playlist_id) : []
  puts "\nCurrent videos in playlist (#{existing_video_ids.length}): #{existing_video_ids.join(', ')}"

  puts "\nSyncing curated rewatch episodes into playlist:"
  EPISODE_MAPPING.each do |ep|
    v_id = ep[:video_id]
    if existing_video_ids.include?(v_id)
      puts "  [EXISTS] Episode #{ep[:ep]} (#{ep[:guest]}): #{v_id} is already in playlist"
    else
      puts "  [ADD]    Episode #{ep[:ep]} (#{ep[:guest]}): #{v_id} -> #{ep[:title]}"
      if options[:apply] && playlist_id
        begin
          client.add_playlist_item(playlist_id, v_id)
          puts "           -> Added #{v_id} successfully."
          sleep 0.5
        rescue => e
          puts "           -> Failed to add #{v_id}: #{e.message}"
        end
      end
    end
  end

  puts "\n=================================================================="
  if options[:apply]
    puts "✅ Sync complete! Playlist URL:"
    puts "   https://www.youtube.com/playlist?list=#{playlist_id}"
  else
    puts "💡 Dry run finished. Run with --apply to push playlist changes."
  end
  puts "=================================================================="
end

run if __FILE__ == $PROGRAM_NAME

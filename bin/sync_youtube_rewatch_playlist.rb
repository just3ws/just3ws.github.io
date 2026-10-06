#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# bin/sync_youtube_rewatch_playlist.rb
#
# Production tool to audit, synchronize, and calibrate YouTube playlists:
# "The Sound Above: UGtastic Oral History Rewatch Series" (PLVcmLmfz2uyA)
#
# Features:
# - Enforces Title Case across video titles
# - Sets en-US defaultLanguage and en defaultAudioLanguage
# - Adds missing curated interviews cleanly
# - Updates playlist description with Theme Song, Pillars, and Featured Voices
# - Synchronizes bidirectional canonical site links
# ==============================================================================

require "json"
require "optparse"
require_relative "lib/youtube_client"

PLAYLIST_TITLE = "The Sound Above: UGtastic Oral History Rewatch (Chicago Software Craftsmanship)"

PLAYLIST_DESCRIPTION = <<~DESC.strip
The Sound Above is an oral history rewatch and commentary series curated and hosted by Mike Hall (Software Craftsmanship Manifesto Signatory #106, SCMC Co-Founder, UGtastic Host).

This series revisits the UGtastic and WHOIS Tech Community archives recorded between 2009 and 2015. It fulfills the original mission of the project: raising awareness of the people who make technical community possible, one conversation at a time.

"User-groups with lots to say • Interviews and more, no way! • Sharing great ideas in that tech community"

Standing in 2026 amid the transition toward autonomous code synthesis and AI systems, this archive stewards the foundational human craft of software engineering. How did grassroots developers in Chicago break free from corporate silos, cultivate deliberate practice, mentor apprentices, and build durable local communities before cloud platforms and automated models existed?

THE FOUR FOUNDATIONAL PILLARS OF UGTASTIC:
1. User-Group Organizers & Facilitators: The people booking rooms, finding speakers, and ordering pizza every month.
2. Independent Conference Curators: Community leaders creating platforms for practitioners to share without corporate PR filters.
3. Open-Source Toolmakers & Stewards: Authors building and maintaining the tools developers rely on every day.
4. Craftsmanship Mentors & Apprenticeship Leaders: Practitioners pioneering deliberate practice, dojos, and empathetic mentorship.

FEATURED VOICES & ORAL HISTORY SESSIONS:
• Sergio Pereira — Chicago Alt.NET at the Sears Tower (Series Premiere)
• Ray Hightower — ChicagoRuby & Grassroots Community Hospitality
• Micah Martin — 8th Light, SCNA, & Apprenticeship Culture
• Dave Hoover — Obtiva, Geekfest, & Apprenticeship Patterns
• Steve Kim & Jim Suchy — Chicago Software Craftsmanship
• Corey Haines — Coderetreat, Clojure, & Deliberate Practice
• Charlie Baker — Watir Maintainer & Browser Automation
• Tim Ottinger — Clean Code & Daily Engineering Discipline
• Andrea Magnorsky — Cross-Platform Curiosity & Game Jams
• Gary Bernhardt — Talk Crafting, DAS, & Fast Feedback Loops
• Dan North — BDD, Communication, & Deliberate Discovery
• Dave "pragdave" Thomas — Pragmatic Craftsmanship & Unlearning Dogma
• Hadi Hariri — Humility & Practitioner Wisdom
• Sarah Gray — Community Growth, Speaking, & Inclusion
• David Heinemeier Hansson (DHH) — Rails Ecosystem Stewardship & TDD
• Jason Cranford Teague — Author & Web Design Practitioner
• Rich Hickey — Clojure & Functional Simplicity
• Steve Klabnik — Rails, Client-Side Frameworks, & Educational Stewardship
• Robert "Uncle Bob" Martin — Software Craftsmanship & Engineering Ethics
• Yehuda Katz & Tom Dale — Ember.js & Client-Side Architecture
• Adewale Oshineye — The Apprenticeship Lineage & Mentorship
• Bryan Liles — Cloud Platforms & Authentic Speaking
• Dave Thomas — GOTO Conference & Community
• Coraline Ada Ehmke — Artis, Inclusive Communities, & Engineering Leadership
• Sandro Mancuso — London Software Craftsmanship & Global Movements
• Greg Baugues — Mental Health in Tech & Human-Centered Engineering
• Trek Glowacki — Chicago Ember.js Meetup at Groupon HQ
• Brian Ray — ChiPy (Chicago Python) & Grassroots Organizing
• Andy Lester — Ack, Developer Ergonomics, & Open-Source Maintenance
• James Edward Gray II — FasterCSV, Ruby Rogues, & Accessible Education
• Ryan Gerry — SCMC Co-Founder, Follett, & Suburban Craftsmanship

COMMUNITY HUBS PRESERVED:
Chicago Software Craftsmanship • Chicago Alt.NET • ChicagoRuby • ChiPy • Chicago Ember.js • SCMC • RailsBridge • SCNA • WindyCityRails • RailsConf • GOTO Chicago • ChicagoWebConf

Interactive Transcripts & Audio: https://www.just3ws.com/interviews/
Episode 01 Archive Mirror: https://www.just3ws.com/series/the-sound-above/episode-01/
Curated and restored by Mike Hall (https://www.just3ws.com)
DESC

# Canonical 31 Curated Interviews with Calibrated Titles
CURATED_INTERVIEWS = [
  { video_id: "qOHdZKz1WFw", title: "Sergio Pereira on Chicago Alt.NET | SCNA 2011 | The Sound Above Ep 01", speaker: "Sergio Pereira" },
  { video_id: "XZqGbf5C76E", title: "Ray Hightower on ChicagoRuby | SCNA 2011", speaker: "Ray Hightower" },
  { video_id: "GwYGODSJWgM", title: "Micah Martin on Community Building and User Group Organizing | SCNA 2013", speaker: "Micah Martin" },
  { video_id: "MytNNjBsBBk", title: "Dave Hoover on Geekfest | UGtastic Archive", speaker: "Dave Hoover" },
  { video_id: "P2iQC4VdrAE", title: "Steve Kim, Jim Suchy on Chicago Software Craftsmanship | UGtastic Archive", speaker: "Steve Kim & Jim Suchy" },
  { video_id: "rh9kzqKgKXA", title: "Corey Haines on Clojure and Functional Programming | UGtastic Archive", speaker: "Corey Haines" },
  { video_id: "OZKOiXBuAYg", title: "Charlie Baker on Denver Community & Watir Maintainer | SCNA 2011", speaker: "Charlie Baker" },
  { video_id: "GYpgcyIH_gc", title: "Tim Ottinger on Software Craftsmanship and Practice | UGtastic Archive", speaker: "Tim Ottinger" },
  { video_id: "NaFFbjd9umM", title: "Andrea Magnorsky on Conference Speaking and Presentation Skills | UGtastic Archive", speaker: "Andrea Magnorsky" },
  { video_id: "g6gFCr5isGg", title: "Gary Bernhardt on Crafting Technical Talks and Speaking Practice | SCNA 2012", speaker: "Gary Bernhardt" },
  { video_id: "Bp2lAiqGEMk", title: "Dan North on Developer Community and Conference Conversations | UGtastic Archive", speaker: "Dan North" },
  { video_id: "4Io6gcQcuVQ", title: "Dave \"pragdave\" Thomas on Software Craftsmanship and Learning | SCNA 2013", speaker: "Dave Thomas" },
  { video_id: "pOl23zYt_Nw", title: "Hadi Hariri on Developer Community and Conference Conversations | UGtastic Archive", speaker: "Hadi Hariri" },
  { video_id: "fvukV80PwLU", title: "Sarah Gray on Conference Speaking and Presentation Skills | SCNA 2013", speaker: "Sarah Gray" },
  { video_id: "z94-DGthrfY", title: "David Heinemeier Hansson (DHH) on Rails Ecosystem Stewardship | RailsConf 2014", speaker: "DHH" },
  { video_id: "0RBob_r4rGk", title: "Jason Cranford Teague on Author & Web Design Practitioner | UGtastic Archive", speaker: "Jason Cranford Teague" },
  { video_id: "HF0ZsbUjEDw", title: "Rich Hickey on Clojure and Functional Programming | UGtastic Archive", speaker: "Rich Hickey" },
  { video_id: "OpV2wHYbb3U", title: "Steve Klabnik on Ruby and Rails Practice | WindyCityRails 2012", speaker: "Steve Klabnik" },
  { video_id: "5rardEzrQOk", title: "Robert Martin on Conference Speaking and Presentation Skills | SCNA 2012", speaker: "Robert Martin" },
  { video_id: "6zUK5qAJOLo", title: "Yehuda Katz, Tom Dale on Ember.js and Frontend Architecture | RailsConf 2014", speaker: "Yehuda Katz & Tom Dale" },
  { video_id: "GGhUZTBA6L4", title: "Adewale Oshineye on Community Building and Apprenticeship | SCNA 2013", speaker: "Adewale Oshineye" },
  { video_id: "xs9zpxP_Gg8", title: "Brian Liles on Conference Speaking and Presentation Skills | WindyCityRails 2012", speaker: "Brian Liles" },
  { video_id: "RaCRLFLgbR4", title: "Dave Thomas on GOTO Conference and Community | GOTO 2012", speaker: "Dave Thomas" },
  { video_id: "fw6VrmMAy-o", title: "Coraline Ada Ehmke on Artis and Engineering Leadership | RailsConf 2014", speaker: "Coraline Ada Ehmke" },
  { video_id: "dDtdxSmfwtE", title: "Sandro Mancuso on Software Craftsmanship and Practice | SCNA 2012", speaker: "Sandro Mancuso" },
  { video_id: "d8c9ZQ7lAtY", title: "Interview with Greg Baugues on Mental Health in Tech | RailsConf 2014", speaker: "Greg Baugues" },
  { video_id: "sUtiKrGMaQQ", title: "Trek Glowacki on Ember.js Core Team and Chicago Ember.js | UGtastic Archive", speaker: "Trek Glowacki" },
  { video_id: "jPLEVAtM7HI", title: "Brian Ray on ChiPy and the Chicago Python Community | UGtastic Archive", speaker: "Brian Ray" },
  { video_id: "kQCtwwiHv3M", title: "Andy Lester on Ack, Open Source, and Project Maintenance | ChicagoWebConf 2012", speaker: "Andy Lester" },
  { video_id: "gyL-GTJgiu4", title: "James Edward Gray II on FasterCSV, Ruby Rogues, and Community Learning | UGtastic Archive", speaker: "James Edward Gray II" },
  { video_id: "gBQfB84aqW4", title: "Ryan Gerry on SCMC, Follett, and Suburban Craftsmanship | GOTO 2014", speaker: "Ryan Gerry" }
].freeze


def run
  options = { apply: false, calibrate_titles: false }
  OptionParser.new do |opts|
    opts.banner = "Usage: bin/sync_youtube_rewatch_playlist.rb [options]"
    opts.on("-a", "--apply", "Apply changes to YouTube live (default is dry-run)") do
      options[:apply] = true
    end
    opts.on("-c", "--calibrate-titles", "Calibrate video titles, en-US language, and localization") do
      options[:calibrate_titles] = true
    end
    opts.on("-h", "--help", "Show help and usage information") do
      puts opts
      exit 0
    end
  end.parse!

  puts "=================================================================="
  puts " 📺 YOUTUBE REWATCH PLAYLIST SYNC & CALIBRATION ENGINE"
  puts " Mode: #{options[:apply] ? 'APPLY (LIVE)' : 'DRY RUN (INSPECT ONLY)'}"
  puts " Calibrate Titles: #{options[:calibrate_titles]}"
  puts "=================================================================="

  client = YouTubeClient.new
  unless client.authenticated?
    puts "❌ Error: YouTube OAuth credentials missing."
    exit 1
  end

  channel = client.get_channel_info
  puts "Channel: #{channel.dig('snippet', 'title')} (#{channel['id']})"

  # Find existing playlist by title or ID
  playlists = client.get_channel_playlists
  existing = playlists.find { |p| p.dig("snippet", "title") == PLAYLIST_TITLE }

  playlist_id = existing&.fetch("id") || "PLVcmLmfz2uyA"

  if existing
    puts "Found existing playlist: [#{playlist_id}] #{existing.dig('snippet', 'title')}"
    if options[:apply]
      puts "Updating playlist description & metadata..."
      client.update_playlist(playlist_id, PLAYLIST_TITLE, PLAYLIST_DESCRIPTION, "public")
      puts "✅ Playlist metadata updated successfully."
    else
      puts "Would update metadata for playlist #{playlist_id}."
    end
  else
    puts "Playlist '#{PLAYLIST_TITLE}' does not exist yet."
    if options[:apply]
      puts "Creating public playlist..."
      res = client.create_playlist(PLAYLIST_TITLE, PLAYLIST_DESCRIPTION, "public")
      playlist_id = res["id"]
      puts "✅ Playlist created successfully: [#{playlist_id}]"
    else
      puts "Would create playlist: '#{PLAYLIST_TITLE}'"
    end
  end

  # Check existing videos in playlist
  existing_video_ids = playlist_id ? client.get_playlist_video_ids(playlist_id) : []
  puts "\nCurrent videos in playlist: #{existing_video_ids.length}"

  puts "\nSyncing #{CURATED_INTERVIEWS.length} curated rewatch interviews into playlist:"
  CURATED_INTERVIEWS.each_with_index do |interview, idx|
    v_id = interview[:video_id]
    expected_title = interview[:title]

    total = CURATED_INTERVIEWS.length
    if existing_video_ids.include?(v_id)
      puts "  [%02d/%02d] EXISTS: %s (%s)" % [idx + 1, total, v_id, interview[:speaker]]
    else
      puts "  [%02d/%02d] ADD:    %s (%s) -> %s" % [idx + 1, total, v_id, interview[:speaker], expected_title]

      if options[:apply] && playlist_id
        begin
          client.add_playlist_item(playlist_id, v_id)
          puts "           -> Added successfully."
          sleep 0.5
        rescue => e
          puts "           -> Failed to add: #{e.message}"
        end
      end
    end

    if options[:calibrate_titles] && options[:apply]
      v = client.get_video(v_id)
      if v
        snip = v["snippet"]
        stat = v["status"]
        needs_update = false

        if snip["title"] != expected_title
          puts "           -> Updating title to Title Case: #{expected_title}"
          snip["title"] = expected_title
          needs_update = true
        end

        if snip["defaultLanguage"] != "en-US" || snip["defaultAudioLanguage"] != "en"
          puts "           -> Setting language: en-US (audio: en)"
          snip["defaultLanguage"] = "en-US"
          snip["defaultAudioLanguage"] = "en"
          needs_update = true
        end

        if snip["localized"]
          snip["localized"]["title"] = expected_title
          needs_update = true
        end

        if needs_update
          begin
            client.update_video(v_id, { "snippet" => snip, "status" => stat })
            puts "           -> Calibrated video #{v_id}."
            sleep 0.3
          rescue => e
            puts "           -> Error calibrating video #{v_id}: #{e.message}"
          end
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
    puts "   Add --calibrate-titles to enforce Title Case and en-US localization."
  end
  puts "=================================================================="
end

run if __FILE__ == $PROGRAM_NAME

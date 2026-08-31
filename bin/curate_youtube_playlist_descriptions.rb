#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/curate_youtube_playlist_descriptions.rb — Curate high-signal titles & descriptions for public playlists
#
# Updates YouTube playlist snippet metadata (title, description) via YouTube Data API v3.
# Usage:
#   ruby bin/curate_youtube_playlist_descriptions.rb [--apply]

require 'optparse'
require 'json'
require_relative 'lib/youtube_client'

apply = ARGV.include?('--apply')

client = YouTubeClient.new
unless client.authenticated?
  warn "❌ Error: Missing YouTube API credentials."
  exit 1
end

CURATED_PLAYLISTS = {
  "PLgmTADxYKzzZItmN7yuhTCzzF3YC7kqGK" => {
    title: "RailsConf 2014 Interviews",
    description: "One-on-one interviews and practitioner discussions recorded on-site at RailsConf 2014 in Chicago, IL. Features conversations with David Heinemeier Hansson (DHH), Aaron Patterson, Coraline Ada Ehmke, Carlos Antonio da Silva, Alexander Dymo, Greg Baugues, and more on Ruby performance, Rails framework internals, mental health in tech, and community governance.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLgmTADxYKzzY6zF2GFV8IREdI7CXE2zEZ" => {
    title: "GOTO Conference 2015 Interviews",
    description: "On-site practitioner interviews recorded at GOTO Chicago 2015. Topics cover distributed systems, JVM languages, reactive architecture, cloud resilience, and engineering leadership. Features conversations with Anita Sengupta (NASA JPL), Attila Szegedi (Nashorn/JVM), Chad Fowler, Dan North, Justin Meyer, Matthew Brender, Corey Haines, and conference organizers.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLgmTADxYKzzZZD8PHLGQpmk6tEdHwoUKp" => {
    title: "GOTO Conference 2014 Interviews",
    description: "On-site interviews recorded at GOTO Chicago 2014 covering cloud architecture, distributed systems, legacy modernization, and engineering culture. Features conversations with Adrian Cockcroft (Netflix/Battery), Camille Fournier, Aino Vonge Corry, Fred George, and community leads.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLgmTADxYKzzYKdyO4oJ04tY28LITr9MLm" => {
    title: "GOTO Conference 2013 Interviews",
    description: "Foundational interviews recorded on-site at GOTO Chicago 2013. Features deep architectural discussions with Erik Meijer (creator of Reactive Frameworks), Rich Hickey (creator of Clojure), and Ola Bini on language design, concurrency, and distributed state.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLgmTADxYKzzbtHZ0VEw7vJ7Fc_RAB4oTW" => {
    title: "WindyCityRails 2011–2012 Interviews",
    description: "Interviews recorded on-site at WindyCityRails in Chicago, IL. Explores early Midwest Ruby culture, startup engineering, production Rails architecture, and developer education. Features conversations with Noel Rappin, Jim Remsik, Amy Kinney, Benjamin Oakes, and regional community organizers.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLgmTADxYKzzYXKUW9T5PEM-wRwRNiLa1M" => {
    title: "ChicagoWebConf 2012 Interviews",
    description: "Interviews recorded at ChicagoWebConf 2012 exploring frontend engineering, open-source maintenance, user experience, and web development craft. Features conversations with Andy Lester, JC Grubbs, Jonathan Baltz, Martin Atkins, Aaron Kalin, and community practitioners.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLgmTADxYKzzbVGRPPXB0z2rePbjLtJ_nM" => {
    title: "WebVisions 2013 Interviews",
    description: "Conversations from WebVisions Chicago 2013 exploring web architecture, interface design systems, and frontend engineering. Features interviews with Bill Scott (VP UI Engineering), Jason Cranford Teague, and event organizers.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLgmTADxYKzzYx1PZlBevlg7jKyUeFpQ8W" => {
    title: "Software Craftsmanship North America 2011 Interviews",
    description: "On-site interviews from SCNA 2011 in Chicago, IL. Deep discussions on agile practices, test-driven development, software craftsmanship, and developer apprenticeships with Uncle Bob Martin, Bobby Johnson, Zach Shaw, Drew Shefman, and foundational community leaders.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLgmTADxYKzzZ-omMjhzhTt50eCCuKK51C" => {
    title: "Software Craftsmanship North America 2012 Interviews",
    description: "On-site practitioner interviews from SCNA 2012 in Chicago, IL. Explores coding katas, deliberate practice, extreme programming, and mentoring. Features conversations with Brian Marick, Leon Gersing, Carl Erickson, Brad Wilkening, Culley Smith, Colin Jones, and Cory Foy.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLgmTADxYKzzapHQE_7ll59sXYzFighQCT" => {
    title: "Software Craftsmanship North America 2013 Interviews",
    description: "Interviews recorded at SCNA 2013 in Chicago, IL. Features discussions on code katas, programming humor, software architecture, and deliberate practice with Gary Bernhardt, Adewale Oshineye, and community practitioners.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  },
  "PLMieFbUNB3hM" => {
    title: "Developer Community, User Groups & Meetup Interviews",
    description: "One-on-one interviews with grassroots developer community organizers, user group leaders, and open-source practitioners from the UGtastic Archive. Focuses on local community building outside of large conferences: Chicago Python (ChiPy), McHenry County Meetups, Tribune Tech, 8th Light, Chicago Software Craftsmanship, and independent community spaces.\n\nFeatures conversations with Uncle Bob Martin, Avdi Grimm, Corey Haines, Ashe Dryden, Aaron Bedra, Brian Ray, Chet Hendrickson, Ron Jeffries, Dave Hoover, Angelique Martin, Arthur Kay, Charles Oliver Nutter, and more.\n\nFull searchable transcripts and archive: https://www.just3ws.com/interviews/"
  }
}

puts "=" * 80
puts "📝 YOUTUBE PLAYLIST CURATION & CONTEXT SYNC"
puts "   Execution: #{apply ? '⚡ LIVE APPLY' : '🔍 DRY RUN'}"
puts "=" * 80

CURATED_PLAYLISTS.each do |pl_id, meta|
  puts "\nPlaylist [#{pl_id}]: #{meta[:title]}"
  puts "Description:"
  meta[:description].lines.each { |l| puts "  | #{l.chomp}" }

  if apply
    begin
      client.update_playlist(pl_id, meta[:title], meta[:description], "public")
      puts "✓ Successfully updated on YouTube live."
      sleep 0.2
    rescue => e
      warn "❌ Error updating playlist #{pl_id}: #{e.message}"
    end
  else
    puts "[DRY RUN] Would update playlist snippet."
  end
end

puts "\n" + "=" * 80
puts "✅ DONE"
puts "=" * 80

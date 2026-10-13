#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/youtube_client"
require "json"

client = YouTubeClient.new
client.fetch_access_token!

puts "📺 [Ramblin\x27 & Amblin\x27 Sync] Authenticated as #{client.get_channel_info['snippet']['title']}"

# 1. Update Playlist
playlist_id = "PLNtb969T2-l0"
playlist_title = "Ramblin' & Amblin' · The Sound Above Field Notes"
playlist_description = <<~DESC.strip
Free-form thoughts largely on personal and professional identity from my personal experiences over 25+ years as a professional software developer who's kind of been everywhere. I'll be talking about "the before times" and how that informed me.

No AI in the recording. That also means that all weirdness, rambling, run-on sentences, redundant references, oxford commas, and ambling with fractals of digressions are part of my charm. ;)

This series serves as the conversational foundation and unscripted field notes informing "The Sound Above" oral history project (https://www.just3ws.com/series/the-sound-above/), exploring practitioner communities, Software Craftsmanship (SCMC, CDG, SCNA, 8th Light Pair Fridays), and the evolving identity of software developers in an era of generative AI.

⚠️ Note on Field Audio: These are candid, unproduced on-location walk-and-talk recordings captured across Northern Illinois. For the forensic audio restoration case study resolving high-voltage electromagnetic interference (EMI) on the right-of-way walk, see Episode 00 (https://youtu.be/8LYHo1dOkMo) and the companion open-source DSP toolchain (https://github.com/just3ws/dehum).
DESC

puts "\n📋 Updating playlist #{playlist_id}..."
res = client.update_playlist(playlist_id, playlist_title, playlist_description)
puts "✅ Playlist updated: #{res['snippet']['title']}"

# 2. Update Videos
videos = [
  {
    id: "0q1EAVJvBcU",
    title: "CDG at Crystal Lake Public Library: Founding Practitioner Rooms & The Sound Above",
    category_id: "22", # People & Blogs
    tags: [
      "Software Craftsmanship", "Cloud Developers Group", "CDG", "SCMC",
      "Crystal Lake", "Crystal Lake Public Library", "Corey Haines", "Ryan Gerry",
      "The Sound Above", "Developer Identity", "Tech Community", "Mike Hall"
    ],
    description: <<~DESC.strip
Standing outside the Crystal Lake Public Library in Crystal Lake, Illinois. The origin story of founding the Cloud Developers Group (CDG) in 2009 after Corey Haines issued a public challenge on Twitter: "Then make one!"

Booking the library basement meeting room, early Google App Engine (WSGI) and AWS S3 presentations with Ryan Gerry, library projector rules, and pivoting CDG into Software Craftsmanship McHenry County (SCMC) with Jim Suchy. Reflections on 17 years of practitioner community continuity, developer identity, and introducing "The Sound Above" oral history rewatch series.

⚠️ AUDIO & FIELD RECORDING CAVEAT:
This is a raw, unscripted field recording captured outdoors with standard mobile audio. If you are interested in forensic audio restoration and digital signal processing, see Episode 00 where we restored extreme 60 Hz electromagnetic hum from high-voltage transmission lines:
• Restored Video: https://youtu.be/8LYHo1dOkMo
• Forensic Case Study: https://www.just3ws.com/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/
• Open Source Toolchain: https://github.com/just3ws/dehum

⏱️ CHAPTER TIMESTAMPS:
00:00 - Introduction at Crystal Lake Public Library
00:34 - Cloud Developers Group (CDG) Origins
01:05 - Booking the Downstairs Meeting Room
03:04 - Meeting Ryan Gerry at SCNA 2009
04:30 - The Corey Haines Challenge: "Then Make One"
06:04 - WSGI on Google App Engine & AWS S3 Talks
09:01 - Decoupling from Microsoft-Centric Silos
12:06 - Pivoting CDG into SCMC (Software Craftsmanship McHenry County)
14:43 - Projector Etiquette & Library Hospitality
15:13 - The Value of Modest Practitioner Rooms
17:01 - 17 Years of Community Continuity & Identity
19:09 - Facing Industry Turmoil & AI Layoffs
21:00 - Announcing "The Sound Above" Rewatch Series

🔗 CONNECTED PLAYLIST & RESOURCES:
• Ramblin' & Amblin' Playlist: https://www.youtube.com/playlist?list=PLNtb969T2-l0
• The Sound Above (Oral History Series): https://www.just3ws.com/series/the-sound-above/
• SCMC Archive & Community Timeline: https://www.just3ws.com/timeline/community/
• Interactive Transcripts & Media: https://www.just3ws.com/interviews/

#SoftwareCraftsmanship #CloudDevelopersGroup #SCMC #UGtastic #CrystalLake #TheSoundAbove #DeveloperCommunity #ProgrammingHistory
    DESC
  },
  {
    id: "DQFs9H3eal8",
    title: "Shift: When the Ground Moves Beneath You (Crystal Lake Co-Working & The Sound Above)",
    category_id: "22",
    tags: [
      "Software Craftsmanship", "Shift Co-Working", "Crystal Lake", "The Sound Above",
      "Developer Identity", "Remote Work", "Corporate Dissolution", "Mike Hall"
    ],
    description: <<~DESC.strip
Standing outside the former Shift Co-working space (now the Crystal Lake Food Pantry) in Crystal Lake, Illinois. Picking up where the Veteran Acres reflection left off: what happens when the rules change and the ground shifts out from underneath you?

Reflections on corporate dissolution, union buyouts, navigating identity across 25+ years in professional software engineering, co-working spaces in 2015, remote work evolution, community volunteering, and the foundations of "The Sound Above" oral history project.

⚠️ AUDIO & FIELD RECORDING CAVEAT:
This is a raw, unscripted outdoor recording (including a passing Metra train). For the companion forensic audio restoration project resolving electromagnetic hum from high-voltage transmission lines, see:
• Episode 00 Restored: https://youtu.be/8LYHo1dOkMo
• Forensic Case Study: https://www.just3ws.com/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/
• Open Source Toolchain: https://github.com/just3ws/dehum

⏱️ CHAPTER TIMESTAMPS:
00:00 - Wrapping up Veteran Acres & Corporate Dissolution
01:00 - Metra UP-NW Train & Crystal Lake Food Pantry
01:44 - Shift Co-Working (circa 2015) & The Ecosystem Transition
03:30 - When the Rules Change: Navigating Shifting Ground
10:00 - 25+ Years in Software: Identity Beyond the Job Title
20:00 - Practitioner Rooms vs Corporate Echo Chambers
30:00 - Remote Work, Isolation, and Staying Grounded
40:00 - Reflections Leading into The Sound Above Series
46:00 - Conclusion

🔗 CONNECTED PLAYLIST & RESOURCES:
• Ramblin' & Amblin' Playlist: https://www.youtube.com/playlist?list=PLNtb969T2-l0
• CDG at Crystal Lake Public Library: https://youtu.be/0q1EAVJvBcU
• Veteran Acres Park Walk: https://youtu.be/52dk-anGBe4
• The Sound Above Curriculum: https://www.just3ws.com/series/the-sound-above/

#SoftwareCraftsmanship #ShiftCoWorking #CrystalLake #TheSoundAbove #DeveloperIdentity #RemoteWork #ProgrammingHistory
    DESC
  },
  {
    id: "52dk-anGBe4",
    title: "Veteran Acres: Carrying Personal & Professional Identity Through Corporate Disintegration",
    category_id: "22",
    tags: [
      "Software Craftsmanship", "Veteran Acres", "Crystal Lake", "Developer Identity",
      "The Sound Above", "Corporate Disintegration", "Mike Hall"
    ],
    description: <<~DESC.strip
Walking the trails of Veteran Acres Park in Crystal Lake, Illinois. Candid thoughts and stories on personal and professional identity, watching a father navigate the collapse of his corporate and union support systems, and the parallel identity crisis facing software developers today.

Featuring an unscripted guest appearance by Officer Mailey from the Crystal Lake Park District Police.

⚠️ AUDIO & FIELD RECORDING CAVEAT:
This is a raw, candid park walk recorded without AI post-processing. For our technical forensic audio restoration case study repairing 60 Hz electromagnetic interference from high-voltage transmission lines, see:
• Restored Video: https://youtu.be/8LYHo1dOkMo
• Forensic Case Study: https://www.just3ws.com/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/
• Open Source Toolchain: https://github.com/just3ws/dehum

🔗 CONNECTED PLAYLIST & RESOURCES:
• Ramblin' & Amblin' Playlist: https://www.youtube.com/playlist?list=PLNtb969T2-l0
• Part 2 (Shift Co-Working): https://youtu.be/DQFs9H3eal8
• CDG at Crystal Lake Public Library: https://youtu.be/0q1EAVJvBcU
• The Sound Above Curriculum: https://www.just3ws.com/series/the-sound-above/

#SoftwareCraftsmanship #VeteranAcres #CrystalLake #TheSoundAbove #DeveloperIdentity #ProgrammingHistory #RamblinAndAmblin
    DESC
  }
]

videos.each do |v|
  puts "\n🎥 Updating Video #{v[:id]} (#{v[:title]})..."
  existing = client.get_video(v[:id])
  unless existing
    puts "⚠️ Video #{v[:id]} not found on channel, skipping."
    next
  end

  payload = {
    "snippet" => {
      "title" => v[:title],
      "description" => v[:description],
      "categoryId" => v[:category_id] || existing["snippet"]["categoryId"],
      "tags" => v[:tags],
      "defaultLanguage" => "en-US"
    },
    "status" => {
      "privacyStatus" => existing["status"]["privacyStatus"]
    }
  }

  res = client.update_video(v[:id], payload)
  puts "✅ Video #{v[:id]} updated: #{res['snippet']['title']} (Status: #{res['status']['privacyStatus']})"
end

puts "\n✨ [Ramblin\x27 & Amblin\x27 Sync] All metadata and playlists updated successfully."

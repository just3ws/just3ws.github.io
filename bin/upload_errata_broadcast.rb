#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require_relative 'lib/youtube_client'

$stdout.sync = true

file_path = "/Users/mike/Movies/2026-10-13_20-01-13_ugtastic_sound_above_staging.mov"
unless File.exist?(file_path)
  abort "Error: Recording file not found at #{file_path}"
end

file_size = File.size(file_path)
puts "🎬 [Errata Upload] Target video: #{file_path} (#{file_size / (1024 * 1024)} MB)"

client = YouTubeClient.new
client.fetch_access_token!

title = "The Mirage of Competence: An Experiment in Public on AI Slop and Domain Boundaries"

description = <<~DESC.strip
The Sound Above: Marginalia, Readings & Demonstrations (Errata Series)
Live Broadcast with Mike Hall (Staff Software Engineer & SCMC Co-Founder)

Origin Premise:
A 13-word search query entered on google.com beneath 345,000-volt transmission lines:
"recording a video under high tension wires repair audio sync"

From that vague prompt, Google's Gemini-powered search overview synthesized an authoritative-sounding specification that diagnosed "clock crystal drift," applied an atempo time-stretch, and slurred human speech into slow-motion. It was confident, articulate, and completely wrong.

Note on In-Stream Browser Audio:
During this live session, desktop audio capture through the browser player cut out briefly for a few moments when playing raw audio clips. For the definitive direct audio comparison, please reference the Forensic Audio A/B Listening Test (15-Second Direct Comparison) on the canonical case study:
https://www.just3ws.com/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/

The Opening Mirror ("Typing Is Not The Bottleneck"):
Mike opens the session by presenting his physical Dell Studio XPS PP35L 16-inch OLED laptop from 2009. It still carries the original "TYPING IS NOT THE BOTTLENECK" sticker featuring two rows of monkeys hammering on keyboards. Purchased specifically for an engagement with Obtiva, that project was both the first and last .NET project Obtiva ever engaged in, and Mike's last .NET job before switching permanently to a MacBook Pro and Vim through the Groupon acquisition.

The Experiment in Public:
This is an experiment in public on how far "AI Slop" can go before you run out of things to generate, and finally have to confront the reality: modern AI creates an illusion of competence in domains far beyond even an experienced engineer's ability to safely reason with.

Acoustic DSP, electromagnetic induction, phase smear, and audio container interleaving are physically unforgiving. The AI has no biological ears. It cannot hear sub-bass pressure or speech warmth. It pulls textbook formulas out of training weights and delivers them with absolute certainty. When an answer looks clean, the hardest question is whether you can tell if it is worth anything, or even operating in the right domain.

Empirical Token Ledger & Economics:
• Total tokens processed: 501,096,098 across 3,695 reasoning/tool steps.
• API list price equivalence: ~$10.63.
• Out-of-pocket cash paid: Under $1.25 (promotional $5/month Google AI Pro subscription, bridged once through a free-tier pool).
• Commercial equivalent human labor: ~$10,010 across 5 specialized engineering disciplines (70 billable hours).
• Economic leverage: ~1,000:1 API list value, up to 8,000:1 out-of-pocket cash.

Primary Resources & Verified Links:
• Interactive Presentation Cockpit: https://www.just3ws.com/dehum/
• In-Depth Case Study: https://www.just3ws.com/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/
• Raw Corrupted Master Video (Bad Audio Warning): https://youtu.be/8LYHo1dOkMo
• Complete 64-Hour Conversation Timeline: https://github.com/just3ws/dehum/blob/main/CONVERSATION_TIMELINE.md
• Economic & Technical Audit: https://github.com/just3ws/dehum/blob/main/ECONOMIC_AND_TECHNICAL_AUDIT.md
• Open-Source Restoration Script: https://github.com/just3ws/dehum

Chapters:
00:00 - Introduction & Cold Open
01:15 - "Typing Is Not The Bottleneck": The Dell Studio XPS PP35L & Obtiva
05:10 - The 13-Word Search Query: From google.com to PROMPT.md
09:20 - The Container Trap: atempo=0.837 and the Mirage of Drift
15:40 - Isolating Physical Ground Truth: Hardware Asymmetry & 60 Hz Buzz
22:10 - The Ledger: 501M Tokens for Under $1.25 vs $10,000 Human Labor
27:30 - Navigating False Confidence & Sovereign Verification
31:40 - Outro & Legacy Systems vs AI Slop Synthesis
DESC

tags = [
  "Software Craftsmanship",
  "Audio Forensics",
  "DSP",
  "AI Slop",
  "Gemini",
  "Antigravity",
  "Systems Architecture",
  "Engineering Ethics",
  "The Sound Above",
  "Errata"
]

payload = {
  "snippet" => {
    "title" => title,
    "description" => description,
    "tags" => tags,
    "categoryId" => "28",
    "defaultLanguage" => "en"
  },
  "status" => {
    "privacyStatus" => "public",
    "selfDeclaredMadeForKids" => false,
    "embeddable" => true
  }
}

puts "🚀 [Upload] Initializing resumable upload session on YouTube..."
init_uri = URI("https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=snippet,status")
http = Net::HTTP.new(init_uri.host, init_uri.port)
http.use_ssl = true

init_req = Net::HTTP::Post.new(init_uri)
init_req["Authorization"] = "Bearer #{client.access_token}"
init_req["Content-Type"] = "application/json; charset=UTF-8"
init_req["X-Upload-Content-Length"] = file_size.to_s
init_req["X-Upload-Content-Type"] = "video/quicktime"
init_req.body = JSON.generate(payload)

init_res = http.request(init_req)
unless init_res.is_a?(Net::HTTPSuccess) || init_res.code == "200" || init_res.code == "201"
  abort "Failed to initialize upload session (#{init_res.code}): #{init_res.body}"
end

location = init_res["Location"]
abort "No upload location returned" unless location

puts "🚀 [Upload] Streaming #{file_size / (1024 * 1024)} MB binary payload to YouTube..."
upload_uri = URI(location)
upload_http = Net::HTTP.new(upload_uri.host, upload_uri.port)
upload_http.use_ssl = true
upload_http.open_timeout = 60
upload_http.read_timeout = 3600

upload_req = Net::HTTP::Put.new(upload_uri)
upload_req["Content-Type"] = "video/quicktime"
upload_req["Content-Length"] = file_size.to_s

new_video_id = nil
File.open(file_path, 'rb') do |file|
  upload_req.body_stream = file
  upload_res = upload_http.request(upload_req)
  if upload_res.is_a?(Net::HTTPSuccess) || upload_res.code == "200" || upload_res.code == "201"
    data = JSON.parse(upload_res.body)
    new_video_id = data["id"]
    puts "✅ [Success] Errata Video uploaded successfully!"
    puts "   Video ID: #{new_video_id}"
    puts "   Link: https://youtu.be/#{new_video_id}"
  else
    abort "Upload failed (#{upload_res.code}): #{upload_res.body}"
  end
end

if new_video_id
  playlist_id = "PLKPAHha6I990"
  puts "📋 [Playlist] Adding video #{new_video_id} to Errata playlist #{playlist_id}..."
  begin
    client.add_playlist_item(playlist_id, new_video_id)
    puts "✅ Added to playlist: https://www.youtube.com/playlist?list=#{playlist_id}"
  rescue => e
    puts "⚠️ Could not add to playlist automatically: #{e.message}"
  end
end

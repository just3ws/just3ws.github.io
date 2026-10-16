#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: calibrate_uploaded_broadcast.rb
# domain: media
# purpose: Calibrate Uploaded Broadcast utility for the just3ws platform
# usage: ruby bin/calibrate_uploaded_broadcast.rb
# ---

require 'json'
require_relative 'lib/youtube_client'

$stdout.sync = true

video_id = ARGV[0] || ENV["VIDEO_ID"]
if video_id.nil? || video_id.empty?
  abort "Usage: ruby bin/calibrate_uploaded_broadcast.rb <VIDEO_ID>"
end

client = YouTubeClient.new
client.fetch_access_token!

puts "🔍 Fetching current video data for #{video_id}..."
video = client.get_video(video_id)
abort "Video #{video_id} not found" unless video

title = "[PRACTICE RUN] The Mirage of Competence: AI Slop & Domain Boundaries"

description = <<~DESC.strip
[WIP / PRACTICE RUN / BREAK-THE-ICE FIRST TAKE]
This is a raw, unpolished practice run and break-the-ice first take for "The Sound Above" broadcast series.

It is a dirty draft. It is not what I want this to be finally, but I had to commit and get this one out the door rather than procrastinating further. You have to start where you are. I'm out of practice, and I already learned a few immediate lessons around audio settings, live pacing, and what it feels like to kind of lose the thread during a live unscripted broadcast. The more I do this, the less nervous I will become.

I will likely re-record a tightened cut, but here is the authentic first test in public.

---

The Sound Above: Marginalia, Readings & Demonstrations (Errata Series)
Live Broadcast Test with Mike Hall (Staff Software Engineer & SCMC Co-Founder)

Note on In-Stream Browser Audio:
During this live session, desktop audio capture through the browser player cut out briefly for a few moments when playing raw audio clips. For the definitive direct audio comparison, please reference the Forensic Audio A/B Listening Test (15-Second Direct Comparison) on the canonical case study:
https://www.just3ws.com/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/

The Opening Mirror ("Typing Is Not The Bottleneck"):
Mike opens the session by presenting his physical Dell Studio XPS PP35L 16-inch OLED laptop from 2009. It still carries the original "TYPING IS NOT THE BOTTLENECK" sticker featuring two rows of monkeys hammering on keyboards. Purchased specifically for an engagement with Obtiva, that project was both the first and last .NET project Obtiva ever engaged in, and Mike's last .NET job before switching permanently to a MacBook Pro and Vim through the Groupon acquisition.

Origin Premise:
A 13-word search query entered on google.com beneath 345,000-volt transmission lines:
"recording a video under high tension wires repair audio sync"

From that vague prompt, Google's Gemini-powered search overview synthesized an authoritative-sounding specification that diagnosed "clock crystal drift," applied an atempo time-stretch, and slurred human speech into slow-motion. It was confident, articulate, and completely wrong.

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
  "Errata",
  "Practice Run"
]

snippet = video["snippet"]
snippet["title"] = title
snippet["description"] = description
snippet["tags"] = tags
snippet["categoryId"] = "28"

puts "Updating video metadata for #{video_id}..."
res = client.update_video(video_id, { "snippet" => snippet, "status" => video["status"] })
puts "✅ Video updated successfully: #{res.dig('snippet', 'title')}"

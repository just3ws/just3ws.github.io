#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: update_youtube_metadata.rb
# domain: media
# purpose: Update Youtube Metadata utility for the just3ws platform
# usage: ruby bin/update_youtube_metadata.rb
# ---

require_relative "lib/youtube_client"
require "json"

client = YouTubeClient.new
client.fetch_access_token!

# 1. Update XS7EZ1eWH4U (Upcoming Broadcast)
live_id = "XS7EZ1eWH4U"
live_video = client.get_video(live_id)

live_title = "The Mirage of Competence: An Experiment in Public on AI Slop and Domain Boundaries"
live_description = <<~DESC.strip
[HEADPHONE / VOLUME WARNING]
The raw recording under analysis contains severe 60 Hz high-voltage induction hum and corona micro-arcing crackle. Please monitor volume levels if reviewing raw clips.

The Sound Above: Marginalia, Readings & Demonstrations (Errata Series)
Live Broadcast with Mike Hall (Staff Software Engineer & SCMC Co-Founder)

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
• Raw Corrupted Master Video (Bad Audio): https://youtu.be/8LYHo1dOkMo
• Complete 64-Hour Conversation Timeline: https://github.com/just3ws/dehum/blob/main/CONVERSATION_TIMELINE.md
• Economic & Technical Audit: https://github.com/just3ws/dehum/blob/main/ECONOMIC_AND_TECHNICAL_AUDIT.md
• Open-Source Restoration Script: https://github.com/just3ws/dehum

Chapters:
00:00 - Introduction & Stream Starting
02:00 - The Vague Search Query: From google.com to PROMPT.md
05:30 - The Container Trap: atempo=0.837 and the Mirage of Drift
10:15 - Isolating Physical Ground Truth: Hardware Asymmetry & 60 Hz Buzz
16:00 - The Ledger: 501M Tokens for Under $1.25 vs $10,000 Human Labor
22:30 - Navigating False Confidence & Sovereign Verification
28:00 - Q&A, Workbench Telemetry, and Wrap-Up
DESC

live_tags = [
  "Software Craftsmanship",
  "Audio Forensics",
  "DSP",
  "AI Slop",
  "Gemini",
  "Antigravity",
  "Systems Architecture",
  "Engineering Ethics",
  "The Sound Above"
]

live_snippet = live_video["snippet"]
live_snippet["title"] = live_title
live_snippet["description"] = live_description
live_snippet["tags"] = live_tags
live_snippet["categoryId"] = "28"

puts "Updating live video #{live_id}..."
res_live = client.update_video(live_id, { "snippet" => live_snippet, "status" => live_video["status"] })
puts "✅ Live broadcast updated: #{res_live.dig('snippet', 'title')}"

# 2. Update 8LYHo1dOkMo (Raw Master Recording with Bad Audio Warning)
raw_id = "8LYHo1dOkMo"
raw_video = client.get_video(raw_id)

raw_title = "Under the High-Tension Wires: Identity, Software Craftsmanship, and AI Forensics"
raw_description = <<~DESC.strip
[HEADPHONE / VOLUME WARNING: BAD AUDIO]
This recording was captured directly beneath active 345 kV high-voltage transmission lines in Northern Illinois. The raw audio contains harsh 60 Hz electromagnetic induction buzz, harmonic overtones up to 600 Hz, and micro-arcing corona discharge crackle captured by an unshielded top microphone. Please monitor volume levels if listening on headphones.

Case Study & Forensics:
https://www.just3ws.com/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/

Interactive Presentation Cockpit:
https://www.just3ws.com/dehum/

64-Hour Conversation Timeline & Audit:
• Forensic Conversation Timeline: https://github.com/just3ws/dehum/blob/main/CONVERSATION_TIMELINE.md (41 user turns, 1,793 steps, prompt-by-prompt autopsy)
• Economic Labor & Compute Audit: https://github.com/just3ws/dehum/blob/main/ECONOMIC_AND_TECHNICAL_AUDIT.md (501M tokens processed across 3,695 steps on a $5/month promotional plan vs $10,010 commercial human labor across 5 disciplines)

Audio & Restoration Timestamps:
• 00:00 - Introduction & The High-Tension Right-of-Way (Audio restored via 7-stage DSP)
• 00:11 - Clean Speech Baseline ("Here I am...") : https://youtu.be/8LYHo1dOkMo?t=11
• 01:21 - UGtastic Oral History Background : https://youtu.be/8LYHo1dOkMo?t=81
• 04:40 - Software Craftsmanship Movement Reflections : https://youtu.be/8LYHo1dOkMo?t=280
• 13:30 - Software Craftsmanship & Engineering Responsibility : https://youtu.be/8LYHo1dOkMo?t=810
• 17:35 - Sergio Pereira & Chicago Alt.NET User Group : https://youtu.be/8LYHo1dOkMo?t=1055
• 18:11 - Presentation Concludes ("Thank you") / Trailing Silent Walk : https://youtu.be/8LYHo1dOkMo?t=1091

Raw Original vs. Restored Comparison:
The original corrupted master (with 60 Hz hum, corona arcing, and inductive drone) and the bit-for-bit restored video are mirrored for forensic comparison in the archive:
Google Drive / ai / dehum/ (3.1 GB Raw vs 3.3 GB Restored)

Walking through the utility right-of-way beneath high-voltage transmission lines in Northern Illinois.

This was recorded as an icebreaker reflection on personal and professional identity, the history of the Software Craftsmanship movement, and where we find ourselves now as software developers, engineers, and craftspeople in an age of generative AI and industry turmoil.

Forensic Restoration & AI Tooling Context:
The original raw recording was severely degraded by high-voltage electromagnetic interference (EMI):
• Intense 60 Hz induction and harmonic buzz up through 600 Hz.
• Corona discharge micro-arcing clicks from high-voltage atmospheric ionization.
• Hardware failure: The phone secondary noise-cancelling microphone acted as an unshielded inductive loop antenna (capturing 65x more rumble than the bottom mic).
• Duration anomaly: 18m 11s audio vs 21m 43s video.

Using Google DeepMind Gemini 3.8 Flash via the Antigravity CLI, we diagnosed physical failure modes, isolated the clean bottom microphone, designed a calibrated 7-stage DSP restoration pipeline (fix_video.sh), and repaired audio with bit-for-bit video passthrough (-c:v copy). Downstream speech recognition (whisper.cpp) achieved 93.3% lexical recovery with 152 unmasked acoustic errors resolved.

Open Source Restoration Toolchain:
https://github.com/just3ws/dehum

Archive & Interviews:
https://www.just3ws.com/ugtastic/

#SoftwareCraftsmanship #AudioForensics #DSP #AI #Gemini #Antigravity #UGtastic #Engineering
DESC

raw_snippet = raw_video["snippet"]
raw_snippet["title"] = raw_title
raw_snippet["description"] = raw_description
raw_snippet["categoryId"] = "28"

puts "Updating raw video #{raw_id}..."
res_raw = client.update_video(raw_id, { "snippet" => raw_snippet, "status" => raw_video["status"] })
puts "✅ Raw video updated with bad audio warning: #{res_raw.dig('snippet', 'title')}"

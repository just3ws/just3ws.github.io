#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: sync_topic_prompts.rb
# domain: media
# role: Synchronize grounded conversation topic prompts to Google Drive intake folders
# description: Compiles proposed conversation topics for Ramblin' & Amblin' and Errata derived from Mike Hall's 20-year history, writings, and interviews, syncing notes and metadata directly into Google Drive queue directories.
# usage: bin/pipeline media sync-prompts
# ---

require 'fileutils'
require 'json'
require 'yaml'
require 'time'

ROOT_DIR = File.expand_path('..', __dir__)
CONFIG_PATH = File.join(ROOT_DIR, '_data', 'media_intake_targets.yml')
PROMPTS_DOCS_DIR = File.join(ROOT_DIR, 'docs', 'prompts')

RAMBLIN_TOPICS = [
  {
    id: "ogilvie-lost-and-found",
    title: "The Ogilvie Lost & Found: Physical Tools vs. Digital Resilience",
    location_suggestion: "Ogilvie Transportation Center / Metra Train Platform, Chicago",
    historical_anchor: "Losing the original UGtastic recording bag, camera, tripod, and microphone on the train; checking the station lost and found daily for weeks.",
    core_inquiry: "What happens when your physical tools vanish overnight? How do you distinguish between disposable gear and permanent discipline?",
    talking_points: [
      "The panic of realizing the camera bag was left on the train seat after a long recording day.",
      "Visiting the Ogilvie lost and found counter every morning during the morning commute.",
      "The realization that footage without backups is fragile, leading to the Maildir-style ingestion pattern.",
      "Tools come and go: what endures is the network of relationships and the habit of showing up."
    ],
    concepts: ["Resilience", "Physical Tools", "Backup Habits", "Metra Commute", "UGtastic Lineage"]
  },
  {
    id: "production-incidents-sre-window",
    title: "Production Incidents & The Fleeting SRE Window",
    location_suggestion: "Downtown Chicago Loop or urban transit corridor",
    historical_anchor: "Reflections on acute production outages across high-traffic consumer systems and SaaS platforms.",
    core_inquiry: "Why does acute production crisis unite engineering teams, and why does that architectural window slam shut so quickly?",
    talking_points: [
      "The psychological shift during an active Sev-1 incident: all political posturing evaporates.",
      "Leadership suddenly pays attention to database connection pools, queue depths, and circuit breakers.",
      "The 72-hour golden window: how experienced Staff engineers use post-incident reviews to secure permanent architectural fixes.",
      "The danger of returning to business as usual before systemic friction is eliminated."
    ],
    concepts: ["Production Incidents", "SRE", "Architectural Windows", "Staff Leadership", "Blameless Postmortems"]
  },
  {
    id: "diesel-mechanics-to-distributed-systems",
    title: "From Diesel Mechanics to Distributed Systems: Sensory Troubleshooting",
    location_suggestion: "Industrial corridor, rail yard, or highway overpass",
    historical_anchor: "Early trade background working on heavy equipment, engines, and mechanical systems before entering software.",
    core_inquiry: "How does wrenching on diesel engines and hydraulic systems train your mind for distributed software architecture?",
    talking_points: [
      "Listening to an engine under load: you hear bearing knock and vacuum leaks before diagnostic codes throw.",
      "Distributed systems exhibit the exact same physical dynamics: backpressure, bottlenecks, and heat.",
      "Why sensory, intuitive systems debugging beats abstract ivory-tower theory every time.",
      "Respecting the trade crafts: why software development is closer to skilled trades than academic computer science."
    ],
    concepts: ["Trades Lineage", "Mechanical Empathy", "Backpressure", "Troubleshooting", "Grounded Craft"]
  },
  {
    id: "typing-is-not-the-bottleneck",
    title: "The Dell Studio XPS Laptop & 'Typing is Not the Bottleneck'",
    location_suggestion: "Suburban park path or coffee shop patio",
    historical_anchor: "The 2009 Obtiva .NET client engagement carrying the Dell Studio XPS PP35L OLED laptop with the monkey typing sticker.",
    core_inquiry: "Why has typing never been the bottleneck in software development, and what does that mean in the generative AI era?",
    talking_points: [
      "The physical artifact: that heavy Studio XPS laptop running early .NET and Vim.",
      "The iconic sticker: a cartoon monkey hammering a keyboard, reminding everyone that keystrokes are cheap.",
      "If typing was not the bottleneck in 2009, generating tokens is certainly not the bottleneck in 2026.",
      "The real work is reading, framing the boundary, validating assumptions, and deleting unnecessary lines."
    ],
    concepts: ["Obtiva Era", "Typing Bottleneck", "Token Generation", "Software as Writing", "Discipline"]
  },
  {
    id: "the-ponytail-principle",
    title: "The Ponytail Principle: Climbing the Complexity Ladder from the Ground",
    location_suggestion: "Woodland trail, Veteran Acres, or nature preserve",
    historical_anchor: "Developing the 4-rung complexity ladder to prevent premature technical debt across local-first platforms.",
    core_inquiry: "How do you protect your codebase from over-engineering without sacrificing long-term extensibility?",
    talking_points: [
      "Rung 1 (Omission): If you do not write the speculative feature, it carries zero maintenance taxes.",
      "Rung 2 (Inlining): Constants over dynamic configs. Sane defaults directly in place.",
      "Rung 3 (Standard Library): Language built-ins before reaching for heavy third-party gems or frameworks.",
      "Rung 4 (Annotated Seam): Mark deliberate shortcuts with '# ponytail:' so trade-offs remain visible.",
      "Why solo operators and high-performing small teams rely on Rung 1 and 2 to outpace funded startups."
    ],
    concepts: ["Ponytail Principle", "YAGNI", "Simplicity", "Technical Debt", "Architecture Discipline"]
  },
  {
    id: "metra-commuter-geometry",
    title: "The Metra Commuter Geometry: How Train Lines Built Chicago Craftsmanship",
    location_suggestion: "Metra train car or suburban commuter platform (UP-NW line)",
    historical_anchor: "Decades of daily commuting from McHenry County into downtown Chicago, reading technical books on the train.",
    core_inquiry: "How did Chicago's radial commuter rail system shape the geography and culture of local software communities?",
    talking_points: [
      "The 75-minute train ride: an uninterrupted cognitive sanctuary for reading SICP, Fowler, and Evans.",
      "Connecting suburban practitioners in Crystal Lake, Barrington, and Libertyville with downtown Loop consultancies.",
      "The contrast between West Coast suburban campus sprawl and Chicago's walkable, transit-linked community.",
      "Why physical geography and commute geometry influence the durability of technical user groups."
    ],
    concepts: ["Metra Commute", "Chicago Geography", "Focus Time", "Community Geometry", "Sovereign Time"]
  },
  {
    id: "scmc-and-community-burnout",
    title: "Co-Founding SCMC & The Reality of Community Burnout",
    location_suggestion: "Quiet suburban neighborhood or park bench",
    historical_anchor: "Co-founding Software Craftsmanship McHenry County (SCMC) with Tim Ottinger, coordinating monthly meetings and coding dojos.",
    core_inquiry: "What does it really take to sustain a grassroots user group for years, and when is it time to let it transform?",
    talking_points: [
      "The early excitement of packing 25 developers into a suburban library room for hands-on kata exercises.",
      "The invisible labor: buying pizza, setting up projectors, reminding speakers, and balancing family load.",
      "The heartbreak of seeing attendance fluctuate and realizing you cannot carry a community alone.",
      "Community leadership lessons: build self-sustaining rituals, distribute ownership early, and avoid savior complexes."
    ],
    concepts: ["SCMC", "Grassroots Organizing", "Burnout", "Community Health", "Tim Ottinger"]
  },
  {
    id: "without-zdots-there-was-nothing",
    title: "Without zdots, There Was Nothing: Thirty Years of Personal Tooling",
    location_suggestion: "Workstation desk or quiet outdoor setting",
    historical_anchor: "The three-decade evolution of personal dotfiles, bare git worktrees, and shell automation powering the Panoramic View platform.",
    core_inquiry: "Why is a disciplined personal OS the most durable career investment an engineer can make?",
    talking_points: [
      "The realization that companies, employers, and laptops change, but your mental models and terminal stay with you.",
      "Structuring dotfiles into zdots, adots, vdots, and my: separating work-tenant secrets from personal platform.",
      "Why keyboard ergonomics, tmux sessions, and shell aliases compound over decades of daily practice.",
      "Maintaining cognitive sovereignty: never letting an enterprise IT vendor dictate your local environment."
    ],
    concepts: ["zdots", "Personal OS", "Dotfiles", "Cognitive Sovereignty", "Long-Term Tooling"]
  }
].freeze

ERRATA_TOPICS = [
  {
    id: "errata-mirage-of-competence-dsp",
    title: "Errata: The 345kV Audio Recovery & Why Gemini Hallucinated 20% Clock Drift",
    focus: "Technical Demonstration & Forensic Audio Walkthrough",
    core_inquiry: "Deconstructing the prompt-based DSP hallucination under high-tension power lines.",
    talking_points: [
      "Walking through the raw frequency waterfall: the sharp 60 Hz fundamental and harmonic spikes.",
      "Showing the exact browser query and Gemini Flash response asserting linear clock drift.",
      "The audio slurring failure: playing the 0.837x output and demonstrating why math without listening is dangerous.",
      "The 4 lines of deterministic scipy code that isolated the clean left channel and silenced the hum in 40ms."
    ],
    demonstration_assets: [
      "fix_video.sh",
      "dehum/dashboard.html",
      "A/B Audio Player (/assets/audio/dehum_comparison_raw.mp4 vs fixed)"
    ]
  },
  {
    id: "errata-phone-mic-antenna-asymmetry",
    title: "Errata: When a Smartphone Noise-Cancellation Mic Becomes an RF Loop Antenna",
    focus: "Hardware Acoustics & Dual-Mic Physics",
    core_inquiry: "Why smartphone noise-cancellation hardware failed catastrophically under electromagnetic induction.",
    talking_points: [
      "How modern phones use dual microphones to perform phase-cancelling noise suppression.",
      "The physical geometry: top microphone was unshielded and positioned directly facing the 345kV conductors.",
      "Measuring 65x more low-frequency inductive rumble on the right channel versus the left channel.",
      "Why splitting stereo channels and dropping the antenna track solved 90% of the problem with zero DSP."
    ],
    demonstration_assets: [
      "Dual-channel FFT spectral graphs",
      "Motorola Moto G hardware teardown diagram"
    ]
  },
  {
    id: "errata-local-whisper-m4-zero-egress",
    title: "Errata: Local whisper.cpp on Apple Silicon M4 with Zero Cloud Egress",
    focus: "Local-First Machine Learning & Transcription Pipelines",
    core_inquiry: "Running multi-gigabyte speech-to-text inference on localhost with zero cloud costs and zero privacy leaks.",
    talking_points: [
      "Setting up whisper.cpp with Metal acceleration on the Apple Silicon Neural Engine.",
      "Benchmarking transcription speed: 1.6 GB video processed in 95 seconds using whisper-large-v3-turbo.",
      "Deterministic post-processing: automated lexical brand repair for community names (e.g. 'eubatastic' to 'UGtastic').",
      "Generating frame-accurate WebVTT subtitle tracks and syncing to YouTube Data API v3."
    ],
    demonstration_assets: [
      "bin/intake_drive_video.rb",
      "whisper.cpp command-line harness",
      "_data/transcripts/ YAML schemas"
    ]
  },
  {
    id: "errata-nginx-unbuffered-sse-daemon",
    title: "Errata: Debugging Unbuffered Server-Sent Events (SSE) Through Nginx",
    focus: "Systems Networking & Realtime Web Telemetry",
    core_inquiry: "Building zero-dependency near-realtime telemetry daemons without WebSockets or heavy framework overhead.",
    talking_points: [
      "Why WebSockets are often overkill for one-way server-to-client telemetry.",
      "The nginx buffering trap: proxy_buffering off and chunked_transfer_encoding off requirements.",
      "Writing a pure Ruby SSE server using TCPServer and Thread.new in under 300 lines.",
      "Handling client disconnects, broadcast keepalives, and instant queue state updates."
    ],
    demonstration_assets: [
      "bin/live_dashboard_streamer.rb",
      "nginx/just3ws.localhost.conf"
    ]
  },
  {
    id: "errata-bpmn-media-intake-observability",
    title: "Errata: BPMN 2.0 as an Executable State Machine for Cloud Media Intake",
    focus: "Enterprise Workflow Architecture & Observability",
    core_inquiry: "Using formal BPMN 2.0 swimlanes, boundary error events, and SLO tripwires for single-operator pipelines.",
    talking_points: [
      "The Maildir pattern: staged, pending, processing, processed, and failed directories.",
      "Modeling 12 discrete service tasks from stability check to YouTube caption upload.",
      "Defining strict Service Level Objectives (SLOs) and incident tripwires for audio DSP and cloud streaming.",
      "Embedding interactive BPMN execution monitors in localhost dashboards."
    ],
    demonstration_assets: [
      "docs/bpmn/media-intake-pipeline.bpmn",
      "docs/bpmn/README.md",
      "youtube/dashboard.html (#tab-bpmn)"
    ]
  }
].freeze

def compile_markdown_sheet(title, channel_name, description, topics, structure_guide = nil)
  lines = []
  lines << "# #{title}"
  lines << ""
  lines << "> **Channel**: #{channel_name}"
  lines << "> **Updated**: #{Time.now.utc.strftime('%Y-%m-%d %H:%M UTC')}"
  lines << "> **Source**: Derived from Mike Hall's 20-year archive, writings, and interviews"
  lines << ""
  lines << "## Overview & Purpose"
  lines << description
  lines << ""
  if structure_guide
    lines << "## Broadcast Intro & Outro Structure"
    lines << ""
    lines << "### Grounded Intro Structure (0:00 - 1:00)"
    lines << structure_guide[:intro]
    lines << ""
    lines << "### Clear Takeaway Outro Structure (Closing 1 - 2 minutes)"
    lines << structure_guide[:outro]
    lines << ""
  end
  lines << "---"
  lines << ""
  lines << "## Curated Conversation Prompts"
  lines << ""

  topics.each_with_index do |t, idx|
    lines << "### Prompt #{idx + 1}: #{t[:title]}"
    lines << ""
    lines << "- **ID**: `#{t[:id]}`"
    lines << "- **Location / Setting**: #{t[:location_suggestion] || t[:focus]}"
    lines << "- **Historical Anchor**: #{t[:historical_anchor]}" if t[:historical_anchor]
    lines << "- **Core Inquiry**: #{t[:core_inquiry]}"
    lines << ""
    lines << "#### Talking Points & Narrative Arcs:"
    t[:talking_points].each do |pt|
      lines << "1. #{pt}"
    end
    lines << ""
    if t[:concepts]
      lines << "- **Key Concepts**: #{t[:concepts].join(', ')}"
      lines << ""
    end
    if t[:demonstration_assets]
      lines << "- **Demonstration Artifacts**: #{t[:demonstration_assets].join(', ')}"
      lines << ""
    end
    lines << "---"
    lines << ""
  end

  lines.join("\n")
end

def sync_prompts
  puts "=================================================================="
  puts " 📋 TOPIC PROMPTS SYNCHRONIZATION"
  puts "=================================================================="

  FileUtils.mkdir_p(PROMPTS_DOCS_DIR)

  config = File.exist?(CONFIG_PATH) ? YAML.safe_load(File.read(CONFIG_PATH)) : {}
  base_path = config['base_path']

  # 1. Compile Ramblin' & Amblin'
  ramblin_desc = "Conversations on the move: engineering observations, personal history, systems architecture, and practitioner reflections recorded during walks, train rides, and field dispatches."
  ramblin_structure = {
    intro: "- **Setting & Atmosphere**: Ground the listener immediately in where you are (trail, commuter platform, downtown corridor).\n- **The Inciting Spark**: Introduce the specific real-world event, observation, or question that prompted this reflection within the first 60 seconds.\n- **Core Inquiry**: State the guiding inquiry directly so the premise and focus are crystal clear right away.",
    outro: "- **Grounded Synthesis**: Bring the freeform observation back to a durable engineering principle.\n- **Actionable Takeaway**: Provide one concrete takeaway the viewer can apply to their daily engineering craft, team architecture, or career sustainability.\n- **Grounded Sign-off**: Warm, unvarnished parting thought ('Keep your feedback loops fast, keep walking, and verify your code')."
  }
  ramblin_md = compile_markdown_sheet("Ramblin' & Amblin' Proposed Topics & Field Prompts", "Ramblin' & Amblin' (@whoistechcmty)", ramblin_desc, RAMBLIN_TOPICS, ramblin_structure)

  local_ramblin = File.join(PROMPTS_DOCS_DIR, 'ramblin-amblin-topics.md')
  File.write(local_ramblin, ramblin_md)
  puts "✅ Saved local copy: docs/prompts/ramblin-amblin-topics.md"

  if base_path && Dir.exist?(base_path)
    drive_ramblin_dir = File.join(base_path, 'whoistechcmty', 'ramblin-amblin')
    if Dir.exist?(drive_ramblin_dir)
      drive_ramblin_file = File.join(drive_ramblin_dir, 'TOPIC_PROMPTS.md')
      File.write(drive_ramblin_file, ramblin_md)
      drive_ramblin_json = File.join(drive_ramblin_dir, 'topic_prompts.json')
      File.write(drive_ramblin_json, JSON.pretty_generate(RAMBLIN_TOPICS) + "\n")
      puts "☁️ Synced to Google Drive: #{drive_ramblin_file}"
    else
      warn "⚠️ Google Drive directory missing: #{drive_ramblin_dir}"
    end
  end

  # 2. Compile Errata
  errata_desc = "Solo technical demonstrations, deep-dive forensic walkthroughs, audio restoration experiments, code reviews, and edge-case postmortems exploring the mechanics behind the systems."
  errata_structure = {
    intro: "- **The Problem / AI Hallucination**: State the exact failure mode, vendor myth, or LLM hallucination being investigated within the first 60 seconds.\n- **Scope of Inspection**: Define the exact artifacts, data boundaries, and code interfaces being inspected today.",
    outro: "- **Deterministic Solution**: Demonstrate the verified, working solution or filter with exact reproducible steps.\n- **Defensive Rule of Thumb**: Provide the core engineering takeaway to prevent this failure in production, with direct links to repository code on just3ws.com."
  }
  errata_md = compile_markdown_sheet("The Sound Above (Errata) Proposed Topics & Deep-Dive Prompts", "The Sound Above: Errata (@whoistechcmty)", errata_desc, ERRATA_TOPICS, errata_structure)

  local_errata = File.join(PROMPTS_DOCS_DIR, 'errata-topics.md')
  File.write(local_errata, errata_md)
  puts "✅ Saved local copy: docs/prompts/errata-topics.md"

  if base_path && Dir.exist?(base_path)
    drive_errata_dir = File.join(base_path, 'whoistechcmty', 'errata')
    if Dir.exist?(drive_errata_dir)
      drive_errata_file = File.join(drive_errata_dir, 'TOPIC_PROMPTS.md')
      File.write(drive_errata_file, errata_md)
      drive_errata_json = File.join(drive_errata_dir, 'topic_prompts.json')
      File.write(drive_errata_json, JSON.pretty_generate(ERRATA_TOPICS) + "\n")
      puts "☁️ Synced to Google Drive: #{drive_errata_file}"
    else
      warn "⚠️ Google Drive directory missing: #{drive_errata_dir}"
    end
  end

  puts "=================================================================="
  puts "✨ Topic prompts synchronization complete!"
  puts "=================================================================="
end

sync_prompts if __FILE__ == $PROGRAM_NAME

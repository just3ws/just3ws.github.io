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
    id: "the-unspoken-debt-patreon-and-support",
    title: "The Unspoken Debt: Early Patreon Backers & The Burden of Support",
    location_suggestion: "Quiet wooded path or suburban neighborhood walk",
    historical_anchor: "The 2014-2015 UGtastic Patreon campaign and GoFundMe for Final Cut Pro X (ugtastic-patreon, ugtastic-fcp), where community members stepped up to fund the work, but personal burnout and mental health struggles made the operational weight overwhelming before having the chance to thank them properly.",
    core_inquiry: "What happens when community goodwill meets personal burnout? How do you carry the emotional weight of support when you are struggling to keep your head above water, and how do you honor that debt ten years later?",
    talking_points: [
      "The vulnerability of launching the Patreon and GoFundMe in 2014 to cover camera gear, travel, and editing licenses.",
      "The immediate generosity: community members, conference attendees, and peers stepping up to pledge monthly support per episode.",
      "The psychological weight: how receiving financial support can feel like an impossible promise when navigating deep personal struggles, depression, and neurodivergent burnout.",
      "Stepping away from the microphone without having the emotional bandwidth to say a proper thank you or explain why the lights went out.",
      "Returning to the archive now: recognizing that those patrons were not asking for perfection, they just believed in preserving the community's story."
    ],
    concepts: ["Patreon Support", "Community Debt", "Burnout", "Vulnerability", "Unspoken Gratitude"]
  },
  {
    id: "carrying-the-camera-alone",
    title: "Carrying the Camera Alone: The Solitary Listener in Crowded Hallways",
    location_suggestion: "Metra platform or urban conference district walkway",
    historical_anchor: "Hauling heavy camera bags, wireless lavaliers, tripods, and laptops alone through GOTO Chicago, SCNA, and RailsConf hallways from 2011 to 2015 to record over 200 technical interviews without an assistant or production crew.",
    core_inquiry: "What is the physical and emotional reality of being the sole documentarian at technical conferences, and why is listening often the loneliest job in the room?",
    talking_points: [
      "The physical toll: hauling 35 pounds of recording equipment between crowded conference rooms on zero sleep.",
      "The sharp contrast: being surrounded by 800 animated engineers while operating as a solitary, detached observer behind the lens.",
      "The discipline of active listening: suppressing your own ego to help the guest articulate what made their work meaningful.",
      "Why grassroots oral history matters more than commercial marketing: catching developers in their authentic, unvarnished state."
    ],
    concepts: ["Grassroots Documentation", "Solitary Observer", "Conference Hallways", "Active Listening", "Physical Toll"]
  },
  {
    id: "founding-cdg-suburban-void",
    title: "The Suburban Void & The SCNA Table: Launching CDG in 2009",
    location_suggestion: "Duke's Alehouse exterior or quiet park, Crystal Lake",
    historical_anchor: "Living 50 miles outside Chicago in McHenry County with zero technical groups; walking up to Ryan Gerry at an SCNA 2009 table and discovering they lived 15 minutes apart in the northwest suburbs.",
    core_inquiry: "How does physical geography isolate suburban software developers, and what does it take to create a technical gravity well from scratch without corporate backing?",
    talking_points: [
      "The isolation of being an enterprise developer in the outer suburbs before remote work existed.",
      "The chance encounter at SCNA 2009: asking Ryan Gerry where he lived and discovering a neighbor in McHenry County.",
      "The scrappy inception: gathering for Cloud Developers Group in Panera Bread backrooms, public libraries, and upstairs at Duke's Alehouse.",
      "The lesson for organizers: you do not wait for permission or corporate sponsorship to create the room you need."
    ],
    concepts: ["Suburban Isolation", "Ryan Gerry", "CDG", "Grassroots Inception", "Duke's Alehouse"]
  },
  {
    id: "8th-light-pair-friday-libertyville",
    title: "Carl Sagan in Libertyville: The Cultural Shock of Pair Friday (2008)",
    location_suggestion: "Quiet street or office park, Lake County",
    historical_anchor: "Stepping into 8th Light's second-floor Libertyville office in late 2008 for Pair Friday, pairing with Micah Martin, Colin Jones, Eric Smith, and Eric Meyer on open-source code.",
    core_inquiry: "What happened when an enterprise .NET developer walked into a room where craftsmen paired in Vim to Carl Sagan remixes, and how did that redefine software as a craft?",
    talking_points: [
      "The stark culture shock between enterprise IT compliance cubicles and the open communal tables of Libertyville.",
      "MelodySheep's Carl Sagan remixes playing in the background while developers wrote RSpec tests in terminal windows.",
      "Seeing the apprenticeship model live: experienced craftsmen guiding apprentices through deliberate practice and immediate feedback.",
      "The realization that software development was not a bureaucratic compliance exercise, but an honorable, disciplined trade."
    ],
    concepts: ["8th Light", "Pair Friday", "Libertyville", "Apprenticeship", "Cultural Shift"]
  },
  {
    id: "ray-hightower-suburban-diner",
    title: "Ray Hightower at the Suburban Diner: The Generosity of an Ambassador (2008)",
    location_suggestion: "Roadside diner, commuter stop, or coffee counter",
    historical_anchor: "Meeting ChicagoRuby founder Ray Hightower at Midway Restaurant between offices while working as remote Principal Developer at BDI.",
    core_inquiry: "What makes a true community ambassador, and how can a single 30-minute act of unconditional generosity alter an engineer's career trajectory?",
    talking_points: [
      "Sitting down with Ray Hightower: zero sales pitch, zero corporate posturing, just pure technical generosity.",
      "Ray opening his laptop to run Cucumber tests, showing how human and readable automated acceptance testing could be.",
      "Ray pointing the way to 8th Light's open doors in Libertyville rather than trying to hoard or gatekeep knowledge.",
      "The responsibility of senior practitioners: opening doors for newcomers without expecting anything in return."
    ],
    concepts: ["Ray Hightower", "ChicagoRuby", "Ambassadorship", "Cucumber", "Open Doors"]
  },
  {
    id: "the-zero-dollar-conference",
    title: "The Zero-Dollar Conference: Chicago Code Camp & Anonymized Merit (2010-2012)",
    location_suggestion: "College campus courtyard or academic hallway",
    historical_anchor: "Co-organizing Chicago Code Camp for 500+ attendees across 6 tracks on a $0 software budget; authoring the custom anonymized blind-review engine.",
    core_inquiry: "Can high-caliber technical discourse flourish without corporate gatekeepers, expensive tickets, and speaker celebrity culture?",
    talking_points: [
      "Delivering a 500-person multi-track Saturday conference on volunteer labor, static websites, and spotty university Wi-Fi.",
      "Why blind review matters: stripping speaker names and corporate sponsors so talks were selected purely on merit.",
      "Giving first-time speakers from local user groups the exact same platform as published keynote authors.",
      "The contrast between an authentic practitioner gathering and a commercial vendor trade show."
    ],
    concepts: ["Chicago Code Camp", "Blind Review", "Zero-Dollar Infrastructure", "Meritocracy", "Volunteer Organizing"]
  },
  {
    id: "scmc-17-year-torch",
    title: "Handing Over the Torch: Ryan Gerry & The 17-Year Continuous Room",
    location_suggestion: "Follett Software exterior or quiet suburban park",
    historical_anchor: "Co-founding SCMC with Ryan Gerry and Jim Suchy, stepping away after the two-year anniversary, and watching Ryan continue running the group monthly for over 15 years.",
    core_inquiry: "What does true community longevity look like, and how do you build a local institution that thrives long after a co-founder steps aside?",
    talking_points: [
      "Co-founding SCMC with Ryan Gerry and Jim Suchy: securing the meeting room at Follett Software Company and establishing the monthly kata habit.",
      "Stepping away after the two-year anniversary: recognizing personal capacity limits and trusting Ryan Gerry to carry the mission forward.",
      "Watching Ryan Gerry sustain the monthly cadence for 17 years through corporate shifts, venue reconfigurations, and the COVID-19 pandemic.",
      "The profound lesson of stewardship: the best things you help build are the ones that continue to thrive after you step away."
    ],
    concepts: ["SCMC", "Ryan Gerry", "Jim Suchy", "Community Longevity", "Stewardship"]
  },
  {
    id: "greg-baugues-mental-health",
    title: "Greg Baugues & The Listener's Burden: Mental Health in Engineering (RailsConf 2014)",
    location_suggestion: "Quiet walkway or conference center courtyard",
    historical_anchor: "Interviewing Greg Baugues at RailsConf 2014 following his pioneering keynote talk on developer depression and bipolar disorder.",
    core_inquiry: "Why was mental health tech's most closely guarded secret in 2014, and what is the emotional cost of holding space for others when struggling yourself?",
    talking_points: [
      "The electrified atmosphere at RailsConf 2014 when Greg Baugues stepped onto the stage to speak openly about depression and bipolar disorder.",
      "The hallway interview: standing with the camera rolling, listening to the shared reality of struggle that so many engineers kept hidden.",
      "The burden of the listener: absorbing the vulnerability of 200 interviewees while carrying undiagnosed neurodivergent and emotional strain.",
      "Why sustainable engineering requires humane empathy, honest vulnerability, and dropping the mask of invulnerability."
    ],
    concepts: ["Greg Baugues", "Mental Health in Tech", "RailsConf 2014", "Empathy", "Vulnerability"]
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
    id: "errata-maildir-queue-resilience",
    title: "Errata: The Maildir Pattern for Video Intake: Preventing File Corruption & Stale Locks",
    focus: "Systems Architecture & File-Based State Machines",
    core_inquiry: "Why complex message brokers fail for single-operator media production, and how Maildir directories guarantee crash recovery.",
    talking_points: [
      "The Maildir architecture: staged, pending, processing, processed, and failed queues.",
      "Multi-sample interval verification to detect files still uploading over cellular or Wi-Fi.",
      "FIFO ordering using filesystem birthtime (btime) to prevent queue starvation.",
      "Automated crash recovery: daemon background watchers auditing worker PID liveness and restoring stranded processing files to pending."
    ],
    demonstration_assets: [
      "bin/intake_drive_video.rb",
      "bin/live_dashboard_streamer.rb",
      "~/.local/state/just3ws/pipeline.pid"
    ]
  },
  {
    id: "errata-bpmn-media-intake-observability",
    title: "Errata: BPMN 2.0 as an Executable State Machine for Cloud Media Intake",
    focus: "Enterprise Workflow Architecture & Observability",
    core_inquiry: "Using formal BPMN 2.0 swimlanes, boundary error events, and SLO tripwires for single-operator pipelines.",
    talking_points: [
      "Modeling 12 discrete service tasks from stability check to YouTube caption upload.",
      "Defining strict Service Level Objectives (SLOs) and incident tripwires for audio DSP and cloud streaming.",
      "Embedding interactive BPMN execution monitors in localhost dashboards.",
      "Connecting live Server-Sent Events (SSE) telemetry to animated BPMN step transitions."
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
    intro: "- **Setting & Atmosphere**: Ground the listener immediately in where you are (trail, commuter platform, downtown corridor).\n- **The Inciting Spark**: Introduce the specific real-world event, observation, or question that prompted this reflection within the first 60 seconds.\n- **Core Inquiry**: State the guiding inquiry directly so the premise and focus are unmistakable right away.",
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

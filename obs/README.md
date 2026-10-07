# The Sound Above: OBS Studio Project

## UGtastic Oral History Rewatch & Chicago Software Craftsmanship in the Age of AI

This directory houses the complete, version-controlled OBS Studio project configuration, production scenes, hardware profiles, dynamic browser overlays, curation sequencing, and operator runbooks for **The Sound Above** livestreaming series.

---

## 1. Project Vision and Narrative Arc

Hosted by Mike Hall (Co-Founder of Software Craftsmanship McHenry County, and Host of UGtastic).

### The Core Inquiry: "The Sound Above"

In January 2025, Mike Hall defined "the sound above":

> "The sound above represents the echoes of ideas, inspirations, and cultural touchstones that have shaped an industry or a mindset. It is the legacy carried forward by those who came before, forming an unspoken language and shared context among those who lived through it... If we want the next generation to care about the sound above, to find inspiration in the values and stories that shaped us, we must first help them thrive. Only then can we inspire them to look up, to hear the echoes of the past and add their own notes to the sound of the future."

When we look back at the artists, musicians, and systems thinkers who shaped an era, we ask:
- Who inspired them before they became famous?
- What records were spinning in their rooms before they stepped on stage?
- What were the grassroots rooms, late-night pairing sessions, and hallway discussions that birthed their ideas?
- What was the sound above?

### The Chicago Craftsmanship Roots and The AI Era

The Software Craftsmanship movement became global, but its deepest roots are in Chicago:
- The 2008 Libertyville Summit that drafted the Software Craftsmanship Manifesto
- Mike Hall signing the Manifesto as Signatory #106 on March 6, 2009
- The founding of Software Craftsmanship McHenry County (SCMC) in spring 2009
- The vibrant communities of Chicago Alt.NET, ChicagoRuby, 8th Light, and Obtiva
- Over 200 video interviews recorded under the UGtastic banner between 2010 and 2015

As the industry transitions into the AI era and confronts massive questions regarding developer identity, code provenance, and autonomous software generation, these historical conversations hold urgent, timeless lessons:
- Deliberate practice and code katas (Corey Haines)
- Testing discipline, Kent Beck's Four Rules of Simple Design, and the TDD debates (DHH, Uncle Bob)
- Software as human communication, deliberate discovery, and avoiding certification dogma (Dan North)
- System boundaries, fast feedback loops, and Unix workbench ergonomics (Gary Bernhardt)
- Unspoken team sociology and cognitive safety (Sarah Mei)
- Small methods, duck typing, and radical simplicity (Sandi Metz)

This rewatch series investigates how these foundational disciplines directly inform our stewardship of autonomous multi-agent fleets, sovereign local inference, and deterministic system cartography today.

---

## 2. Directory Layout

```
obs/
├── README.md                         # Master documentation and operator runbook
├── scenes/
│   └── ugtastic-sound-above.json     # Complete OBS 32.2 Scene Collection (8 calibrated scenes)
├── profiles/
│   └── The Sound Above/
│       ├── basic.ini                 # Apple Silicon M4 hardware encoder & 4-track audio profile
│       └── service.json              # YouTube Live streaming service template
├── overlays/
│   ├── css/
│   │   └── craftsmanship-theme.css   # Warm Chicago craftsmanship palette & typography
│   ├── js/
│   │   └── overlay-controller.js     # Live JSON state synchronizer & URL parameter parser
│   ├── overlay-state.json            # Single source of truth for active stream metadata
│   ├── lower-third.html              # Dynamic lower-third HUD (interviewee, conference, era)
│   ├── now-watching.html             # Video HUD card with live discussion thesis
│   ├── stream-starting.html          # Pre-stream title card with animated pulse and quote
│   ├── stream-brb.html               # Intermission card: "Holding the Thread"
│   └── stream-outro.html             # Closing credits with archive links and summary
├── curation/
│   ├── rewatch-curation-sequence.md  # 37-episode master curation guide & thematic movements
│   ├── sequence-manifest.json        # Machine-readable episode roadmap and metadata
│   └── errata-manifest.json          # Pre-curated catalog for Errata readings, concepts & artifacts
├── scripts/
│   ├── install-obs-config.sh         # Installs scenes & profile to ~/Library/Application Support/
│   ├── update-overlay-state.sh       # CLI tool to cue episodes and update overlays in real time
│   └── test-audio-routing.sh         # Audio diagnostic tool for CoreAudio and ScreenCaptureKit
└── docs/
    ├── reaction-and-coding-setup.md  # Display scaling, Orion browser, and window ergonomics
    └── audio-routing-macos.md        # ScreenCaptureKit zero-driver audio & multitrack guide
```

---

## 3. The Eight Production Scenes

The scene collection (`ugtastic-sound-above.json`) provides eight dedicated production scenes:

| Scene Name | Primary Visual Focus | Audio Routing | Intended Purpose |
| :--- | :--- | :--- | :--- |
| **01. Starting Soon** | Ambient slate background, pre-stream title, episode card, animated pulse | Off / Bumper | Pre-stream countdown and audience arrival |
| **02. Monologue / Full Camera** | Host camera full screen with Lower-Third overlay | Mic/Aux only | Opening thesis, historical context, and concluding takeaways |
| **03. Reaction - Video Focus** | Orion browser window (80% canvas) + Host Camera PiP (lower right) + Now Watching HUD | Mic/Aux + Orion Video Audio | Watching UGtastic interviews, pausing, and commenting |
| **04. Split Screen - Video & Research** | Side-by-side: Orion video on left, `just3ws.localhost` on right, centered host cam | Mic/Aux + Orion Video Audio | Comparing interview moments directly against transcripts and timeline |
| **05. Workbench - Code & Terminal** | Full terminal/editor window capture + Host Camera PiP (lower right) | Mic/Aux | Live code analysis, git archaeology, and zdots tool demos |
| **06. Guest & Co-Host Discussion** | Two-up side-by-side camera boxes + shared screen inset | Mic/Aux + Guest Audio | Joint retrospectives with Chicago tech veterans |
| **07. Intermission / BRB** | Clean pause card: "Holding the Thread" with current topic | Muted | Stepping away from the workbench during long streams |
| **08. Outro & Next Stream** | Closing credits, quote card, and digital archive links | Mic/Aux | Wrapping up the broadcast and previewing the next episode |

---

## 4. Hardware Optimization for Apple Silicon M4 & macOS Golden Gate

This project is tailored specifically for macOS Golden Gate (Darwin 27) running on Apple Silicon (Apple M4, 10 cores, 16GB RAM):

- **Zero-CPU Video Encoding**: Utilizes `apple_h264` (Apple VT H264 Hardware Encoder), routing video compression directly to the Apple M4 media engine. The machine runs completely silent and cool without dropping frames.
- **True 1080p Unscaled Canvas**: Base canvas and output resolution are set to 1920x1080 at 60 fps. Eliminates downscaling blur, guaranteeing that terminal code, small font sizes, and browser text remain perfectly legible to viewers.
- **macOS Golden Gate Native Sound Capture**: Leverages Golden Gate's built-in ScreenCaptureKit and CoreAudio output capture architecture. Eliminates the need for legacy virtual audio drivers (BlackHole, Soundflower, Loopback) entirely:
  - **Isolated App Audio**: Captures Orion video sound directly via `sck_audio_capture` without catching Slack dings or notification sounds.
  - **Desktop Audio**: Native `coreaudio_output_capture` routes system audio cleanly at 48,000 Hz.
- **Multitrack Master Recording**: Advanced recording mode (`RecTracks=15`) captures 4 separate synchronized audio tracks into high-quality hybrid MOV files:
  - **Track 1**: Stream composite mix (Host Mic + Orion Video Audio + Overlays)
  - **Track 2**: Host microphone isolated (Pristine speech for podcasting and Whisper transcripts)
  - **Track 3**: Orion video audio isolated (Reference interview audio)
  - **Track 4**: Guest / Discord / Zoom isolated (Remote co-host voice)

---

## 5. Live Stream Operator Runbook

Follow this step-by-step checklist before and during each stream:

### Step 1: Install or Sync Configuration
If running for the first time or updating scenes:
```bash
./obs/scripts/install-obs-config.sh
```

### Step 2: Cue the Target Episode
Select an episode from `obs/curation/sequence-manifest.json` (for example, Episode 1: Sergio Pereira):
```bash
./obs/scripts/update-overlay-state.sh --episode 1
```
All HTML overlays (`lower-third.html`, `now-watching.html`, `stream-starting.html`) update automatically via JSON polling within 2.5 seconds.

### Step 3: Run the Audio Diagnostic
Verify microphone permissions and audio device sample rates:
```bash
./obs/scripts/test-audio-routing.sh
```

### Step 4: Window Management on macOS
1. Open **Orion** browser and navigate to the cued UGtastic interview video (or local video archive file).
2. Open a secondary browser window pointing to `https://just3ws.localhost/timeline/community/` and `https://just3ws.localhost/interviews/` for instant lookup.
3. Open **Terminal** (Ghostty, iTerm2, or macOS Terminal) with font size set to at least 18pt.
4. Launch **OBS Studio**, select Profile: `The Sound Above` and Scene Collection: `The Sound Above - UGtastic Rewatch`.
5. Put on **headphones or IEMs** to prevent video audio from leaking into your microphone.

### Step 5: Going Live
1. Select Scene: **01. Starting Soon**.
2. Click **Start Streaming** and **Start Recording** in OBS.
3. After 3 to 5 minutes, transition cleanly to Scene: **02. Monologue / Full Camera** to introduce the historical era and context.
4. Transition to Scene: **03. Reaction - Video Focus** and press `Spacebar` in Orion to play the interview.
5. Pause at key inflection points to reflect, comment, or switch to Scene: **04. Split Screen** and Scene: **05. Workbench**.
6. When concluding, switch to Scene: **08. Outro & Next Stream** to share archive links and sign off.

---

## 6. Real-Time Overlay Overrides & Broadcast Archetypes

The overlay engine dynamically adapts across three distinct broadcast archetypes:

### Archetype 1: Oral History Rewatch ("The Sound Above")
```bash
# Cue Episode 1 from the sequence manifest
./obs/scripts/update-overlay-state.sh --rewatch --episode 1

# Manual override for a rewatch interview
./obs/scripts/update-overlay-state.sh --rewatch --guest "Uncle Bob Martin" --conference "SCMC 2011" --year "2011" --prompt "Professionalism vs Speed: The 2011 SCMC Keynote"
```

### Archetype 2: Personal Insights, Readings & Demos ("Errata")
```bash
# Book Reading or Close Study
./obs/scripts/update-overlay-state.sh --errata --mode reading --title "The Cat Ate My Source Code" --citation "The Pragmatic Programmer (1999)" --prompt "Provide options, don't make lame excuses."

# Systems Architecture Concept or Live Code Demo
./obs/scripts/update-overlay-state.sh --errata --mode demo --title "The Blink Test: Deterministic Verification" --citation "The Observable Control Plane" --prompt "Green, Red, Green again before any claim of success is accepted."

# Archival Memorabilia or Story
./obs/scripts/update-overlay-state.sh --errata --mode artifact --title "The 2008 Sears Tower Meeting Badges" --citation "Chicago Alt.NET Archive" --year "2008" --prompt "Physical tokens from the room where it started."

# Behind the Scenes Studio Tour & Broadcast Systems Engineering
./obs/scripts/update-overlay-state.sh --errata --mode bts --title "Inside The Control Plane: OBS & Golden Gate Audio" --citation "Broadcast Rig Architecture" --prompt "Hardware-isolated CoreAudio routing and low-latency streaming."
```

### Archetype 3: Invited Guest Conversations ("The Room")
```bash
# Cue a peer dialogue or community roundtable
./obs/scripts/update-overlay-state.sh --dialogue --guest "Ryan Gerry" --conference "SCMC Co-Founder" --title "17 Years of Sub-Second Feedback Loops" --prompt "How did suburban craftsmanship sustain continuous monthly meetings for seventeen years?"
```

You can also pass URL parameters directly in OBS browser source properties:
```
file:///Users/mike/github.com/just3ws/just3ws.github.io/obs/overlays/lower-third.html?type=errata&mode=reading&title=The+Pragmatic+Programmer&citation=Hunt+%26+Thomas
```

---

## 7. Companion Documentation & Playbooks

- **[Broadcast Operations Playbook](../docs/runbooks/broadcast-operations-playbook.md)**: Sequential pre-flight, live switching, and teardown runbook for all three broadcast archetypes.
- **[Curation Sequence Guide](curation/rewatch-curation-sequence.md)**: Full 37-episode roadmap across six movements.
- **[Reaction and Coding Setup](docs/reaction-and-coding-setup.md)**: Window scaling, Retina ergonomics, and privacy boundaries.
- **[macOS Audio Routing](docs/audio-routing-macos.md)**: ScreenCaptureKit audio setup, vocal processing, and multitrack recording.
- **[Broadcast CLI Manual (`broadcast.1`)](../man/man1/broadcast.1)**: UNIX manual page for `bin/broadcast`.
- **[OBS Livestream Manual (`obs-livestream.1`)](../man/man1/obs-livestream.1)**: UNIX manual page for OBS hardware contracts.

---

## 8. System Reading Order: Understanding How the Platform is Built

To understand how the broader CareerOS and just3ws system is constructed, read the repository documentation in this sequence:

### Layer 1: Core System Architecture, Platform Topology & Boundaries
1. **[CONTEXT.md](../CONTEXT.md)**: The foundational public-canon contract, private-context boundary (`$HOME/my`), 3-tier content classification (Organic Writing, Forensic Transcripts, Quarantined AI Syntheses), and the installed localhost runtime contract (`https://just3ws.localhost/`).
2. **[AGENTS.md](../AGENTS.md)**: System identity across the two-repo CareerOS platform (`just3ws.github.io` and `wwworkremote.localhost`), `zdots` message bus registration (`agent-just3ws`), Persona Review Council, and registered skills.
3. **[docs/style-guide-and-canonical-naming.md](../docs/style-guide-and-canonical-naming.md)**: Permanent naming standards, disambiguation (Panoramic View vs. PVL vs. Pavel), Chicago community lineages, and the strict zero em-dash writing rule.
4. **[docs/inter-tool-communication-protocol.md](../docs/inter-tool-communication-protocol.md)**: Bus messaging channels (`job-leads`, `general`), peer synchronization mutex (`CareerOS::PeerMutex`), and inter-agent coordination.

### Layer 2: Positioning Strategy, Career Canon & Datalake Query Engine
5. **[CODEX.md](../CODEX.md)**: Senior career coach and hiring-loop evaluation contract: Mike Hall's canonical professional identity as **Staff Software Engineer**, title-to-scale calibration, and anti-inflation principles.
6. **[docs/career-strategy-audhd-principal-engineering.md](../docs/career-strategy-audhd-principal-engineering.md)**: AuDHD cognitive strategy guide: translating hyperfocus into 4D System Cartography, pattern recognition into runtime edge-case handling, and async documentation discipline.
7. **[docs/career-datalake-and-mcp-guide.md](../docs/career-datalake-and-mcp-guide.md)**: Full-corpus query engine over 29 positions, 136 technologies with active year spans, 156 articles, 211 interview transcripts, and 402 knowledge graph nodes via CLI (`bin/query_career_datalake.rb`) and MCP server.
8. **[docs/resume-narrative-and-storytelling-guide.md](../docs/resume-narrative-and-storytelling-guide.md)** and **[docs/resume-quality-and-ats-benchmarking-guide.md](../docs/resume-quality-and-ats-benchmarking-guide.md)**: Structural storytelling across 5 resume archetypes, plain-text ATS parseability simulation, and automated keyword match gating.

### Layer 3: Engineering Automation, Operations & Broadcasting
9. **[docs/tooling-user-guide.md](../docs/tooling-user-guide.md)**: Operational guide for executable CLI tooling: Executive Brief Generator (`bin/generate_executive_brief.rb`), Job Lead Evaluator (`bin/evaluate_job_lead.rb`), and automated PDF resume pipelines.
10. **[docs/runbooks/broadcast-operations-playbook.md](../docs/runbooks/broadcast-operations-playbook.md)**: Operations runbook for live video broadcasting across all three archetypes (Rewatch, Errata, Dialogue), pre-flight checks, 4-track CoreAudio capture, and post-stream Whisper transcription.
11. **[man/man1/broadcast.1](../man/man1/broadcast.1)** and **[man/man1/obs-livestream.1](../man/man1/obs-livestream.1)**: UNIX man page references for terminal commands, CLI options, and hardware contracts.

---
name: oral-history-broadcaster
description: Directs, validates, cues, and audits live video broadcasts across all three archetypes (The Sound Above oral history rewatches, Errata solo readings and demos, and The Room invited guest dialogues).
---

# Oral History Broadcaster Skill

Use this skill when preparing, curating, validating, or directing livestreams for Mike Hall (Software Craftsmanship Signatory #106).
This covers the entire tri-archetype broadcast architecture:
1. **The Sound Above**: Forensic oral history rewatch series across 31 curated episodes.
2. **Errata**: Solo broadcasts including book readings, concept breakdowns, live terminal workbench demonstrations, oral memoirs, and physical memorabilia showcases.
3. **The Room**: Invited peer dialogues, collegial pair programming, and community roundtables.

---

## 🎯 Core Responsibilities

1. **Unified Broadcast Orchestration (`bin/broadcast`)**:
   - Inspect active live state and overlay HUD configuration:
     `bin/broadcast --status`
   - List complete 31-episode sequence and pre-curated Errata entries:
     `bin/broadcast --list`
   - Cue oral history rewatches (Episodes 1 to 31):
     `bin/broadcast --rewatch <N>`
   - Cue pre-curated or custom Errata solo broadcasts:
     `bin/broadcast --cue <ID>`
     `bin/broadcast --errata --mode <reading|concept|demo|story|artifact> --title <TITLE> --citation <CITATION> --prompt <PROMPT>`
   - Cue invited peer dialogues and roundtables:
     `bin/broadcast --dialogue --guest <NAME> --subtitle <ROLE> --title <TOPIC> --prompt <QUESTION>`

2. **Automated Production & Contract Verification**:
   - Run automated contract assertions before any broadcast:
     `bin/broadcast --validate` or `bundle exec rake validate:obs`
   - Verify all 8 production scenes exist and match the contract in `obs/scenes/ugtastic-sound-above.json`:
     `01. Starting Soon`, `02. Monologue / Full Camera`, `03. Reaction - Video Focus`, `04. Split Screen - Video & Research`, `05. Workbench - Code & Terminal`, `06. Guest & Co-Host Discussion`, `07. Intermission / BRB`, `08. Outro & Next Stream`.
   - Verify hardware encoding settings: Apple Silicon VideoToolbox (`com.apple.videotoolbox.videoencoder.ave.avc`), 1080p60 unscaled canvas, and 48 kHz CoreAudio clock.

3. **Audio Routing Verification (macOS Golden Gate)**:
   - Audit macOS CoreAudio and ScreenCaptureKit permissions:
     `./obs/scripts/test-audio-routing.sh`
   - Verify 4-track isolated master recording architecture:
     Track 1: Composite Stream Mix.
     Track 2: Host Microphone Isolated (with RNNoise suppression and compressor).
     Track 3: Browser Video Audio Isolated (`sck_audio_capture` from Orion).
     Track 4: Remote Guest Audio Isolated.

4. **Thematic YouTube Playlist & Thumbnail Automation**:
   - Synchronize and curate the official public rewatch playlist across all 31 episodes:
     `bundle exec ruby bin/sync_youtube_rewatch_playlist.rb --apply`
   - Render coordinated 1080p master and 720p YouTube thumbnails from sequence manifest:
     `ruby bin/generate_rewatch_thumbnail.rb --episode <N>`
   - Manage scheduled live stream broadcasts via API:
     `ruby bin/manage_youtube_broadcasts.rb --episode <N>`

5. **Narrative & Historical Framing**:
   - **For Rewatches**: Frame the Chicago room (2005 to 2015). Who inspired the interviewee before the keynote? Connect craftsmanship disciplines to modern AI system orchestration.
   - **For Errata**: Ground concepts in primary literature (Beck, Hickey, Hunt & Thomas, Hoover). Demonstrate live on the terminal workbench with sub-second feedback loops.
   - **For Dialogues**: Structure peer inquiry around shared craftsmanship lineage, deliberate practice, and modern engineering challenges.

---

## 🛑 Guardrails & Boundaries

- **Zero Em Dashes**: Never use em dashes (`—`), double hyphens (`--`), or spaced hyphens (` - `) in prose, overlays, or metadata. Use colons, commas, semicolons, or distinct sentences instead.
- **Zero Secrets**: Never commit or broadcast stream keys, OAuth refresh tokens, or private credentials.
- **True Title Compliance**: Maintain **Staff Software Engineer** as Mike Hall's canonical title.
- **Hardware Portability**: Ensure all paths in OBS configurations use dynamic project roots rather than static assumptions.

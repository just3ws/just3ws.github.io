---
name: oral-history-broadcaster
aliases:
  - technical-rewatch-broadcaster
description: Directs, validates, cues, and audits live video broadcasts across all three archetypes (The Sound Above interview rewatches, Errata solo readings and demos, and The Room invited peer dialogues).
---

# Technical Rewatch & Broadcast Director Skill

Use this skill when preparing, curating, validating, or directing livestreams for Mike Hall (Staff Software Engineer, UGtastic Creator, and SCMC Co-Founder).
This covers the entire tri-archetype broadcast architecture:
1. **The Sound Above**: UGtastic interview rewatch series across 37 numbered curriculum broadcasts (35 curated practitioner interviews plus 2 closing codas: Coda 1 Host Demonstration and Coda 2 Community Roundtable).
2. **Errata**: Solo broadcasts including the series pilot ("The Mirage of Competence: AI Slop & Domain Boundaries", Episode 00), book readings, concept breakdowns, live terminal workbench demonstrations, physical memorabilia showcases, and behind the scenes engineering walkthroughs.
3. **The Room**: Invited peer dialogues, collegial pair programming, and community roundtables.

---

## 🎯 Core Responsibilities

1. **Episode Workbench & Semantic Dossier Management (`bin/episode_workbench.rb`)**:
   - Inspect episode dossiers and narrative anatomy:
     `bin/episode_workbench.rb show <N>`
   - List the complete 37-episode curriculum and pilot:
     `bin/episode_workbench.rb list`
   - Compile modular 6-act teleprompter scripts with host recollections:
     `bin/episode_workbench.rb compile <N> [--markdown|--json]`
   - Workshop episode framing with custom prompts:
     `bin/episode_workbench.rb workshop <N> --prompt "..."`

2. **Staging & Pre-Broadcast Verification Harness (`bin/stage_episode_workflow.rb`)**:
   - Non-destructively exercise and verify the complete publishing pipeline before going live:
     `bin/stage_episode_workflow.rb <N>`
     `bin/stage_episode_workflow.rb --all`
   - Verifies 7 discrete pipeline gates:
     * Dossier schema and zero em-dash compliance
     * YouTube title length (under 100 chars) and description character budget
     * Transcript and WebVTT caption parity
     * OBS overlay state and scene cues
     * 6-act teleprompter compilation with marginalia
     * YouTube Data API quota safety
     * Patreon patron credit formatting

3. **Textream Teleprompter Integration (`bin/generate_sound_above_teleprompter.rb`)**:
   - Compile native Textream JSON documents (`obs/teleprompter/episode-XX.textream`) for on-device speech recognition word tracking and prompter glass mirroring in `/Applications/Textream.app`:
     `bin/pipeline media textream <N> --open`
     `bin/pipeline media textream --all`
   - Generate instant speech-tracking deep links:
     `bin/pipeline media textream <N> -u`
   - Integrated with the YouTube Operations Cockpit teleprompter studio (`https://www.just3ws.localhost/youtube/dashboard/#tab-teleprompter`) with direct 1-click launch and `.textream` export.

4. **Patreon Archive Integration & Patron Credits (`bin/patreon_pipeline.rb`)**:
   - Track monthly recurring compute funding for Whisper and AI model tokens:
     `bin/patreon_pipeline.rb status`
   - Format closing credit acknowledgments for Act 6 teleprompter and YouTube descriptions:
     `bin/patreon_pipeline.rb credits`
   - Sync live members from Patreon API v2:
     `bin/patreon_pipeline.rb sync`

5. **Unified Broadcast Orchestration (`bin/broadcast`)**:
   - Inspect active live state and overlay HUD configuration:
     `bin/broadcast --status`
   - List complete sequence and Errata entries:
     `bin/broadcast --list`
   - Cue technical interview rewatches (Episodes 1 to 37):
     `bin/broadcast --rewatch <N>`
   - Cue pre-curated or custom Errata solo broadcasts:
     `bin/broadcast --cue <ID>`
   - Cue invited peer dialogues and roundtables:
     `bin/broadcast --dialogue --guest <NAME> --subtitle <ROLE> --title <TOPIC> --prompt <QUESTION>`

5. **Automated Production & Contract Verification**:
   - Run automated contract assertions before any broadcast:
     `bin/broadcast --validate` or `bundle exec rake validate:obs`
   - Verify all 8 production scenes exist and match the contract in `obs/scenes/ugtastic-sound-above.json`:
     `01. Starting Soon`, `02. Monologue / Full Camera`, `03. Reaction - Video Focus`, `04. Split Screen - Video & Research`, `05. Workbench - Code & Terminal`, `06. Guest & Co-Host Discussion`, `07. Intermission / BRB`, `08. Outro & Next Stream`.
   - Verify hardware encoding settings: Apple Silicon VideoToolbox (`com.apple.videotoolbox.videoencoder.ave.avc`), 1080p60 unscaled canvas, and 48 kHz CoreAudio clock.

6. **Audio Routing Verification (macOS Golden Gate)**:
   - Audit macOS CoreAudio and ScreenCaptureKit permissions:
     `./obs/scripts/test-audio-routing.sh`
   - Verify 4-track isolated master recording architecture:
     Track 1: Composite Stream Mix.
     Track 2: Host Microphone Isolated (with RNNoise suppression and compressor).
     Track 3: Browser Video Audio Isolated (`sck_audio_capture` from Orion).
     Track 4: Remote Guest Audio Isolated.

7. **Narrative & Historical Framing**:
   - **For Rewatches**: Frame the Chicago room (2005 to 2015). Who inspired the interviewee before the keynote? Connect craftsmanship disciplines to modern AI system orchestration.
   - **For Errata**: Ground concepts in primary literature (Beck, Hickey, Hunt & Thomas, Hoover). Demonstrate live on the terminal workbench with sub-second feedback loops.
   - **For Dialogues**: Structure peer inquiry around shared craftsmanship lineage, deliberate practice, and modern engineering challenges.

---

## 🛑 Guardrails & Boundaries

- **Zero Em Dashes**: Never use em dashes (`\u2014`), double hyphens (`--`), or spaced hyphens (` - `) in prose, overlays, or metadata. Use colons, commas, semicolons, or distinct sentences instead.
- **Zero Secrets**: Never commit or broadcast stream keys, OAuth refresh tokens, or private credentials.
- **True Title Compliance**: Maintain **Staff Software Engineer** as Mike Hall's canonical title.
- **Hardware Portability**: Ensure all paths in OBS configurations use dynamic project roots rather than static assumptions.
- **Media Ingestion & Publishing**: Refer to `.agents/skills/media-pipeline-operator/SKILL.md` for the zero-disk-waste cloud intake pipeline, Concurrency Lock, FIFO queues, and YouTube publication details.

---
name: the-sound-above-producer
description: Prepares, templates, verifies, and closes out weekly episodes of The Sound Above oral-history rewatch series and its companion Errata series from canonical episode YAML dossiers, diarized transcripts, era-specific Wayback Machine captures, Textream scripts, 3-Pane Broadcast Workbenches, and media-pipeline publication metadata. Use when preparing a new Sound Above episode (e.g., Episode 2), preparing an unscripted Errata deep dive, generating episode surfaces/bookmarks, polishing Textream spoken scripts, or closing out a recorded episode in media-pipeline.
---

# The Sound Above Producer

Standardizes weekly production of **The Sound Above** (`@just3ws-mike`, playlist `PLVcmLmfz2uyA`) and its companion **Errata** series (playlist `PLKPAHha6I990`) around a single data-driven source of truth (`_data/episodes/episode-NN.yml` in `just3ws.github.io`) so every episode follows the proven Episode 1 blueprint with minimal friction.

## Modular Documentation Suite

This skill is organized into four focused guides:
1. **[SCHEMA_SPECIFICATION.md](SCHEMA_SPECIFICATION.md)**: Exhaustive technical schema for `_data/episodes/episode-NN.yml`, validation contracts, and field mappings across Jekyll surfaces, OBS overlays, and Textream files.
2. **[RESEARCH_GUIDE.md](RESEARCH_GUIDE.md)**: Deep research methodology for oral-history rewatches (transcript forensics, ear-checking phonetic mishearings, Wayback CDX HTTP 200 capture recovery, git commit forensics, and framing the 2026 AI-era echo).
3. **[SCRIPTING_PLAYBOOK.md](SCRIPTING_PLAYBOOK.md)**: Spoken voice guidelines for Mike Hall (first-person singular, sibilant cluster smoothing, 2-3 sentence breath blocks, `showParagraphDividers = 1`), 6-act broadcast arc, and unscripted Errata prompt formulation.
4. **[REFERENCE.md](REFERENCE.md)**: Quick CLI cheat sheet for preparation, validation, and media-pipeline closeout.

---

## Dual-Track Cadence Architecture

To establish a calm, confident, and sustainable weekly production cadence, each episode is produced across two complementary tracks:

1. **Track A: The Sound Above (Primary Episode):**
   - **Tone & Pacing:** Disciplined, forensic, narrative arc (~25-35 minutes).
   - **Scripting:** 6 scripted acts in Textream (`obs/teleprompter/`) with smooth sibilants, first-person singular voice, and 2-3 sentence breath blocks.
   - **Studio Setup:** OBS Scene switching (`01. Starting Soon` -> `02. Monologue` -> `03. Reaction` / `04. Split Screen` -> `02. Monologue` -> `08. Outro`) using the locked 910x1080 split-screen geometry.
   - **Workbench:** 3-Pane Live Broadcast Workbench (`/series/the-sound-above/episode-NN/workbench/`) driving the canonical interview player via `BroadcastChannel('just3ws-interview-sync')`.
   - **Ingestion Target:** `the-sound-above` (ingestion root: `~/ai/media-pipeline/just3ws-mike/the-sound-above/pending/`).
   - **YouTube Playlist:** `PLVcmLmfz2uyA` (`The Sound Above`), public post-review.

2. **Track B: The Sound Above: Errata (Companion Episode):**
   - **Tone & Pacing:** Relaxed, unscripted, freeform practitioner deep dive (~15-45 minutes).
   - **Scripting:** Zero teleprompter script. Driven by unordered discussion prompts in `errata.unscripted_prompts` and demonstrations in `errata.demonstrations`.
   - **Focus Areas:** Deep dive into recovered 2007-2015 historical links, legacy git repositories (`twatio.com`, `just3ws/ccs`, `fluffle`), audio DSP / restoration demonstrations (`dehum`), and transcript ear-check forensics (verifying phonetic mishearings against primary sources).
   - **Studio Setup:** OBS Scene `02. Monologue` or Display Capture, showing browser tabs, terminals, and audio tools.
   - **Ingestion Target:** `errata` (ingestion root: `~/ai/media-pipeline/just3ws-mike/errata/pending/`).
   - **YouTube Playlist:** `PLKPAHha6I990` (`The Sound Above: Errata`), unlisted by default as a companion artifact.
   - **Non-Negotiable Convergence:** Never leave an Errata video detached. Always link back to the primary episode page (`/series/the-sound-above/episode-NN/`) and its canonical hosted interview.

---

## Non-Negotiable Principles

1. **Canonical Interview Convergence:** All video rewatches and chapter jumps converge on the hosted interview page (`/interviews/<slug>/`) with its chapters and diarized transcript. Never add detached raw YouTube iframes or duplicate `youtube.com/watch` bookmarks for Episodes 1-35.
2. **Primary-Source & Era-Specific Archival Grounding:** Pin every external historical link to an exact HTTP 200 Wayback Machine capture (`https://web.archive.org/web/<YYYYMMDDHHMMSS>/...`), never wildcard `*` URLs. Cross-check Whisper transcripts against primary 2007-2015 sources (e.g., `chicagoalt.net`, git logs, Manifesto ledger) to catch phonetic name mishearings before recording.
3. **Mike's Authentic Spoken Voice (Textream):**
   - Strictly first-person singular (`I` / `my`) for Mike's own actions; reserve `we`/`our` for genuine plurals.
   - Smooth out sibilant clusters (`s`/`z`/`sh`/`ts`/`sts`/`sks` and `s`-`th` collisions) while keeping proper nouns exact.
   - Format every scripted act with double-newline (`\n\n`) 2-3 sentence breath blocks and `showParagraphDividers = 1`.
   - Zero em dashes (`\u2014`) anywhere.
4. **Broadcast Arc:** `01. Starting Soon` (voiceover hook + series premise) -> `02. Monologue` (greeting + context) -> `03. Reaction` / `04. Split Screen` (open-ended unscripted rewatch driven by the 3-Pane Workbench via `BroadcastChannel('just3ws-interview-sync')`) -> `02. Monologue` (synthesis) -> `08. Outro` (credits + next episode tease).

---

## Weekly 5-Stage Production Workflow

1. **Stage 1: Deep Research & Transcript Forensics:**
   - Audit `_data/transcripts/<slug>.yml`, recover era-specific IA/WBM captures via CDX, cross-check git/Manifesto receipts, and populate `_data/episodes/episode-NN.yml` with structured `rewatch_cues`, `archival_receipts`, `research_attachments`, and `errata` prompts (see [RESEARCH_GUIDE.md](RESEARCH_GUIDE.md)).
2. **Stage 2: Spoken Script & Textream Prep (Track A):**
   - Draft 6 acts (`Acts 1-3` intro and archival receipts, `Act 4` unscripted rewatch cue summary, `Acts 5-6` synthesis & outro).
   - Apply spoken voice and sibilant polish, and compile `obs/teleprompter/episode-NN.textream` (see [SCRIPTING_PLAYBOOK.md](SCRIPTING_PLAYBOOK.md)).
3. **Stage 3: Rendered Surfaces & Bookmarks:**
   - Run `ruby bin/prepare_sound_above_episode.rb <NN>` to validate the dossier contract, generate Textream files, build Jekyll surfaces (`/series/the-sound-above/episode-NN/` and `/workbench/`), sync localhost webroot, and install Chromium bookmarks (`bin/episode_bookmarks.rb --install`).
4. **Stage 4: Studio Pre-Flight & Recording:**
   - Track A: Verify OBS `910x1080` Split Screen, Logitech C920 Background Replacement (not Portrait), `The Sound Above - Staging` profile, Textream pinned to `XV275K P3` (`fixedDisplay`), and `overlay-state.json` cued to Episode NN.
   - Track B: Verify OBS Monologue / Display Capture, open the Workbench Errata card (`data-scene="errata"`), and record unscripted deep dive.
5. **Stage 5: Post-Recording Closeout (`media-pipeline`):**
   - Move Track A master `.mov` into `~/ai/media-pipeline/just3ws-mike/the-sound-above/pending/`.
   - Move Track B master `.mov` into `~/ai/media-pipeline/just3ws-mike/errata/pending/`.
   - Run `bin/mp scan` to ingest both recordings.
   - Extract verified chapter timestamps from `MediaAsset#transcript_vtt`.
   - Curate YouTube title/description/tags/social copy via `media-metadata-curator` rules while preserving editorial holds.
   - Review and sign off in `https://media-pipeline.localhost/media_assets/<id>`.

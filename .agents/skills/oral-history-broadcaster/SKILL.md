---
name: oral-history-broadcaster
description: Directs, validates, cues, and audits live oral history rewatch broadcasts, OBS Studio production scene contracts, dynamic HTML overlays, and 'Sound Above' commentary arcs across the UGtastic and Chicago Software Craftsmanship corpus.
---

# Oral History Broadcaster Skill

Use this skill when preparing, curating, validating, or directing livestreams for "The Sound Above: UGtastic Oral History Rewatch Series" and related technical coding streams.

---

## 🎯 Core Responsibilities

1. **Production Pre-Flight & Contract Verification**:
   - Run automated contract assertions before any broadcast:
     `bundle exec rake validate:obs`
   - Verify that all 8 production scenes exist and match the contract in `obs/scenes/ugtastic-sound-above.json`.
   - Verify hardware encoding settings (Apple Silicon VideoToolbox `com.apple.videotoolbox.videoencoder.ave.avc`, 1080p60 unscaled canvas, 48 kHz CoreAudio clock).

2. **Episode Curation & Live State Synchronization**:
   - Cue episodes from `obs/curation/sequence-manifest.json`:
     `./obs/scripts/update-overlay-state.sh --episode <N>`
   - Verify that `obs/overlays/overlay-state.json` updates and broadcasts cleanly to all browser source HUDs (`lower-third.html`, `now-watching.html`, `stream-starting.html`).

3. **Audio Routing Verification (macOS Golden Gate)**:
   - Audit macOS CoreAudio and ScreenCaptureKit permissions:
     `./obs/scripts/test-audio-routing.sh`
   - Ensure Orion application audio is isolated via `sck_audio_capture` on Track 3.
   - Ensure host microphone vocal processing (RNNoise suppression, compressor, limiter) is active on Track 2.

4. **Thematic YouTube Playlist & Thumbnail Automation**:
   - Synchronize and curate the official public rewatch playlist:
     `bundle exec ruby bin/sync_youtube_rewatch_playlist.rb --apply`
   - Render coordinated 1080p master and 720p YouTube thumbnails from sequence manifest:
     `ruby bin/generate_rewatch_thumbnail.rb --episode <N>`

5. **"The Sound Above" Narrative Direction**:
   - Frame the historical room: What was happening in Chicago (2005–2015)?
   - Probe earlier inspirations: Who inspired the interviewee before they wrote the book or gave the keynote?
   - Connect the past to the AI era: Contrast early testing and craftsmanship disciplines with modern multi-agent system orchestration.
   - Anchor claims in primary transcripts from `_data/interviews.yml` and `lake/witc/`.

---

## 🛑 Guardrails & Boundaries

- **Zero Em Dashes**: Never use em dashes (`—`), double hyphens (`--`), or spaced hyphens (` - `) in prose, overlays, or metadata. Use colons, commas, semicolons, or separate sentences instead.
- **Zero Secrets**: Never commit or broadcast stream keys, OAuth refresh tokens, or private credentials.
- **True Title Compliance**: Maintain **Staff Software Engineer** as Mike Hall's canonical title.
- **Hardware Portability**: Ensure all paths in OBS configurations use dynamic project roots rather than static assumptions.

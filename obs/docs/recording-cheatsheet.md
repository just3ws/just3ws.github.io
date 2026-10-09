# Live Recording Cheatsheet & Quick Reference Guide

A high-density operational reference for live broadcasting and local recording with OBS Studio, ScreenCaptureKit, and interactive HTML overlays on macOS.

---

## 1. Quick-Start Command Sequence (Terminal)

From the project root (`~/github.com/just3ws/just3ws.github.io`):

```bash
# 1. Run automated pre-flight validation (contract + audio check)
bundle exec rake validate:obs
./obs/scripts/test-audio-routing.sh

# 2. Sync project configuration to OBS Studio (if repo updated)
./obs/scripts/install-obs-config.sh

# 3. Cue the broadcast archetype & content:
# Archetype 1: Rewatch ("The Sound Above")
bin/broadcast --episode 1

# Archetype 2: Errata ("Solo Broadcast")
bin/broadcast --errata --mode concept --title "The Blink Test"

# Archetype 3: Dialogue ("The Room")
bin/broadcast --dialogue --guest "Corey Haines" --topic "Simple Design"

# 4. Open OBS Studio & launch iTerm2 profile
open -a OBS
# In iTerm2: Profile -> "The Sound Above"
```

---

## 2. OBS Production Scenes (At A Glance)

| # | Scene Name | Key Sources Active | Primary Use Case |
|---|------------|--------------------|------------------|
| **01** | `01. Starting Soon` | Dark Slate, Overlay: Starting Screen | Pre-stream standby (play intro countdown) |
| **02** | `02. Monologue / Full Camera` | Host Camera, Camera Background, Overlay: Lower Third | Opening framing, historical context, monologue |
| **03** | `03. Reaction - Video Focus` | Video Window (Orion), Video Audio (Orion), Host Camera Inset, Overlay: Now Watching HUD, Overlay: Lower Third | Video reaction & commentary |
| **04** | `04. Split Screen - Video & Research` | Video Window (Orion), Research Browser (`just3ws.localhost`), Host Camera Inset, Overlay: Lower Third | Deep forensic analysis, transcripts, dossier |
| **05** | `05. Workbench - Code & Terminal` | Workbench Terminal (`iTerm2`), Host Camera Inset, Overlay: Lower Third (Minimal HUD) | Live coding, git archaeology, CLI demos |
| **06** | `06. Guest & Co-Host Discussion` | Host Camera, Guest Window, Overlay: Lower Third | Remote peer dialogues, paired discussions |
| **07** | `07. Intermission / BRB` | Dark Slate, Overlay: BRB Screen | Bio breaks, mid-stream pauses |
| **08** | `08. Outro & Next Stream` | Dark Slate, Overlay: Outro Screen | Closing credits, next episode preview |

---

## 3. Window & Desktop Ergonomics (1920x1080 1:1 Canvas)

* **Canvas & Output**: Locked to **1920x1080 @ 60fps** (Apple Silicon VideoToolbox H264 hardware encoding).
* **Headphones / IEMs**: **Mandatory**. Prevents room echo into the open microphone.
* **Orion Browser (Video Player)**:
  * Open target interview (YouTube / Vimeo / local file).
  * Press `Cmd+Option+T` to toggle the tab bar off for a clean capture.
  * In Scene 03/04: Click `Video Window (Orion)` in Sources to ensure window binding.
* **Research Browser (`just3ws.localhost`)**:
  * Open `/timeline/community/` or the speaker's dossier page `/interviews/people/<slug>/`.
  * In Scene 04: Click `Research Window` to confirm window target.
* **Terminal (`iTerm2`)**:
  * Use the dynamic profile: **The Sound Above** (font size: 18pt+, high-contrast theme).
  * Never display `.env`, API keys, or personal secrets on stream.

---

## 4. Overlay Behavior & Troubleshooting Cheatsheet

### Lower Third HUD (`lower-third.html`)
* **Location**: Bottom-left corner (Scene 02, 03, 04, 06) or top status pill (Scene 05 Minimal mode).
* **Auto-Hide**: Fades out automatically after **10 to 12 seconds** to keep screen unobscured.
* **How to Refresh / Bring Back Lower Third**:
  * Option A: In OBS Sources list, select `Overlay: Lower Third` -> click **Refresh cache of current page**.
  * Option B: In terminal, run `bin/broadcast --episode <N>` (re-triggers state update).
  * Option C (Persistent Display): If you want it visible permanently during testing, append `?autohide=0` in the Browser Source URL properties in OBS.
* **Why Scene 02 Only Has Lower Third**:
  * Monologue/Full Camera is intentionally uncluttered: it only renders the lower third, whereas Scene 03 adds the `Now Watching HUD` card in the upper-right corner.

---

## 5. Audio Routing & Multi-Track Isolation

Native macOS Golden Gate routing:
* **Track 1**: Full Program Composite (Master mix for live stream / recording playback).
* **Track 2**: Isolated Host Microphone (`AuxAudioDevice1` with RNNoise + Compressor + Limiter).
* **Track 3**: Isolated Interview Video Audio (`sck_audio_capture` tapping Orion directly).
* **Track 4**: Isolated Guest / Communications Audio (Zoom / Discord / Teams).

> [!TIP]
> Pausing the interview in Orion immediately silences Track 3 via spacebar control.
> System notification alerts and Slack chimes are never routed into Orion audio capture.

---

## 6. Pre-Flight Run Checklist (T-5 Minutes)

1. [ ] **Headphones plugged in** and default audio output selected.
2. [ ] **Mic check**: Speak into mic; verify green-to-yellow level bounce on `Mic/Aux` (~-12 dB to -6 dB).
3. [ ] **Video check**: Play a test second in Orion; verify bounce on `Video Application Audio (Orion)` meter.
4. [ ] **Episode cued**: `bin/broadcast --episode <N>` executed; check interviewee name in OBS preview.
5. [ ] **Window capture attached**: Verify Orion in Scene 03 and iTerm2 in Scene 05.
6. [ ] **Start in Scene 01 or 02**: Click Scene `01. Starting Soon` or `02. Monologue`.
7. [ ] **Hit "Start Recording"** (or "Start Streaming").

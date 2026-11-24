# Studio Robustness, Named Profiles & Modular Recording Plan
## The Sound Above: Oral History & Technical Rewatch Series

This document provides a durable, pickupable specification for standardizing the studio recording environment, eliminating window and audio capture drift, and implementing a modular 3-take recording workflow for **The Sound Above** series (commencing with **Episode 01: Sergio Pereira and Chicago Alt.NET**).

---

## 1. Foundational Philosophy: What Was Our "Sound Above"?

The series title is grounded in the critical concept coined by **Marcus Parks** on *No Dogs in Space* during the retrospective on Krautrock pioneers Can, later codified into written music criticism by **Abigail Devoe** (*Vinyl Monday*):

> **"The Sound Above"** describes art, ideas, or engineering that deliberately exist **one tier higher than an audience's current level of comprehension, comfort, and structural expectation.**

In revisiting the 218-interview UGtastic archive from fifteen years ago, the central question is forensic: **What was inspiring us? What was our "sound above" in that 2008 to 2012 era?**

1. **The 2008 Enterprise Baseline (Comfortable Default)**:
   - Microsoft ASP.NET WebForms drag-and-drop visual designers, wizards hiding HTTP request-response cycles, and stored procedures holding business logic.
   - Seductive, vendor-sanctioned, and frictionless to produce, but suffocating and un-testable to maintain.
2. **Our "Sound Above"**:
   - Small rooms in the Sears Tower (Chicago Alt.NET), Follett in McHenry (Software Craftsmanship McHenry County), and the Swissotel (SCNA) reaching for practices that sounded strict, foreign, and jarring to enterprise shops:
     - **Test-Driven Development (TDD)**: Writing the test before the code (like Jaki Liebezeit's motorik drum pulse on *Tago Mago*, relentless discipline that unlocks structural freedom).
     - **Polyglot & Cross-Platform Craft**: .NET developers writing Ruby on Rails, Haml, and Sass for Chicago Code Camp (`just3ws/ccs`), porting NHaml, and adopting open-source tooling.
     - **Inversion of Control & Domain-Driven Design**: Decoupling domain logic from database tables and UI controls.
     - **Vulnerable Peer Formats**: Four-chair fishbowls (March 12, 2009 DDD & db4o fishbowl), pairing, coding dojos, and katas.
3. **The 2026 AI Era Echo**:
   - Today's comfortable default is instant LLM boilerplate, synthetic code generation, and frictionless video summaries.
   - The 2026 "sound above" is sitting with raw 15-year-old Photo Booth tapes, unvarnished diarized transcripts, and primary git forensics. Insisting on empirical verification over synthetic generation.

---

## 2. Technical Friction & Root Causes in Studio Recording

1. **Browser Audio Drops in OBS**:
   - macOS ScreenCaptureKit application audio (`sck_audio_capture`) hooks to the running Mach process of Chromium (`org.chromium.Chromium`).
   - If Chromium restarts while OBS is open, the audio hook can disconnect.
   - macOS power management throttles WebAudio and background tabs when the browser loses window focus.
2. **OBS Window Capture Drift**:
   - OBS `window_capture` matches by application name (`owner_name`) and window title.
   - If multiple Chromium or terminal windows are open, OBS binds to the wrong window.
   - The repository's OBS scene collection (`obs/scenes/ugtastic-sound-above.json`) still references `iTerm2` for the Workbench Terminal rather than Ghostty.
3. **Continuous 45-Minute Take Fatigue**:
   - Attempting a continuous live take where you nail a 2-minute scripted intro, conduct a 30-minute forensic rewatch, and deliver a clean outro in one uninterrupted take introduces immense psychological friction. A stumble on minute 42 risks invalidating the entire recording.

---

## 3. The Modular 3-Take Recording Workflow

Instead of an unbroken marathon, each episode is recorded across three independent, calm stages and stitched losslessly:

```
+-----------------------------------------------------------------------------------+
|                        MODULAR 3-TAKE PRODUCTION WORKFLOW                         |
+-----------------------------------------------------------------------------------+
|                                                                                   |
|  [ Take 1: Intro ]        [ Take 2: Rewatch & Workbench ]     [ Take 3: Outro ]   |
|  - Acts 1-3 (~2-3 mins)   - Act 4 (~25-35 mins)               - Acts 5-6 (~2 mins)|
|  - Teleprompter-driven    - Reaction / 3-Pane Cockpit         - Teleprompter / HUD|
|  - Repeat take if needed  - Natural pauses & commentary       - Clean sign-off    |
|         |                               |                            |            |
|         +-------------------------------+----------------------------+            |
|                                         |                                         |
|                                         v                                         |
|                 [ bin/assemble_sound_above_episode.rb <NN> ]                      |
|                                         |                                         |
|                     Lossless Stream Copy (ffmpeg -c copy)                         |
|                     - Zero re-encoding, zero quality loss                         |
|                     - Executes in 2 to 4 seconds                                  |
|                     - Preserves 4 discrete multi-track audio channels             |
|                                         |                                         |
|                                         v                                         |
|     Final Master: ~/ai/media-pipeline/just3ws-mike/the-sound-above/pending/       |
|                   The_Sound_Above_Episode_NN_Master.mov                           |
+-----------------------------------------------------------------------------------+
```

### Technical Compatibility Guarantee
Because all takes are recorded in OBS Studio using the same hardware profile (`The Sound Above`):
- **Video**: 1920x1080, 60 fps, Apple VideoToolbox H.264, Rec. 709, yuv420p.
- **Audio**: 48,000 Hz, 320 kbps AAC across all 4 discrete tracks (Track 1 Program Mix, Track 2 Host Vocal Solo, Track 3 Browser Audio Solo).
- **Stream-Copy Concatenation**: `ffmpeg -f concat -safe 0 -c copy` joins the segments in 2 to 4 seconds with zero re-encoding, zero pixel degradation, and zero audio sync drift.

---

## 4. Dedicated Named Profiles Architecture

### A. Chromium Studio Profile
- **Isolated User Data Directory**: `~/Library/Application Support/Chromium-TheSoundAbove`
- **Isolation Guarantee**: Completely separated from any daily browsing profile. History, extensions, cookies, window geometry, and restored tabs remain deterministic.
- **Launch Command**: `bin/launch_sound_above_browser.sh [options]`
  - Enforces single-instance execution (terminates any stale studio instance before starting).
  - Runtime flags:
    - `--autoplay-policy=no-user-gesture-required` (smooth playback start without click focus).
    - `--disable-background-timer-throttling` (prevents event loop slowing when OBS or Ghostty is focused).
    - `--disable-renderer-backgrounding` (maintains high audio thread priority).
    - `--disable-backgrounding-occluded-windows` (prevents frame drops during split-screen).
    - `--window-name="The Sound Above - Browser"`

### B. Ghostty Studio Profile
- **Config Path**: `~/.config/ghostty/the-sound-above.config` (tracked in `obs/ghostty/the-sound-above.config`).
- **Configuration Contract**:
  - `title = "The Sound Above - Terminal"`
  - `theme = craftsmanship`
  - `font-family = FiraCode Nerd Font Mono`
  - `font-style = Retina`
  - `font-size = 18`
  - `window-padding-x = 16`, `window-padding-y = 14`
  - `cursor-style = block`, `cursor-style-blink = false`
- **Launch Command**: `bin/launch_sound_above_ghostty.sh`
  - Launches with `open -na /Applications/Ghostty.app --args --config-file=... --title="The Sound Above - Terminal"`.
  - Ensures a single terminal window anchored to the episode workspace.

### C. OBS Scene Collection Update
- In `obs/scenes/ugtastic-sound-above.json`:
  - Update `"Workbench Terminal"` from `owner_name: "iTerm2"` to `owner_name: "Ghostty"`, with `window_name: "The Sound Above - Terminal"`.
  - Update `"Video Window (Chromium)"` to match `The Sound Above - Browser`.
  - Run `./obs/scripts/install-obs-config.sh` while OBS is closed.

---

## 5. Bookmarks Taxonomy: /Episode vs. /Errata Subgrouping

In `bin/episode_bookmarks.rb`, every episode folder under `Season One` is partitioned into two distinct subfolders:

```
Bookmarks Bar
└── The Sound Above
    └── Season One: working target of up to 17 interviews
        └── Episode 01: Sergio Pereira and Chicago Alt.NET
            ├── Episode
            │   ├── Canonical Interview (Video + Chapters + Transcript)
            │   ├── Live Broadcast Workbench (3-Pane Cockpit)
            │   ├── Episode Page (/series/the-sound-above/episode-01/)
            │   ├── Broadcast Rundown & Rewatch Cue Sheet (Markdown)
            │   ├── Textream Teleprompter Script (Textream)
            │   ├── Chicago Alt.NET (Wayback Oct 2008 Capture)
            │   ├── SCNA 2011 Conference Schedule (Wayback Capture)
            │   └── Chicago Code Camp (just3ws/ccs Git Log Receipt)
            └── Errata
                ├── Unscripted Discussion Prompts & Audio Forensics
                ├── Twatio.com Twitter Overlap Experiment (Wayback Capture)
                ├── Redpoint Technologies in the Sears Tower (Wayback Capture)
                ├── Rockford .NET Talk: JavaScript Beyond Curly Braces (Wayback)
                ├── 4-Chair Fishbowl: Domain-Driven Design & db4o (Wayback)
                ├── Software Craftsmanship Manifesto Ledger (Signatory #592)
                ├── Photo Booth Recording Rig & Hardware Context
                └── Hister Oral History Deep Research Search
```

Bookmarks are installed directly into `~/Library/Application Support/Chromium-TheSoundAbove/Default/Bookmarks`.

---

## 6. Spoken Teleprompter Scripts (Episode 01)

### Act 1: The Cold Open & Series Premise (`act_1`)
```
[SCENE: 01. Starting Soon (hold on Starting Soon card for voiceover intro).]
On the podcast No Dogs in Space, Marcus Parks coined a phrase while breaking down the German band Can.
He called it "The Sound Above."
It means art, music, or ideas that deliberately exist one tier higher than an audience's current level of comfort and comprehension.

It isn't noise. It has a pulse you can follow.
But it forces your brain to stretch until the underlying structure clicks.

[SCENE: Switch to 02. Monologue / Full Camera.]
[PAUSE]
Welcome to The Sound Above. I'm Mike Hall.

In 2008, the comfortable default for enterprise software was drag-and-drop wizards and click-to-generate code.
A small group of developers in Chicago started meeting on the second Wednesday of the month in the Sears Tower to pursue something harder: Test-Driven Development, domain modeling, and open-source tooling.
To the enterprise mainstream, it sounded unnatural and overly strict.
It was the sound above.

[PAUSE]
For Episode 1, we pull out the very first interview I ever recorded on video: November 19, 2011, at Software Craftsmanship North America at the Swissotel in downtown Chicago, with Sergio Pereira, the co-founder of Chicago Alt.NET.

Three years before I flipped open a laptop in that hotel hallway to film Sergio in Photo Booth, he was the guy behind the camera filming my very first user group presentation.

In an era of instant AI code generation, we are putting the original 2011 tape right beside the recovered code, git receipts, and primary records to examine what early software craftsmanship looks like when you look past the nostalgia.

Let's pull up the tape and follow the evidence.
```

### Act 6: Synthesis, Community Friction & Tease (`act_6`)
```
[SCENE: Outro card with Sergio Pereira's name and the episode link.]
When you listen to Can's Tago Mago or Miles Davis's Bitches Brew for the first time, it doesn't meet you on your terms. You have to meet it on its terms.

The same thing happened with Chicago Alt.NET.
It wasn't built for easy corporate consumption.
It was a room where working developers challenged the defaults of their day and made space for each other to learn.

Thank you to Sergio Pereira for building that room, for writing code with us on Chicago Code Camp, and for recording that inaugural interview fifteen years ago.

If you were in those rooms at ThoughtWorks or Redpoint in the Sears Tower, or if you remember the friction of giving your first talk when everything felt unfamiliar, share that memory in the comments below.

In Episode 2, Ray Hightower joins us to explore ChicagoRuby and how to build rooms that welcome developers across platforms without lowering the standard of craft.

Interactive transcripts, primary git logs, and show notes are at just3ws.com.
Until next time, keep your feedback loops tight, take care of each other, and keep making room to learn.
```

---

## 7. Next Implementation Steps (Ready for Next Agent)

When resuming this work:
1. **Build Profile Launchers**:
   - Author `bin/launch_sound_above_browser.sh` with profile isolation flags.
   - Author `obs/ghostty/the-sound-above.config` and `bin/launch_sound_above_ghostty.sh`.
   - Make executable: `chmod +x bin/launch_sound_above_*.sh`.
2. **Build Lossless Segment Assembler**:
   - Author `bin/assemble_sound_above_episode.rb` using `ffmpeg -f concat -safe 0 -c copy`.
3. **Update OBS Scene Collection**:
   - Modify `obs/scenes/ugtastic-sound-above.json` ("Workbench Terminal" -> Ghostty).
   - Run `obs/scripts/install-obs-config.sh`.
4. **Refactor Bookmarks**:
   - Update `episode_folder(number)` in `bin/episode_bookmarks.rb` to generate `/Episode` and `/Errata`.
   - Run `bin/episode_bookmarks.rb --install` targeting the dedicated profile.
5. **Update Episode 01 Dossier**:
   - Update `_data/episodes/episode-01.yml` `act_1` and `act_6`.
   - Run `bin/prepare_sound_above_episode.rb 01 --cue-overlay --bookmarks`.

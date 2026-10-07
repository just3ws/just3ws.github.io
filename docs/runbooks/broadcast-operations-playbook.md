# Broadcast Operations Playbook

This playbook establishes unambiguous, sequential operating procedures for live video broadcasting across all three production archetypes for Mike Hall (Staff Software Engineer and UGtastic Host).
It coordinates the unified CLI (`bin/broadcast`), OBS Studio 32, hardware encoding on Apple Silicon M4, native audio capture on macOS Golden Gate, interactive HTML overlays, and YouTube live scheduling.

---

## 1. Core Architecture & Archetypes

Every broadcast belongs to one of three archetypes:

```
                                  ┌────────────────────────┐
                                  │     bin/broadcast      │
                                  └───────────┬────────────┘
                                              │
                     ┌────────────────────────┼────────────────────────┐
                     │                        │                        │
                     ▼                        ▼                        ▼
        ┌─────────────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐
        │       REWATCH           │  │     ERRATA      │  │        DIALOGUE         │
        │   "The Sound Above"     │  │  Solo Broadcast │  │       "The Room"        │
        ├─────────────────────────┤  ├─────────────────┤  ├─────────────────────────┤
        │ • 31 Curated Episodes   │  │ • Book Readings │  │ • Invited Peers/Guests  │
        │ • Historical Inquiry    │  │ • Concept Nodes │  │ • Pair Workbench        │
        │ • Chicago Craft Context │  │ • Live Coding   │  │ • Community Roundtables │
        │ • Video Playback Split  │  │ • Oral Memoirs  │  │ • Two-Up Camera Boxes   │
        │ • Modern AI Synthesis   │  │ • Memorabilia   │  │ • Shared Screen Layout  │
        └─────────────────────────┘  └─────────────────┘  └─────────────────────────┘
```

### Archetype 1: Rewatch ("The Sound Above")
* **Purpose**: Forensic rewatch and oral history commentary over 200+ UGtastic interviews (2009 to 2015).
* **Curriculum**: Exactly 31 sequential episodes across 6 historical movements cataloged in `obs/curation/sequence-manifest.json`.
* **Primary Scenes**: `01. Starting Soon`, `02. Monologue / Full Camera`, `03. Reaction - Video Focus`, `04. Split Screen - Video & Research`, `08. Outro & Next Stream`.
* **Audio Routing**: Orion browser playback isolated via `sck_audio_capture` on Track 3.

### Archetype 2: Errata ("Errata")
* **Purpose**: Personal reflections, book readings, live coding demonstrations, deep-dive concept breakdowns, and physical archival memorabilia showcases.
* **Modes**:
  1. `reading`: Annotated passages from foundational literature (Beck, Hickey, Hunt & Thomas, Hoover).
  2. `concept`: Architectural philosophy (The Blink Test, Value vs. State vs. Identity, Cognitive Load).
  3. `demo`: Hands-on terminal live coding, TDD cadence, AST transformations, and sub-second feedback loops.
  4. `story`: First-person oral memoirs of early user groups, pairing road trips, and consultancy history.
  5. `artifact`: Physical objects from the archive (badges, conference programs, printed ephemera).
* **Primary Scenes**: `02. Monologue / Full Camera`, `05. Workbench - Code & Terminal`, `04. Split Screen - Video & Research`.

### Archetype 3: Dialogue ("The Room")
* **Purpose**: Invited peer conversations, pair programming, and community roundtables.
* **Focus**: Shared craft history, modern engineering challenges, and collective inquiry.
* **Primary Scenes**: `06. Guest & Co-Host Discussion`, `05. Workbench - Code & Terminal`, `01. Starting Soon`, `08. Outro`.
* **Audio Routing**: Remote peer audio isolated on Track 4.

---

## 2. Pre-Flight Checklist (T-30 Minutes)

Follow these steps in exact sequence before going live:

### Step 1: Verify Hardware & Audio Health
Run the automated diagnostic checker:
```bash
./obs/scripts/test-audio-routing.sh
```
Verify that:
1. CoreAudio default input and output devices are locked to 48,000 Hz sample rate.
2. Headphones or IEMs are connected to prevent acoustic feedback into the microphone.
3. macOS microphone permissions and ScreenCaptureKit permissions are granted to OBS.

### Step 2: Run Automated Contract Validation
Run the automated broadcast test suite:
```bash
bin/broadcast --validate
```
Or execute via Rake:
```bash
bundle exec rake validate:obs
```
Assert that all 40 contract assertions pass cleanly:
- Scene collection matches all 8 required production scenes.
- Canvas and output resolutions are locked to 1920x1080 at 60 fps.
- Apple Silicon VideoToolbox hardware encoder is selected.
- All 5 HTML overlays and theme stylesheets exist without drift.
- Sequence manifest contains 31 sequential episodes.

### Step 3: Install or Synchronize OBS Configurations
If running on a fresh workstation or after scene updates:
```bash
./obs/scripts/install-obs-config.sh
```
Launch OBS Studio 32:
```bash
open -a OBS
```
Confirm the active Scene Collection is **The Sound Above - UGtastic Rewatch** and Profile is **The Sound Above**.

---

## 3. Cueing the Broadcast (T-15 Minutes)

Use `bin/broadcast` to cue the live state in `obs/overlays/overlay-state.json`. Live browser overlays poll this file every 2.5 seconds and update automatically.

### Option A: Cueing a Rewatch Episode
Inspect the 31-episode catalog:
```bash
bin/broadcast --list
```
Cue an episode by number (e.g. Episode 1 with Sergio Pereira):
```bash
bin/broadcast --rewatch 1
```
Check the live state:
```bash
bin/broadcast --status
```

### Option B: Cueing an Errata Broadcast
Choose a pre-curated entry from `obs/curation/errata-manifest.json`:
```bash
bin/broadcast --cue errata-concept-blink-test
```
Or cue an ad-hoc reading or demonstration:
```bash
# Book Reading Mode:
bin/broadcast --errata --mode reading \
  --title "The Cat Ate My Source Code" \
  --subtitle "Chapter 1: A Pragmatic Philosophy" \
  --citation "The Pragmatic Programmer (1999)" \
  --prompt "Provide options, don't make excuses: take responsibility and offer solutions."

# Live Code Workbench Demo Mode:
bin/broadcast --errata --mode demo \
  --title "Four Rules of Simple Design" \
  --subtitle "Live Refactoring on Neovim" \
  --citation "Kent Beck (1999)" \
  --prompt "1. Passes tests. 2. Reveals intention. 3. No duplication. 4. Fewest elements."

# Physical Archival Artifact Mode:
bin/broadcast --errata --mode artifact \
  --title "2008 Alt.NET Willis Tower Conference Badges" \
  --subtitle "Physical Ephemera Showcase" \
  --year "2008" \
  --prompt "Before dedicated meetup spaces, developers met on the 84th floor of the Sears Tower."

# Behind the Scenes (BTS) Studio & Systems Engineering Mode:
bin/broadcast --errata --bts \
  --title "Inside The Control Plane: OBS Studio & Golden Gate Audio" \
  --subtitle "Broadcast Engineering & 4-Track Routing Walkthrough" \
  --citation "Broadcast Rig Architecture & System Blueprint" \
  --prompt "How hardware-isolated macOS CoreAudio routing and Apple Silicon VideoToolbox power deterministic streaming."
```

### Option C: Cueing an Invited Guest Dialogue
Cue an invited peer or panel discussion:
```bash
bin/broadcast --dialogue \
  --guest "Corey Haines" \
  --subtitle "Author, Understanding the 4 Rules of Simple Design" \
  --conference "SCNA / Global Day of Coderetreat" \
  --title "Deliberate Practice in the Age of AI" \
  --prompt "How does intentional practice evolve when AI synthesizes code instantly?"
```

---

## 4. Live Broadcast Runbook (T-0 to Wrap)

```
[ T-05:00 ] Scene: 01. Starting Soon
            │ • Start OBS Streaming and Recording
            │ • Ambient slate active, quote carousel rotating
            │ • Audio: Low ambient synth or silent, mic muted
            ▼
[ T-00:00 ] Scene: 02. Monologue / Full Camera
            │ • Unmute host microphone
            │ • Welcome audience, state the broadcast thesis
            │ • Lower-third HUD displays speaker credos
            ▼
[ IN-FLIGHT ] Dynamic Scene Switching:
            │ • Rewatch: Scene 03 (Reaction Video Focus) or Scene 04 (Split Screen)
            │ • Live Code Demo: Scene 05 (Workbench - Code & Terminal)
            │ • Guest Discussion: Scene 06 (Guest & Co-Host Discussion)
            │ • Need a break: Scene 07 (Intermission / BRB - Holding the Thread)
            ▼
[ CLOSING ] Scene: 08. Outro & Next Stream
            │ • Summarize key insights and thank guests/viewers
            │ • Display archive resource URLs
            │ • Stop Streaming, then Stop Recording
```

---

## 5. Post-Stream Teardown & Preservation Checklist

1. **Verify Recorded Tracks**:
   Inspect recorded video container in `~/Movies/`:
   ```bash
   ffprobe -i ~/Movies/latest_recording.mov 2>&1 | grep Audio
   ```
   Confirm all 4 audio streams are intact (Track 1 Mix, Track 2 Host Mic, Track 3 Application Audio, Track 4 Guest Audio).

2. **Automated Speech Retranscription**:
   Route clean vocal track (Track 2) into local Whisper transcription pipeline:
   ```bash
   ffmpeg -i ~/Movies/latest_recording.mov -map 0:a:1 -c:a pcm_s16le tmp/host_vocals.wav
   whisper-ctl transcribe tmp/host_vocals.wav --model medium.en --output-dir tmp/
   ```

3. **Status Check & Next Episode Cue**:
   Reset overlay status or prepare next broadcast:
   ```bash
   bin/broadcast --status
   ```

---

## 6. AI Agent Delegation & Automation Playbook

When an AI assistant or subagent (`oral-history-broadcaster`) is instructed to stage a stream, it must execute the following deterministic protocol:

1. **Load Current State**:
   Run `bin/broadcast --status` to inspect current state.
2. **Consult Sequence or Errata Manifest**:
   Examine `obs/curation/sequence-manifest.json` or `obs/curation/errata-manifest.json`.
3. **Stage Live Overlays**:
   Run `bin/broadcast` with the appropriate flags (`--rewatch`, `--errata`, or `--dialogue`).
4. **Run Contract Gate**:
   Execute `bin/broadcast --validate`. If any assertion fails, resolve the issue before proceeding.
5. **Report Readiness**:
   Provide the human broadcaster with a concise summary: Archetype, Title, Guest/Citation, Active Topic, and YouTube Stream ID.

---

## 7. Single-Monitor Operations, Hotkey Conventions & Orion Profile

Operating a broadcast on a single monitor requires strict window-level targeting and muscle memory so OBS controls never leak onto the recorded canvas.

### 7.1 Single-Monitor Operating Principles

1. **Target Window Buffers, Never Display Capture**:
   - Scene 03 & 04 (`Research Window`) bind to the dedicated **Orion** window.
   - Scene 05 (`Workbench Terminal`) binds directly to **iTerm2**.
   - macOS ScreenCaptureKit captures the application window buffer directly. You can keep OBS open beside, on top of, or behind your work without OBS ever showing up in the output.
2. **Dual-Space Virtual Desktop Architecture**:
   - **macOS Space 1 (Studio Control)**: OBS Studio maximized. Monitor audio VU meters, elapsed recording time, and live scene status.
   - **macOS Space 2 (Presentation & Workbench)**: Left half = Orion (125% zoom for viewer legibility); Right half = iTerm2 (or full-screen terminal for Scene 05).
   - Switch spaces instantly using `Control + Left/Right Arrow`.

### 7.2 Conflict-Free OBS Global Hotkey Map

To switch scenes and control recording without bringing OBS into keyboard focus, configure these system-wide hotkeys in **OBS Studio -> Settings -> Hotkeys**:

| Function | Hotkey | Why It is Conflict-Free |
|---|---|---|
| **Start Recording** | `Control + Option + Command + R` | Does not collide with terminal, editor, or browser shortcuts |
| **Stop Recording** | `Control + Option + Command + S` | Requires deliberate modifier chord; prevents accidental cutoff |
| **Scene 01 (Pre-Show)** | `Control + Option + 1` | Standard macOS app shortcuts rarely use `Control + Option` |
| **Scene 02 (Monologue / Full Camera)** | `Control + Option + 2` | Instant return to host camera during discussions |
| **Scene 03 (Interview Focus)** | `Control + Option + 3` | Switches to historical video with host PIP |
| **Scene 04 (Split Screen Research)** | `Control + Option + 4` | Switches to dual video + Orion research window |
| **Scene 05 (Workbench Terminal)** | `Control + Option + 5` | Full terminal view (lower-third auto-hides after 10s) |
| **Scene 06 (Guest Discussion)** | `Control + Option + 6` | Two-up camera layout for The Room dialogues |
| **Scene 07 (BRB Intermission)** | `Control + Option + 7` | Clean break screen if stepping away |
| **Scene 08 (Outro & Wrap Up)** | `Control + Option + 8` | Credits and next broadcast cues |

### 7.3 Orion Profile: "The Sound Above" Configuration

When presenting web archives, transcripts, and timeline pages during a broadcast, configure the dedicated Orion profile as follows:

1. **Window Resolution & Sizing**:
   - Set Orion window bounds to **1280x720** (16:9 ratio) placed on the right side of Space 2.
   - In Scene 04 (Split Screen), OBS scales this window cleanly into the research frame.
2. **View & Zoom Settings**:
   - Set default zoom to **125%** (`Command + Plus`). This ensures 14px and 16px body text renders crisp and readable on 1080p stream downscales and mobile video players.
   - Hide Tab Bar when single tab: **View -> Hide Tab Bar**.
   - Enable Compact Tabs or auto-hiding address bar for maximum vertical content area.
3. **Craftsmanship UserStyle**:
   - In Orion, open **Preferences -> Extensions -> Add User Scripts / Styles** (or use Stylus).
   - Load `obs/browser-themes/the-sound-above-orion.css`:
     - Suppresses cookie banners and popups automatically.
     - Enforces antialiased typography optimized for video encoding.
     - Styles text selection with the warm craftsman amber highlight (`rgba(180, 83, 9, 0.25)`).
4. **Primary Broadcast Bookmarks Bar**:
   - `https://www.just3ws.localhost/timeline/community/` (Chicago Community Timeline)
   - `https://www.just3ws.localhost/interviews/` (Oral History Archive index)
   - `https://www.just3ws.localhost/series/the-sound-above/episode-01/` (Episode mirror)
   - `https://web.archive.org/web/20081101091417/http://www.chicagoalt.net/Home` (Chicago Alt.NET 2008 archive)
   - `https://www.slideshare.net/chicagoaltnet` (Chicago Alt.NET slide decks)

### 7.4 iTerm2 Profile: "The Sound Above" Configuration & Dynamic Profiles

Scene 05 (`05. Workbench - Code & Terminal`) presents code, shell operations, and git histories. To maintain broadcast visual hierarchy and prevent compression artifacts, use the dedicated iTerm2 profile:

1. **Profile Specifications & Visual Hierarchy**:
   - **Profile Name**: `The Sound Above`
   - **Font**: `Fira Code Nerd Font`, 18pt regular with ligatures enabled. 18pt is calibrated for 1080p full-screen and downscaled mobile streaming.
   - **Cursor**: Solid box cursor (`Cursor Type: Box`), non-blinking (`Blinking Cursor: False`). ScreenCaptureKit window captures can drop blinking cursors on keyframe boundaries. A solid cursor guarantees constant visibility.
   - **Colors**:
     - Background: `#1a1a2f` / sumi dark slate (`#1e232a`)
     - Foreground: `#faf8f5` canvas parchment
     - Amber Highlight / Accent: `#b45309`
     - Craftsman Teal Accent: `#0f766e`
   - **Badge**: Top-right corner displays `The Sound Above` watermark at 50% opacity, providing instant visual confirmation of the active broadcast context.

2. **Automated Dynamic Profile Synchronization**:
   - The canonical profile definition is tracked in version control at `obs/iterm2/the-sound-above.json`.
   - Running `./obs/scripts/install-obs-config.sh` automatically copies this profile to `~/Library/Application Support/iTerm2/DynamicProfiles/the-sound-above.json`.
   - iTerm2 detects changes to dynamic profile JSON files immediately without requiring an application restart.

3. **OBS Window Binding**:
   - Scene 05's `Workbench Terminal` window capture source is configured to match `owner_name: iTerm2`.
   - Because window capture hooks the window buffer directly, terminal activity in Space 2 is captured at 60 fps without displaying other applications or notification popups.



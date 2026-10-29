# Livestreaming Tutorial and Operator Guidelines

## The Sound Above: UGtastic Oral History Rewatch Series

This document provides the end-to-end operational tutorial, technical runbook, and broadcast guidelines for hosting "The Sound Above" livestream using OBS Studio on macOS Golden Gate.

The authoritative technical sequence is [the recording playbook](recording-playbook.md), also available with `bin/broadcast --playbook`. This document supplements it with episode framing and presentation guidance. Do not use older command examples in other documents when they conflict with the playbook or `bin/broadcast --help`.

---

## 1. Pre-Flight Preparation (T-30 Minutes)

A great technical livestream is built on disciplined pre-flight habits:

### Step 1: Run the Automated Validation Suite
Verify all contracts, scenes, profiles, overlays, and environment prerequisites:
```bash
bundle exec rake validate:obs
```
Review all reported errors and warnings. A passing repository check does not replace preview, meter, disk-space, or YouTube Live Control Room checks.

### Step 2: Install or Synchronize Configuration
If you have pulled new commits or modified scenes:
```bash
./obs/scripts/install-obs-config.sh --dry-run
./obs/scripts/install-obs-config.sh
```
Close OBS before installing. The installer exits without writing if OBS is running.

### Step 3: Run the Audio Diagnostic
Inspect CoreAudio device details and prior OBS permission-log hints:
```bash
./obs/scripts/test-audio-routing.sh
```

### Step 4: Cue the Target Episode
Select your target episode from `obs/curation/sequence-manifest.json`:
```bash
# Example: Cue Episode 1 (Sergio Pereira):
bin/broadcast --rewatch 1
bin/broadcast --status
```
The preferred cue command is `bin/broadcast --rewatch 1`. Verify the interviewee, event, era, and prompt with `bin/broadcast --status` and in the OBS preview. Cueing updates overlay metadata only.

---

## 2. Window and Desktop Arrangement

To keep stream text crisp and readable for viewers on 1080p displays or mobile devices:

1. **Video Browser (Chromium)**:
   - Open Chromium and navigate to the target interview on Vimeo, YouTube, or your local archive folder.
   - Set window size to 16:9 ratio.
   - Use a dedicated clean window or full-screen mode to reduce visual clutter.
2. **Investigation Browser (Safari or Secondary Browser Window)**:
   - Open `https://just3ws.localhost/timeline/community/` and `https://just3ws.localhost/interviews/`.
   - Keep the interviewee's dossier, transcript, and signatory network graph ready for immediate reference.
3. **Workbench Terminal (Ghostty or iTerm2)**:
   - Launch your terminal and increase font size to at least 18pt (Menlo, SF Mono, or JetBrains Mono).
   - Anchor working directory to `~/github.com/just3ws/just3ws.github.io` or `~/.config/zsh`.
   - Never open `.env` or credential files during a live broadcast.
4. **OBS Studio**:
   - Select Profile: **The Sound Above**.
   - Select Scene Collection: **The Sound Above - UGtastic Rewatch**.
   - In Scene `03. Reaction - Video Focus`, click `Video Window (Chromium)` in the Sources panel to confirm window attachment.

---

## 3. Audio Discipline and Feedback Prevention

On macOS Golden Gate (Darwin 27), audio routing is fully digital:

- **Mandatory Headphones**: Always wear headphones or in-ear monitors. If interview audio plays through your physical laptop speakers, your open microphone will capture room echo.
- **Isolated App Audio**: ScreenCaptureKit (`sck_audio_capture`) taps the Chromium process directly. It will never capture system alert chimes, Slack dings, or email notifications.
- **Global Desktop Audio**: Keep the global desktop source disabled in the rewatch collection. Enabling it alongside Chromium ScreenCaptureKit can duplicate interview playback and include system notifications in the program mix.
- **Spacebar Control**: Pausing playback in Chromium instantly silences the video audio stream, giving you a clean stage to comment without audio overlap.
- **Vocal Processing**: The microphone template includes RNNoise suppression, compression, and a limiter at -1.5 dB. Listen to a test recording; filters cannot replace mic placement or gain checks.

---

## 4. The Art of the "Sound Above" Reaction

This is not a generic reaction stream; it is a forensic exploration of software craft and community history. Follow these broadcast guidelines:

### Guideline 1: Frame the Historical Room First
Before playing the video, spend 5 to 10 minutes in Scene `02. Monologue / Full Camera`:
- What year was this recorded?
- What was happening in the Chicago software ecosystem at that exact moment?
- What was the prevailing industry orthodoxy they were fighting against (for example, corporate enterprise monoliths, manual testing, slow release cycles)?
- Who was this person in the community?

### Guideline 2: Probe "The Sound Above"
When listening to the interview, listen past the surface technology. Probe the deeper influences:
- Who inspired this person when they were early in their career?
- What were the books, user groups, or mentors that shaped their thinking?
- Notice their phrasing: what unspoken values were they taking for granted?

### Guideline 3: Pause and Dissect
Do not let the video run uninterrupted for 15 minutes while you sit silently:
- Pause when an interviewee mentions a critical concept (such as pairing, katas, mock objects, or user groups).
- Switch to Scene `04. Split Screen` to show the exact transcript turn, timestamp, or timeline milestone on `just3ws.localhost`.
- Explain what was happening behind the scenes that the camera did not capture.

### Guideline 4: Connect the Past to the AI Era
Every episode must build a bridge between the craftsmanship era and modern engineering:
- If Corey Haines discusses Conway's Game of Life, show how Kent Beck's Four Rules of Simple Design serve as the evaluation criteria for LLM-generated code.
- If Gary Bernhardt demonstrates sub-second unit tests, explain why slow test suites break autonomous AI agent feedback loops.
- If Dan North emphasizes deliberate discovery, contrast it with hallucinations born of false certainty in prompt engineering.

### Guideline 5: Live Workbench Demonstrations
Transition to Scene `05. Workbench - Code & Terminal` to make concepts tangible:
- Run git archaeology commands (`git log -S`, `git blame`) to show historical code evolution.
- Run tests in the terminal to demonstrate red-green-refactor cadence.
- Apply the **Blink Test**: show the test failing, apply the fix, and show it passing cleanly.

---

## 5. Post-Stream Production and Asset Extraction

When the stream ends:

1. **Stop Recording**: OBS saves a multi-track `.mov` file to `/Users/mike/Movies/`.
2. **Multi-Track Separation**:
   - Track 1 contains your full broadcast composite.
   - Track 2 contains your clean, isolated microphone vocal track.
   - Track 3 contains the isolated interview audio.
   - Track 4 is reserved and remains silent until a guest application's ScreenCaptureKit source is explicitly configured and routed.
3. **Editorial Content Studio Integration**:
   - Use [`studio/index.html`](file:///Users/mike/github.com/just3ws/just3ws.github.io/studio/index.html) to extract vertical YouTube Shorts, Reels, and quotable soundbites.
   - Feed Track 2 into local Whisper (`whisper-ctl`) to produce transcripts of your live commentary.
   - Update `obs/curation/sequence-manifest.json` to mark the episode status as `recorded`.

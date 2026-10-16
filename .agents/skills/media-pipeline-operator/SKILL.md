---
name: media-pipeline-operator
description: Operates, monitors, and audits the zero-disk-waste media intake and YouTube publishing pipeline across all channels and playlists (Ramblin' & Amblin', The Sound Above, Errata). Manages Maildir queues, Concurrency Locks, FIFO order, SSE telemetry, SwiftBar status, and BPMN SLO compliance.
---

# /media-pipeline-operator: Media Intake & YouTube Publishing Pipeline

Use this skill when ingesting, processing, monitoring, or troubleshooting media files destined for YouTube playlists across all configured channels.

The media intake pipeline operates on a zero-disk-waste cloud streaming architecture: videos sync from mobile devices or local capture to Google Drive Maildir queues, stream ephemeral audio to `/tmp/` for whisper.cpp transcription on Apple Silicon, stream directly to YouTube Data API v3 via chunked resumable upload, upload verified WebVTT captions, and archive cloud masters with zero permanent local SSD consumption.

---

## 1. Core Architectural Invariants

1. **Zero Permanent Local SSD Footprint**: Video files are never duplicated or permanently stored on the local drive. Ephemeral scratch WAV files in `/tmp` are strictly purged upon completion.
2. **Cross-Channel Concurrency Lock (1-at-a-Time)**: Exactly one video may reside in `processing/` across all channels and targets at any time to preserve localhost CPU, RAM, and Apple Silicon Neural Engine headroom.
3. **Strict FIFO Queue Discipline**: When multiple files are pending, the orchestrator orders candidates across all channels ascending by filesystem ingress age (APFS birthtime falling back to mtime). The oldest file is always processed first.
4. **Staged Safety Hold**: The `staged/` directory provides pre-queue storage so phone uploads can safely sync to Google Drive without triggering automated ingestion until moved into `pending/`.

---

## 2. The 5-State Maildir Directory Lifecycle

Queue directories are organized by channel and target playlist under:
`~/Google Drive/My Drive/Media Intake/<channel>/<target>/`

| Directory | State Purpose | Operator Action |
| :--- | :--- | :--- |
| `staged/` | Pre-intake hold | Upload video from phone/desktop. Held safe without triggering ingestion. |
| `pending/` | Ingress queue | Move file here (`mv staged/* pending/`) when ready for autonomous ingestion. |
| `processing/` | Atomic Concurrency Lock | Pipeline moves file here during audio DSP, Whisper STT, and YouTube upload. |
| `processed/YYYY-MM/` | Archived masters | Organized chronologically by year and month upon successful publication. |
| `failed/` | Quarantined errors | Isolated assets with companion `<filename>.error.log` diagnostics. |

---

## 3. Operational CLI Grammar (`bin/pipeline media`)

All media operations are routed through the unified `media` namespace:

```sh
# Queue status and Concurrency Lock report
./bin/pipeline media status
./bin/pipeline media intake --status

# Process the single oldest pending file (FIFO) and exit
./bin/pipeline media intake --one

# Continuous autonomous watcher (polls every 30s)
./bin/pipeline media intake --watch

# Non-destructive simulation without moving or uploading files
./bin/pipeline media intake --dry-run

# Start near-realtime Server-Sent Events (SSE) telemetry streamer (port 7025)
./bin/pipeline media stream

# Emit SwiftBar pulse and status breakdown
./bin/pipeline media swiftbar

# Full 37-episode pre-broadcast staging harness
./bin/pipeline media stage --all

# Patreon compute funding status and patron credits
./bin/pipeline media patreon status
```

---

## 4. Real-Time Telemetry & Observability Surfaces

1. **Localhost Subnav Processor Pulse**:
   - Every page on `https://www.just3ws.localhost/` displays `#lh-processor-pulse`.
   - Green dot: Processor Idle (FIFO Ready).
   - Amber dot: Pending files queued for FIFO ingestion.
   - Electric Blue dot: Actively ingesting video (with glowing pulse).
   - Red dot: Quarantined failure in `failed/`.
   - Clicking the badge jumps directly to the BPMN Workflow Monitor.

2. **macOS SwiftBar Menu Bar Monitor**:
   - Installed at `~/.swiftbar/youtube-pipeline.30s.sh` delegating to `bin/youtube-swiftbar`.
   - Emits `🎬 Ready`, `🎬 X pending`, or `🎬⚡ Ingesting` with 30-second refresh.

3. **Operations Cockpit & Interactive BPMN Monitor**:
   - Location: `https://www.just3ws.localhost/youtube/dashboard/#tab-bpmn`
   - Interactive SVG canvas with active task highlighting and SLO latency tracking.

---

## 5. Incident Diagnosis & Recovery Playbook

1. **Stranded in `processing/`**:
   - If a previous process was killed during upload, check `active_processing_files`.
   - Inspect whether `ffmpeg` or `whisper-cli` is running:
     `pgrep -fl '(intake_drive_video|whisper|ffmpeg)'`
   - If stale, move file back to `pending/` to retry or `failed/` to investigate.

2. **Quarantined in `failed/`**:
   - View the diagnostic error log:
     `cat "Media Intake/<channel>/<target>/failed/<filename>.error.log"`
   - Address the root cause (e.g., token expiration, corrupt container), then move back to `pending/`.

3. **Quota Exhaustion**:
   - YouTube Data API v3 enforces a 10,000 unit daily limit (resetting midnight PT).
   - Video upload costs 1,600 units; thumbnail update costs 50 units.
   - Check quota headroom via `./bin/pipeline media youtube quota`.

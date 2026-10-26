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

## 3. Operational CLI Grammar (`bin/pipeline media` & `mp`)

All media operations are routed through the unified `media` namespace or the dedicated `mp` microservice tool suite:

```sh
# 1. Pipeline Status & Ingress Queries
./bin/pipeline media query
./bin/pipeline media status
mp status
mp status --compact
mp status --json

# 2. Service Supervision & Health Diagnostics
mp service status
mp service restart
mp service doctor
mp service logs -f

# 3. Process FIFO Candidates & Ingress Scanning
mp scan
./bin/pipeline media intake --one

# 4. Quarantined & Corrupt Intake Inspections
mp corrupt

# 5. Offline Metadata Editing & YouTube API Sync (Zero Re-upload)
mp metadata show <id>
mp metadata edit <id>
mp metadata push <id>

# 6. Remote Browser Automation & DevTools MCP
mp devtools test
mp devtools audit https://media-pipeline.localhost

# 7. SwiftBar Pulse & Lateral References
./bin/pipeline media swiftbar
mp swiftbar
```

---

## 4. Real-Time Telemetry & Observability Surfaces

1. **Operations Cockpit (Port 32000)**:
   - Location: `https://media-pipeline.localhost/`
   - Real-time SSE swimlanes, substate inspection modal, 1-click single and bulk requeue, and spatial cartography.

2. **Process Health & Supervision Deck**:
   - Location: `https://media-pipeline.localhost/admin/operations`
   - Real-time host runtime metrics (PID, memory RSS, NVMe storage), daemon status, Solid Queue concurrency, and operational controls (Scan, Pause/Resume, Sweep Corrupt, Rotate Logs, Service Doctor).

3. **Sovereign Ahoy Analytics**:
   - Location: `https://media-pipeline.localhost/ahoy` (or `/analytics`)
   - First-party cookie-less dashboard displaying 30-day visit and event volumes, technology breakdowns, and live event stream.

4. **Database Performance & Health**:
   - Location: `https://media-pipeline.localhost/pghero`
   - Live query metrics, table/index cache hit rates (99.999%+), missing/duplicate index checks.

5. **Local AI Hybrid Vector Search & Conversational RAG**:
   - Location: `https://media-pipeline.localhost/#tab-analytics`
   - Powered by PostgreSQL 18 `pgvector` and local Apple Silicon Metal GPU inference (`http://127.0.0.1:11500/v1` for LLaMA 3.1 8B and `http://127.0.0.1:11501/v1` for Nomic Embed 768-dim).

6. **macOS SwiftBar Menu Bar Monitor**:
   - Installed at `~/.swiftbar/media-pipeline.30s.sh` delegating to `bin/media-pipeline-swiftbar`.
   - Displays real-time pending counts, series submenus, candidate file sizes, and one-click operational triggers.

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
   - Check quota headroom via `./bin/pipeline media query --quota` or `./bin/pipeline media youtube quota`.

---

## 6. MCP Protocol Integration (`just3ws-site`)

When interacting via AI coding agents or MCP clients:
- **Tool `query_media_pipeline`**: Queries live intake queues, worker state, quota cooldown, and recent events. Arguments: `section` (`all`, `summary`, `queues`, `quota`, `worker`, `activity`), `target`, `format` (`text`, `json`).
- **Resource `site://pipeline/status`**: Returns real-time JSON status payload with queue breakdown, worker lock, quota cooldown timer, and recent activity log.

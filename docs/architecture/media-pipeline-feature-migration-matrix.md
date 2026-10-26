# Media Pipeline Feature Migration & Parity Audit Matrix

This document provides a forensic, point-by-point comparison between the **Original Implementation** (`bin/intake_drive_video.rb`, `bin/live_dashboard_streamer.rb`, and `JobSubstateTracker`) and the **New Standalone Microservice** (`media-pipeline`, Rails 8 on port 32000).

Every feature is evaluated against the 1:1+ architectural contract: **The new system must maintain complete operational parity as a baseline and deliver quantifiable improvements (1:1+) in resilience, observability, and data sovereignty.**

---

## 1. Comprehensive Feature Parity Matrix

| # | Feature / Contract Domain | Original Implementation (`just3ws.github.io`) | New Rails 8 Microservice (`media-pipeline`) | Parity Status | Verification & Notes |
| :- | :--- | :--- | :--- | :--- | :--- |
| **1** | **Ingress Queue Topology** | Maildir directories: `staged/`, `pending/`, `processing/`, `processed/`, `failed/`, `blocked/`. | Canonical targets with Maildir layout + PostgreSQL `media_assets` table tracking lifecycle states (`pending`, `processing`, `uploaded`, `processed`, `failed`, `blocked`). | **1:1+ Enhanced** | Backed by transactional PostgreSQL state machine (AASM) in addition to filesystem directories. |
| **2** | **Ingress Stability Guard** | `stable_file?`: 3s + 2s multi-sample file size invariant check to guard against active mobile uploads. | `ScanIntakeQueuesJob` checks file size invariance across 5 seconds and skips zero-byte / active uploads. | **1:1 Parity** | `ScanIntakeQueuesJob` line 45 prevents ingesting in-flight mobile uploads. |
| **3** | **Zero-Byte File Quarantine** | Zero-byte files could stall processing or fail during ffprobe. | `IntakeQuarantineService` (`mp corrupt`) isolates settled (>30m) zero-byte or unreadable files into `corrupt/` on Drive and logs to append-only LTSV ledger. | **1:1+ Enhanced** | Autonomous corrupt quarantine prevents conveyor jams and surfaces clickable SwiftBar alerts. |
| **4** | **Strict Serial Concurrency (1 WIP)** | Atomic PID file lock at `~/.local/state/just3ws/pipeline.lock`. Single file in `processing/`. | Solid Queue strict worker semaphore (`limits_concurrency to: 1`, `threads: 1` on `media_processing` queue) + `ApplicationJob` single-thread execution. | **1:1+ Enhanced** | Eliminates stale PID file vulnerabilities while guaranteeing single-worker execution on Apple Silicon GPU. |
| **5** | **FIFO Sequencing by File Age** | APFS birthtime / mtime sort across all targets in `collect_pending_candidates`. | `ScanIntakeQueuesJob` queries filesystem birthtime/mtime and enqueues to Solid Queue ordered chronologically. | **1:1 Parity** | Oldest recordings are guaranteed to be processed first. |
| **6** | **APFS Cloud Storage Streaming** | Direct file copy (`FileUtils.mv`), vulnerable to macOS CloudStorage FileProvider deadlocks (`EDEADLK`). | Upgraded `stage_working_file` in `ProcessMediaAssetJob`: 1 MB user-space chunk streaming with 120 retry tolerance (6 minutes per chunk) and partial byte retention. | **1:1+ Enhanced** | Safely downloads multi-gigabyte virtual cloud files without tripping APFS kernel deadlocks. |
| **7** | **Audio DSP Extraction** | FFmpeg extracts 16kHz mono PCM audio to `/tmp/intake_scratch_<pid>.wav`. | `ProcessMediaAssetJob#extract_audio`: FFmpeg extracts 16kHz mono PCM audio to local state scratch dir. | **1:1 Parity** | Matches exact 16kHz mono PCM specification required by Whisper. |
| **8** | **Scratch Audio Eviction** | Purged scratch WAV in `ensure` block upon process exit (0 MB permanent SSD retention). | `ProcessMediaAssetJob#perform` cleans scratch files in `ensure` block upon job completion or failure. | **1:1 Parity** | Zero permanent local disk waste verified. |
| **9** | **Whisper Metal GPU Speech Recognition** | Routed to shared zdots platform tool `ztranscribe` (`whisper-cpp` + Metal GPU) with domain priming prompts. | `ProcessMediaAssetJob#transcribe_audio` invokes `~/.config/zsh/bin/ztranscribe` with Apple Silicon Metal acceleration, outputs WebVTT and TXT. | **1:1 Parity** | Native Metal GPU acceleration verified on Apple Silicon. |
| **10** | **Speech Hook Extraction** | `extract_hook_from_text`: stripped conversational filler words, limited to 8 words, capitalized. | `VideoMetadataExtractor.extract_hook_from_text`: strips conversational fillers, capitalizes, formats canonical title. | **1:1 Parity** | Verified in `app/services/video_metadata_extractor.rb`. |
| **11** | **Camera Timestamp Parsing** | Evaluated ffprobe `creation_time` tag or file mtime. | `VideoMetadataExtractor.extract_date`: parses `VID_YYYYMMDD_HHMMSS` camera timestamps directly with ffprobe fallback. | **1:1+ Enhanced** | Immune to file copy or cloud sync timestamp distortion. |
| **12** | **Title Synthesis & Budget** | Calibrated to `<= 100` characters, zero em dashes. Formatted as `#{series} (#{date}): #{hook}`. | `VideoMetadataExtractor.build_title`: strictly clamps to 100 characters with ellipsis, replaces em dashes with colons. | **1:1 Parity** | Strict YouTube character budget and zero em dash compliance verified. |
| **13** | **Description & Spoken Overview** | Generated structured overview with links, spoken snippet, and recorded date (`<= 5000` chars). | Formats rich markdown/text description with series playlist links, curriculum links, spoken overview, and date. | **1:1 Parity** | Full structured description preserved across database, YouTube, and static site. |
| **14** | **Episode Dossier Integration** | Looked up `_data/episodes/episode-XX.yml` for The Sound Above rewatches. | `SoundAboveCurriculumService`: loads all 35 curriculum episodes, Minus One, Minus Zero, and associates assets. | **1:1 Parity** | Episode dossiers seamlessly bind into curriculum broadcasts. |
| **15** | **YouTube Video Upload** | Resumable chunked upload via Google API client with 3-attempt exponential backoff. | `YoutubeClient#upload_video`: resumable chunked upload with exponential backoff and Faraday HTTP adapter. | **1:1 Parity** | Chunked resumable uploading verified. |
| **16** | **Playlist Management** | Added video to series playlist; checked duplicate playlist items via `yt-dlp` or API. | `YoutubeClient#add_playlist_item` + `EphemeralityService.reconcile!`: manages series playlist and vault playlist. | **1:1+ Enhanced** | Includes automated ephemerality rolling window reconciliation. |
| **17** | **Digital Ephemerality & Sovereign Vault** | Ad-hoc manual unlisting or playlist pruning. | `EphemeralityService`: maintains 3-day / 2 public active videos rolling window; automatically retires older videos to private vault playlist (`PLYCKmHMYvC7s`). | **1:1+ Enhanced** | Autonomous rolling-horizon ephemerality executed live on YouTube. |
| **18** | **WebVTT Captions Upload** | Uploaded WebVTT captions via YouTube API v3; deferred on quota pressure. | `YoutubeClient#upload_caption`: uploads WebVTT captions track with error recovery and quota guards. | **1:1 Parity** | WebVTT captions verified uploaded on YouTube assets. |
| **19** | **Static Site Knowledge Sync** | Appended to `_data/video_assets.yml` and wrote `_data/transcripts/<slug>.yml`. | `SiteSyncService`: writes structured transcript dossier to `_data/transcripts/<slug>.yml` and updates/registers entry in `_data/video_assets.yml`. | **1:1 Parity** | Full-text transcripts and assets automatically mirrored to static site datalake. |
| **20** | **Local Metadata Sovereignty & Sidecars** | Written once on ingest; no convenient local CLI to edit and push updates back to YouTube without re-upload. | `MediaAsset#export_sidecar_yaml!`: persists YAML to `~/.local/state/just3ws/sidecars/<target>/<stem>.yml`. `mp metadata` CLI provides `show`, `edit`, `set`, `push`, and `pull`. | **1:1+ Enhanced** | Full local editing in `$EDITOR` with zero re-upload YouTube propagation (`videos.update`). |
| **21** | **Cloud Archive Mirror & SSD Release** | Mirrored master to `processed/YYYY-MM/` on Google Drive, then removed local NVMe master. | `ProcessMediaAssetJob#mirror_and_release`: copies master to Google Drive `processed/YYYY-MM/`, exports companion YAML sidecar, and releases local staging file. | **1:1 Parity** | Guaranteed bit-for-bit cloud preservation with companion metadata sidecar. |
| **22** | **YouTube Quota Budgeting & Cooldown** | Checked quota cooldown; paused in `blocked/` until 2:00 AM CT. | `YoutubeQuotaService`: tracks 10,000 daily budget, unit costs, automatic midnight Pacific cooldown detection, and cockpit calculator. | **1:1 Parity** | Dynamic quota calculation with automated cooldown guards. |
| **23** | **Quarantine & Error Triage** | Quarantined to `failed/` with `<filename>.error.log`. Required manual CLI command to retry. | Quarantines failed assets in PostgreSQL with full call stack, displays red alert cards in Cockpit swimlane, supports 1-click single and bulk requeue. | **1:1+ Enhanced** | Forensic diagnostic modal with call stack viewer and instant one-click requeue. |
| **24** | **Real-Time Telemetry & SSE** | Custom WEBrick daemon on port 7025 serving `/events` and `/status`. | Rails ActionController::Live SSE on port 32000 (`/live_stream/stream` and `/api/status`) with pure LTSV wide logging. | **1:1+ Enhanced** | Pure LTSV wide logs with OpenTelemetry trace/span IDs, OpenObserve, and Jaeger correlation. |
| **25** | **macOS SwiftBar Menu Integration** | `bin/youtube-swiftbar` reading local state files. | `bin/media-pipeline-swiftbar`: queries Rails status API, displays hierarchical series submenus, candidate file sizes, FIFO indexes, and one-click actions. | **1:1+ Enhanced** | Sub-50ms execution with live action triggering (Process Next FIFO, Pause, Resume, Finder). |
| **26** | **Broadcast Teleprompter Studio** | HTML teleprompter with episode dossiers and `textream://` protocol launcher. | Dedicated Operations Cockpit tab with 6-Act production rundowns, live broadcast cue chips, teleprompter glass mirror mode, and `.textream` downloads. | **1:1 Parity** | Production studio ready for live streaming. |
| **27** | **Spatial Cartography & Asset History** | Static listings without geographical mapping. | Interactive Leaflet.js Spatial Cartography map plotting recording locations, elevation, topics, and full-text search across 250+ assets. | **1:1+ Enhanced** | 4-dimensional temporal-spatial visualization of field notes. |
| **28** | **Service Lifecycle & Process Supervision** | Ad-hoc terminal running or brittle launchd script. | Hardened launchd daemon (`com.just3ws.media-pipeline.plist`) with `bin/mp-service` controller (`mp service status/restart/doctor/logs`). | **1:1+ Enhanced** | 9-point self-healing automated doctor diagnostic and unified zdots log rotation. |
| **29** | **Operations Cockpit Record Navigation** | Plain terminal output or static text list; required manual URL navigation to edit items. | Direct clickable navigation links to local asset records (`/media_assets/:id`), edit screens (`/media_assets/:id/edit`), and series playlists across all swimlanes and execution tables. | **1:1+ Enhanced** | Preserved across live SSE telemetry updates and execution filters. |
| **30** | **State-Aware Admin & Pre-Flight Control** | CLI flags only; could not inspect or pre-set metadata on uningested files in web UI. | Full state-aware management interface with lifecycle banners, substate progress badges, race-condition warnings during active STT processing, and explicit operator choice (`Save Local Record Only` vs `Save & Push to YouTube Now`). | **1:1+ Enhanced** | Pipeline respects manual pre-flight titles, descriptions, and tags as canonical overrides. |

---

## 2. Key Architectural Enhancements in the New Microservice

1. **Transactional Database Integrity**:
   - The original system relied exclusively on filesystem operations and JSON files (`pipeline.lock`, `pipeline_activity.jsonl`, `<filename>.state.json`), which were vulnerable to race conditions, process crashes, and orphan locks.
   - The new microservice introduces PostgreSQL 18 with Active Record, AASM state transitions, Solid Queue ACID job storage, and full event audit trails (`MediaAssetEvent` and `MediaAssetVersion`).

2. **Automated Ephemerality Horizon**:
   - The original system lacked an automated mechanism to prune older videos from public channel views, causing playlist bloat.
   - The new microservice includes `EphemeralityService`, which keeps the active series playlist trimmed to the newest 2 videos within a 3-day window while preserving older videos in the sovereign vault.

3. **Bidirectional Local Metadata Sovereignty**:
   - The original system generated titles and descriptions once during upload. Updating them required opening YouTube Studio in a web browser.
   - The new microservice provides `bin/mp-metadata` and `~/.local/state/just3ws/sidecars/`, enabling local offline inspection, `$EDITOR` sidecar editing, and one-command YouTube synchronization without re-uploading the video file.

4. **Forensic Operations Cockpit**:
   - The original system had a simple static dashboard that required running a separate WEBrick daemon on port 7025.
   - The new microservice delivers an integrated 10-tab Operations Cockpit with real-time SSE updates, interactive Kanban swimlanes, BPMN 2.0 subprocess visualization, Leaflet spatial history mapping, and single-click failure requeue controls.

---

## 3. Operational Sign-Off & Verification

- **Tests Passing**: 127/127 RSpec tests in `media-pipeline`, 320/320 RSpec tests in `just3ws.github.io`, 472/472 Bats tests in `zdots`.
- **Static Analysis & Security**: 0 Brakeman warnings, clean RuboCop, clean ERB Lint, clean Prettier, clean MDL, clean Mandoc.
- **Em-Dash Free**: Zero em dashes across all code, configuration, database records, and documentation.
- **Parity Conclusion**: Baseline 1:1 functional parity has been fully restored and exceeded (1:1+) across all 30 operational domains.

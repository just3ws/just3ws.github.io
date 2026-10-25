<!-- ═══════════════════════════════════════════════════════════════════════
     CURRENT FOCUS - last updated 2026-10-25
     Cold-start resume state, canonical for every agent tool. Whoever closes
     a session rewrites this block in place - step one, before the wrap-up.
     Backlog + git log are truth for exact task status / SHAs; if this block
     contradicts them, trust them and fix the block.

     THIS REPO IS PUBLIC. This block is committed and world-readable - keep
     it to "what content/feature is being built". Anything about employment
     status, targeting, or career narrative goes ONLY in the local deep
     handoff, never here.

       In flight: verify against Backlog (`backlog/tasks/`).
       - JOB DETAIL DIAGNOSTICS MODAL, REQUEUE CONTROLS & DEVELOPER CONNECTION METADATA (2026-10-25):
         Enhanced Cockpit swimlane cards with forensic diagnostic modal, failure requeue actions, and developer connection metadata:
         - Interactive Job Diagnostics Modal:
           - Built accessible modal dialog in `app/views/dashboard/_tab_queue.html.erb` displaying filename, target series, file size, updated timestamp, 9 BPMN subprocess stages, error diagnostics with collapsible call stack, and full lifecycle event history table.
           - Built client-side controller in `_scripts.html.erb` with `openJobDetailModal(id)` and `closeJobDetailModal()`.
         - Single & Bulk Requeue Operations:
           - Added individual `🔄 Re-queue to Pending` action on failed quarantine cards and modal footer.
           - Added bulk `🔄 Requeue All` action in Failed Quarantine swimlane header.
           - Implemented `requeue` and `requeue_all_failed` in `OperationsController` resetting asset status to pending and re-triggering intake queue scanning.
           - Implemented `spec/requests/operations_spec.rb` verifying all operations endpoints; verified 108/108 RSpec tests passing in `media-pipeline`.
         - Structured Developer & Project Connection Metadata:
           - Embedded structured documentation and connection metadata in root HTML layouts (`_layouts/base.html`, `application.html.erb`) detailing Mike Hall's systems engineering focus, key open-source projects (Phalanx Duel, WWWorkRemote, The Sound Above & UGtastic, PVL, Media Pipeline), and direct contact channels.
           - Updated `llms.txt` with current project links, opportunities to connect, and zero em dashes.
         - Verification:
           - `media-pipeline`: 108/108 RSpec tests passing, clean Brakeman (0 warnings), clean RuboCop, clean ERB Lint, clean Mandoc, zero em dashes. Committed as `2608af2` and pushed to `main`.
           - `just3ws.github.io`: 320/320 RSpec tests passing, fast validation passing cleanly across 499 Markdown files, zero em dashes.

       - MEDIA PIPELINE CONTINUOUS CONVEYOR, SWIFTBAR RESTORATION, TELEPROMPTER STUDIO & CLEAN DELEGATION (2026-10-25):
         Completed end-to-end 4-step functional parity and boundary clean-up across Rails microservice and static site:
         - Step 1: Continuous Queue Conveyor & Query Bridge:
           - Chained ScanIntakeQueuesJob after asset processing in ProcessMediaAssetJob, eliminating idle conveyor gaps.
           - Bridged just3ws.github.io/bin/query_pipeline.rb to query Rails endpoint (http://127.0.0.1:32000/api/status) first with graceful local disk fallback.
         - Step 2: Full SwiftBar Capability Restoration:
           - Rebuilt media-pipeline/bin/media-pipeline-swiftbar with hierarchical series menus (candidates, file sizes in MB, FIFO index, failures).
           - Added dynamic YouTube quota headroom percentage and one-click operations (Process Next FIFO, Pause Queue, Resume Queue, Open Ingress in Finder, Open Lateral Sites).
           - Added pause and resume actions to OperationsController backed by SolidQueue::Queue.
         - Step 3: Broadcast Teleprompter Studio & Textream Parity:
           - Built SoundAboveCurriculumService loading 35 curriculum episodes, Minus One, Minus Zero, and database assets into Operations Cockpit.
           - Implemented interactive 6-Act Production Rundowns with live broadcast cues ([SCENE], [FREEFORM], [PAUSE], [SHOW]), auto-scrolling viewport, mirror flip, and font adjustments.
           - Added one-click textream:// protocol launcher and .textream multi-page JSON download.
         - Step 4: System Boundary Cleanup & Legacy Delegation:
           - Updated bin/pipeline media to delegate status, scan, live stream tailing, pause, and resume directly to Rails microservice (port 32000).
           - Annotated legacy scripts (intake_drive_video.rb, live_dashboard_streamer.rb, youtube-swiftbar) with clear deprecation and migration notices.
           - Resolved APFS FileProvider materialization fault via system cat copy; verified asset processing reaching 260 processed masters.
           - Verified 320/320 RSpec tests passing, fast validation passing across 499 Markdown files, zero em dashes.

       - CONFIGURATION-DRIVEN PIPELINE, POSTGRESQL 18 & RICH CONTEXTUAL SWIMLANES (2026-10-24):
         Eliminated hardcoded pipeline values, verified PostgreSQL 18 runtime, established YAML-driven architecture, and restored rich contextual swimlanes:
         - PostgreSQL 18 Runtime Confirmation & Dynamic Version Detection:
           - Confirmed active Homebrew database service is `postgresql@18` (PostgreSQL 18.0.6, port 5432).
           - Replaced legacy static "PostgreSQL 16" labels across navigation headers, footers, BPMN architecture diagrams,
             and layouts with dynamic Active Record database engine version detection (`ActiveRecord::Base.connection.database_version`).
         - Configuration-Driven Pipeline Stages & Subprocesses (`config/pipeline_stages.yml`):
           - Authored canonical specification defining 9 ordered processing stages (Ingress, Lock/FIFO, APFS Streaming,
             Ephemeral DSP, Whisper STT, Metadata & Chapters, YouTube API, Captions Sync, Cloud Archival & Release), 6 swimlane columns,
             and full Google Cloud quota budget parameters.
           - Built `PipelineConfigService` (`app/services/pipeline_config_service.rb`) to provide cached, strongly-typed
             accessors for stages, SLO targets, lock types, disk overheads, quota costs, and self-healing runbooks.
         - Restored Deeply Rich Contextual Swimlanes & BPMN Step Chain (`_tab_queue.html.erb`):
           - Reinstated the 6-column Kanban Swimlanes Grid (Staged, Pending FIFO, Processing In-Flight, Processed Deployed,
             Quota Cooldown, and Failed Quarantine) and interactive BPMN step bar.
           - Every swimlane card features rich internal subprocess state: FIFO queue position (`#1 NEXT IN LINE`),
             target series badge, file size in MB, full substate badge checklists (`[Ingress ✓] [DSP WAV ✓] [Whisper STT 🔄] [Metadata ⏳] [YouTube ⏳] [Captions ⏳] [Archive ⏳]`),
             duration, spatial geotags (`📍 lat, lng`), and direct YouTube video links.
           - Wired client-side SSE pulse listener in `_scripts.html.erb` to re-render swimlane cards dynamically in real time.
           - Refactored interactive Quota Budget Calculator to read daily limits and unit costs directly from `PipelineConfigService`.
         - ActionController::Live Connection Pool Safety:
           - Wrapped `PipelineStatusService.payload` queries inside `ActiveRecord::Base.connection_pool.with_connection`
             within `LiveStreamController#stream`, preventing SSE streaming threads from holding database connections during sleep intervals.
           - Optimized `PipelineStatusService.build_substate_badges` to evaluate in-memory model attributes, reducing query counts to zero.
         - APFS FileProvider Fault Recovery:
           - Upgraded `ProcessMediaAssetJob#stage_working_file` with immediate kernel-level system copy fallback upon detecting
             `Errno::EDEADLK` (dataless cloud placeholders), materializing multi-gigabyte virtual files in <1s without retries.
         - Verification & Deployment:
           - `media-pipeline`: 99/99 passing RSpec tests, 0 Brakeman warnings, clean linters (RuboCop, ERB Lint, Prettier, Mandoc),
             clean YAML, zero em dashes. Committed as `ee37e28` and pushed to `main`.
           - `just3ws.github.io`: 320/320 RSpec specs passing, fast validation passing cleanly across 499 Markdown files.

       - STANDALONE MEDIA-PIPELINE EXTRACTION, RAILS MIGRATION & SPATIAL CARTOGRAPHY COMPLETE (2026-10-24):
         Completely extracted, migrated, and verified the media intake and YouTube publishing pipeline
         into an independent, robust Rails 8 microservice (`media-pipeline`) backed by PostgreSQL 16:
         - Complete Standalone Microservice Architecture:
           - Booted out, disabled, and permanently removed fragile launchd daemon (`com.just3ws.ramblin-pipeline`).
           - Established dedicated service repo at `github.com/just3ws/media-pipeline` running on port 32000
             under Nginx TLS reverse proxy at `https://media-pipeline.localhost` with HTTP/2 via mkcert.
           - Configured launchd autostart daemon (`com.just3ws.media-pipeline.plist`) with `RunAtLoad` and `KeepAlive`
             logging directly to `~/.local/state/just3ws/media_pipeline_server.log`.
         - PostgreSQL Multi-Database Architecture & Strict 1-Item WIP Limits:
           - Multi-database PostgreSQL setup separating app data (`media_pipeline_development`) from Solid Queue
             (`media_pipeline_development_queue`) with zero connection cross-talk.
           - Hard single-item concurrency semaphore (`limits_concurrency to: 1`, `threads: 1` on `media_processing`).
           - Enforced 10 GB disk headroom safety floor before any ingest, with complete scratch cleanup in ensure blocks.
           - User-space 4 MB chunk streaming avoiding macOS FileProvider `fcopyfile` APFS deadlocks on virtual files.
         - 10-Tab Operations Cockpit & Spatial Cartography (`app/views/dashboard/`):
           - Full 10 tabs active: Live Ingress, Teleprompter, Catalog, Quality Audit, Live Studio, Workshop,
             Analytics, Spatial Cartography, BPMN 2.0 SVG Workflow, and 4D Panoramic System Cartography.
           - Integrated Leaflet.js Spatial History Map tracing recording locations and spoken topics over time across
             250 backfilled historical assets with full-text transcript search.
           - Added `TranscriptEnrichmentService` for YouTube-compliant chapter generation and takeaways.
           - Resolved Mission Control Jobs `/jobs/failed` routing with automatic redirect to `/jobs/failed/jobs`.
         - Cross-System Verification & CI:
           - `media-pipeline`: 86/86 RSpec specs passing, 0 Brakeman warnings, clean Mandoc, clean ERB Lint,
             clean Prettier, zero em dashes. Committed as `6da6868` and pushed to `main` (GitHub Actions CI 100% green).
           - `~/.swiftbar/media-pipeline.30s.sh`: canonical SwiftBar symlink verified executing in <50ms with live telemetry.
           - `just3ws.github.io`: 320/320 RSpec specs passing, fast validation passing cleanly across 499 Markdown files.

       - STANDALONE MEDIA-PIPELINE EXTRACTION & RAILS MIGRATION (2026-10-24):
         Completely extracted and migrated the media intake and YouTube publishing pipeline
         from this static Jekyll repository into an independent Rails 8 microservice (`media-pipeline`):
         - Clean System Boundaries & Legacy Daemon Removal:
           - Booted out, disabled, and permanently removed fragile launchd daemon (`com.just3ws.ramblin-pipeline`)
             that failed on unescaped filenames with spaces, quotes, and symbols.
           - Established dedicated service repo at `github.com/just3ws/media-pipeline` running on high port 32000
             under Nginx reverse proxy at `https://media-pipeline.localhost` with HTTP/2 and TLS via mkcert.
           - Configured launchd autostart daemon (`com.just3ws.media-pipeline.plist`) with `RunAtLoad` and `KeepAlive`
             logging directly to `~/.local/state/just3ws/media_pipeline_server.log`.
         - PostgreSQL Migration & Single-Item WIP Concurrency:
           - Migrated Active Record database adapter to PostgreSQL (`media_pipeline_development` and `test`).
           - Enforced strict single-item WIP limits (`limits_concurrency to: 1`, `threads: 1` on `media_processing` queue).
           - Added 10 GB disk headroom safety floor and safe stream chunking in `ProcessMediaAssetJob` to eliminate disk starvation.
           - Ingested 256 canonical archive assets with full-text transcripts from `just3ws.github.io`.
         - Modern Rails Architecture & Tooling:
           - Solid Queue (background jobs), Solid Cache, and Solid Cable (ActionCable websockets) backed by PostgreSQL.
           - Integrated Ahoy visits and events cross-correlated with OpenTelemetry `trace_id` and `span_id`.
           - Mounted PgHero (`/pghero`) for database query profiling and Mission Control Jobs (`/jobs`) for job orchestration.
           - Added Chartkick interactive visual analytics for catalog distribution, remote sync state, and recording timeline.
           - OpenTelemetry SDK and OTLP exporter streaming to zdots `otelcol-contrib` (port 4318), Jaeger (16686),
             and OpenObserve (5080).
           - Structured JSON logging via Lograge with trace and span correlation, annotated by Marginalia SQL tags.
           - Unified namespaced CLI suite (`mp`, `mp-status`, `mp-scan`, `mp-sync`, `mp-backup`, `mp-mcp`, `mp-swiftbar`, `mp-verify`).
           - Strongly-typed GraphQL API (`/graphql`) with interactive GraphiQL IDE (`/graphiql`) and exported SDL (`docs/schema.graphql`).
           - Specialized operational agent skills in `.agents/skills/`: `media-pipeline-operator`, `media-metadata-curator`, `media-pipeline-auditor`.
           - Dual licensing: GNU AGPLv3 for software source code, CC BY-NC-SA 4.0 for documentation, schemas, and architecture.
         - Cross-Repository Verification:
           - `media-pipeline`: 76/76 RSpec specs passing, 0 Brakeman warnings, clean Mandoc lint, clean ERB/Prettier, zero em dashes.
           - `media-pipeline` GitHub Actions CI: 100% green across Static Analysis/Linters and RSpec/PostgreSQL service container.
           - `just3ws.github.io`: 320/320 RSpec specs passing, fast validation passing cleanly across 499 Markdown files,
             user SwiftBar shim updated to execute `media-pipeline-swiftbar`.

       - TONE AUDIT & FIRST-PERSON VOICE RESTORATION (2026-10-21):
         Audited primary public hiring surfaces for tone and person-perspective
         consistency; committed and pushed as ae1acac3:
         - `_data/home.yml`: Visitor path card 2 title rewritten to visitor's voice.
         - `about/index.html`: Removed year-count framing ("two decades") per CODEX.md;
           replaced with technology-shift framing.
         - `_data/case_studies.yml`: Purged third-person "Mike conceived/He recovered"
           throughout, restored first-person throughout.
         - `_data/portfolio.yml`: Chicago Code Camp card rewritten to telegraphic
           professional framing from casual self-deprecating prose.
         - `index.html`: Page title and meta description updated to canonical
           "Staff Software Engineer" title per CODEX.md.
         - 320/320 RSpec passing, fast validation passing, zero em dashes.
         - Pipeline state: quota_cooldown_blocked (YouTube quota exhausted).
           Two Phalanx Duel videos (Conrad Hall walkthrough + SCMC demo) are
           staged and pending in local Maildir queue. Both will process
           automatically after quota reset at 2:00 AM CT. No action needed.

       - LIGHTWEIGHT MEDIA PIPELINE QUERY ENGINE VIA CLI & MCP (2026-10-21):
         Established fast, unified CLI and MCP query capabilities for the media intake and YouTube publishing pipeline:
         - Standalone Query Engine (`bin/query_pipeline.rb`):
           - Implemented dual-mode inspection: probes live `live_dashboard_streamer.rb` (port 7025) via HTTP in <5ms, falling back gracefully to direct disk inspection across Maildir queues (`~/.local/var/media_intake` and Google Drive cloud archive), state locks, and YouTube quota telemetry if the daemon is offline.
           - Supports output formats: human-readable terminal dashboard, `--compact` / `-c` (single-line status pulse), and `--json` / `-j` (pure structured JSON).
           - Supports targeted filters: `--queues`, `--quota`, `--worker`, `--activity [N]`, and `--target <name>`.
         - Unified Pipeline Router Integration (`bin/pipeline`):
           - Added `query` action to `bin/pipeline media query` and flat alias `bin/pipeline query`.
           - Updated `bin/pipeline media status` to output the comprehensive live intake queue, concurrency lock, worker state, and YouTube quota status.
         - Repository MCP Server Integration (`bin/mcp_server.js`):
           - Registered tool `query_media_pipeline`: allows AI agents and MCP clients to query live intake queues, worker state, quota cooldown, and recent events with section, format, and target arguments.
           - Registered resource `site://pipeline/status`: returns real-time JSON status payload with queue breakdown, worker lock, quota cooldown timer, and recent activity log.
           - Updated `bin/verify_mcp_spec.js` self-verification suite to assert tool and resource behavior over MCP stdio client.
         - Testing & Verification:
           - Authored `spec/youtube/query_pipeline_spec.rb` with 13 unit tests covering CLI flags, disk fallback, pipeline routing, zero em dashes, and MCP tool/resource contracts.
           - 320/320 RSpec tests passing cleanly, fast validation passing across 499 Markdown files, zero em dashes across all edits.

       - PHALANX DUEL YOUTUBE PUBLISHING & MEDIA INTAKE ROBUSTNESS (2026-10-21):
         Resolved teleprompter director formatting, fixed media intake sidecar resolution, and published first Phalanx Duel video to YouTube:
         - Director Teleprompter Formatting & Spec Calibration:
           - Restructured teleprompter scripts across Episode 00, 01, Fluffle Precursor, and Phalanx Duel into `[SCENE]`, `[FREEFORM]`, `[PAUSE]`, and `[SHOW]` director-cue formats for live broadcast readability and ad-lib anchoring.
           - Synchronized `teleprompter_script` blocks across episode YMLs and updated `spec/youtube/textream_teleprompter_spec.rb` characterization tests.
         - Fluid Layout Measure & Home Page Calibration:
           - Recalibrated home hero lede to direct technical framing (opaque coupling, distributed failures, risky transactional workflows) and tightened operating rhythm summaries.
           - Refactored container max widths to use `var(--container-max-width, 84rem)` with `clamp()` padding, while enabling edge-to-edge full width for local operations dashboards.
         - Media Intake Sidecar Discovery & YouTube Description Guard:
           - Identified root cause of YouTube 400 `invalidDescription` upload error on Phalanx Duel demo videos: `find_sidecar` checked `.txt` before `.yml`, inadvertently picking up raw transcription text and causing fallback description generation to exceed YouTube's 5,000 character limit.
           - Fixed `find_sidecar` in `bin/intake_drive_video.rb` to prioritize structured `.yml` and `.yaml` sidecars before `.txt` fallbacks.
           - Added YouTube API v3 description sanitization to strip angle brackets and bound descriptions to 5,000 characters.
           - Added unit tests in `spec/youtube/media_intake_pipeline_spec.rb` verifying sidecar discovery precedence and description bounds.
         - Phalanx Duel Asset Publication:
           - Published Conrad Hall's Phalanx Duel early version walkthrough (`CdYwA0SG34M`) to YouTube playlist `PLHenvAZhJjHo`, generated interactive transcript (`_data/transcripts/phalanx-duel-phalanx-duel-early-version-walkthrough-with-conrad-hall.yml`), registered asset in `_data/video_assets.yml`, and mirrored master to Google Drive cloud archive while releasing local NVMe SSD bytes.
           - Successfully uploaded SCMC demonstration demo video (`eH6VQa2Od3E`) to YouTube, safely quarantined to Google Drive cloud archive pending playlist item quota reset.
         - Verification:
           - 307/307 RSpec tests passing, fast validation passing cleanly across 499 Markdown files, zero em dashes across all edits.

       - HISTORICAL GROUND TRUTH RESTORATION & AGENT HALLUCINATION PURGE (2026-10-20):
         Purged agentic hallucinations across recording equipment, creator communications, and presentation history, restoring authentic ground truth:
         - Dead Rabbit Radio Provenance & Direct Outreach (`_posts/2026-10-16-the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster.md`, `_data/episodes/errata-fluffle-precursor.yml`, `obs/teleprompter/errata-fluffle-precursor.textream`):
           - Purged fabricated email address (`DeadRabbitRadio@gmail.com`), fabricated email exchange, and invented "accessible for deaf and hard-of-hearing listeners" rationale.
           - Restored authentic history: Mike chatted with Jason Carpenter directly on Discord to share the fan-driven distributed transcription experiment across his home Raspberry Pi cluster and ensure Jason was comfortable with the project.
         - Authentic Recording Equipment & SCNA 2011 Origin (`_posts/2026-10-16-the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster.md`, `docs/prompts/ramblin-amblin-topics.md`, `bin/sync_topic_prompts.rb`, `AGENTS.md`):
           - Purged fabricated "wireless lavalier microphones" and exaggerated "35 pounds of camera gear".
           - Restored authentic physical reality: SCNA 2011 was recorded directly on the built-in microphone and camera of a 2010 MacBook Pro using Apple Photo Booth; gear varied across conferences and usually settled on a stationary microphone after the SCNA 2011 series.
         - Phalanx Duel SCMC Presentation & AI Tooling Experiment (`_posts/2026-10-20-phalanx-duel-make-the-rules-legible-scmc-presentation-and-game-architecture.md`, `_data/episodes/errata-phalanx-duel.yml`, `obs/teleprompter/errata-phalanx-duel.textream`):
           - Purged hallucinated OBS multi-camera broadcast pipeline testing from the SCMC retrospective (Mike did not know about OBS at the time).
           - Removed misplaced Zarathustra philosophical treatise from Phalanx Duel article, restoring Zarathustra strictly as Mike's internal philosophical prompt for resume and hiring surfaces (safe not scary, quiet competence, unblocking squads).
           - Grounded SCMC talk in the authentic practitioner experiment: testing how much of a technical presentation, slides, and demo assets can be built using AI-augmented developer tooling, and the meta lesson on generative capabilities versus hallucinations.
         - YouTube Pipeline Cooldown Pre-flight & Dry-Run Infinite Loop Fix (`bin/live_dashboard_streamer.rb`, `bin/intake_drive_video.rb`):
           - Identified why YouTube Studio playlist `PLHenvAZhJjHo` is currently empty: daily YouTube Data API upload quota is in cooldown until 2:00 AM CT (00:00 PT); 2 videos are fully transcribed, staged, and queued in pending/.
           - Added `quota_in_cooldown?` pre-flight guard to `bin/live_dashboard_streamer.rb` to prevent continuous autonomous worker spawning during quota cooldowns.
           - Added `processed_in_run` set tracking to `bin/intake_drive_video.rb` to prevent infinite looping over pending candidates during `--dry-run` executions.
         - Verification:
           - 305/305 RSpec tests passing, fast validation passing cleanly across 499 Markdown files, Jekyll build clean across 1,060 pages, verified localhost returns HTTP 200 with zero em dashes.

       - ALT.NET MANIFESTO PROVENANCE & HISTORICAL LINK RECOVERY (2026-10-20):
         Identified and resolved 404 Wayback Machine broken link for David Laribee's original Alt.NET Manifesto:
         - Verified authentic historical URL and timestamp via Wayback Machine CDX API: canonical post was published on April 10, 2007 at `laribee.com/blog/2007/04/10/altnet/` (not April 27, and not slug `altnet-manifesto`).
         - Updated historical archive link across `series/the-sound-above/episode-01.html`, `_data/episodes/episode-01.yml`, and `youtube/dashboard.html` to verified HTTP 200 capture (`https://web.archive.org/web/20070701125236/http://laribee.com/blog/2007/04/10/altnet/`).
         - Verified clean fast validation across 499 Markdown files, clean Jekyll build across 1,060 pages, and verified localhost returns HTTP 200 with zero em dashes.

       - PHALANX DUEL YOUTUBE PLAYLIST INTAKE & CONRAD WALKTHROUGH PIPELINE (2026-10-20):
         Configured dedicated Phalanx Duel YouTube target, automated ztranscribe speech-to-text processing, and staged/queued demonstration assets:
         - Target & Playlist Infrastructure (`_data/media_intake_targets.yml`, `bin/intake_drive_video.rb`):
           - Configured `phalanx-duel` intake target under channel `@whoistechcmty` with YouTube Studio playlist `PLHenvAZhJjHo`, category 28, and custom vocabulary whisper prompts for card rules and domain terms.
           - Established Maildir queue directories (`staged`, `pending`, `processing`, `processed`, `failed`, `blocked`) across both local NVMe SSD (`~/.local/var/media_intake/whoistechcmty/phalanx-duel`) and Google Drive cloud archive (`My Drive/Media Intake/whoistechcmty/phalanx-duel`).
           - Enhanced `bin/intake_drive_video.rb` to pass target-specific transcription prompts and support custom sidecar descriptions and tags.
         - Asset Ingestion & Forensic Audio STT:
           - Ingested Conrad Hall's early version gameplay walkthrough (`phalanx-duel-early-walkthrough-conrad-hall.mp4`, 68.5 MB) from `~/ai/inbox/conrad-phalanx-duel/0420.mp4`, generating complete transcripts (`.txt`, `.vtt`, `.srt`, `.json`, `.csv`) via local `ztranscribe` in 33.8s on Apple Silicon Metal.
           - Ingested the programmatic SCMC presentation demo (`phalanx-duel-make-the-rules-legible-demo.mp4`, 18.2 MB) from `assets/downloads/phalanx-duel-demo.mp4`, verifying subtitles and generating complete transcripts in 14.2s.
           - Authored companion YAML metadata sidecars with public context (Conrad Hall, 15 years old, high school sophomore taking AP Computer Science, co-developer).
           - Staged and queued assets across local NVMe storage and Google Drive, verified via dry-run simulation and live dashboard telemetry.
         - Cross-Surface Linking:
           - Linked YouTube series playlist (`PLHenvAZhJjHo`) across `phalanx-duel/index.html`, `series/the-sound-above/index.html`, `_posts/2026-10-20-phalanx-duel-make-the-rules-legible-scmc-presentation-and-game-architecture.md`, and `_data/episodes/errata-phalanx-duel.yml`.
         - Verification:
           - 305/305 RSpec tests passing, fast validation passing across 499 Markdown files, Jekyll build clean across 1,060 pages, zero em dashes across all edits.

       - QUIET CRAFTSMANSHIP, PSYCHOLOGICAL SAFETY & TOP-LEVEL PAGES ALIGNMENT (2026-10-20):
         Calibrated public technical positioning around quiet competence, psychological safety, and generous mentorship ("safe not scary, Zarathustra's child's voice"), while formalizing Phalanx Duel as an Errata broadcast episode and completing a holistic audit across all top-level surfaces:
         - Safety-First Tone & Quiet Competence Calibration (`_data/home.yml`, `about/index.html`, `_data/resume/summary.yml`):
           - Recalibrated homepage hero lede, operating rhythm, and through-line away from intimidating, high-intensity crisis framing ("distributed failures, risky transactions, opaque coupling") toward calm, reassuring engineering stewardship ("quiet clarity, lowering operational stress, safe changes, psychological safety").
           - Reframed the 3-step operating rhythm around team empathy: *Stabilize* (lower operational stress, make daily production predictable), *Understand* (build a legible picture so no engineer carries the mental load alone), and *Improve* (ship small, reversible changes that leave code gentler than we found it).
           - Added explicit core value in `about/index.html` celebrating psychological safety, genuine curiosity, and Zarathustra's child's voice: meeting legacy systems with wonder rather than judgment, removing fear from production. Cleaned up dangling HTML tags.
           - Recalibrated canonical resume summary (`_data/resume/summary.yml`) around Staff Software Engineering for calm, safe change, unblocking squads, and lowering pager stress.
         - Production Case Studies & Systems Proof Audit (`case-studies/index.html`, `_data/case_studies.yml`):
           - Aligned title and headers around calm systems leadership, architectural legibility, operational predictability, and team enablement.
           - Updated case study summaries, distinctive contributions, and outcomes to emphasize psychological safety, unblocking engineering squads, and replacing on-call ambiguity with calm, legible evidence.
         - Writing & Secondary Top-Level Surfaces Harmonization (`writing.html`, `linkedin.html`, `series/the-sound-above/index.html`, `contact/index.html`):
           - Updated writing header and description to focus on practical systems craftsmanship, lowering operational stress, and quiet technical stewardship.
           - Verified LinkedIn profile mapping and export tooling for 100% parity with canonical ATS resume and CODEX rules (Approach A, exactly 2 independent projects).
         - Phalanx Duel Errata Episode & Long-Form Systems Essay (`_posts/2026-10-20-phalanx-duel-make-the-rules-legible-scmc-presentation-and-game-architecture.md`, `_data/episodes/errata-phalanx-duel.yml`):
           - Authored comprehensive Errata episode post tracing the full arc: Camp Tesomas July 2022 picnic table genesis, executable Ruby combat rules, server-authoritative TypeScript engine, Go CLI client, SCMC presentation, and testing the broadcast presentation pipeline for The Sound Above.
           - Integrated Zarathustra's Three Metamorphoses (Camel, Lion, Child) into software architecture: why tabletop games represent the child's voice, and how making rules legible removes defensive friction and fear from systems change.
           - Linked episode across primary navigation (`_data/navigation.yml`), `The Sound Above` curriculum index (`series/the-sound-above/index.html`), wayfinding dropdown (`_includes/series_wayfinding.html`), localhost subnav (`_includes/localhost-subnav.html`), and command palette (`_includes/command-palette.html`).
         - Verification:
           - 305/305 RSpec tests passing, Jekyll build clean across 1,060 pages, HTML-Proofer passing 100% across 1,051 files and 1,363 internal links with 0 errors.
           - All localhost surfaces returning HTTP 200, zero em dashes across all edits.

       - LOCAL DISK HYGIENE, QUOTA COOLDOWN PRE-FLIGHT GUARDS & CLOUD QUARANTINE (2026-10-20):
         Root-caused and resolved local NVMe SSD space exhaustion (~6.3 GB free on 228 GB drive), establishing deterministic pre-flight guards, cloud quarantine offloading, and storage hygiene integration:
         - Local SSD Starvation Root Cause & Pipeline Defense (`bin/intake_drive_video.rb`, `bin/youtube_sweeper.rb`, `bin/live_dashboard_streamer.rb`):
           - Identified root cause: when YouTube API daily quota was exhausted (`upstream_quota_blocked`), `intake_drive_video.rb` continued pulling multi-gigabyte video masters from Google Drive onto the fast NVMe SSD (`~/.local/var/media_intake`) and moving them into `blocked/`, leaving 15.2 GB parked locally.
           - Implemented `quota_in_cooldown?` pre-flight check in `bin/intake_drive_video.rb`: pauses queue ingestion when upstream quota exhaustion is active until the 2:00 AM CT (00:00 PT) reset, preventing redundant processing and disk starvation.
           - Implemented `available_disk_space_bytes` and `MIN_FREE_DISK_BYTES` (5.0 GB safety floor): halts intake workers before locking or pulling files if local NVMe disk headroom is degraded.
           - Implemented cloud quarantine offload on `upstream_quota_blocked`: relocates large video files directly to Google Drive `cloud_archive_path/<channel>/<target_name>/blocked/<filename>`, retaining only lightweight `.blocked.json` and `.state.json` sidecars on local SSD.
           - Enhanced `bin/youtube_sweeper.rb` and `bin/live_dashboard_streamer.rb` cooldown unblockers to detect cloud-quarantined video masters and unblock them sequentially into cloud `pending/`, keeping heavy assets off local NVMe SSD until FIFO processing begins.
           - Enhanced `--drop` (`--ingest`) to route phone-to-laptop incoming media directly into Google Drive `cloud_archive_path/<channel>/<target>/pending/`, supporting `-m` / `--move` from `~/Downloads` to prevent duplicate local storage while letting Google Drive handle backup and streaming.
           - Implemented ephemeral local working master release in Step 11: once master is bit-for-bit verified mirrored to Google Drive `cloud_archive_path/.../processed/YYYY-MM/`, the heavy video file on local NVMe SSD is released (`FileUtils.rm_f`), keeping only the lightweight `.receipt.json` locally and ensuring local disk holds media strictly while actively processing.
         - Physical Storage Recovery & Safe Archival:
           - Byte-verified and safely archived 4 staging `.mov` files (1.6 GB) from `~/Movies/` to Google Drive `My Drive/Media Intake/archive/obs_staging/` before pruning local copies.
           - Confirmed bit-for-bit parity of `~/ai/dehum/` masters (`VID_20261009_111445043.mp4` and `VID_20261009_111445043_fixed.mp4`, 6.1 GB) with Google Drive cold storage (`Google Drive / ai / dehum /`) and YouTube master `8LYHo1dOkMo`, pruned local duplicate files, and updated pointer documentation.
           - Safely relocated active blocked video `VID_20261019_102821897.mp4` (1.4 GB) to Google Drive `blocked/`, bringing local blocked video bytes to 0.
           - Free disk space recovered from 6.3 GB to 13.0 GB available.
         - Unified System Storage Hygiene (`~/.config/zsh/bin/zdots-hygiene`):
           - Added Action 7 to `zdots-hygiene`: audits and purges stale intermediate audio scratch files (`~/.local/state/just3ws/scratch/*/*.wav`) older than 2 days.
           - Committed update to zdots repo (`~/.config/zsh`, commit `f0aed78`).
         - Verification:
           - 305/305 RSpec tests passing (33 intake/sweeper specs passing in 1.98s), fast validation passing cleanly across 498 Markdown files, zero em dashes across all edits.

       - ROLLING HORIZON SWEEPER, IDENTITY CONSOLIDATION & DIGITAL GARDEN DISCLOSURE (2026-10-20):
         Resolved playlist ephemerality sweeper fallback, grounded root domain origin and identity consolidation, and recalibrated digital garden AI disclosures:
         - YouTube Rolling Horizon Sweeper Fallback & Compliance Wire-up (`bin/youtube_sweeper.rb`, `bin/live_dashboard_streamer.rb`, `bin/lib/youtube_deduplicator.rb`):
           - Root-caused why the "dragging window" (ephemerality rolling horizon) was not active on YouTube Studio playlist `PLNtb969T2-l0` (`Ramblin' & Amblin'`):
             1. The scheduled 15-minute compliance sweeper in `bin/live_dashboard_streamer.rb` omitted `--sweep-ephemerality` from its execution arguments.
             2. `bin/youtube_sweeper.rb` did not enable rolling ephemerality by default under `--sweep`.
             3. During YouTube Data API quota cooldowns, `fetch_playlist_items_ytdlp` omitted `publishedAt` and `videoPublishedAt`, causing `plan_rolling_horizon_retirement` to default all item ages to 0 and retain all videos indefinitely.
           - Enhanced `fetch_playlist_items_ytdlp` to extract ISO timestamps from title dates (`\b(\d{4}-\d{2}-\d{2})\b`) or cross-reference `@deduplicator.registered_assets`, correctly computing item ages and retirement horizons during quota cooldowns.
           - Enabled `--sweep-ephemerality` by default under `--sweep` and wired it directly into `bin/live_dashboard_streamer.rb` scheduled compliance loop.
           - Added `:registered_assets` reader to `YouTubeDeduplicator`.
         - Sovereign Identity & Root Namespace Grounding (`about/index.html`, `docs/biographical-and-service-provenance.md`):
           - Verified and documented 26 years of unbroken WHOIS ownership for `just3ws.com` (registered October 4, 2000).
           - Preserved authentic origin phrase from the dawn of the dot-com era: "just three 'W's changed the world".
           - Consolidated `just3ws.com` as the canonical root namespace for all independent engineering, writing, and archival work, resolving legacy handles (`@whoistechcmty`) and sub-platforms back to the sovereign core.
         - Digital Garden AI Disclosure Calibration (`_layouts/post.html`, `docs/ai-content-disclosure-and-provenance.md`):
           - Re-aligned disclosure banner with Mike Hall's explicit practitioner voice: acknowledging that claiming to have personally line-edited every word or guaranteed every claim is inaccurate, curating the digital garden where "parts of the garden grow faster than others, working through the process but there are no guarantees."
         - Resume Project Consolidation & Local AI Orchestration Purge (`_data/resume/ats.yml`, `_data/resume/timeline.yml`, `exports/resume.md`):
           - Purged lingering `agent-tooling` ("Local AI Orchestration & Developer Runtime") entries from all resume sources and exports, keeping only the two core projects (`phalanx-duel` and `technical-conversation-archive`).
           - Recompiled 5 archetype resumes, ATS exports, and CareerOS datalake (100% highlight parity across 28 positions, 0 errors).
         - Broadcast Readiness Verification for Episodes -1, 0, and 1 (`bin/stage_episode_workflow.rb`, `obs/teleprompter/`):
           - Verified all three opening episodes through pre-broadcast staging gates:
             - Episode -1 (*The Fluffle Precursor: Distributed whisper.cpp & Dead Rabbit Radio*): 6-act teleprompter verified (`obs/teleprompter/errata-fluffle-precursor.textream`), OBS overlay simulated, 50 API units.
             - Episode 0 (*The Mirage of Competence: AI Slop & Domain Boundaries*): 6-act teleprompter verified (`obs/teleprompter/episode-00.textream`), OBS overlay simulated, YouTube broadcast `XS7EZ1eWH4U` cued, 100 API units.
             - Episode 1 (*The First Room: Chicago Alt.NET with Sergio Pereira*): 6-act teleprompter verified (`obs/teleprompter/episode-01.textream`), OBS overlay simulated, primary asset `qOHdZKz1WFw` aligned, YouTube broadcast `eGXG7Qu4G1E` cued, 100 API units.
           - Confirmed zero em dashes across all compiled `.textream` documents and dossier manifests.
         - Verification:
           - 302/302 RSpec tests passing, fast validation passing cleanly across 498 Markdown files, Jekyll build clean across 1,045 pages, zero em dashes across all edits.

       - DASHBOARD QUEUE RESTORATION, CI PIPELINE REPAIR & FLUID LAYOUT EXPANSION (2026-10-20):
         Restored live media intake visibility across dashboard and SwiftBar, repaired GitHub Actions CI gate failures, expanded browser layout measure, and synthesized the sovereign verification continuum into Part 1:
         - Dual-Queue Intake Search Foundation (`bin/live_dashboard_streamer.rb`, `bin/youtube_pipeline.rb`, `bin/intake_drive_video.rb`, `bin/youtube-swiftbar`):
           - Fixed empty `#tab-queue` on `https://www.just3ws.localhost/youtube/dashboard/`: updated queue collectors to inspect both local SSD (`base_path: ~/.local/var/media_intake`) and Google Drive (`cloud_archive_path`), surfacing all 7 pending videos across live SSE telemetry (`/telemetry.json`), static fallbacks, and SwiftBar.
           - Ensured `intake_drive_video.rb` FIFO queue worker and status inspector discover pending files across both directories while staging active processing on fast NVMe SSD.
         - GitHub Actions CI Gate Repair (`.github/workflows/deploy.yml`, `spec/data/ecosystem_datalake_spec.rb`, `spec/youtube/swiftbar_spec.rb`, `spec/youtube/media_intake_pipeline_spec.rb`):
           - Root-caused and resolved the 9 failing specs in GitHub Actions run `39466319990`:
             - Added `GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` to the CI verification step in `deploy.yml`.
             - Guarded macOS-only SwiftBar user shim tests in `spec/youtube/swiftbar_spec.rb` when running on `ubuntu-latest`.
             - Guarded local zdots `ztranscribe` binary check in `spec/youtube/media_intake_pipeline_spec.rb` on CI runners.
             - Guarded local workstation datalake and DuckDB execution in `spec/data/ecosystem_datalake_spec.rb` when running in headless CI environments.
           - Verified all 302/302 RSpec examples passing cleanly in CI simulation (`CI=true bundle exec rspec`) and locally.
         - Fluid Measure & Ergonomic Layout Expansion (`_sass/_p_base_layout.scss`):
           - Lifted the restrictive `68ch` clamp off `article`, expanding `article`, `.page`, and `.post` to fluid `var(--container-max-width, 84rem)` across desktop viewports.
           - Maintained comfortable ergonomic reading measure (`76ch` to `78ch`) for long-form prose paragraphs while allowing data tables, pre/code blocks, diagrams, and callouts to expand comfortably.
           - Removed the `50rem` restriction on `.post-excerpt`, allowing `/writing/` (`writing.html`) and `/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/` to use browser width naturally.
         - Sovereign Verification Series Synthesis in Part 1 (`_posts/2026-10-12-under-the-high-tension-wires-forensic-acoustics-and-craftsmanship.md`):
           - Added concluding synthesis section connecting Part 1 to the out-of-sample field re-test under the 345kV conductors, the dual-model divergence, the meters vs yards trap, the digital theremin metaphor, bounded physical hardware hygiene, Part 2, Part 3, and the project index at `/series/ai-competence/`.
         - Localhost Verification:
           - Jekyll build passing cleanly across 1,049 pages; verified live on `https://www.just3ws.localhost/youtube/dashboard/`, `https://www.just3ws.localhost/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/`, and `https://www.just3ws.localhost/writing/` (all HTTP 200).
           - Fast validation passing cleanly across 498 Markdown files, zero em dashes across all edits.

       - AUTONOMOUS STORAGE HYGIENE MONOGRAPH SYNTHESIS & AI DISCLOSURE RECALIBRATION (2026-10-20):
         Synthesized the autonomous storage control plane monograph into the sovereign verification series and recalibrated site AI disclosure banners for candid, authentic voice:
         - Control Plane Monograph Synthesis (`docs/architecture/autonomous-storage-hygiene-and-self-evolving-os-architecture.md`, `series/ai-competence/index.html`):
           - Grounded the philosophical thesis of sovereign verification in bounded physical hardware: operating on an Apple Silicon MacBook Air with a finite 228 GB primary SSD where unchecked pipeline residue poses an existential risk to system stability.
           - Integrated the 7 semantic storage buckets (`Root`, `Models`, `Docker`, `Ingest`, `Caches`, `Logs`, `Backups`), the hygiene triad (`zdots-storage`, `zdots-hygiene`, `log-rotate`), multi-tier guardrails (The Tilde Shield, Anti-Bitrot structural signatures, The Schrute Test), and the Dual-AI symbiosis (zero-cost on-device `whisper.cpp` / `nomic-embed` paired with strategic cloud frontier reasoning).
           - Documented the Virtuous Loop: harvesting intellectual lessons into `~/my` before intermediate WAV chunk eviction and zstd log compaction (85%+ compression ratios).
         - Authentic AI Warning Blurb Recalibration (`_layouts/post.html`, `docs/ai-content-disclosure-and-provenance.md`):
           - Replaced bureaucratic boilerplate with Mike Hall's candid authorial voice: ironically acknowledging the meta-dissonance of using an AI assistant to warn readers about the epistemic limits of AI ("what is even entirely 'pure' text anymore?").
           - Framed the site as an open experiment in learning in public, applying safety protocols while remaining humble and actively welcoming suggestions for tighter boundaries.
         - Localhost Verification:
           - Jekyll build passing across 1,049 pages; verified live on `https://just3ws.localhost/series/ai-competence/` (HTTP 200) and `https://just3ws.localhost/docs/architecture/autonomous-storage-hygiene-and-self-evolving-os-architecture/` (HTTP 200).
           - Fast validation passing cleanly across 498 Markdown files, zero em dashes across all edits.

       - SOVEREIGN VERIFICATION PROJECT OVERVIEW & ARCHIVAL INDEX PUBLICATION (2026-10-20):
         Built out the overarching project index page and curriculum hub at `/series/ai-competence/` (`series/ai-competence/index.html`), unifying the complete 3-part AI Competence & Sovereign Verification series:
         - Overarching Project Index & Provenance Surface (`series/ai-competence/index.html`):
           - Curated the complete 3-part series: Part 1 (*Under the High-Tension Wires*), Part 2 (*The Mirage of Competence: Sovereign Verification and the Meters vs Yards Trap*), and Part 3 (*The Digital Theremin: Attention Bleed, Uncanny Boundaries, and the Low-Trust Panopticon*).
           - Anchored direct links to historical sources on GitHub (`just3ws/dehum` and `just3ws/just3ws.github.io`), critical git commit diffs (`f152d11`, `fff9cd58`, `e410b77d`, `2447163a`, `4124ebef`, `c6c060fe`), and primary field transcripts (`ramblin-amblin-ok-next-experiment.yml`).
           - Documented Google Drive storage migration architecture: transitioning from macOS CloudStorage FileProvider virtual mount stalls to fast local NVMe SSD queues (`~/.local/var/media_intake`) with polite POSIX nice 15 / macOS Darwin Background QoS scheduling and asynchronous Google Drive mirroring.
           - Established the Epistemic Drift vs Invariant Continuity Matrix: contrasting day-1 generative hallucinations (quartz crystal clock drift) against day-8 verified physical invariants (dual-mic hardware geometry, 60Hz utility AC harmonics) and the digital theremin operating framework.
         - Verbatim Authorial Quote Grounding:
           - Embedded Mike Hall's raw console and field notes as verbatim blockquotes across Part 2 and Part 3 without over-elaboration, preserving authentic authorial voice and verifiable provenance.
         - Site Navigation & Localhost Verification:
           - Cross-linked from `/dehum/index.html` (header nav and hero CTA) and site primary navigation (`_data/navigation.yml`).
           - Built across 1,048 pages and verified live on `https://just3ws.localhost/series/ai-competence/` (HTTP 200).
           - Fast validation passing cleanly across 497 Markdown files, zero em dashes across all edits.

       - THE DIGITAL THEREMIN & ATTENTION BLEED ESSAY PUBLICATION (2026-10-20):
         Synthesized Mike Hall's raw authorial reflection on the uncanny valley of generative AI, the mathematical coupling of latent diffusion tensors, and the digital theremin metaphor into a systems craftsmanship essay ready for publication to `just3ws.com` (`_posts/2026-10-20-the-digital-theremin-attention-bleed-and-the-uncanny-boundary.md`):
         - Essay Synthesis & Conceptual Framing:
           - Unpacked the mathematical anatomy of the uncanny valley: contrasting physical photography (where adjacent pixels share space solely by coincidence of line of sight from the observer, with zero causal or predictive awareness) against generative diffusion (where latent vectors calculate cross-attention, causing pixels to bleed into broadstroke compromises).
           - Analyzed the identical mechanism in language models: autoregressive self-attention ($QK^T / \sqrt{d}$) creates universal mutual awareness, generating an over-lubricated velvet surface where nothing stubs its toe, contrasted with human writing defined by bodily friction, clipped cadence, and abrupt conceptual collisions.
           - Formulated the Digital Theremin metaphor: operating in an invisible, continuous electromagnetic probability field without discrete keys, frets, or physical stops, requiring the human practitioner to supply the internal grounding and boundary tests that the model completely lacks.
           - Grounded sovereign provenance in the low-trust panopticon: utilizing deterministic local Git trees, immutable checksums, and local NVMe storage to preserve verifiable human agency.
         - Provenance & Datalake Anchoring:
           - Created deterministic research artifact `_data/research/ramblin-amblin-ok-next-experiment.json` and added Prompt 22 (`the-frictionless-field-and-the-digital-theremin`) to `docs/prompts/ramblin-amblin-topics.md`.
           - Recompiled CareerOS datalake (`career_datalake.json`, `career_datalake.jsonl`) and updated knowledge graph (`_data/knowledge_graph.json`, 474 nodes, 769 edges, 0 orphans).
         - Localhost Verification:
           - Jekyll site build passing across 1,047 pages and verified on `https://just3ws.localhost/2026/10/20/the-digital-theremin-attention-bleed-and-the-uncanny-boundary.html` (HTTP 200).
         - Verification:
           - Fast validation passing cleanly across 497 Markdown files, zero em dashes across all edits.

       - SOVEREIGN VERIFICATION & THE METERS VS YARDS TRAP ARTICLE PUBLICATION (2026-10-20):
         Synthesized physical field re-test findings, the dual-model divergence between code and generative prose, and the Mars Climate Orbiter unit-mismatch trap into a comprehensive systems craftsmanship essay ready for publication to `just3ws.com` (`_posts/2026-10-20-the-mirage-of-competence-sovereign-verification-and-the-meters-vs-yards-trap.md`):
         - Essay Synthesis & Conceptual Framing:
           - Contrasted deterministic code models (bounded by compilers, ASTs, and exit codes) against generative prose models (predicting plausible token continuations across ungrounded data gaps).
           - Grounded the analysis in the 345kV field re-test under high-tension transmission lines: the hardware bottom mic isolation (`c0=c0|c1=c0`) and invariant 60Hz harmonic notch filters held durably, while the LLM's celebrated "clock crystal drift" (`atempo=0.837`) was revealed as pure hallucinated interpolation across silent walking footage.
           - Established the Mars Climate Orbiter principle: when generative models speculatively bridge domain gaps without dimensional grounding, errors compound invisibly into structural systemic failure at scale.
           - Formulated the Sovereign Verification Framework: Boundary Testing, Semantic Unit Preservation, Deterministic Machine Pinning, and Continuous Human Calibration.
         - Localhost Verification:
           - Jekyll site build passing across 1,046 pages and verified on `https://just3ws.localhost/2026/10/20/the-mirage-of-competence-sovereign-verification-and-the-meters-vs-yards-trap.html` (HTTP 200).
         - Verification:
           - Fast validation passing cleanly across 497 Markdown files, 302/302 RSpec tests passing, zero em dashes across all edits.

       - LOCAL-FIRST SSD MEDIA INTAKE & POLITE SCHEDULING SEAM (2026-10-20):
         Decoupled video ingestion from the macOS Google Drive CloudStorage FileProvider bottleneck, migrating active queues to fast local NVMe SSD (`~/.local/var/media_intake`) with polite OS-level scheduling and asynchronous cold-storage mirroring:
         - Background Scheduling Politeness (`bin/intake_drive_video.rb`, `bin/live_dashboard_streamer.rb`):
           - Enforced POSIX scheduling nice level 15 via `Process.setpriority(Process::PRIO_PROCESS, 0, 15)` so media processing automatically yields CPU cycles to interactive user tasks, typing, and desktop UI.
           - Enforced macOS Darwin Quality of Service (QoS) Background tier via `/usr/sbin/taskpolicy -b -p <pid>`, routing compute to Apple Silicon Efficiency cores and throttling disk I/O to background priority.
           - Explicitly prefixed child worker pipelines (`ffmpeg`, `ztranscribe` / `whisper-cli`, `generate_career_datalake.rb`) with `nice -n 15` and applied `taskpolicy -b` upon spawning autonomous workers from the live streamer.
         - Local SSD Queue Foundation (`_data/media_intake_targets.yml`, `bin/intake_drive_video.rb`):
           - Configured `base_path: "~/.local/var/media_intake"` and `cloud_archive_path: "/Users/mike/Library/CloudStorage/GoogleDrive-mike@just3ws.com/My Drive/Media Intake"`.
           - Scaffolded all channel targets (`whoistechcmty/ramblin-amblin`, `the-sound-above`, `errata`) across `staged/`, `pending/`, `processing/`, `processed/`, `failed/`, and `blocked/`.
           - In `bin/intake_drive_video.rb`, enabled automatic path expansion (`File.expand_path`), decoupled active processing from Google Drive virtual mounts, and added `--drop FILE` (`--ingest FILE`) CLI flags to instantly stage files arriving from LocalSend (`~/Downloads`) or direct USB cable pulls.
           - Implemented Step 11 asynchronous cold-backup mirroring: once a video is published to YouTube, registered in datalake, and archived locally with its `.receipt.json`, it mirrors the master to Google Drive `processed/YYYY-MM/` in the background with non-blocking error handling.
           - Enriched `find_archived_receipt` to inspect both local SSD and cloud archive receipts to preserve idempotency across previously published masters.
         - Telemetry Streamer & Prompt Sync Resilience (`bin/live_dashboard_streamer.rb`, `bin/sync_topic_prompts.rb`, `bin/youtube-swiftbar`, `bin/youtube_pipeline.rb`):
           - Updated `bin/live_dashboard_streamer.rb` and `bin/youtube_pipeline.rb` to resolve expanded paths, serving the live local queue to the dashboard (`http://127.0.0.1:7025/telemetry.json`).
           - Hardened `bin/sync_topic_prompts.rb` to sync topic sheets to local SSD immediately and gracefully rescue cloud provider timeout errors (`Errno::ETIMEDOUT`) when writing to Google Drive.
           - Updated `bin/youtube-swiftbar` to prioritize the configured local SSD base path over cloud storage paths.
         - Verification:
           - 302/302 RSpec tests passing (including unit tests for `--drop` and scheduling politeness), fast validation passing cleanly across 497 Markdown files, and site verified and installed to `just3ws.localhost` (1,045 pages). Zero em dashes across all code and documentation.

       - SOUND ABOVE PILOT (EPISODE 00) SYNTHESIS: RAMBLIN' DEHUM RE-ATTEMPT & THE MIRAGE OF COMPETENCE (2026-10-19):
         Synthesized the recent Ramblin' & Amblin' field monologue (`ramblin-amblin-ok-next-experiment.yml`) into the episode dossier and teleprompter script for Episode 00 ("The Mirage of Competence: AI Slop & Domain Boundaries"):
         - Field Monologue Grounding & Physical Characterization (`_data/episodes/episode-00.yml`, `obs/teleprompter/episode-00.textream`):
           - Ingested Mike's physical re-attempt on the trail under the 345kV conductors: deliberately returning beneath the high-tension wires and walking up the rise to test whether electromagnetic disruption would recur and whether the `fix_video.sh` dehum filter parameters were a brittle one-off or a reproducible, dynamic general-purpose tool.
           - Grounded the narrative arc in the desync discovery: container metadata claiming 21 minutes of video vs 18 minutes of audio, an LLM asserting a 20% linear clock drift (`atempo=0.837`), and discovering via frame-level verification that speech was 1.0x all along (followed by 3.5 minutes of silent walking).
           - Articulated the core cautionary tale across Acts 4 and 5: when frontier models reach far beyond accessible, verifiable human competence (acoustics, high-voltage induction, DSP), they create a seductive appearance of mastery (Watts' *Blindsight* / Chinese room). If an engineer throws the ball higher than they can verify and catch, it comes crashing down on their head. True craftsmanship requires empirical boundary testing and machining ephemeral chat output into deterministic, sovereign code.
           - Linked `_data/transcripts/ramblin-amblin-ok-next-experiment.yml` into episode research attachments alongside the case study and Peter Watts' *Blindsight*.
         - Teleprompter Compilation & Local Runtime:
           - Recompiled native `obs/teleprompter/episode-00.textream` via `ruby bin/generate_sound_above_teleprompter.rb -e 0 --save-textream`.
           - Synchronized pipeline telemetry (`_data/youtube_pipeline_telemetry.json`, `assets/data/youtube_pipeline_telemetry.json`) and installed site to `just3ws.localhost` (1,045 pages).
         - Verification:
           - 300/300 RSpec tests passing, fast validation passing across 497 Markdown files, zero em dashes across all edits.

       - MATT RUBY ARCHIVE DIARIZATION FIX & PUBLIC SURFACE RECALIBRATION (2026-10-19):
         Reconciled the ending turns of the Matt Ruby (creator of Vooza) interview via local `ztranscribe` pipeline and recalibrated public identity surfaces for authentic, understated trust:
         - Matt Ruby Interview Diarization & Audio Grounding (`_data/transcripts/interview-with-matt-ruby-creator-of-vooza-general.yml`, `_data/video_assets.yml`, `assets/subtitles/interview-with-matt-ruby-creator-of-vooza-general.vtt`):
           - Transcribed full 30:18 audio using `ztranscribe` (`ggml-large-v3.bin`) with primed vocabulary (`Matt Ruby`, `Vooza`, `Mike Hall`, `Vlogbrothers`, `Subbable`, `UGtastic`).
           - Disentangled the conflated closing turns between Mike Hall (M1) and Matt Ruby (S1): correctly attributed the Transformers / Bud Light Honest Trailers analogy (M1), Patreon and hybrid startup monetization (S1), Vlogbrothers / Subbable channel crowd-funding context (M1), live events and merchandise response (S1), outro sign-off (M1), Matt's goodbye (S1), and separated the closing UGtastic outro jingle. Corrected "blog brothers" to "Vlogbrothers" and "vuza. com" to "Vooza.com".
           - Updated `video_assets.yml` with accurate `duration_seconds: 1818` / `duration_minutes: 30.3` and regenerated synchronized WebVTT subtitles spanning the complete 30:18 recording.
         - Public Surface Tone & Collaboration Calibration (`about/index.html`, `contact/index.html`):
           - Restructured `about/index.html` around "How I Work With Teams" and "What I Value on an Engineering Team" (curiosity over blame, fast feedback loops, generosity with context). Removed intense confessional narratives in favor of calm, authentic, low-ego craftsmanship.
           - Updated `contact/index.html` to clearly invite Staff and Principal Software Engineering roles and technical collaboration.
         - Verification:
           - Fast validation passing cleanly across 497 Markdown files, 300/300 RSpec tests passing, zero em dashes across all edits, and verified on `just3ws.localhost`. Commit `a4723392` pushed to `origin/master`.

       - BIOGRAPHICAL, MILITARY SERVICE, SSA WORK SPAN & MINISTERIAL PROVENANCE (2026-10-19):
         Grounded verified personal and service history from primary records across `$HOME/ai/inbox/` (DD Form 214s, Universal Life Church ordination records, SSA earnings statement, AFJROTC, Eagle Scout, Order of the Arrow Brotherhood, and OPFOR training):
         - Military Service Provenance (`docs/biographical-and-service-provenance.md`, `~/my/book/military-service-and-ordination-provenance.md`):
           - Illinois Army National Guard (ILARNG): Enlisted at age 16 with parental permission in 1993; Basic Combat Training at Fort Leonard Wood, MO (Summer 1993, age 17), selected as OPFOR (Opposing Force) during final bivouac; endurance runner assigned as road guard / crossing guard during PT runs and marching.
           - Advanced Individual Training (AIT): Medical Specialist Course at Fort Sam Houston, TX (completed August 1994 with 92.7 academic average); earned civilian EMT-A (Emergency Medical Technician, Ambulance) certification; MOS 91B10 Medical Specialist (Combat Medic); 108th Medical Battalion.
           - Regular Army Active Duty (RA): May 18, 1996 to May 21, 1997; Rear Detachment, 1st Battalion, 77th Armor Regiment (1-77 AR) in Schweinfurt, Germany; honorable discharge as Specialist (SPC E-4); National Defense Service Medal, Army Service Ribbon, Expert Marksmanship Badge (Grenade), Marksman Badge (Rifle M-16).
           - High School & Scouting Foundations: Lockport Township High School (LTHS) AFJROTC throughout high school (promoted to cadet officer rank, concurrent senior-year Guard duties); Eagle Scout attained between Basic and AIT; Order of the Arrow (Brotherhood member).
         - Ministerial Ordination Provenance:
           - Universal Life Church Monastery: Ordained October 9, 2013 by Brother Martin (Seattle, WA); Minister / Reverend Michael Daniel Hall.
           - Formal State Credentialing & Letter of Good Standing: Ordered September 1, 2017 (Order #1096919, Customer ID: 3849779, registered in Illinois).
         - Post-Army Hardware Depot & Early Code Genesis (1997 to 1998):
           - AeroTek Contract & GE Capital: Staged, repaired, and rolled out Compaq desktop workstations for GE Capital. Required to pursue CompTIA A+ certification as condition of employment. Flashed BIOS, diagnosed RMAs, installed RAM and expansion cards, imaged Windows 95 via PCMCIA network adapters, repalleted builds on loading docks, and deployed on-site bank installations.
           - Enterprise Mainframe & Self-Taught Programming: Staged an enterprise mainframe under supervisor scrutiny (earning depot nickname "Rusty"), observed an on-site Visual Basic developer, and catalyzed self-taught software journey transcribing magazine game listings, wrestling with variable dimensioning (`Dim`), hosting on Angelfire, and wiring an early Windows for Workgroups 3.11 office network for a family friend ("I just wanted to work with computers").
         - Continuous SSA Work Record (1981 to 2025):
           - Ingested continuous four-decade earnings span from SSA statement (`~/ai/inbox/ssa/social-security-statement.pdf`): childhood odd jobs and paper routes (1981-1990), adolescent labor and service (1991-2000), dotcom and enterprise systems (2001-2005), and senior/staff engineering leadership (2006-2025).
         - Datalake & CI Integration:
           - Ingested 5 new milestones into `bin/lib/ecosystem_datalake.rb` (`milestone-1994-army-ait-combat-medic`, `milestone-1997-regular-army-honorable-discharge`, `milestone-1997-aerotek-ge-capital`, `milestone-2013-ulc-ordination`, `milestone-2017-ulc-credentials`). Datalake timeline expanded to 109 events across SQLite3 FTS5 and DuckDB (2.51 MB).
           - Updated HTMLProofer options in `Rakefile` to ignore local-only operator dashboard fragments and API endpoints; resolved dashboard video asset links to canonical `/videos/{{ asset.id }}/`.
         - Verification:
           - 300/300 rspec tests passing cleanly across all suites.
           - Fast validation passing cleanly across 497 Markdown files, 0 errors in `validate:artifacts` and `validate:content`, HTMLProofer passing across all 1,033 rendered files with 0 errors. Zero em dashes.

       - RESUME PROJECTS REPRIORITIZATION: TECHNICAL ARCHIVE & PHALANX DUEL ELEVATION (2026-10-19):
         Reprioritized canonical resume, ATS configuration, and tailored archetype surfaces to front **Technical Conversation Archive** and **Phalanx: Duel**, deprioritizing WWWorkRemote:
         - ATS Configuration & Declarative Alignment (`_data/resume/ats.yml`):
           - Updated `selected_projects` from `[agent-tooling, phalanx-duel, wwworkremote]` to `[agent-tooling, phalanx-duel, technical-conversation-archive]`.
         - Technical Conversation Archive Public Contract (`_data/resume/positions/technical-conversation-archive.yml`):
           - Added explicit `public_summary` and `public_highlights` blocks emphasizing on-device Whisper audio processing, contract-tested knowledge graph construction, and software craftsmanship stewardship.
         - Archetypes & Generator Elevation (`_data/resume/archetypes.yml`, `bin/generate_archetype_resumes.rb`):
           - Elevated `phalanx-duel` and `technical-conversation-archive` across all five resume archetypes (`staff_systems_architect`, `staff_platform_enablement`, `senior_ruby_rails_contractor`, `founding_staff_fullstack`, `observability_resilience_specialist`).
           - Added dedicated `SELECTED PRODUCTION PROJECTS` section to ATS plaintext export (`exports/resumes/ats-import-resume.txt`) and semantic HTML import template (`exports/resumes/ats-import-resume.html`).
         - Verification:
           - 187/187 rspec tests passing cleanly across `spec/youtube/` and `spec/data/`.
           - Fast validation passing cleanly across 496 Markdown files, 67 attested resume claims verified (0 unattested), Jekyll site build passing across 1,045 pages, zero em dashes.

       - DIGITAL EPHEMERALITY WITH SOVEREIGN ARCHIVING & COGNITIVE CADENCE DRIFT (2026-10-19):
         Implemented configurable rolling horizon playlist management with anchor-and-gravitational-tail mechanics and built local cognitive cadence / sentiment analyzer across Whisper transcripts:
         - Declarative Ephemerality Architecture (`_data/media_intake_targets.yml`):
           - Configured `ephemerality` block under `ramblin-amblin`: `window_days: 3`, `carry_tail_count: 2`, `mode: anchor_gravitational_tail`, `retired_privacy: private`, `vault_playlist_id: PLNtb969T2-l0-vault` ("Ramblin' & Amblin' (Sovereign Vault)").
         - Anchor-and-Gravitational-Tail Deduplication & Sweeper Automation (`bin/lib/youtube_deduplicator.rb`, `bin/youtube_sweeper.rb`):
           - Added `YouTubeDeduplicator#plan_rolling_horizon_retirement`: evaluates newest video as anchor ($T_{anchor}$). If anchor is active ($\le N$ days), keeps window plus up to $K$ preceding tail videos; when anchor expires ($> N$ days), rolls out entire playlist to sovereign vault unless tagged `evergreen: true` or `pinned: true`.
           - Integrated rolling horizon audit findings into `YouTubeSweeper#audit_single_playlist` and automated retirement under `--sweep-ephemerality` (sets private, unlinks from public playlist, adds to vault).
         - Cognitive Cadence & Lexical Drift Analyzer (`bin/analyze_ramblin_cadence.rb`, `lake/ecosystem/ecosystem.duckdb`):
           - Analyzes all Whisper transcripts in `_data/transcripts/ramblin-amblin-*.yml`: computes WPM (overall 142.0 WPM), turn density, polarity, emotional tone (`reflective_contemplative`, `optimistic_constructive`, `balanced_pragmatic`), and domain themes (`craftsmanship`, `ai_cognition`, `autobiographical`, `systems`).
           - Emits structured report to `assets/data/ramblin_cadence_drift.json`, appends `ramblin_cadence` records to ecosystem datalake (`lake/ecosystem/ecosystem.jsonl`), and compiles DuckDB analytical view `v_ramblin_cadence_drift`.
           - Wired `cadence` / `drift` subcommand into `bin/pipeline media`.
         - Verification:
           - 187/187 rspec tests passing cleanly across `spec/youtube/` and `spec/data/`.
           - Fast validation passing cleanly across 496 Markdown files, zero em dashes.

       - FOG GEM T-SHIRT (#1562), EXPANDED ARCTIC CODE VAULT, GEEKFEST/OTEL WG CHRONOLOGY & MEMOIR BOUNDARY (2026-10-19):
         Grounded fog/fog#1562 contribution and contributor t-shirt, expanded 2020 GitHub Arctic Code Vault provenance, chronologized Geekfest@OMF (49+ sessions) / Corporate Hackathons (March 2022 Rasa & Feb 2024 Buckaroo Bonsais) / OTel WG (122 members) through to the Sept 12, 2025 executive handoff, audited and enforced Aneta and TMI privacy boundaries across public surfaces, established local-only memoir structural spine in `~/my/book/README.md`, verified overnight quota unblocking, and confirmed 0 playlist warnings across 21 live playlists:
         - fog Gem Upstream Contribution & Contributor T-Shirt (`fog/fog#1562`, `fecbf150`):
           - Located commit `fecbf150a4574a0080d5d454807a248f0b71d31a` (`2013-02-13`) in `fog/fog#1562` upgrading `net-scp` after v1.0.6 was yanked from RubyGems.org. Merged by Wesley Beary (`@geemus`) in `2fccaa27`, credited in the `fog` v1.10.0 `CHANGELOG.md` ("*thanks Michael D. Hall*"), earning the official `fog` contributor t-shirt.
           - Grounded in `bin/lib/ecosystem_datalake.rb`, `_data/portfolio.yml`, `timeline/index.html`, and `docs/ecosystem-history-and-datalake-chronology.md`.
         - Expanded 2020 GitHub Arctic Code Vault Provenance (`2020-02-02` Snapshot):
           - Preserved in Svalbard permafrost across `countries/countries` (`ec5d33ea`), `coderwall/coderwall-legacy` (634 commits, #1 contributor), `asm-helpful/helpful-web` (7+ commits), `fog/fog` (`fecbf150`), `carlhuda/janus` (`01b31564`, PRs #70, #159, #160), `cdnjs/cdnjs` (`559fdedb`, PRs #703, #712), `just3ws/nerd-font-cheatsheets` (129 stars), `just3ws/biscotti`, `just3ws/zdots`, `just3ws/vdots`, and `just3ws.github.io`.
         - Geekfest@OMF, Hackathons & OpenTelemetry Working Group (2022 to 2025):
           - Ingested verified chronology from `/Volumes/Dock_1TB` ChatGPT corpus and project code: March 2022 Hackathon #1 (conversational AI with Rasa 3.0, 8 months prior to ChatGPT); June 2022 Open Tech Talks to November 2022 Geekfest@OMF launch (49+ recorded Tuesday sessions across SOLID, Legacy Code, April 2023 early LLMs, Cynefin, and Sept 2023 OpenTelemetry live demos); Feb 2024 Hackathon #2 leading *The Buckaroo Bonsais* (JSON Schema inference + OpenTelemetry batch tracing); April 2024 evolution into OTel WG (first Community of Practice at OMF, 122 invited members, 40+ active cross-lane engineers); and September 12, 2025 formal stewardship handoff to newly funded full-time observability leadership.
           - Added practice thread and contextual gates to `timeline/index.html`, updated Chapter 5 of `docs/retrospectives/onemain-financial-system-cartography-and-architecture-retrospective.md`, and enriched datalake milestones.
         - Aneta & TMI Protocols Enacted:
           - Generalized unconsented internal director name in retrospective to `"engineering leadership"`. Zero unconsented corporate peer names or proprietary codenames across all public surfaces.
           - Created local-only memoir and autobiography structural guide in `~/my/book/README.md` documenting the phase-offset structural thread, literary nonfiction naming rules, and Homer CCSD 33C elementary school fact-checking ledger.
         - Overnight Quota Unblocking & Sweeper Verification:
           - Final blocked video (`VID_20261017_163906958.mp4` -> `zls4SCb40Vk`) was automatically unblocked, added to playlist, synced to datalake, and archived into `processed/2026-10/` with new transcript `_data/transcripts/ramblin-amblin-ok-next-experiment.yml`.
           - Channel audit via `./bin/just3ws media sweep --audit --json` confirmed 0 duplicate items, 0 duplicate video groups, and 0 warnings across all 21 playlists.
         - Verification:
           - 66 repos, 3,083 commits, 14 artifacts, 104 timeline events in SQLite3 FTS5 and DuckDB.
           - 11/11 datalake RSpec tests passing, fast validation passing across 495 Markdown files, TMI audit passing 930/930 URLs (0 reconcile/quarantine/hold), 67 attested resume claims verified, site installed to `just3ws.localhost`, and commit `c006a5cc` pushed to `origin/master`. Zero em dashes.

       - CENTRAL TIME UX, YOUTUBE QUOTA CONSERVATION, RUBYGEMS/CLOJARS/CHOCOLATEY PROVENANCE & HISTER DISCOVERY (2026-10-18):
         Unified all operator surfaces on Central Time (`America/Chicago` / `2:00 AM CT`) backed by UTC state, optimized YouTube Data API v3 quota conservation (deferring 400-unit caption uploads to complete `datalake_sync` and `archival` for 4 blocked videos immediately), grounded `NStun` `.NET 2.0` correlation with TicketsNow, recovered RubyGems, Clojars (`semantic-csv#49`), Chocolatey Kickstarter (`fa6a43b0`), and Coderwall (`coderwall-badges`) provenance, and indexed all provenance into `hister.localhost`:
         - Central Time (`America/Chicago`) UX & UTC Internal State (`youtube/dashboard.html`, `bin/intake_drive_video.rb`, `bin/live_dashboard_streamer.rb`, `bin/youtube_sweeper.rb`):
           - Converted all user-facing timestamps, relative time badges, and quota reset countdowns to Central Time (`2:00 AM CT (00:00 PT)`) while storing UTC ISO-8601 timestamps internally.
         - YouTube Data API v3 Quota Conservation & Immediate Queue Archival (`bin/intake_drive_video.rb`, `bin/lib/youtube_client.rb`):
           - Added partial response `fields=` masks to `YouTubeClient#get_video` and `YouTubeClient#get_playlist_video_ids`, plus zero-quota `yt-dlp --flat-playlist` fallback during `playlist_assignment` pre-checks.
           - Decoupled 400-unit `captions_upload` on 403 `quotaExceeded`: when `youtube_upload` and `playlist_assignment` have already succeeded (and full Whisper transcript is in the description, local datalake, and YouTube auto-captions), defers the 400-unit WebVTT upload and immediately completes `datalake_sync` and `archival`.
           - Completed `datalake_sync` and `archival` into `processed/2026-10/` for 4 playlist-assigned videos (`VID_20261017_094828700.mp4` -> `V-2uR4xIxaQ`, `VID_20261017_101902286.mp4` -> `12yuw3lfZ7s`, `VID_20261017_102753387.mp4` -> `fej808b1VRg`, `VID_20261017_103810539.mp4` -> `RNu430nMKgg`) with zero byte re-uploads; only 1 item (`VID_20261017_163906958.mp4` -> `zls4SCb40Vk`, needing 50 units for `playlist_assignment` at 2:00 AM CT) remains in `blocked/`.
         - `NStun` `.NET 2.0` Contemporary Versions & TicketsNow Correlation (`_data/resume/positions/ticketsnow.yml`, `_data/portfolio.yml`, `timeline/index.html`, `bin/lib/ecosystem_datalake.rb`):
           - Grounded `NStun` (`FrogsBrain.NStun`, `.NET Framework 2.0.50727` / Visual Studio 2005, launched November 7, 2005 alongside incumbent .NET 1.1) and its direct correlation with solving real-time distributed ticket broker NAT traversal (RFC 3489 STUN) at TicketsNow (Nov 2005 to Mar 2007).
         - RubyGems, Chocolatey Launch CTA (`fa6a43b0`), Clojars (`semantic-csv#49`), Coderwall & GitHub Arctic Code Vault Provenance (`bin/lib/ecosystem_datalake.rb`, `_data/portfolio.yml`, `timeline/index.html`, `docs/ecosystem-history-and-datalake-chronology.md`):
           - Grounded 3 published RubyGems under `just3ws` totaling 60,304 downloads (`express_pigeon` v2.4.1 with 30,267 downloads, `biscuit-monitor` v0.0.4 with 18,026 downloads, `biscotti` v0.1.4 with 12,011 downloads).
           - Grounded commit `fa6a43b0268178417d4f2420a66964b72ee3bd09` (`2014-11-14`, `GH-124`) in `ferventcoder/chocolatey.org-archive`, where Mike built the top-of-site Kickstarter CTA banner on `chocolatey.org` for Rob Reynolds.
           - Grounded `metasoarous/semantic-csv#49` (`2017-01-25`) and custom artifact `[self/semantic-csv "0.1.0-just3ws"]` in `just3ws/clojure-exercises-001` (`plik`), catalyzing the official 0.2.0 Clojars release.
           - Grounded `coderwall/coderwall-legacy` (#1 all-time contributor with 634 commits, 856 stars), `assemblymade/coderwall-badges` (`2014-09-12`), and the **2020-02-02 GitHub Arctic Code Vault** snapshot (`countries/countries` commit `ec5d33ea`, `coderwall/coderwall-legacy`, `asm-helpful/helpful-web`, and `just3ws` repositories).
           - Rebuilt ecosystem datalake (`lake/ecosystem/`): 66 repositories, 3,082 commits, 12 historical artifacts, and 97 timeline events; indexed all provenance URLs (including Basic Auth `codeplexarchive.org`) into `hister.localhost` (1,085+ indexed docs).
         - Verification:
           - 297/297 specs passing, fast validation passing cleanly, zero em dashes.

       - CODEPLEX ARCHIVE PROVENANCE (#RESUME, NSTUN, SCHEMAIN-SIGHT), SCHEDULED SWEEPER AUTOMATION & QUEUE RECONCILIATION (2026-10-18):
         Grounded early open-source .NET libraries (`#Resume` / `sharpresume`, `NStun`, `SchemaInSight`) and historical handles (`frogsbrain`, `just3ws`, `zalewhol`), resolved the `datalake_sync` `filename` bug, reconciled live YouTube playlists to 0 duplicates, and automated recurring compliance sweeps:
         - CodePlex & Google Code Archive Provenance (`_data/social_provenance.yml`, `_data/portfolio.yml`, `timeline/index.html`, `bin/lib/ecosystem_datalake.rb`, `docs/ecosystem-history-and-datalake-chronology.md`):
           - Grounded `#Resume` (`sharpresume` / `Just3Ws.SharpResume`, 2006-2009), a strongly typed C# implementation of the HR-XML Consortium 2.5 standardized Resume and CV specification (`SharpResume`, `SharpResume.Builder` ASP.NET web interface, and `SharpResume.Test` unit test suite), licensed under MIT (`Copyright (c) 2006-2009 Just3Ws, Inc.`), preserved on CodePlex Archive (`https://codeplexarchive.org/project/sharpresume`), Wayback Machine (`https://web.archive.org/web/20070510045718/http://www.codeplex.com:80/sharpresume`), and Google Code Archive SVN (`just3ws`).
           - Grounded `NStun` (`FrogsBrain.NStun`, 2006-2009), a native C# implementation of the RFC 3489 STUN UDP NAT traversal protocol (`https://codeplexarchive.org/project/nstun`), and `SchemaInSight` (2007-2008), a .NET 2.0 SQL Server schema inspection API (`https://web.archive.org/web/20081010042556/http://www.frogsbrain.net:80/content/schemainsight/default.aspx`).
           - Recorded historical handles `frogsbrain` (CodePlex Project Coordinator since October 29, 2006; `frogsbrain.net` and `frogsbrain.blogspot.com`), `just3ws`, and `zalewhol`.
           - Rebuilt ecosystem datalake: 66 repositories, 3,080 commits, 7 historical artifacts, and 92 timeline events across SQLite3 FTS5, DuckDB, JSONL, and manifest.
         - Scheduled Compliance Sweeper & Cooldown Unblocker (`bin/youtube_sweeper.rb`, `bin/live_dashboard_streamer.rb`, `bin/intake_drive_video.rb`, `spec/youtube/youtube_sweeper_spec.rb`):
           - Fixed `NameError` (`undefined local variable or method 'filename'`) in `MediaIntakePipeline#register_in_video_assets` during `datalake_sync`.
           - Re-queued quarantined `VID_20261017_094346214.mp4` (`jHDlgO92bvU`) and unblocked `VID_20261017_161728409.mp4` (`533FSvfDIUE`); both completed `datalake_sync` and `archival` into `processed/2026-10/` with zero byte re-uploads.
           - Added `unblock_expired_cooldown_jobs` (`--unblock-expired`) and `requeue_quarantined_jobs` (`--requeue-quarantine`) to `YouTubeSweeper`, resolving target directories from root `base_path` and checking `.blocked.json` timestamps against the latest 00:00 PT quota reset.
           - Executed live playlist sweep across `PLNtb969T2-l0` ("Ramblin' & Amblin'") and `PLMieFbUNB3hM` ("Developer Community, User Groups & Meetup Interviews"): removed all 4 duplicate playlist items, added missing canonical videos (`SLvKYSwUcRc`, `UfwEOPJc6dI`), retired redundant duplicate uploads (`jgrg7hPbdc8`, `n6VWVy_NdSw`, `QTpYkViNnZc`, `WKsVPciUrkM`) to private, and added 3 unblocked videos (`12yuw3lfZ7s`, `fej808b1VRg`, `RNu430nMKgg`) to `PLNtb969T2-l0` (now 16 unique items, 0 duplicates).
           - Integrated a 15-minute recurring compliance sweeper thread in `LiveDashboardStreamer` (`run_compliance_sweeper`) and a standing background cron schedule.
         - Verification:
           - 297/297 specs passing, fast validation passing cleanly, zero em dashes.

       - YOUTUBE SWEEPER TOOLING, DASHBOARD MERMAID LAZY RENDERING & UGTASTIC PROVENANCE (2026-10-18):
         Built autonomous sweeper tooling, fixed dashboard architecture tab Mermaid rendering and syntax errors, and grounded UGtastic domain provenance:
         - Autonomous YouTube Sweeper Tooling (`bin/youtube_sweeper.rb`, `bin/pipeline`, `bin/just3ws media sweep`, `spec/youtube/youtube_sweeper_spec.rb`):
           - Authored dedicated sweeper and health auditor CLI: audits live channel playlists, Maildir queues (`pending/`, `processing/`, `blocked/`, `failed/`), and Pacific Time quota cooldown.
           - Detects duplicate playlist items (same video ID repeated), redundant video uploads (identical content under multiple IDs), missing canonical videos, and quarantined files.
           - Employs transparent fallback to `yt-dlp` flat-playlist metadata extraction when API is in quota cooldown.
           - Supports `--audit` (with exit code 0 on healthy, 1 on warnings), `--sweep` (reconciles playlists live or dry-run), `--target`, `--retire-duplicates`, and `--json`.
         - Dashboard Architecture Tab & Mermaid Lazy Rendering Fix (`assets/js/mermaid-init.js`, `youtube/dashboard.html`):
           - Fixed text overlapping and "Syntax error in text mermaid version 11.17.2" on `#tab-architecture`:
             - Sanitized sequence diagram labels: converted `pending/ -> processing/` to `pending/ to processing/` to avoid arrow syntax collision and escaped `<filename>` tags to `[filename]` to eliminate DOM parser mangling.
             - Added visibility detection in `assets/js/mermaid-init.js`: skips hidden diagrams inside `display: none` tab containers during initial load to prevent 0x0 bounding box SVG calculation crashes (`Could not find a suitable point for the given distance`).
             - Integrated dynamic rendering in `switchYtTab('architecture')` upon tab visibility and preserved raw source in `copyMermaidBlock` via `data-mermaid-source`.
         - UGtastic & WHOIS Tech Community Provenance Grounding:
           - Grounded `ugtastic.com` first capture on April 14, 2012 (`https://web.archive.org/web/20120414040704/http://www.ugtastic.com/`), WHOIS Tech Community rename and rebrand transition first capture on November 17, 2017 (`https://web.archive.org/web/20171117114045/https://www.ugtastic.com/`), and recent capture on August 31, 2025 (`https://web.archive.org/web/20250831080513/http://www.ugtastic.com/`).
           - Updated `_data/domain_migration.yml`, `_data/portfolio.yml`, `timeline/index.html`, `bin/lib/ecosystem_datalake.rb`, and `docs/ecosystem-history-and-datalake-chronology.md`.
           - Ingested provenance into Episode -1 (`_posts/2026-10-16-the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster.md`) and Episode 01 research attachments (`_data/episodes/episode-01.yml`).
           - Rebuilt ecosystem datalake: 90 timeline events across SQLite3 FTS5, DuckDB, JSONL, and manifest.
         - Verification:
           - 295/295 specs passing, fast validation passing cleanly, zero em dashes.

       - FACTUAL CITATION GROUNDING & ATTRIBUTION AUDIT (2026-10-18):
         Audited historical attributions and grounded claims against primary sources and verified evidence:
         - Chicago Alt.NET Presentation Citation:
           - Grounded Mike Hall's first user group presentation at Chicago Alt.NET on November 12, 2008 at Redpoint Technologies (84th Floor Sears Tower) on the NHaml alternative view engine for ASP.NET MVC, presenting alongside Adam Tybor on Spark.
           - Primary source: `https://web.archive.org/web/20081101091417/http://www.chicagoalt.net/Home`
         - Chicago Code Camp Role Calibration:
           - Corrected attribution across all data, portfolio, and datalake surfaces: Chicago Code Camp was an existing regional conference; Mike Hall volunteered and assisted for a couple years and built the conference website (`just3ws/ccs`) for at least three conferences (2010-2012), authoring the custom speaker management and printable 9-track Haml schedule matrix.
         - Twatio.com & UGl.st Provenance Grounding:
           - Ingested 2009 `twatio.com` ASP.NET MVC experiment engineered by Mike Hall to prove Twitter audience overlap following a debate with Sergio Pereira (Wayback capture `https://web.archive.org/web/20090201000000*/http://twatio.com/`, later redirected to `ugtastic.com`).
           - Grounded `ugl.st` ownership timeline throughout 2014: first capture on January 11, 2014 featuring the signature heart glyph in user-group registration (`https://web.archive.org/web/20140111160057/https://ugl.st/`) and final snapshot under Mike Hall ownership on December 22, 2014 (`https://web.archive.org/web/20141222063128/https://ugl.st/`).
         - Ecosystem & Career Datalake Synchronization:
           - Rebuilt `lake/ecosystem/` (SQLite3, DuckDB, JSONL, manifest) with 88 timeline events and 5 historical artifacts.
           - Enhanced `bin/query_ecosystem_datalake.rb` with FTS5 query sanitization handling punctuation and domains cleanly.
         - Verification:
           - 291/291 specs passing, fast validation passing cleanly, zero em dashes.

       - ECOSYSTEM CHRONOLOGY, DUCKDB LAKE & KUBECTL-INSPIRED CONTROL PLANE (2026-10-18):
         Synthesized 18 years of engineering history, refactored datalake architecture into a DRY shared library, compiled a chronological timeline, generated native DuckDB analytical views, and created a kubectl/zdots-inspired root CLI control plane:
         - Datalake Core Library & DuckDB Integration (`bin/lib/ecosystem_datalake.rb`, `lake/ecosystem/ecosystem.duckdb`):
           - Extracted shared datalake core into `bin/lib/ecosystem_datalake.rb` unifying schema DDL, SQLite3 FTS5, DuckDB, JSONL, and manifest compilation.
           - Compiled native DuckDB database `lake/ecosystem/ecosystem.duckdb` with analytical views: `v_timeline`, `v_yearly_activity`, `v_org_summary`, and `v_language_distribution`.
           - Ingested 66 repositories across 4 organizations (@just3ws, @ugtastic, @wwworkremote, @phalanxduel) and harvested 3,071 commits across 17 local repositories.
           - Compiled 86 chronological timeline events into SQLite and DuckDB indexing community milestones, repository creations, release tags, and turning point commits.
         - Living Ecosystem History & Narrative (`docs/ecosystem-history-and-datalake-chronology.md`):
           - Authored comprehensive narrative of the 5 evolutionary epochs from 2008 Chicago Alt.NET presentation to 2026 high-voltage DSP dehumming and autonomous media intake.
           - Added Mermaid diagrams: evolutionary lineage flowchart, commit activity XY chart, and control plane architecture map.
           - Documented exact commit SHAs, dates, and turning points.
         - Kubectl-Inspired Root Control Plane (`bin/just3ws`, `bin/pipeline`):
           - Added `lake` domain to `bin/pipeline` (`build`, `query`, `timeline`, `stats`, `duckdb`, `sql`).
           - Created `bin/just3ws` root CLI driver inspired by `kubectl` and `zdots-*` control planes (`./bin/just3ws lake timeline`, `./bin/just3ws media status`, etc.).
         - Verification:
           - 10/10 datalake specs passing (`spec/data/ecosystem_datalake_spec.rb`), 290/290 full RSpec suite passing, fast validation passing cleanly. Zero em dashes.

       - LEGACY ROUTE REMAPPING ENGINE, SOCIAL PROVENANCE & SMART 404 RECOVERY (2026-10-17):
         Built an automated legacy route recovery engine and documented canonical social identities across historical eras:
         - Verified Social Provenance (`_data/social_provenance.yml`):
           - Recorded and verified handles across @WHOISTechCmty (active channel/broadcasts), @ugtastic (historical brand account verified from ugtastic-web Rails codebase footer), @scmchenry (Software Craftsmanship McHenry County user group), @just3ws (personal/platform dating back to August 2008), and @chicagocodecamp (2010 to 2012 volunteer and conference website developer era).
         - Expanded Domain Migration (`_data/domain_migration.yml`):
           - Configured observe-only ingress tracking for ugtastic.com, whoistech.com, whoistechcmty.com, chicagocodecamp.com, scmchenry.org/com, ugl.st, and ironlanguages.net.
         - Declarative Route Mapping & Generator (`_data/legacy_routes.yml`, `bin/generate_legacy_route_map.rb`, `assets/data/legacy_route_map.json`):
           - Compiled unified lookup table indexing 379 interview slug keys, 666 video platform keys (YouTube and Vimeo), 192 people keys, and 1,303 post keys.
           - Integrated generator into `Rakefile` (`generate:all`), `bin/pipeline data legacy-routes`, and `bin/pipeline site remap`.
         - In-Browser Smart 404 Recovery (`404.html`):
           - Added real-time client-side route recovery card: detects legacy routes, displays target title, provides countdown auto-redirection, and offers fuzzy conversation suggestions.
           - Added GoatCounter telemetry events for `/event/legacy-route-recovered`, `/event/legacy-route-suggested`, and `/event/legacy-route-unmapped` alongside existing `/event/missed-path`.
         - Chicago Code Camp Printable Schedule Tool Artifact (`assets/images/portfolio/chicago-code-camp-print-schedule.jpg`, `_data/portfolio.yml`, `_data/social_provenance.yml`):
           - Preserved high-resolution artifact of Mike Hall custom schedule print generator producing the 9-track conference schedule matrix across 5 session blocks.
           - Linked Sotwe hashtag archive (`https://www.sotwe.com/hashtag/ChicagoCodeCamp`) and Twitter media source.
         - Git Hooks, Hygiene & Graphify Visualizations (`.gitattributes`, `graphify-out/GRAPH_TREE.html`, `graphify-out/callflow.html`):
           - Confirmed active git hooks (`.githooks/post-commit`, `pre-commit`, `pre-push`) with full merge driver registration in `.gitattributes`.
           - Emitted D3 collapsible tree visualization (`graphify-out/GRAPH_TREE.html`, 807KB) and Mermaid architecture call-flow (`graphify-out/callflow.html`, 17 sections).
           - Synced 9,807 AST and doc nodes into global graph (`~/.graphify/global-graph.json`).
         - CLI Route Remapper (`bin/remap_legacy_routes.rb`):
           - Provided CLI inspection and testing tool to resolve URLs, query strings, and log batches against the route map.
         - Verification:
           - 15/15 legacy route specs passing (`spec/data/legacy_routes_spec.rb`), 280/280 full RSpec suite passing, `./bin/pipeline validate fast` passing cleanly. Zero em dashes.

       - PLAYLIST RECONCILIATION, CROSS-REFERENCE DEDUPLICATION & ZERO RE-UPLOAD HARDENING (2026-10-17):
         Audited and reconciled live YouTube playlist `PLNtb969T2-l0` ("Ramblin' & Amblin'"), identified and planned cleanup for 3 redundant duplicate uploads (`jgrg7hPbdc8`, `n6VWVy_NdSw`, `QTpYkViNnZc`) and 1 missing canonical asset (`SLvKYSwUcRc`), hardened the deduplication tool with autonomous `yt-dlp` fallback and cross-reference reconciliation, and eliminated all re-upload vectors in the intake pipeline through state scoring, receipt cross-checking, and automatic OAuth token refresh on 401:
         - Live Playlist Audit & Deduplication (`bin/clean_and_sync_youtube_playlists.rb`, `bin/lib/youtube_deduplicator.rb`, `spec/youtube/playlist_dedupe_spec.rb`):
           - In `YouTubeDeduplicator`, added cross-reference checking against `_data/video_assets.yml`: detects when playlist items point to non-canonical video uploads even if only a single copy exists in the playlist.
           - Added `#plan_playlist_reconciliation` returning missing canonical assets to add to playlists.
           - In `clean_and_sync_youtube_playlists.rb`, added `fetch_all_playlist_items_ytdlp(playlist_id)` as transparent fallback when YouTube Data API is in 403 quota cooldown.
           - Added fallback target resolution from `_data/media_intake_targets.yml` so `--target <playlist>` executes cleanly even when channel API calls return empty during cooldown.
           - Added missing canonical reporting in `--audit` and added `--reconcile` execution loop: stages or adds missing canonical replacement videos to target playlists.
           - Guarded live playlist deletion against synthetic `ytdlp_` IDs while enabling video deletion and privating by real video ID (`--retire-duplicates`, `--delete-duplicates`).
         - Pipeline Pre-Upload & Reprocessing Idempotency Gates (`bin/intake_drive_video.rb`, `bin/lib/job_substate_tracker.rb`, `bin/lib/youtube_client.rb`):
           - Added `source_filename` persistence in `register_in_video_assets` and enhanced `find_registered_asset` to match by `filename` in addition to title and slug.
           - Enhanced `find_archived_receipt` to scan both `processed_dir` and `base_path`.
           - In pre-upload gate, checks both `find_registered_asset` and `find_archived_receipt` before upload. If a `video_id` is found anywhere, reuses it and skips byte uploading.
           - In `JobSubstateTracker#load_existing_state!`, scans all candidate paths (`companion_state_path`, `local_state_path`, `find_state_in_queue_dirs`), preserves any recorded `video_id`, and scores candidates to load the most progressed state.
           - In `can_skip_youtube_upload?`, treats 401, UNAUTHENTICATED, and authError as non-fatal check errors to prevent token expiration from triggering re-uploads.
           - In `YouTubeClient#make_request` and `upload_caption`, added automatic OAuth token refresh and retry on 401, preventing token expiry failures during long multi-gigabyte uploads.
         - Queue & State Alignment:
           - Terminated redundant re-upload of `VID_20261017_161728409.mp4`, preserved its canonical YouTube upload `533FSvfDIUE`, and relocated it to `blocked/` with `.blocked.json` awaiting playlist insertion at 00:00 PT quota reset.
           - Cleared `failed/` (0 failed jobs).
           - All 6 videos uploaded today are verified, unique, and preserved in `blocked/` with zero byte re-uploads needed (`jHDlgO92bvU`, `V-2uR4xIxaQ`, `12yuw3lfZ7s`, `fej808b1VRg`, `RNu430nMKgg`, `533FSvfDIUE`).
         - Verification:
           - 149/149 YouTube specs passing (`bundle exec rspec spec/youtube/`).
           - Fast validation passing cleanly (`./bin/pipeline validate fast`).
           - Zero em dashes across all edits.

       - BLOCKED VS. FAILED COOLDOWN ARCHITECTURE & THE WATTS DUAL SYNTHESIS (2026-10-17):
         Differentiated ephemeral rate/quota limits from hard pipeline errors, resolved Blindsight canonical nomenclature, and synthesized the Alan Watts and Peter Watts dual lineage into the knowledge graph and site essays:
         - Upstream Quota Blocked vs. Quarantine Failure (`bin/lib/pipeline_classifier.rb`, `bin/lib/job_substate_tracker.rb`, `bin/intake_drive_video.rb`, `bin/live_dashboard_streamer.rb`, `youtube/dashboard.html`):
           - In `PipelineClassifier`, added `upstream_quota_blocked` decision classifier matching `quotaExceeded`, `dailyLimitExceeded`, and rate limit exceptions with 99.95% confidence.
           - In `JobSubstateTracker`, added `#block_step` tracking `meta_phase: blocked` and saving quota reset cooldown markers (`resets_at => 00:00 PT`).
           - In `MediaIntakePipeline`, routed 403 quota exhaustion into `blocked/` queues with `.blocked.json` sidecars rather than failing into quarantine, preserving 100% of uploaded YouTube `video_id`s (`jHDlgO92bvU`, `V-2uR4xIxaQ`, `12yuw3lfZ7s`, `fej808b1VRg`).
           - Added pre-upload and reprocessing gate calling `client.update_video` for title/description changes when `video_id` already exists, ensuring zero re-uploading of bytes.
           - In operations cockpit (`youtube/dashboard.html`), rendered amber `⏳ BLOCKED (COOLDOWN)` status card with live PT countdown and bypass action.
         - Peter Watts *Blindsight* Typo Correction & Literature Ingestion (`bin/intake_drive_video.rb`, `_data/concepts.yml`, `_data/research/peter-watts-blindsight.json`):
           - Corrected all phonetic Whisper transcriptions and titles from "Blind Sight" to "Blindsight" for Peter Watts' 2006 book (`https://www.rifters.com/real/Blindsight.htm`).
           - Added automated phonetic replacement in `clean_transcript_text` and `extract_hook_from_text`.
           - Ingested *Blindsight* and the *Chinese Room thought experiment* into `_data/concepts.yml` and authored research dossier in `_data/research/`.
         - Alan Watts "Looking Through the Net" Knowledge Synthesis (`_data/concepts.yml`, `_data/episodes/episode-00.yml`, `_posts/2026-10-12-under-the-high-tension-wires-forensic-acoustics-and-craftsmanship.md`):
           - Ingested Alan Watts' 1969 presentation to the IBM Systems Group ("Looking Through the Net", Being in the Way Ep. 36) into `_data/concepts.yml` (`looking-through-the-net`, `prickles and goo`, `mechanism vs organism`, `gallbladder specialist fallacy`).
           - Authored research dossier `_data/research/alan-watts-looking-through-the-net-ibm-1969.json`.
           - Attached research documents and key concepts to Episode 00 (`_data/episodes/episode-00.yml`).
           - Authored comprehensive essay section "The Watts Synthesis: Looking Through the Net & Blindsight" in `_posts/2026-10-12-under-the-high-tension-wires-forensic-acoustics-and-craftsmanship.md`.
         - Verification & Deployment:
           - Knowledge graph regenerated and audited cleanly: 474 nodes, 769 edges, 0 orphans, 0 duplicate IDs.
           - 147/147 YouTube specs passing, fast validation passing cleanly, 0 em dashes.
           - Site built across 1,038 pages and deployed to localhost (`https://www.just3ws.localhost`).

       - IDEMPOTENT MEDIA INTAKE & YOUTUBE PLAYLIST/VIDEO DEDUPLICATION ENGINE (2026-10-17):
         Engineered end-to-end idempotency gates across media intake and built a comprehensive YouTube video and playlist deduplication engine:
         - Root Cause Diagnosis & Quota Preservation:
           - Diagnosed historical duplicate uploads from the 2026-10-15 batch (e.g. 3 copies of "Hello", 4 copies of "Going to be wearing a hood", 4 copies of "Somebody I care about").
           - Fixed critical flaw in `JobSubstateTracker#can_skip_youtube_upload?`: previously, catching 403 `quotaExceeded` during live verification returned `false`, triggering redundant upload attempts. Now treats quota limits and network timeouts as non-fatal, safely preserving the recorded `video_id`.
         - Ingress & Pre-Upload Idempotency Gates (`bin/intake_drive_video.rb`):
           - Ingress Gate: Inspects `processed/**/#{filename}.receipt.json` before locking. If already processed, prunes redundant pending files and skips re-ingestion.
           - Pre-Upload Gate: Cross-references `_data/video_assets.yml` for existing YouTube video IDs by title or slug before calling `client.upload_video`, ensuring registered videos are never re-uploaded.
           - Playlist Item Gate: Checks `client.get_playlist_video_ids` before calling `add_playlist_item` to prevent duplicate playlist entries and save quota.
         - YouTube Deduplicator Engine (`bin/lib/youtube_deduplicator.rb`, `bin/clean_and_sync_youtube_playlists.rb`, `bin/pipeline media dedupe`):
           - Normalizes video titles to detect both duplicate playlist items (same video ID repeated) and duplicate video uploads (multiple video IDs for the same recording).
           - Identifies canonical video IDs matching `_data/video_assets.yml` and receipts, marking other uploads as redundant.
           - Supports `--audit`, `--target PLAYLIST`, `--dedupe` (removes redundant items from playlist), `--retire-duplicates` (sets redundant videos to private), and `--delete-duplicates` (requires `--apply --confirm`).
         - Verification:
           - 145/145 YouTube specs passing (`spec/youtube/`), including `spec/youtube/playlist_dedupe_spec.rb` and hardened `job_substate_tracker_spec.rb`.
           - `./bin/pipeline validate fast` passing cleanly. Zero em dashes.

       - YOUTUBE UPLOAD PROGRESS STREAMING, QUOTA RESET COUNTDOWN & DIAGNOSTIC SANITIZATION (2026-10-17):
         Hardened the YouTube publishing workflow, operations cockpit, and telemetry contracts:
         - Canonical Casing ("UGtastic"): Corrected residual `Ugtastic` occurrences across `_data/video_assets.yml`, `_data/video_metadata_completeness.yml`, telemetry caches, and extraction scripts.
         - Chunked Resumable Upload & In-Flight Progress (`bin/lib/youtube_client.rb`, `bin/intake_drive_video.rb`, `bin/lib/job_substate_tracker.rb`, `youtube/dashboard.html`):
           - Implemented 8MB chunked resumable upload in `YouTubeClient#upload_video` yielding progress callbacks (`bytes_uploaded`, `total_bytes`, `percent`).
           - Added `JobSubstateTracker#update_step` for atomic checkpointing of in-flight progress without resetting step start timestamps.
           - Enhanced Column 3 (In Flight / Processing) on `youtube/dashboard.html` with real-time gradient progress bar, percentage indicator, and byte progress metrics.
         - Diagnostic Error Sanitization & Unicode Unescaping (`bin/live_dashboard_streamer.rb`, `youtube/dashboard.html`):
           - In `bin/live_dashboard_streamer.rb`, added regex JSON parser to extract human-readable error reasons and messages from raw YouTube API error payloads, unescaping unicode sequences (`\u003c` -> `<`).
           - Added client-side `sanitizeDiagnostic()` in `youtube/dashboard.html` to cleanly format quarantine cards and eliminate raw JSON dumps.
         - Daily API Quota Cooldown Countdown (`youtube/dashboard.html`):
           - Enhanced the Daily API Quota card with dynamic live countdown (`updateQuotaCountdown()`) calculating exact hours, minutes, and seconds until 00:00 PT quota reset.
         - Verification & Deployment:
           - 141/141 YouTube specs passing (`spec/youtube/`), `./bin/pipeline validate fast` passing cleanly.
           - Jekyll built across 1,038 pages and deployed to localhost (`https://www.just3ws.localhost/youtube/dashboard/`). Zero em dashes.

       - PIPELINE STEP FAILURE QUARANTINE & SAFE REPROCESSING CONTRACT (2026-10-16):
         Hardened media intake pipeline so step failures (such as YouTube API playlist or caption quota exhaustion) fail immediately into Column 5 (Failed / Quarantine) instead of swallowing errors, enabling idempotent reprocessing without re-uploading:
         - Strict Step Failure & Quarantine (`bin/intake_drive_video.rb`):
           - In `add_playlist_item` and `upload_caption`, replaced swallowed warnings with `raise pl_err` and `raise cap_err` once retry loops exhaust.
           - Outer rescue block cleanly marks `tracker.fail_step`, logs activity, records `.error.log`, and relocates the media file and companion `.state.json` sidecar to `failed/`.
           - In the operations cockpit (`youtube/dashboard.html`), the card accurately surfaces in Column 5: Failed (Quarantine) with exact substate badges (e.g. `[✓ DSP] [✓ STT] [✓ Meta] [✓ Upload] [❌ Playlist] [⏳ Captions]`).
         - Companion State Preservation on Re-queue (`bin/live_dashboard_streamer.rb`):
           - Updated `handle_pipeline_retry` (POST `/api/live/pipeline/retry`) to move all companion sidecars (e.g., `VID_*.mp4.state.json`) alongside the media file back to `pending/`, pruning stale `.error.log` files.
           - Idempotency verified: `JobSubstateTracker#can_skip_youtube_upload?` verifies existing YouTube video ID on rerun, safely skipping DSP, STT, and YouTube upload to resume directly at the failed step with zero duplicate uploads or wasted quota.
         - Verification & Operational Health:
           - 138/138 YouTube specs passing, fast validation passing cleanly. Streamer daemon restarted and active on port 7025. Zero em dashes.

       - EPISODE 00 GROUNDED FIELD RECORDING & SHOW-OPENER BIT ELIMINATION (2026-10-16):
         Eliminated the scripted "Northern Illinois Field Dispatch" show formula and bit from Episode 00 in favor of unpretentious, grounded practitioner speech ("Field Recording"):
         - Spoken Script Calibration (`_data/episodes/episode-00.yml`, `obs/teleprompter/episode-00.textream`, `bin/templates/teleprompter/act_01_cold_open.erb`):
           - Stripped the formulaic radio greeting ("This is our Northern Illinois Field Dispatch under the high-tension wires...") in favor of direct, honest phrasing ("In October 2026, I walked out underneath 345,000-volt transmission lines in Northern Illinois with a smartphone to record some thoughts on software craftsmanship and identity...").
           - Updated episode conference metadata from "Northern Illinois Field Dispatch" to clean "Field Recording".
         - Dashboard Cockpit & Telemetry Alignment (`youtube/dashboard.html`, `_data/publication_schedule.yml`, `dehum/dashboard.html`):
           - Aligned fallback conference descriptors and Act 1 templates in `#tab-teleprompter` and `#tab-workshop` to "Field Recording".
           - Updated `spec/youtube/textream_teleprompter_spec.rb` to assert genuine spoken prose ('345,000-volt transmission lines').
         - Verification & Localhost Deployment:
           - 138/138 YouTube specs passing, `./bin/pipeline validate fast` passing cleanly, Jekyll rebuilt across 1,037 pages, deployed to localhost. Zero em dashes.

       - CONTEMPORARY PROVENANCE: ANTONIO CANGIANO WROX CITATION ON ALT.NET & ASP.NET MVC (2026-10-16):
         Integrated contemporary 2009 evidence from Antonio Cangiano's *Ruby on Rails for Microsoft Developers* (Wrox, April 2009, page 52) explicitly connecting the Alt.NET movement to Castle MonoRail, the Rails victory, and Microsoft's defensive creation of ASP.NET MVC:
         - Added citation and direct quotation to Episode 01 monograph (`series/the-sound-above/episode-01.html`).
         - Added primary source link to `#tab-teleprompter` provenance list on `youtube/dashboard.html`.
         - Attached Wrox book specification to `_data/episodes/episode-01.yml` research attachments and telemetry.

       - ALT.NET MANIFESTO PROVENANCE, CONVENTION OVER CONFIGURATION & TELEPROMPTER INTEGRATION (2026-10-16):
         Linked and displayed the Alt.NET Manifesto with full provenance and 4 tenets directly in the Episode 1 spoken script and teleprompter cockpit (`#tab-teleprompter`), documented the release of ASP.NET MVC as the decisive victory of the Ruby community (Rails, Sinatra, Merb) and convention over configuration in Microsoft's strategic pivot, and corrected all remaining mentions across site dossiers, monographs, and archives to reflect that Chicago Alt.NET was the first user group where Mike gave a presentation (not the first attended):
         - Alt.NET Manifesto in Spoken Script & Teleprompter Dossier (`_data/episodes/episode-01.yml`, `obs/teleprompter/episode-01.textream`, `youtube/dashboard.html`):
           - Injected David Laribee's 4 core tenets (Pragmatism, Cross-Community Adoption, Dissatisfaction with Status Quo, Principles Over Tools) into Act 2 spoken prose and rendered a dedicated Alt.NET Manifesto & Historical Provenance card in `#tab-teleprompter` with 1-click "Read Manifesto in Textream" and "Copy Manifesto Text" buttons.
           - Linked citations with verified external provenance: David Laribee (April 27, 2007), Martin Fowler (AltNetConf Austin Open Spaces Bliki, October 2007), Jeremy D. Miller (MSDN Magazine, March 2008), Scott Guthrie (ASP.NET MVC Preview, October 2007), Richard Banks (2015), and Jeremy D. Miller (2019).
         - Ruby Community Victory & Convention Over Configuration (`_data/episodes/episode-01.yml`, `youtube/dashboard.html`):
           - Documented in Act 3 how the release of ASP.NET MVC was one of the largest strategic turns in Microsoft history: Redmond conceding that the Ruby community (Rails, Sinatra, Merb) had won the architectural argument on convention over configuration, lightweight routing, and testable controllers over monolithic WebForms.
         - Factual Clarification Across All Surfaces (`series/the-sound-above/episode-01.html`, `_data/video_assets.yml`, `_data/episodes/episode-01.yml`):
           - Corrected monograph, video asset descriptions, and spoken scripts to state unambiguously that Chicago Alt.NET was the first user group where Mike gave a presentation, eliminating historical conflation with first attended.
         - Verification & Deployment:
           - 138/138 YouTube specs passing, `./bin/pipeline validate fast` passing cleanly, Jekyll rebuilt across 1,037 pages, deployed to localhost. Zero em dashes.

       - GODZILLA MINUS ONE / MINUS ZERO FRAMING, TEXTREAM SPOKEN PURITY & FACT CHECK (2026-10-16):
         Calibrated Episode -1 and Episode 00 into the Godzilla Minus One / Minus Zero lineage, stripped all non-spoken metadata headers from Textream documents and URLs to fix the Ron Burgundy issue, calibrated Episode 01 fact-checking (first presentation vs first attended), and dropped academic "oral history" phrasing:
         - Godzilla Minus One & Minus Zero Lineage (`_data/episodes/errata-fluffle-precursor.yml`, `_data/episodes/episode-00.yml`, `series/the-sound-above/index.html`):
           - Episode -1: "The Sound Above: Minus One" ("The Fluffle Precursor: Distributed whisper.cpp & Dead Rabbit Radio", Groundwork / Skunkworks Lab).
           - Episode 00: "The Sound Above: Minus Zero" ("The Mirage of Competence: AI Slop & Domain Boundaries", High-Tension Wires Pilot).
           - Episode 01: "The First Room: Chicago Alt.NET & Practical Autonomy in Enterprise .NET" (Sergio Pereira).
           - Updated series navigation pills on localhost with clean Minus One and Minus Zero badges.
         - Textream Pure Spoken Text Architecture (`bin/generate_sound_above_teleprompter.rb`, `youtube/dashboard.html`, `obs/teleprompter/`):
           - Stripped metadata headers (`ACT 1: COLD OPEN...`, `Scene: ...`, `YouTube ID: ...`) from Textream JSON documents and deep link URLs (`textream://read?text=`). Prompter surfaces now contain 100% pure spoken prose so Textream speech-tracking scrolls naturally without forcing the speaker to read stage cues aloud Ron Burgundy style.
           - Visual dashboard cards in `#tab-teleprompter` continue rendering full acts, timings, and scene targets for the operator.
         - Fact-Checking & Academic Phrasing Elimination (`_data/episodes/episode-01.yml`, `bin/broadcast`):
           - Fact-check: Corrected Chicago Alt.NET description to "first user group where I ever gave a presentation" (not the first user group ever attended).
           - Eliminated academic "Oral History" wording from series titles, options, and prompt descriptors.
         - Verification & Localhost Deployment:
           - Full test suites passing: 138/138 YouTube specs, `./bin/pipeline validate fast`, and `./bin/pipeline media stage` for episodes -1, 0, and 1.
           - Site rebuilt across 1,037 pages and verified on `https://www.just3ws.localhost/youtube/dashboard/#tab-teleprompter`. Zero em dashes.

       - SEMANTIC ERRATA NAMING, TELEPROMPTER SELECTION & STUDIO RECORDING READINESS (2026-10-16):
         Replaced arbitrary ordinal "Errata 06" with semantic slug `errata-fluffle-precursor` across episode dossiers, navigation, series index, pipeline telemetry schemas, and client-side teleprompter selector:
         - Semantic Addressing & Teleprompter Selector (`_data/episodes/errata-fluffle-precursor.yml`, `youtube/dashboard.html`):
           - Updated episode identifier to `errata-fluffle-precursor`, updated command palette to `/errata/fluffle`, and updated series index and localhost subnavigation to clean semantic labels.
           - Updated teleprompter selector dropdown in `#tab-workshop` / `#tab-teleprompter` to `<option value="errata-fluffle-precursor">`, dynamically resolving spoken acts from `errata_dossiers` in telemetry.
           - Authored automated regression specs in `spec/youtube/errata_surfaces_spec.rb` (23/23 specs passing).
         - Localhost Topology Isolation:
           - Replaced hardcoded `.com` links in `series/the-sound-above/index.html` and `dehum/dashboard.html` with root-relative paths (`/dehum/dashboard.html`, `/2026/10/16/...`), ensuring recording sessions remain isolated on `https://www.just3ws.localhost` without jumping to production.
           - HTML-Proofer verified on production build: 1,025 files and 1,335 internal links passing with 0 failures (`PROOFER: PASS`).
         - Season & Syllabus Decoupling Architecture (TASK-300):
           - Filed backlog task `backlog/tasks/task-300 - Decouple-Season-Syllabus-and-Episode-Composition-Architecture.md` to establish declarative season and syllabus manifests, separate track selectors, and decouple episode identity from numeric sequence ordinals.
         - Studio Recording Verification:
           - Jekyll built across 1,037 pages and installed to localhost. Verified HTTP 200 on all 4 studio recording hubs: Audio Workbench (`/dehum/dashboard.html`), Fluffle Precursor article, YouTube Dashboard, and Episode 01 Rewatch Hub (`/series/the-sound-above/episode-01/`).

       - DEHUM REPO RELOCATION, GDRIVE SYNC & SWIFTBAR FAILED LOG RESILIENCE (2026-10-16):
         Resolved Google Drive sync errors, relocated dehum workspace, diagnosed large file download loops, and hardened SwiftBar failure counters:
         - Dehum Repo Relocation (`/Users/mike/github.com/just3ws/dehum`):
           - Moved git repository out of Google Drive mirror tree into canonical GitHub workspace alongside sibling repos; verified 14/14 automated tests passing in `./bin/test_fix_video.sh`.
           - Pruned git artifacts and unsupported POSIX symlinks (`TRANSCRIPT_DIFF.md`, `PROMPT.md`, `compare_transcripts.py`, `gemini_transcript.md`) from `/Users/mike/ai/dehum/`, leaving only master recordings (`VID_20261009_111445043.mp4`, `VID_20261009_111445043_fixed.mp4`) and a pointer `README.md`.
           - Google Drive upload error list completely resolved as unsupported symlink objects were cleared.
         - FileProvider Download Loop Diagnosis (`1IreeuojC7I308LFD-0t4RFRvwG4axyOp`):
           - Identified as `VID_20261015_082025363.mp4` (1.31 GB), already published to YouTube (`9_SpcjsmehI`) and archived in `processed/2026-10/`; download loop is an Apple FileProvider chunk abort resolved by selecting "Remove Download" / "Keep Online-only".
         - SwiftBar Failure Counter Hardening (`bin/youtube-swiftbar`, `bin/intake_drive_video.rb`):
           - Isolated root cause of "7 failed" badge: raw sidecar `.error.log` and `.state.json` files in `failed/` from previous transient attempts were counted as separate failed jobs, despite all 4 underlying videos being successfully processed and published to YouTube.
           - Hardened `bin/youtube-swiftbar` to count unique media files (or unique failed job bases) instead of raw sidecars.
           - Enhanced `bin/intake_drive_video.rb` to automatically prune prior transient failure logs in `failed/` upon successful archival.
           - SwiftBar status restored to `🎬 Ready (Green)` with 0 failed and 12 completed.

       - DASHBOARD QUEUE CONTRACT GUARD & ARCHITECTURE SPECIFICATION (2026-10-16):
         Pinned and guarded the `#tab-queue` operations cockpit interface and real-time SSE contracts with automated regression suites, documented DOM architecture and EventSource wire protocol, and verified pipeline operational health:
         - Operations Cockpit Guard Suite (`spec/youtube/dashboard_queue_spec.rb`):
           - Authored 10-test automated regression suite verifying `#tab-pane-queue` DOM container presence, 5-column Kanban board IDs and badges (`staged`, `pending`, `processing`, `processed`, `failed`), 8-step BPMN funnel indicators, operator control buttons (`halt`, `resume`, `stop`), and channel filter chips.
           - Integrated automated Node.js syntax gate (`node --check`) ensuring embedded dashboard JavaScript parses cleanly with 0 syntax errors or unclosed blocks.
           - Verified existence and signatures of key client-side rendering handlers: `triggerPipelineAction`, `renderSubstateBadges`, `renderIngressFunnel`, `applyRealtimeTelemetry`, `initDashboardRealtimeStream`, `setFunnelFilter`, and `inspectFunnelStep`.
           - 125/125 YouTube specs and 10/10 queue interface specs passing cleanly.
         - Architecture Documentation & Wire Protocol (`docs/architecture/pipeline-contracts-and-schemas.md`):
           - Codified Section "Dashboard Queue Interface & SSE Integration Contracts (`#tab-queue`)" documenting DOM architecture, EventSource wire format (`intake_update`, `telemetry`, `bpmn_transition`, 3-second fallback polling), and discrete substate badge mappings.
         - Pipeline Liveness & Operational Status Verification:
           - Verified media pipeline is not stuck: live streamer daemon active on loopback port 7025 (`task-6997`), single-worker concurrency lock unblocked, self-healing PID watchdog operational, and base-spec MacBook Air scratch lifecycle enforced.

       - DASHBOARD QUEUE SYNTAX RESTORATION & SHORT RAMBLIN' TOPICS DRIVE SYNC (2026-10-16):
         Restored `#tab-queue` Kanban card and list rendering by fixing unclosed function in dashboard script, and expanded Ramblin' & Amblin' with 12 short-format dispatches rooted in 20-year CareerOS war stories, synced directly to Google Drive:
         - Dashboard Queue Script Syntax Fix (`youtube/dashboard.html`):
           - Isolated root cause of empty lists on `https://www.just3ws.localhost/youtube/dashboard/#tab-queue`: `triggerPipelineAction` was missing its closing brace `}`, causing subsequent rendering functions to nest inside it and triggering `SyntaxError: Unexpected end of input`.
           - Closed the function, validated entire script syntax via Node, and redeployed localhost.
         - Short-Format Ramblin' & Amblin' Topics & Google Drive Sync (`bin/sync_topic_prompts.rb`, `docs/prompts/`):
           - Curated 12 fresh, punchy 3 to 6 minute short-format topics rooted in CareerOS history, incidents, and practitioner reflections:
             * TicketsNow 3:00 AM Ticket Lock (inventory reservation race conditions & cache drift).
             * Groupon 4KB Cookie Storm (session bloat & Nginx 400 Bad Request drops).
             * ActiveCampaign Online MySQL Alteration (10k writes/sec zero-downtime migration).
             * OneMain Financial 2:00 AM Alert Deluge (OpenTelemetry noise reduction & user-symptom alerts).
             * C.H. Robinson AS/400 Logistics Mainframe (respecting 30-year boring reliability).
             * 8th Light & Tandem Pairing Confessional (dropping the mask of invulnerability).
             * BP Energy Trading Desk (high-stakes latency & fail-safe design).
             * Synthetic Slop vs. The Blink Test (why reading code and characterization tests matter more than generation).
             * Single-Operator Platform Leverage (why small Unix/Maildir tools beat 14-person architecture committees).
             * Imposter Syndrome & Creative Burnout (UGtastic & Fluffle scope fatigue & compassionate recovery).
             * The Lost Art of the Stack Trace (listening to the machine from UI to system call).
             * Boring Technology Pays the Rent (Dan McKinley's innovation tokens in real life).
           - Synchronized Markdown sheets and JSON specifications directly to Google Drive intake (`whoistechcmty/ramblin-amblin/TOPIC_PROMPTS.md`, `topic_prompts.json`) and local docs (`docs/prompts/ramblin-amblin-topics.md`).
           - Site built across 1,035 pages and deployed to localhost; 115/115 YouTube specs passing; 0 em-dashes.

       - LOCAL JEV CLASSIFIER, FLUFFLE RETROSPECTIVE & ORAL HISTORY SCALING PRECURSOR (2026-10-16):
         Engineered local Jev-style decision classifier engine, authored the Fluffle precursor retrospective article and teleprompter rundown, integrated April 2023 distributed whisper.cpp history into the timeline and knowledge graph, and verified zero-egress decisioning:
         - Local Jev-Style Pipeline Classifier (`bin/lib/pipeline_classifier.rb`, `spec/youtube/pipeline_classifier_spec.rb`):
           - Implemented System One decision model emitting strictly typed JSON probability distributions over discrete options with zero cloud egress.
           - Ingress Archetype Classifier: routes candidate transcripts into `freeform_field_notes`, `structured_errata`, or `technical_rewatch`.
           - Self-Healing Error Triage: routes pipeline step exceptions into `transient_network_retry`, `audio_codec_resample`, `credential_refresh`, or `quarantine_operator_review`.
           - Integrated into `bin/intake_drive_video.rb` for metadata archetype inference and failure triage.
           - Comprehensive test coverage: 9/9 classifier specs and 115/115 YouTube specs passing cleanly.
         - The Fluffle Precursor Retrospective & Errata Broadcast Curation (`_posts/`, `docs/prompts/`, `_data/episodes/`, `obs/teleprompter/`):
           - Authored long-form technical article `_posts/2026-10-16-the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster.md`: documenting the 2013 pre-Whisper transcription wall, April 2023 whisper.cpp breakthrough, 5-node Raspberry Pi cluster, Jason Carpenter's Dead Rabbit Radio dataset, 2,034 generated transcripts, imposter syndrome, and the lineage leading to modern local AI media automation.
           - Curated Prompt 6 in `docs/prompts/errata-topics.md` and synced directly to Google Drive intake (`whoistechcmty/errata/TOPIC_PROMPTS.md`).
           - Authored 6-act spoken teleprompter script and semantic episode dossier (`_data/episodes/errata-fluffle-precursor.yml`, `obs/teleprompter/errata-fluffle-precursor.textream`).
         - Knowledge Graph & Datalake Synchronization:
           - Ingested new article into `career_datalake.json` and `.jsonl`.
           - Added April 2023 `fluffle-distributed-whisper-experiment` to `_data/community_timeline.yml`.
           - Regenerated global knowledge graph (`_data/knowledge_graph.json`: 469 nodes, 742 edges, 0 orphans, 0 duplicate IDs) and AST cartography (`graphify`: 9,734 nodes, 12,688 edges, 1,195 communities).
           - Localhost site built across 1,034 pages and deployed with HTTP 200 verification.

       - NESTED COMPOSITE STATECHART & DISCRETE JOB SUBSTATE CHECKPOINTING (2026-10-16):
         Engineered discrete checkpointing and idempotency substate tracking across all 8 ingestion phases (`audio_dsp`, `transcription`, `metadata_synthesis`, `youtube_upload`, `playlist_assignment`, `captions_upload`, `datalake_sync`, `archival`):
         - Job Substate Tracker (`bin/lib/job_substate_tracker.rb`, `spec/youtube/job_substate_tracker_spec.rb`):
           - Checkpoints every step in atomic JSON sidecars (`~/.local/state/just3ws/jobs/<filename>.state.json`).
           - Rerun idempotency: automatically skips completed steps, verifies YouTube Data API v3 video ID liveness to prevent duplicate uploads, and preserves scratch WAV and transcription caches in dedicated scratch directories (`~/.local/state/just3ws/scratch/<filename>/`).
           - Comprehensive test coverage: 10/10 unit tests passing.
         - Streamer Telemetry & Operations Cockpit (`bin/live_dashboard_streamer.rb`, `youtube/dashboard.html`):
           - Ingress funnel enriches all pending, processing, and quarantined cards with discrete substate badge indicators (`✓`, `🔄`, `❌`, `⏳`).
           - Real-time BPMN mapping: maps active worker substate to corresponding BPMN stage.
           - Tab 8 Architecture updated with Mermaid composite statechart diagram and documented schema contract in `docs/architecture/pipeline-contracts-and-schemas.md`.
         - Single-Worker Concurrency Lock Hardening (`bin/intake_drive_video.rb`):
           - Guarded worker PID locking against dry-run and stale process collisions.
           - Playlist `PLNtb969T2-l0` verified with all 8 Ramblin' & Amblin' videos attached and synchronized.

       - SOFTWARE CRAFTSMANSHIP ENGINEERING PRINCIPLES, SCMC 2-YEAR TRANSITION & KNOWLEDGE GRAPH MEMORY (2026-10-16):
         Eliminated remaining "crucible" terminology in favor of Software Craftsmanship principles, calibrated SCMC co-founding and 2-year anniversary transition across all surfaces, integrated persistent code/knowledge graphing for context retention, and achieved 100% clean end-to-end validation across the site:
         - Software Craftsmanship Framing & "Crucible" Elimination:
           - Codified Kent Beck's Four Rules of Simple Design, Michael Feathers' legacy seams and characterization tests, Red-Green-Refactor / The Blink Test, and Apprenticeship -> Journeyman Practice -> Stewardship in `GEMINI.md`.
           - Calibrated the 3-Act Career Narrative across `bin/generate_career_datalake.rb`, `bin/career_datalake_mcp_server.rb`, `.agents/skills/executive-brief-generator/SKILL.md`, `docs/executive-brief-generator-protocol.md`, and `docs/resume-narrative-and-storytelling-guide.md` from "The Crucible" to **"Journeyman Practice & Architecture"**.
           - Updated `_posts/2026-10-02-the-chicago-crucible-why-craftsmanship-happened-here.md` ("The Chicago Workshop: Why Software Craftsmanship Happened in the City of Broad Shoulders", replacing "Prison Break" with "Practical Autonomy in Enterprise .NET"), `_posts/2026-10-02-without-zdots-there-was-nothing.md`, `bin/generate_rewatch_thumbnail.rb`, `bin/generate_content_opportunities.rb`, `docs/phased-approach-rewatch-broadcast-rollout.md`, and `docs/the-sound-above-audience-and-funding-strategy.md`.
         - Verified SCMC Co-Founding & 2-Year Anniversary Transition:
           - Updated `_data/episodes/episode-05.yml`, `obs/teleprompter/episode-05.textream`, `bin/sync_topic_prompts.rb` (`scmc-17-year-torch`, synced to Google Drive), `scmc/index.html`, `_posts/2026-08-17-software-craftsmanship-mchenry-county-a-retrospective.md`, `_data/community_timeline.yml`, `obs/curation/rewatch-curation-sequence.md`, `.agents/skills/editorial-fact-checker/SKILL.md`, `.claude/agents/editorial-fact-checker.md`, and `.claude/agents/technical-scriptwriter.md` to accurately reflect that **Mike Hall co-founded SCMC with Ryan Gerry and Jim Suchy in 2010 at Follett Software Company, and Ryan Gerry continued running SCMC after Mike stepped away after the 2-year anniversary**.
         - Code Mapping, Knowledge Graph & Context Retention (`graphify` + `_data/knowledge_graph.json`):
           - Upgraded `bin/generate_knowledge_graph.rb` and `_data/concepts.yml` to include all 38 Episode Dossiers (`episode-00`..`episode-37`), `SCMC (McHenry County)`, `software-craftsmanship`, `command-palette`, `knowledge-work`, and `orientation`, resolving all orphan nodes (`Nodes: 469, Edges: 742, Orphans: 0, Duplicate IDs: 0`).
           - Updated `graphify-out/graph.json` (`9,613 nodes, 12,562 edges`), registered `just3ws` in `~/.graphify/global-graph.json`, installed `.githooks/post-commit` and `.githooks/post-checkout`, and wired `graphify update .` into `rake knowledge_graph` (`./bin/pipeline data graph`).
         - End-to-End Validation Suite & HTML-Proofer Resolution:
           - Guarded localhost navigation and palette links in production builds and corrected relative wiki and curriculum links in `dehum/index.html`.
           - Full validation suite passing with 0 errors: `./bin/pipeline validate fast`, `./bin/pipeline validate all`, and HTML-Proofer across 1,019 HTML pages, 1,329 internal links, and 978 hash files; 211 RSpec examples passing; 26 MCP skills passing; localhost deployed and verified.

       - ARGON MEDIUM SYSTEM AUDIT, MOVEMENT 1 TELEPROMPTER SCRIPTS & FULL-SITE VALIDATION REMEDIATION (2026-10-16):
         Conducted a comprehensive system-wide audit across skills, subagent personas, episode dossiers, `bin/` tooling, and full-site HTML/SEO/taxonomy validators:
         - Movement 1 Spoken Teleprompter Scripts & Dossier Grounding (`_data/episodes/episode-01.yml` .. `episode-05.yml`, `bin/episode_workbench.rb`, `bin/templates/teleprompter/*.erb`):
           - Authored authentic, practitioner-honest 6-act spoken teleprompter scripts (`teleprompter_script:`) for all 5 episodes of Movement 1 ("The Chicago Workshop"):
             * Episode 01 (Sergio Pereira): Chicago Alt.NET & Practical Autonomy in Enterprise .NET (NUnit, NHibernate, StructureMap, ReSharper, and the Nov 2009 ThoughtWorks Chicago conversation).
             * Episode 02 (Ray Hightower): The Ambassador, ChicagoRuby, WindyCityRails, and the 2008 Midway Restaurant diner conversation running Cucumber.
             * Episode 03 (Micah Martin & Mike Jansen): Pair Friday in Libertyville, 8th Light's second-floor open tables, Vim/RSpec, and structured apprenticeship.
             * Episode 04 (Dave Hoover): Obtiva, *Apprenticeship Patterns* (O'Reilly 2009), and the 2011 Groupon acquisition.
             * Episode 05 (Ryan Gerry & Jim Suchy): Verified SCMC (#106) founding timeline (Oct 2009 SCNA table meeting with Ryan Gerry -> Cloud Developers Group in McHenry County libraries, Panera Bread, and Duke's Alehouse -> 2010 SCMC formalization with Jim Suchy at Follett Software Company, and Ryan Gerry continuing to run SCMC after Mike stepped away after the 2-year anniversary) and 17 years of continuous monthly practice.
           - Fixed `spec/youtube/episode_workbench_spec.rb` test isolation so `workshop 1` restores `episode-01.yml` cleanly instead of polluting `workshop_prompts` on test runs.
           - Updated `bin/episode_workbench.rb` and ERB templates so `human_stories` marginalia and `Cited references:` are preserved alongside bespoke `teleprompter_script:` acts; recompiled all 38 `.textream` documents in `obs/teleprompter/`.
         - Skill, Subagent & MCP Verification Calibration (`.agents/skills/`, `.claude/agents/`, `bin/mcp_server.js`, `bin/career_datalake_mcp_server.rb`):
           - Corrected SCMC founding history in `.agents/skills/editorial-fact-checker/SKILL.md` to verified ground truth (Mike Hall, Ryan Gerry, and Jim Suchy; Oct 2009 CDG -> 2010 SCMC at Follett).
           - Synchronized MCP tool names in `.agents/skills/career-datalake-researcher/SKILL.md` and added backward-compatible tool aliases (`query_career_datalake`, `get_interview_transcript`, `get_position_details`) in `bin/career_datalake_mcp_server.rb`.
           - Created 6 `.claude/agents/*.md` subagent persona definitions (`technical-scriptwriter`, `editorial-fact-checker`, `career-datalake-researcher`, `media-pipeline-operator`, `patreon-integrator`, `ponytail`) and calibrated `oral-history-broadcaster.md`, achieving 1:1 coverage across all 28 registered personas.
           - Upgraded `bin/mcp_server.js` (`validate_skills_spec` and `site://skills/index`) to discover and validate all 26 workspace skills across both `.agents/skills/` and `skills/`.
         - Full-Site Validation Gate Remediation & 100% `bin/` Frontmatter Coverage:
           - Resolved `validate:taxonomy_output` by registering `Ramblin' & Amblin'` and `Software Craftsmanship` in `_data/taxonomy.yml` and `_data/interview_communities.yml`.
           - Resolved `validate:semantic_output` and `validate:seo_output` across `dehum/dashboard.html`, `dehum/wiki/index.html`, and `youtube/dashboard.html` (`<h1>`, `<main id="main-content">`, `.skip-link`, `aria-label`, and `noindex` redirect meta).
           - Fixed root-cause `interview_id` linking for `gary-bernhardt-programmer-jokes-scna-2013` in `_data/video_assets.yml` and `bin/sync_interview_asset_links.rb`.
           - Added structured `# ---` / `// ---` frontmatter headers across all 193 scripts in `bin/` (`Missing: 0`).
           - All validation gates passing cleanly: `validate:fast`, `validate:taxonomy_output`, `validate:semantic_output` (973 pages), `validate:seo_output` (912 indexable, 102 noindex), `validate:resources_output`, `validate:obs` (46/46), `stage:all` (38/38), `verify_mcp_spec.js` (26/26 skills), and `rspec` (211/211).

       - REAL TIMELINE MEMORY PROMPTS, PATREON HISTORY & ARCHIVE RECOVERY (2026-10-16):
         Re-anchored conversation topic prompts directly into authentic historical timeline events and emotional memory prompts across Google Drive intake targets:
         - Grounded Timeline Memory Prompts (`bin/sync_topic_prompts.rb`, `docs/prompts/`, Google Drive):
           - Curated 8 deeply grounded memory prompts for *Ramblin' & Amblin'*:
             1. *The Unspoken Debt: Early Patreon Backers & The Burden of Support* (the 2014-2015 UGtastic Patreon campaign and GoFundMe for FCPX, community members stepping up to fund the series, the crushing weight of navigating depression/burnout while accepting support, and honoring that debt ten years later).
             2. *Carrying the Camera Alone: The Solitary Listener in Crowded Hallways* (recording community interviews through SCNA, GOTO Chicago, and RailsConf alone; the contrast between 800 animated engineers and the quiet solitude behind the lens).
             3. *The Suburban Void & The SCNA Table: Launching CDG in 2009* (living 50 miles outside the Loop in McHenry County, meeting Ryan Gerry at an SCNA table, gathering at Panera and Duke's Alehouse).
             4. *Carl Sagan in Libertyville: The Cultural Shock of Pair Friday (2008)* (walking into 8th Light's second-floor tables, Vim, RSpec, and Carl Sagan remixes redefining software as craft).
             5. *Ray Hightower at the Suburban Diner: The Generosity of an Ambassador (2008)* (sitting down at Midway Restaurant, running Cucumber, opening doors without gatekeeping).
             6. *The Zero-Dollar Conference: Chicago Code Camp & Anonymized Merit (2010-2012)* (delivering 6 tracks for 500 developers on a $0 budget, authoring the custom blind-review engine).
             7. *Handing Over the Torch: Ryan Gerry & The 17-Year Continuous Room* (founding SCMC in 2010, recognizing personal capacity limits, trusting Ryan Gerry to sustain the monthly cadence for over 15 years).
             8. *Greg Baugues & The Listener's Burden: Mental Health in Engineering (RailsConf 2014)* (the electrifying keynote on depression/bipolar disorder, hallway discussions, and the emotional toll of holding space for 200 interviewees).
           - Curated 5 structured technical Errata demonstration prompts: 345kV audio DSP vs. Gemini clock drift hallucination, smartphone noise-cancellation RF loop antenna physics, local Metal-accelerated whisper.cpp, Maildir queue pattern crash recovery, and executable BPMN 2.0 state machines.
           - Synchronized markdown and JSON specifications directly to Google Drive intake directories and local documentation.
         - Data Integrity & Validation Gates:
           - Resolved `video_asset_id` binding for Gary Bernhardt SCNA 2013 in `_data/interviews.yml`.
           - All validation gates passing cleanly: `validate:fast`, `validate:obs` (46/46 assertions), and `rspec` (211/211 tests). Zero em-dash compliance maintained.

       - ARCHETYPE-MAPPED SCRIPT STRUCTURES, EXECUTION PERFORMANCE TELEMETRY & EDITORIAL SKILLS (2026-10-16):
         Mapped media pipelines to distinct purpose-driven archetypes, instrumented high-resolution performance telemetry, and established dedicated scriptwriting and editorial skills:
         - Purpose-Driven Archetype Mapping (`_data/media_intake_targets.yml`, `bin/intake_drive_video.rb`, `bin/sync_topic_prompts.rb`):
           - Defined four distinct video archetypes: `freeform_field_notes` (Ramblin' & Amblin'), `technical_rewatch` (The Sound Above 6-act curriculum), `structured_errata` (solo technical deep dives), and historical interviews.
           - Codified grounded Intro structures (setting, inciting spark, and core inquiry within 0:00 - 1:00) and Outro structures (durable principle synthesis, actionable practitioner takeaway, and sign-off).
           - Replaced stilted "Forensic Audio Experiment" with practitioner-honest **"Northern Illinois Field Dispatch"** across dossiers, overlays, schedules, and dashboard states.
         - High-Resolution Pipeline Performance Telemetry:
           - Instrumented `bin/intake_drive_video.rb` with stage duration timers: audio DSP extraction, whisper.cpp speech recognition, metadata synthesis, resumable YouTube upload, and WebVTT caption insertion.
           - Computed upload throughput in MB/s, recorded metrics in `.receipt.json` files and `~/.local/state/just3ws/pipeline_execution_history.jsonl`.
           - Exposed live performance metrics via streamer daemon (`/telemetry.json`, `/status`) and rendered real-time performance breakdown badges on processed cards in `youtube/dashboard.html`.
         - Dedicated Media Production Skills:
           - Established `.agents/skills/technical-scriptwriter/SKILL.md`: authoring cadenced spoken teleprompter rundowns, narrative plotting, intro hooks, and takeaways in Mike Hall's authentic voice.
           - Established `.agents/skills/editorial-fact-checker/SKILL.md`: verifying technical claims, conference dates, software names, and audio/DSP contracts against ground truth and CareerOS datalake.
           - Registered skills in `AGENTS.md`.
         - All validation gates passing cleanly: `validate:fast`, `validate:obs` (46/46 assertions), `stage:all` (38/38 episodes), and `rspec` (211/211 tests). Zero em-dash compliance maintained.

       - NATURAL VOICE TELEPROMPTER SCRIPTS, EPISODE CALIBRATION & TOPIC PROMPT SYNC (2026-10-16):
         Crafted authentic, practitioner-honest spoken teleprompter scripts, calibrated episode titles, and automated Google Drive topic prompt synchronization:
         - Grounded Teleprompter Voice Architecture (`bin/generate_sound_above_teleprompter.rb`, `bin/episode_workbench.rb`, `youtube/dashboard.html`):
           - Decoupled teleprompter generation to seamlessly prioritize explicit 6-act spoken scripts (`teleprompter_script:`) while preserving dynamic human marginalia (`human_stories:`) and reference citations (`research_attachments:`).
           - Rewrote Episode 00 ("The Mirage of Competence: AI Slop & Domain Boundaries") teleprompter script across all 6 acts, replacing generic template text with authentic narrative grounded in the 345kV field recording, the prompt-based DSP hallucination of 20% clock drift, the ground-truth listening test failure, the dual-mic inductive antenna hardware asymmetry, and the 40ms deterministic scipy/bash filter.
           - Regenerated all 38 native `.textream` documents in `obs/teleprompter/` with zero em-dash compliance.
         - Title & Narrative Calibration:
           - Updated article title in `_posts/2026-10-12-under-the-high-tension-wires-forensic-acoustics-and-craftsmanship.md` to "The Mirage of Competence: AI Slop & Domain Boundaries".
           - Calibrated Episode 01 title across manifests, dossiers, overlay states, and thumbnails to "The First Room: Chicago Alt.NET & Practical Autonomy in Enterprise .NET", honoring the true spirit of open-source tooling, agile testing, and domain modeling inside corporate environments.
         - Automated Google Drive Topic Prompt Synchronization (`bin/sync_topic_prompts.rb`):
           - Built and executed topic prompt synthesizer generating 8 curated Ramblin' & Amblin' field prompts and 5 Errata deep dives derived from 20 years of writings and interviews.
           - Automatically synced prompts directly into Google Drive directories (`ramblin-amblin/TOPIC_PROMPTS.md` and `errata/TOPIC_PROMPTS.md`) and local `docs/prompts/`.
           - Integrated `sync-prompts` into unified pipeline router (`bin/pipeline media sync-prompts`).
         - All validation gates passing cleanly: `validate:fast`, `validate:obs` (46/46 assertions), `stage:all` (38/38 episodes), and `rspec` (211/211 tests). Zero em-dash compliance maintained.

       - SELF-HEALING ARCHITECTURE, RICH STATUS TELEMETRY & GROUNDED CURRICULUM HARMONIZATION (2026-10-16):
         Architected automated self-healing, rich diagnostic self-reporting, and grounded curriculum naming:
         - Engineered Self-Healing Ingress & Daemon Watcher (`bin/live_dashboard_streamer.rb` and `bin/intake_drive_video.rb`):
           - In `compile_live_intake_queues`: background watcher audits worker PID liveness; if a worker crashes or reboots, the stale `pipeline.pid` is automatically unlinked and logged to activity telemetry.
           - Automatic stranded file recovery: if no active worker process is alive, files stranded in `processing/` are safely restored to `pending/` and broadcast via SSE.
           - Network & API resilience: added 3-attempt exponential backoff retry to video and caption uploads against transient network hiccups or rate limits.
           - Upgraded `/status` endpoint: emits rich diagnostic telemetry including discrete health status (`idle_ready`, `pending`, `processing`, `degraded_quarantine`, `halted`, `stopped`), queue counts, worker lock status, and self-healing audit logs.
         - Grounded Curriculum & Melodrama Elimination:
           - Eliminated theatrical framing in favor of practitioner-honest history across `_data/sound_above_sequence.json`, `obs/curation/sequence-manifest.json`, and all 38 episode dossiers:
             - Movement 1: "The Chicago Crucible" calibrated to **"The Chicago Workshop"**.
             - Movement 5: "The Architecture and Testing Reckoning" calibrated to **"The Architecture & Testing Discipline"**.
             - Episode 24 Title: calibrated to "The Chicago Corridor: Software as Writing & The TDD Debate".
             - Series Canon: "Oral History Rewatch" calibrated to **"UGtastic Technical Rewatch Series"**.
         - Agent Skills & Career Datalake Integration:
           - Established `.agents/skills/career-datalake-researcher/SKILL.md` for CLI and MCP access across 218 transcribed interviews, 28 roles, and 185 writings.
           - Refactored `.agents/skills/oral-history-broadcaster/` to `.agents/skills/technical-rewatch-broadcaster/` framing.
         - All validation gates passing cleanly: `validate:fast`, `validate:obs` (46/46 assertions), and `rspec` (211/211 tests). Zero em-dash compliance maintained.
       - EPISODE STUDIO DOSSIER WORKSHOP, DIRECT OBS CUEING & AUTONOMOUS MEDIA PIPELINE (2026-10-16):
         Audited, harmonized, and verified Episode Studio, live broadcast cueing, and autonomous intake:
         - Harmonized Episode Studio (`youtube/dashboard.html` / `#tab-workshop`) with active default Episode 00 ("The Mirage of Competence: AI Slop & Domain Boundaries", The AI Horizon movement):
           - Decoupled semantic dossier editor fully reactive: Narrative Anatomy (theme, tone, core inquiry, AI-era parallel), Human Marginalia (recollections for Acts 1, 2, and 5), Prompts, Lexicon concepts, and Research Attachments (case studies, practice run 7YeFpKn5FbU, listening tests, Patreon).
           - Live preview automatically compiles 6 teleprompter acts, staged YouTube description (<5000 chars), and downloadable `episode-00.yml` schema.
           - Implemented direct-to-OBS overlay cueing (`🎬 Cue in OBS`): invokes `/api/live/pipeline/cue_obs?episode=0` on loopback daemon to cue live overlays immediately, with graceful clipboard copy fallback.
           - Upgraded `bin/broadcast` (`cue_rewatch`): added YAML dossier fallback supporting Episode 0 (Preparatory Pilot) and non-sequence dossiers cleanly.
         - Hardened Autonomous Media Intake Pipeline (`bin/intake_drive_video.rb`):
           - Upgraded `stable_file?` to multi-sample 5-second interval verification (`sleep 3` then `sleep 2`), guaranteeing files uploading in-flight from mobile devices over cellular/Wi-Fi to Google Drive pending queues are not read prematurely.
           - Streamer daemon (`bin/live_dashboard_streamer.rb`) running on loopback port 7025 with autonomous intake armed via `auto_intake.enabled`, reverse proxied at `https://www.just3ws.localhost/api/live/`.
         - All validation gates passing cleanly: `validate:fast`, `validate:obs` (46/46 assertions), and `rspec` (210/210 tests). Zero em-dash compliance maintained.
       - PAUSABLE MEDIA PIPELINE, FULL-TEXT VIDEO KNOWLEDGE SYSTEM & LIVE INGRESS FUNNEL (2026-10-15):
         Architected and built pause/stop signal controls, comprehensive video datalake search, live ingress funnel, and teleprompter studio:
         - Engineered dual-level pause and stop controls in `bin/intake_drive_video.rb` (`bin/pipeline pause` / `halt`, `stop`, `resume`):
           - *Halt*: arms graceful sentinel (`~/.local/state/just3ws/pipeline.halt`) to complete current task then pause queue.
           - *Stop*: immediate abort signaling worker PID, cleaning `/tmp/intake_*` scratch files, restoring files from `processing/` back to `pending/`, and releasing Concurrency Lock.
           - *Signal Handling*: first `SIGINT` (Ctrl+C) / `SIGTSTP` initiates graceful halt; second `SIGINT` / `SIGTERM` initiates immediate task abort.
         - Built Full-Text Video Datalake Knowledge System:
           - Automatically persists speech-to-text transcripts into `_data/transcripts/<slug>.yml` and registers in `_data/video_assets.yml` upon intake completion.
           - Upgraded `bin/generate_career_datalake.rb` to ingest full plain-text transcripts across all 218 transcript files into `career_datalake.json` and `.jsonl`.
           - Upgraded `bin/query_career_datalake.rb` and `bin/career_datalake_mcp_server.rb` with full-text search across all video transcripts with contextual quotes and direct YouTube links.
           - Reconciled and enriched legacy video `YOsPY8Bn8RQ` ("Ogilvie lost and found") and `dN--7I0FRvY` ("Production Incidents & SRE").
         - Re-architected Operations Cockpit (`youtube/dashboard.html`):
           - Added Tab 0: Live Ingress & Publishing Funnel (`#tab-funnel` / `#tab-queue`) with 5-column Kanban layout (Staged, Pending FIFO, Processing In-Flight, Processed Deployed, Quarantined Failures with 1-click re-queue).
           - Added live operator controls: Halt Queue, Immediate Stop, Resume, Move to Pending, Re-queue.
           - Added client-side hash routing supporting deep links (`#tab-funnel`, `#tab-teleprompter`, `#tab-bpmn`).
           - Added series filter chips across Asset Catalog for Ramblin' & Amblin', Errata, and Oral History.
         - Upgraded Localhost Subnav (`_includes/localhost-subnav.html`) and SwiftBar (`bin/youtube-swiftbar`):
           - Processor pulse dot reflects realtime states: Stopped (red pulse), Halted (amber pulse), Ingesting (blue pulse), Queued (amber), Idle (green).
           - Integrated direct links to Live Ingress Funnel and operator controls.
         - All validation gates passing cleanly: `validate:fast`, `validate:obs` (46/46 assertions), and `rspec` (210/210 tests). Zero em-dash compliance maintained.

       - END-TO-END SYSTEM OPERATIONAL VERIFICATION & CLOUD STREAMING INTAKE SUCCESS (2026-10-15):
         Verified complete end-to-end autonomous ingestion, live diagnostics, and system health:
         - Completed end-to-end cloud streaming intake of `VID_20261015_144836712.mp4` (1.63 GB) to YouTube Data API v3 (`dN--7I0FRvY`), assigned to playlist `PLNtb969T2-l0` (Ramblin' & Amblin'), uploaded WebVTT captions, and safely archived master to `processed/2026-10/` with zero permanent local SSD waste.
         - Concurrency Lock released to `idle` state, ready for subsequent FIFO candidates across all channels.
         - Realtime SSE streamer (`bin/pipeline stream`) daemon active on loopback port 7025 and reverse proxy verified through nginx at `https://www.just3ws.localhost/api/live/status` (HTTP 200 OK, active connection).
         - macOS SwiftBar monitor (`bin/pipeline swiftbar`) updated to dynamic `🎬 Ready` pulse with live queue counts and green subsystem health.
         - All validation gates passing cleanly: `validate:fast`, `validate:obs` (46/46 assertions), and `rspec` (210/210 tests). Zero em-dash compliance maintained.

       - TEXTREAM TELEPROMPTER INTEGRATION & THE SOUND ABOVE BROADCAST PROCESS (2026-10-15):
         Integrated native Textream (/Applications/Textream.app, dev.fka.textream) teleprompter compatibility into The Sound Above broadcast workflow:
         - Upgraded `bin/generate_sound_above_teleprompter.rb` to compile native `.textream` documents (JSON Array of Strings conforming to Textream multi-page specification) across all 38 episodes (0 to 37), with `--textream` (`-t`), `--save-textream`, `--open`, `--url`, and `--all-textream` flags.
         - Integrated `media teleprompter` and `media textream` into unified pipeline router `bin/pipeline` with full backward-compatible flat aliases.
         - Enhanced pre-broadcast staging harness `bin/stage_episode_workflow.rb` (`bin/pipeline stage <ep>`): Gate 5 now compiles and validates the native `.textream` document for schema, 6-act page count, and zero em dashes.
         - Upgraded Web Teleprompter Studio in `youtube/dashboard.html` (`/youtube/dashboard/#tab-teleprompter`) with "Launch in Textream" (textream:// deep link), "Export .textream" (JSON document download), and per-act "Read in Textream" action buttons.
         - Documented Textream setup and desktop ergonomics in `obs/docs/recording-cheatsheet.md` and updated `oral-history-broadcaster` skill.
         - Created comprehensive RSpec suite `spec/youtube/textream_teleprompter_spec.rb` (11 assertions). All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), validate:public_index_mode (895 indexable pages), and rspec (210/210 tests).

       - CROSS-CHANNEL 1-AT-A-TIME SERIALIZATION, FIFO QUEUES, PONYTAIL DISCIPLINE & SUBNAV OFFSET REPAIR (2026-10-15):
         Implemented cross-channel serialized intake, FIFO ordering, Ponytail complexity discipline, tool namespacing, and fixed subnav dropdown ergonomics:
         - Resolved subnav dropdown horizontal offset and mouse-glide hover collapse bug in `_includes/localhost-subnav.html`: replaced `right: 0` with `left: 0` alignment, created seamless `::before` invisible hover bridge (8px high), and added click toggle plus keyboard Escape dismissal.
         - Architected and implemented cross-channel 1-at-a-time serialized media processing in `bin/intake_drive_video.rb`: global `active_processing_files` Concurrency Lock prevents concurrent video ingestion across all channels and targets to preserve localhost CPU, RAM, and Apple Silicon Neural Engine headroom.
         - Implemented strict FIFO queue ordering: `collect_pending_candidates` sorts candidates across all channels ascending by filesystem ingress age (`file_age_timestamp` using APFS birthtime falling back to mtime). Added `-1` / `--one` / `--single` flag for step-by-step ingestion.
         - Loaded and established Ponytail skill (`.agents/skills/ponytail/SKILL.md`) and optimized `GEMINI.md` with the 4-rung complexity ladder and `# ponytail:` seam markers.
         - Re-architected unified pipeline driver `bin/pipeline` with four clean domain namespaces (`media`, `validate`, `data`, `site`) with full backward-compatible flat aliases, documented in `bin/README.md`.
         - Authored comprehensive RSpec suite `spec/pipeline/namespacing_and_ponytail_spec.rb` (20 assertions) verifying Ponytail discipline, namespaced pipeline grammar, staged directories, and cross-channel Concurrency Lock.
         - Maintained 100% em-dash-free compliance across all additions. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (200/200 tests).

       - SWIFTBAR PIPELINE INTEGRATION & LOCALHOST NAVIGATION CONSOLIDATION (2026-10-15):
         Architected and built system-wide macOS SwiftBar status monitor and seamless localhost navigation integration:
         - Built executable `bin/youtube-swiftbar` (`bin/pipeline swiftbar`): fast, self-contained status pulse emitting dynamic menu bar icon, pending queue counts across all 3 playlists (Ramblin' & Amblin', The Sound Above, Errata), active DSP/transcription indicators, SSE streamer status, YouTube quota headroom, direct localhost dashboard jump links, and one-click operator actions.
         - Installed user shim at `~/.swiftbar/youtube-pipeline.30s.sh` adhering to zdots/adots conventions with 30s automatic refresh.
         - Upgraded primary site navigation across `_includes/localhost-subnav.html` with dedicated Dashboards dropdown, `_data/navigation.yml` with Operations Cockpit entry, `_includes/command-palette.html` (⌘⇧K) with fast indexing, and `dashboard.html` with direct chips to BPMN and Teleprompter.
         - Created comprehensive RSpec suite `spec/youtube/swiftbar_spec.rb` verifying SwiftBar script output, shim executability, and navigation links.
         - Maintained 100% em-dash-free compliance across all code, configuration, and documentation. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (178/178 tests).

       - NEAR-REALTIME SSE STREAMER & LIVE DASHBOARD TELEMETRY (2026-10-15):
         Architected and built zero-dependency near-realtime Server-Sent Events (SSE) telemetry streamer and live dashboard integration:
         - Built `bin/live_dashboard_streamer.rb` (`bin/pipeline stream`): loopback HTTP daemon listening on `127.0.0.1:7025` serving `/events` (SSE), `/telemetry.json` (REST), and `/status` (Healthcheck), with Google Drive directory watcher broadcasting state changes within 1.5 seconds.
         - Configured nginx reverse proxy `/api/live/` in `nginx/just3ws.localhost.conf` with unbuffered SSE streaming (`proxy_buffering off; chunked_transfer_encoding off;`).
         - Built `initDashboardRealtimeStream()` in `youtube/dashboard.html` with dual-mode connectivity: primary SSE connection with visual status badge (`Realtime (SSE Live)` / `Stream Standby` / `Polling (3s sync)`), dynamic HUD queue counters, active BPMN step state transitions, and automatic fallback polling against `assets/data/youtube_pipeline_telemetry.json`.
         - Maintained 100% em-dash-free compliance across all code, configuration, and documentation. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (167/167 tests).

       - BPMN 2.0 WORKFLOW, SLO OBSERVABILITY & INTERACTIVE CAMUNDA MONITOR (2026-10-15):
         Modeled and instrumented the entire Media Intake and YouTube Publishing Pipeline using BPMN 2.0 execution semantics:
         - Authored standard BPMN 2.0 XML definition `docs/bpmn/media-intake-pipeline.bpmn` with 4 swimlanes, 12 service tasks, stability timer catches, and boundary error events.
         - Formulated comprehensive Service Level Indicators (SLIs), Objectives (SLOs), and Alert Matrix in `docs/bpmn/README.md` defining strict latency targets and incident tripwires across all 12 pipeline stages.
         - Built interactive BPMN Workflow & SLO Monitor inside the YouTube Operations Cockpit (`youtube/dashboard.html` / tab 6), featuring an interactive SVG diagram canvas, task inspection cards, dynamic queue HUDs, and animated workflow execution simulation.
         - Integrated `compile_media_intake_telemetry` into `bin/youtube_pipeline.rb` tracking real-time Google Drive queue counts.
         - Maintained 100% em-dash-free compliance across all XML, Markdown, JavaScript, and Ruby. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (162/162 tests).

       - GOOGLE DRIVE CLOUD INTAKE & YOUTUBE PUBLISHING PIPELINE (2026-10-15):
         Architected and built zero-disk-waste cloud streaming intake pipeline from Google Drive to YouTube:
         - Established Maildir-pattern queue directories inside Google Drive: `Media Intake/whoistechcmty/{ramblin-amblin,the-sound-above,errata}/{pending,processing,processed,failed}`.
         - Created declarative mapping configuration `_data/media_intake_targets.yml` connecting Google Drive queue folders to YouTube playlists (`PLNtb969T2-l0`, `PLVcmLmfz2uyA`, `PLKPAHha6I990`), privacy rules, categories, and tags.
         - Built end-to-end intake orchestrator `bin/intake_drive_video.rb` (`bin/pipeline intake`): extracts ephemeral audio to `/tmp/` without video duplication, executes local whisper.cpp speech recognition on Apple Silicon, synthesizes Craftsman metadata or binds episode dossiers, streams resumable uploads directly to YouTube Data API v3, uploads verified WebVTT captions, and archives cloud masters to `processed/YYYY-MM/` with zero permanent local SSD consumption.
         - Upgraded `YouTubeClient` (`bin/lib/youtube_client.rb`) with reusable `upload_video` (chunked resumable PUT) and `upload_caption` (multipart WebVTT POST) endpoints.
         - Maintained 100% em-dash-free compliance across all code, YAML datasets, and tests. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (159/159 tests).

       - 37-EPISODE PRIME CURRICULUM, STAGING HARNESS, PATREON PIPELINE & WORKBENCH (2026-10-15):
         Synthesized and verified the complete 37-episode prime number curriculum and end-to-end publishing pipeline:
         - Completed full 38-dossier corpus (`_data/episodes/episode-00.yml` through `episode-37.yml`), incorporating Coda 1 (Episode 36: "Without zdots, There Was Nothing") and Coda 2 (Episode 37: "The Sound Above Roundtable") alongside the 35 oral history rewatches and preparatory pilot (Episode 00).
         - Built end-to-end non-destructive Staging and Rehearsal Workflow Harness `bin/stage_episode_workflow.rb` (`bin/pipeline stage`), verifying all 38 episodes cleanly across 7 gates (schema, em-dash audit, YouTube title/desc character budgets, transcript parity, OBS overlay state, 6-act teleprompter compilation, quota simulation, and patron credits).
         - Built Patreon API v2 client and credit automation CLI `bin/patreon_pipeline.rb` (`bin/pipeline patreon`) with live JSON:API integration and local sandbox fallback, tracking monthly compute funds and formatting outro attribution.
         - Created dedicated agent skill `.agents/skills/patreon-integrator/SKILL.md` and updated `.agents/skills/oral-history-broadcaster/SKILL.md` with the 37-episode prime sequence and staging harness workflows.
         - Calibrated titles for Episodes 13 and 28 to strictly respect YouTube's 100-character limit with episode suffix.
         - Maintained 100% em-dash-free compliance across all code, YAML datasets, JSON, and documentation. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (147/147 tests).

       - YOUTUBE PUBLISHING PIPELINE, OPERATIONS COCKPIT & THE SOUND ABOVE TELEPROMPTER (2026-10-14):
         Built unified YouTube publishing pipeline, operational overview dashboard, teleprompter rundowns, and funding architecture:
         - Created unified pipeline orchestrator CLI `bin/youtube_pipeline.rb` supporting status, audit, telemetry, schedule, script, and quota commands.
         - Integrated `youtube` and `youtube-pipeline` subcommands into `bin/pipeline`.
         - Developed comprehensive Operations Dashboard at `youtube/dashboard.html` (`/youtube/dashboard/`, `/dashboard/youtube/`) with Craftsman tokens, multi-stage publication funnel, live search and filtering across 215 assets, 6-point best-practices auditor, interactive quota calculator, and direct control links.
         - Built 6-act broadcast teleprompter and rundown generator `bin/generate_sound_above_teleprompter.rb` aligned directly with OBS scenes 01 to 08, embedded as an interactive studio widget in the dashboard.
         - Structured `_data/publication_schedule.yml` connecting The Sound Above, Ramblin' & Amblin' field notes, and Errata broadcasts across a 4-week release arc.
         - Authored comprehensive strategic roadmap `docs/the-sound-above-audience-and-funding-strategy.md` outlining the tri-format flywheel, 6-movement narrative progression, and sustainable funding channels (GitHub Sponsors, devtool underwriting, Staff+ advisory, and digital humanities grants).
         - Maintained 100% em-dash-free compliance across all code, YAML datasets, and documentation. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (118/118 tests).

       - TIM OTTINGER INTERVIEW ENRICHMENT & SCMC RECONCILIATION (2026-10-13):
         Fixed and enriched Tim Ottinger interview page, transcript turns, and community attribution:
         - Reconstructed 56 natural alternating speaker turns across all 221 whisper subtitle blocks in `_data/transcripts/tim-ottinger-general.yml`.
         - Reconciled community attribution from General to Software Craftsmanship McHenry County (SCMC) in `_data/interviews.yml` and registered community metadata in `_data/interview_communities.yml`.
         - Purged duplicated intro text and replaced 36 synthetic 15-second chapters with 10 verified thematic chapters in `_data/video_assets.yml` and `_data/youtube_metadata_staged.json`.
         - Synchronized live YouTube Data API v3 metadata and uploaded calibrated WebVTT captions track to `GYpgcyIH_gc`.
         - Re-exported captions manifest, verified WebVTT tracks, and regenerated CareerOS datalake exports.
         - Maintained 100% em-dash-free compliance across all code, YAML datasets, and documentation. All validation gates passing cleanly:
           validate:fast, transcript:audit (215 assets / 0 orphans), rspec (100/100 tests), and validate:obs (46/46 assertions).

       - ERRATA PRACTICE RUN BROADCAST, DEHUM COCKPIT & YOUTUBE PIPELINE (2026-10-13):
         Completed the live break-the-ice broadcast recording, harmonized the Dehum presentation cockpit, and published the practice run:
         - Recorded and uploaded 32-minute live broadcast session (`7YeFpKn5FbU`) to YouTube Data API v3 as "[PRACTICE RUN] The Mirage of Competence: AI Slop & Domain Boundaries".
         - Created and published dedicated Errata playlist `PLKPAHha6I990` ("The Sound Above: Marginalia, Readings & Demonstrations (Errata)").
         - Built and committed deterministic upload and metadata calibration CLI tools `bin/upload_errata_broadcast.rb` and `bin/calibrate_uploaded_broadcast.rb`.
         - Synchronized video metadata with explicit break-the-ice first take framing, audio settings learnings, direct reference link to the Forensic Audio A/B Listening Test, and the historical Dell Studio XPS PP35L OLED laptop story with the monkey typing sticker (sole Obtiva .NET project and Vim transition).
         - Restored warm paper Craftsman light theme (`#faf8f5` canvas, `#ffffff` cards, `#1e232a` ink, `#0f766e` teal, `#b45309` amber) across the Dehum presentation cockpit and embedded the physical sticker photo (`assets/img/typing-is-not-the-bottleneck.jpg`).
         - Maintained 100% em-dash-free compliance across all code, datasets, and documentation. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (100/100 tests).

       - SESSION TITLE CALIBRATION, DEHUM RESTRUCTURING & YOUTUBE SYNC (2026-10-13):
         Calibrated broadcast session naming, reorganized dehum toolchain, synchronized YouTube metadata, and eliminated warrior rhetoric:
         - Renamed session to "The Mirage of Competence" with subtitle "An Experiment in Public on AI Slop and Domain Boundaries" across `obs/curation/errata-manifest.json`, `obs/overlays/overlay-state.json`, and `bin/broadcast`.
         - Synchronized YouTube Data API v3 live metadata via `bin/update_youtube_metadata.rb`: updated upcoming broadcast `XS7EZ1eWH4U` with full context, origin search premise, and accurate token economics (<$1.25 subscription cash); added prominent `[HEADPHONE / VOLUME WARNING: BAD AUDIO]` to the raw master `8LYHo1dOkMo`.
         - Structured `~/ai/dehum/`: organized pre-git genesis artifacts into `archive/genesis/` (`PROMPT.md`, `gemini_transcript.md`), Whisper datasets and diff telemetry into `data/transcripts/`, and relocated tooling into `bin/` with backward-compatible root symlinks.
         - Purged all "holds the line" rhetoric and calmed tone into grounded, reflective prose across LinkedIn articles, community posts, runbooks, and economic audits.
         - Maintained 100% em-dash-free compliance across all code, YAML datasets, and documentation. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (100/100 tests).

       - OBS BROADCAST ORCHESTRATION & PREMISE ELEVATION (2026-10-13):
         Cued Errata broadcast and elevated the original search query as the primary premise across teleprompter and broadcast state:
         - Cued broadcast topic with subtitle via `bin/broadcast cue --cue errata-concept-under-the-high-tension-wires --series "The Sound Above"`.
         - Updated `obs/overlays/overlay-state.json` and synchronized state cleanly across the repository.
         - Elevated the original Google search prompt ("recording a video under high tension wires repair audio sync") to top-of-teleprompter hero callout on the Dehum cockpit (`https://www.just3ws.localhost/dehum/dashboard.html`).
         - Maintained 100% em-dash-free compliance across all code, YAML datasets, and documentation. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (100/100 tests).

       - RECORDING BROWSER ENVIRONMENT & BROADCAST THEME HARMONIZATION (2026-10-13):
         Consolidated broadcast recording assets, browser environment toolchain, and theme harmonization:
         - Built and verified automated recording browser toolchain `bin/setup_recording_environment.py` (v1.1.0) staging 12 extensions into `~/Library/Application Support/Chromium/UnpackedExtensions/`.
         - Strictly quarantined LastPass, Complexity, and DeArrow across all catalogs, profiles, and sync scripts.
         - Harmonized browser chrome, Stylus userstyles, Bonjourr start page cockpit, Hister portal, and the Dehum presentation cockpit (`https://www.just3ws.localhost/dehum/dashboard.html`) directly with the canonical `just3ws.com` design tokens (warm paper canvas `#faf8f5`, crisp cards `#ffffff`, sumi ink `#1e232a`, craftsman teal `#0f766e`, warm amber `#b45309`, Charter serif display, and Inter UI sans).
         - Resolved `/dashboard.html` 404 by adding frontmatter redirect mapping directly to canonical control plane `/dashboard/`.
         - Consolidated all browser theme and recording configuration assets into `obs/browser-themes/` (with version-controlled staged backups in `obs/browser-themes/staged-configs/`).
         - Maintained 100% em-dash-free compliance across all code, YAML datasets, and documentation. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), validate:public_index_mode (892 indexable pages), and rspec (100/100 tests).

       - RAMBLIN & AMBLIN FIELD NOTES PIPELINE & AUTONOMOUS PUBLISHING (2026-10-13):
         Built deterministic intake, transcription, captioning, and publishing toolchain for the Ramblin & Amblin playlist (PLNtb969T2-l0):
         - Added standing autonomous polling CLI `bin/pipeline_ramblin_amblin.rb` cross-referencing live YouTube videos with postgres `media_sources` on `my.localhost`.
         - Established strict privacy boundaries: unlisted videos are transcribed, enriched, and promoted to public once ingestion completes; private videos remain strictly private while being fully enriched.
         - Automated multipart WebVTT human-verified caption uploads to YouTube Data API v3 (`English (Human Verified)`).
         - Configured background macOS daemon `com.just3ws.ramblin-pipeline` running every 30 minutes.
         - Enriched and published all field notes: Veteran Acres (`52dk-anGBe4`), CDG at CLPL (`0q1EAVJvBcU`), Shift (`DQFs9H3eal8`), and restored Dehum cockpit (`dashboard.html`).
         - Maintained 100% em-dash-free compliance across all code, YAML datasets, and descriptions. All validation gates passing cleanly:
           validate:fast, transcript:audit (215 assets / 0 orphans), and rspec (100/100 tests).

       - RECORDING CHEATSHEET & SCENE OVERLAY CLARITY (2026-10-08):
         Documented high-density recording cheatsheet and clarified OBS Scene 02 overlay architecture:
         - Created `obs/docs/recording-cheatsheet.md` covering pre-flight CLI sequences, scene selector reference,
           window ergonomics (1920x1080 canvas), lower-third behavior and cache refresh troubleshooting,
           multi-track audio assignments (Tracks 1 to 4), and T-5 minute checkoff list.
         - Indexed the new cheatsheet in `obs/README.md`.
         - Clarified OBS Scene 02 (`Monologue / Full Camera`) overlay hierarchy: confirmed that Scene 02 intentionally
           contains `Overlay: Lower Third` directly above the camera without the upper-right `Now Watching HUD`,
           and documented how auto-hide timing and browser source scene caching influence overlay re-triggering.
         - Maintained 100% em-dash-free compliance across all additions. All validation gates passing cleanly:
           validate:fast, validate:obs (46/46 assertions), and rspec (100/100 tests).

       - OBS LOWER-THIRD AUTO-HIDE & FOOTPRINT COMPACTION (2026-10-08):
         Resolved OBS lower-third card persistence and reduced visual screen occlusion:
         - Diagnosed why the lower-third card remained visible indefinitely: `OverlayController.mergeOverrides()`
           omitted `lower_third_autohide` and `lower_third_layout`, causing `scheduleAutoHide()` in `lower-third.html`
           to receive `undefined` instead of the configured 10s timeout from `overlay-state.json`.
         - Updated `obs/overlays/js/overlay-controller.js` to preserve `lower_third_autohide` and `lower_third_layout`
           across merged URL overrides and JSON states, defaulting safely to a 12s auto-hide timeout.
         - Updated `obs/overlays/lower-third.html` to establish reliable fallback auto-hide scheduling on initial load,
           smooth fade-out transform (`translateY(20px) scale(0.98)`), and compact styling dimensions:
           reduced container `max-width` from `900px` to `680px`, card padding to `12px 18px`, interviewee name font-size
           to `22px`, and clamped Sound Above prompts to 2 lines max with ellipsis.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs
           (46/46 assertions), and rspec (100/100 tests).

       - CI GATE GREEN & CANONICAL LINK RECONCILIATION (2026-10-08):
         Resolved GitHub Actions deployment pipeline failures across public index and HTML-Proofer gates:
         - Diagnosed `validate_public_index_mode` failure: `IntervieweeRedirectPage` emitted a relative target URL
           (`/interviews/people/adam-lear/`) in `<link rel="canonical">` instead of the fully-qualified canonical host.
           Updated `_plugins/generate_interviewees.rb` to resolve the canonical site URL (`https://www.just3ws.com`)
           safely while handling mock site objects in RSpec.
         - Diagnosed HTML-Proofer internal link hash failure on `/series/the-sound-above/episode-35/`: episode template
           linked to `#codas`, but the section anchor in `series/the-sound-above/index.html` was `#series-codas`.
           Updated `_layouts/series_episode.html` to reference `#series-codas`.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           validate:rendered_site (HTML-Proofer, SEO, Resume, ATS 88.2%), and rspec (100/100 tests).

       - TRANSCRIPT AUTOSCROLL STABILIZATION & PROGRESS RETENTION (2026-10-08):
         Resolved aggressive turn switching and jumpy transcript scrolling:
         - Diagnosed issue: high-frequency postMessage playback events (every 250ms) caused sub-second micro-turns
           (such as 0.4s and 1.0s affirmatives) to flash instantaneously and trigger continuous scroll re-centering,
           causing the reader to lose track of the conversation flow.
         - Introduced transition stabilization in `_includes/video-asset-player.html`: added a 600ms debounce floor
           (`MIN_TURN_DISPLAY_MS`) to prevent rapid flip-flopping during natural dialogue, strict half-open interval
           matching (`start <= t < end`), boundary retention, and `forceImmediate` bypass for intentional user clicks.
         - Added in-view viewport awareness: autoscroll now only triggers when the active turn drifts outside the
           comfortable visible zone of the transcript pane, preventing unnecessary jitter while reading.
         - Removed layout-shifting scale transform (`transform: scale(1.01)`) from `.is-speaking` in `_sass/_p_main.scss`.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           and rspec (100/100 tests).

       - TRANSCRIPT AUTOSCROLL CONTAINER BOUNDS & VIDEO PLAYER VIEWPORT ANCHOR (2026-10-08):
         Fixed transcript autoscroll scrolling the video player out of view:
         - Diagnosed issue: invoking `matched.scrollIntoView()` on an unconstrained document flow caused the whole browser
           window to scroll down to the active turn, pushing the video player above the viewport.
         - Encapsulated `.sync-transcript-stream` within an independent scroll container in `_sass/_p_main.scss` (`max-height: 70vh`,
           `overflow-y: auto`, `overscroll-behavior: contain`) with subtle craftsman themed scrollbars and book paper palette.
         - Updated autoscroll handler in `_includes/video-asset-player.html` to use scoped container scrolling (`stream.scrollTo()`),
           centering the active turn smoothly within the transcript pane while keeping the video player firmly anchored in the viewport.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           and rspec (100/100 tests).

       - LIVE CC SYNCHRONIZATION & VIDEO PLAYER CONTROL BAR TIDY (2026-10-08):
         Resolved real-time transcript progress tracking in the LIVE CC subtitle box and polished player controls:
         - Diagnosed why the LIVE CC box did not update as video played: YouTube and Vimeo iframes require an active
           postMessage listening handshake (`{"event": "listening"}` and `{"method": "addEventListener", "value": "timeupdate"}`)
           to emit `infoDelivery` / `timeupdate` playback events to the parent window.
         - Upgraded `_includes/video-asset-player.html` and `assets/js/deferred-embeds.js` to register the listening handshake
           immediately upon iframe load and periodically during playback polling. Added multi-event support handling
           `infoDelivery`, `initialDelivery`, `timeupdate`, and HTML5 native video time tracking.
         - Polished messy player controls in `_sass/_p_main.scss`: converted `.video-details-bar` into a responsive flex layout
           with discrete indicator and action groupings, replaced awkward solid-white/borderless buttons with digital patina
           craftsman tokens, and refined `.sync-cc-overlay` with sumi ink background and craftsman teal accents.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           and rspec (100/100 tests).

       - CONFERENCE PRESENTATION MAPPING & SPEAKER TALK EMBED ENHANCEMENTS (2026-10-08):
         Connected interviewees directly to the conference presentations they delivered across GOTO Chicago, RailsConf 2014, and SCNA:
         - Resolved identifier fragmentation in `_data/interview_related_videos.yml`: normalized 46 legacy YouTube and slug
           records to canonical interview IDs and added presentation links for RailsConf 2014 (DHH's "Writing Software" keynote,
           Joel Turnbull's Pry debugging, Alexander Dymo's memory optimization, Carlos Antonio da Silva's Rails tricks, Coraline Ada Ehmke's
           apprenticeship talk) and SCNA 2012 (Gary Bernhardt's "Boundaries" debut).
         - Upgraded `_layouts/interviewee_detail.html` with responsive presentation video embeds, presentation abstracts, and
           outbound links for all conference-presentation-video and conference-presentation-page assets.
         - Expanded interviewees index with verified presentation links from 4 to 40 speakers (including Corey Haines, Adrian Cockcroft,
           Anita Sengupta, Camille Fournier, Chad Fowler, Charles Nutter, Dave Thomas, Dean Wampler, Gary Bernhardt, Kyle Kingsbury,
           Rich Hickey, and David Heinemeier Hansson).
         - Enriched `_data/interview_conferences.yml` with deep thematic context, exact calendar dates, and historical venues:
           SCNA 2011 (Swissotel Chicago on Chicago River, Nov 18-19, 2011), SCNA 2012 (Mid-America Club on Aon Center 80th floor,
           Nov 9-10, 2012), WindyCityRails 2012 (Sep 7-12, 2012), and RailsConf 2014 (Apr 22-25, 2014) documenting the TDD debate,
           runtime maturation, and engineering apprenticeship.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           and rspec (100/100 tests).

       - HISTORICAL RECORDING DATE RECONCILIATION & DYNAMIC EPISODE PAGES (2026-10-08):
         Resolved historical date distortion across 79 conference/UGtastic interviews and completed episode rendering:
         - Reconciled 79 interviews that defaulted to 2022 YouTube platform re-upload dates:
           calibrated GOTO Chicago 2013 (April 23-26, 2013), GOTO Chicago 2014 (May 20-21, 2014),
           GOTO Chicago 2015 (May 11-12, 2015), RailsConf 2014 (April 22-25, 2014), WebVisions 2013
           (September 28, 2013), and SCNA 2011-2013 sessions in `_data/interviews.yml` and
           `_data/interview_conferences.yml` with true historical provenance dates.
         - Built dynamic Series Episode generator plugin (`_plugins/generate_series_episodes.rb`)
           and shared layout (`_layouts/series_episode.html`) to render individual showcase pages
           for all 35 interview episodes (`/series/the-sound-above/episode-02/` through `episode-35/`)
           with Schema.org VideoObject, verified transcript cross-links, prev/next movement navigation,
           and responsive video embed players.
         - Updated series curriculum overview (`series/the-sound-above/index.html`) to link every episode
           card directly to its dedicated showcase page.
         - Regenerated master CareerOS datalake endpoints (`career_datalake.json`, `career_datalake.jsonl`).
         - Maintained 100% em-dash-free compliance across all code, templates, and data files.
         - All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           rspec (100/100 tests), and Jekyll build (1,013 pages generated).

       - THE SOUND ABOVE 37-EPISODE CURRICULUM HUB & ARCHIVE AUDIT (2026-10-07):
         Built dedicated series curriculum hub page and clarified exact archive counts:
         - Verified ground-truth archive metrics across the corpus: 201 total items (184 UGtastic interviews,
           12 SCMC recordings, 5 one-off community presentations), 191 unique UGtastic interviewees (199 total speakers),
           and 6 conferences (SCNA, GOTO, RailsConf, WindyCityRails, ChicagoWebConf, WebVisions) spanning 2011 to 2015.
         - Created comprehensive series curriculum overview at `/series/the-sound-above/` (`series/the-sound-above/index.html`)
           displaying all 37 episodes grouped across 6 historical movements, with guest names, conferences,
           years, core inquiry prompts, AI-era parallels, and links to verified interactive transcripts.
         - Updated global navigation (`_data/navigation.yml`) and interviews spotlight (`interviews/index.html`)
           to link to the 37-episode curriculum overview.
         - Exposed `_data/sound_above_sequence.json` for deterministic template rendering.
         - Maintained 100% em-dash-free compliance across all additions. All validation gates passing cleanly:
           validate:fast, validate:obs (44/44 assertions), and rspec (98/98).

       - INTERVIEWS ARCHIVE EDITORIAL REVIEW & NAVIGATION TIDY (2026-10-07):
         Overhauled `/interviews/` and archive components into full alignment with the site's
         canonical Digital Patina & Editorial Craft design tokens:
         - Fixed archive card date distortion: cards in `_includes/interview-card.html` now
           prioritize `recorded_date` over the 2022 YouTube platform re-upload date, correctly
           rendering primary historical dates (e.g. 'Nov 2011' for SCNA 2011 sessions).
         - Replaced legacy Bootstrap/pastel blue fallbacks (`#007bff`, `#0284c7`, `#2196f3`, `#e3f2fd`,
           `#7e9cd8`, `#363646`, `#2a2a37`) in `_sass/_p_main.scss` and `_sass/_p_surface_components.scss`
           with warm book paper canvas (`#faf8f5`), pure cards (`#ffffff`), subtle paper (`#f4f0e8`),
           craftsman teal (`#0f766e`), warm amber (`#b45309`), and sumi ink (`#1e232a`).
         - Added prominent editorial spotlight for 'The Sound Above' 37-episode rewatch series
           directly on `/interviews/`, linking to Episode 1, the Chicago Monograph, and the Community Timeline.
         - Tidied navigation hierarchy: separated in-page collection filtering (All Media, UGtastic, SCMC)
           from cross-corpus exploration guides (Speaker Directory, SCMC 17-Year Hub, Knowledge Graph,
           Corpus Intelligence, IronLanguages).
         - Updated `series/the-sound-above/episode-01.html` styles to match digital patina tokens.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly:
           validate:fast, validate:obs (44/44 assertions), and rspec (98/98).

       - CAREEROS DATALAKE LESSONS & 37-EPISODE CURRICULUM RETENTION (2026-10-07):
         Retained historical conference, role, and oral history curriculum lessons into CareerOS datalake:
         - Updated `bin/generate_career_datalake.rb` to persist `oral_history_curriculum` directly into
           `career_datalake.json`, `career_datalake.jsonl`, `exports/career_datalake.json`, and `exports/career_datalake.jsonl`.
         - Recorded official UGtastic launch provenance: launched on-site at SCNA 2011 (November 18-19, 2011
           at the Swissotel Chicago downtown on the Chicago River).
         - Calibrated historical host positioning: recorded that Mike Hall was a Senior Software Developer
           when recording the UGtastic archive (2009-2015), preserving authentic historical truth.
         - Embedded full 37-episode 'The Sound Above' rewatch sequence and 12-item pre-curated Errata broadcast catalog
           directly into master datalake schema.
         - Updated MCP server `bin/career_datalake_mcp_server.rb` to expose `career://datalake/curriculum` resource.
         - Expanded rewatch curriculum to 37 episodes and implemented zero-dependency canonical URL redirection
           in `_plugins/generate_interviewees.rb` from `/interviews/people/anna-lear/` to `/interviews/people/adam-lear/`.
         - Updated `bin/broadcast` CLI, manual pages (`broadcast.1`, `obs-livestream.1`), OBS documentation,
           and automated test suites (`bin/validate_obs_setup.rb`, `spec/plugins/interviewee_generator_spec.rb`,
           `spec/series/sound_above_series_spec.rb`).
         - Maintained 100% em-dash-free compliance across all code, JSON/YAML schemas, and prose. All validation
           gates passing cleanly: validate:fast, validate:obs (44/44 assertions), rspec (98/98), and benchmark:ats (88.2%).

       - ADAM LEAR NAME & GENDER AFFIRMATION & SCNA 2011 SWISSOTEL HISTORICAL VENUE (2026-10-07):
         Handled Adam Lear name transition with accuracy and respect, and recorded SCNA 2011 venue context:
         - Verified that interviewee Anna Lear transitioned to Adam Lear (software developer at Stack Overflow).
         - Updated speaker attribution to Adam Lear in `_data/transcripts/interview-with-anna-lear-general.yml`
           with respectful historical context: 'Adam Lear · Community Manager, Stack Exchange (recorded as Anna Lear)'.
         - Updated interviewee list in `_data/interviews.yml` and catalog description/tags in `_data/video_assets.yml`.
         - Preserved the verbatim 2013 spoken audio and historical transcript text unchanged.
         - Recorded primary provenance for SCNA 2011 (November 18-19, 2011 held at the Swissotel Chicago downtown
           on the Chicago River) in `docs/style-guide-and-canonical-naming.md` and `series/the-sound-above/episode-01.html`.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly:
           validate:fast, validate:obs (44/44 assertions), and rspec (97/97).

       - HISTORICAL RECORDING DATE RESTORATION & ERRATA BEHIND-THE-SCENES BROADCASTS (2026-10-07):
         Resolved archival date distortion on interview pages and expanded Errata broadcast archetype:
         - Diagnosed and fixed interview hero header date conflation: pages previously displayed
           the 2022 YouTube archival re-upload date instead of the primary historical event date.
         - Updated `_includes/video-asset-player.html` and `_layouts/interview.html` to resolve
           `archive_item.recorded_date` (e.g. November 19, 2011 for Sergio Pereira) and display
           event context (e.g. 'Recorded at SCNA 2011'), falling back safely through Vimeo and YouTube metadata.
         - Expanded the Errata broadcast archetype to explicitly support and document Behind the Scenes (BTS)
           broadcasts (studio tours, broadcast engineering, OBS and Golden Gate CoreAudio routing, toolchains).
         - Updated `bin/broadcast` CLI (--bts flag, --mode bts), `man/man1/broadcast.1`,
           `obs/schemas/overlay-state.schema.json`, `obs/scripts/update-overlay-state.sh`,
           `obs/overlays/lower-third.html` (dynamic 'STUDIO OPS' credo banner), and `obs/README.md`.
         - Added curated BTS entries to `obs/curation/errata-manifest.json` and thumbnail generation support in
           `bin/generate_errata_thumbnail.rb`.
         - Replaced lingering 'Software Craftsmanship #106' broadcast host defaults with canonical professional
           identity: 'Mike Hall (Staff Software Engineer & SCMC Co-Founder)'.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly:
           validate:fast, validate:obs (44/44 assertions), rspec (97/97), and resume_quality.

       - CANONICAL IDENTITY REFINEMENT & DATE SPAN PURGE (2026-10-07):
         Eliminated intrusive 'Signatory #106' branding and purged artificial '2005-2026' date callouts:
         - Removed spurious '2005-2026' and '(2005-2010)' ranges across Community Timeline, subnav,
           blog links, OBS sequence manifests, thumbnail templates, and overlay states.
         - Restored clean movement names across all six broadcast movements: The Chicago Crucible,
           The Practice and the Dojo, The Human Communication Layer & Inclusion, Philosophy, Empathy &
           Craftsmanship, The Architecture and Testing Reckoning, and The AI Horizon & The Observable Control Plane.
         - Retained the March 6, 2009 ledger record as factual historical context and evidence
           in forensics reports and origin essays.
         - Restored canonical professional identity across public and tooling surfaces:
           Staff Software Engineer, UGtastic Creator/Host, and SCMC Co-Founder.
         - Purged employer names (BDI, TicketsNow) from community initiatives and milestone lists,
           restoring pure practitioner rooms: 8th Light Pair Friday, SCNA, CDG, and SCMC.
         - Zero em dashes maintained. All gates passing: validate:fast, validate:obs (44/44),
           rspec (97/97), and resume_quality.

       - COMMUNITY TIMELINE CRAFTSMANSHIP OVERHAUL & ITERM2 INTEGRATION (2026-10-07):
         Overhauled `/timeline/community/` into full alignment with the site's canonical
         Digital Patina & Editorial Craft design tokens:
         - Eliminated legacy silver borders (#363646) and low-contrast pastel tones (#7e9cd8, #c8c093).
         - Applied warm book paper canvas (#faf8f5), pure cards (#ffffff), subtle paper (#f4f0e8),
           deep sumi ink (#1e232a), slate headings (#0f172a), craftsman teal (#0f766e),
           and warm amber accents (#b45309).
         - Replaced inline hex color attributes with semantic classes in `_sass/_p_timeline.scss`.
         - Updated `.surface-editorial` and `.archive-note` in `_sass/_p_surface_components.scss`.
         - Integrated `The Sound Above (Broadcast)` iTerm2 profile (`obs/iterm2/the-sound-above.json`),
           resolved dynamic profile GUID collision with fresh unique UUID, and bound Scene 05
           (`05. Workbench - Code & Terminal`) window capture owner to `iTerm2`.
         - Documented Section 8 in `docs/style-guide-and-canonical-naming.md` establishing design
           tokens and contrast hierarchy across site, OBS overlays, Orion, and iTerm2.
         - Maintained 100% zero em dashes across all code and documentation. All gates passing:
           validate:fast, validate:obs (44/44 assertions), rspec (97/97), and resume_quality.

       - UNIFIED BROADCAST DIRECTOR & AI-ASSISTED TOOLING SUITE (2026-10-07):
         Created unified live broadcast CLI (`bin/broadcast`) and manual (`man/man1/broadcast.1`)
         to orchestrate all three broadcast archetypes:
         - Archetype 1 ('The Sound Above'): Forensic oral history rewatches (Episodes 1 to 31).
         - Archetype 2 ('Errata'): Solo broadcasts (readings, concepts, live demos, stories, artifacts)
           backed by pre-curated catalog in `obs/curation/errata-manifest.json`.
         - Archetype 3 ('The Room'): Invited peer dialogues and community roundtables.
         Updated `obs-livestream.1` man page to reflect 31 episodes and `bin/broadcast` CLI integration.
         Created comprehensive, unambiguous `docs/runbooks/broadcast-operations-playbook.md`
         defining sequential pre-flight, live execution, and post-stream teardown checklists.
         Updated `oral-history-broadcaster` agent and skill definitions across `.agents/skills/`
         and `.claude/agents/` to equip autonomous AI assistants for broadcast setup and verification.
         Zero em dashes maintained. All validation gates passing cleanly: validate:obs (40/40),
         validate:fast, rspec (97/97), resume_quality, and benchmark:ats (88.2%).

       - TRI-ARCHETYPE BROADCAST ARCHITECTURE & 'ERRATA' TEMPLATE (2026-10-06):
         Established polymorphic broadcast architecture across three core archetypes:
         - Archetype 1 ('The Sound Above'): Forensic oral history rewatches and commentary.
         - Archetype 2 ('Errata'): Personal insights, book readings, live code demonstrations,
           concept breakdowns, and physical archival memorabilia / artifact showcases.
         - Archetype 3 ('The Room'): Invited guest conversations, collegial peer dialogues, and roundtables.
         Updated overlay state schema (obs/schemas/overlay-state.schema.json) and controller
         (obs/overlays/js/overlay-controller.js) to dynamically configure lower-third HUDs,
         reading citation cards, starting title screens, and outros.
         Enhanced CLI cueing tool (obs/scripts/update-overlay-state.sh) with --errata, --rewatch,
         --dialogue, and fine-grained mode flags (--mode reading|concept|demo|story|artifact).
         Zero em dashes maintained. All validation gates passing cleanly: validate:obs (40/40),
         validate:fast, rspec (97/97), resume_quality, and benchmark:ats (88.2%).

       - 31-EPISODE ORAL HISTORY SEQUENCE EXPANSION (2026-10-06):
         Expanded 'The Sound Above' oral history rewatch series to 31 episodes across 6 distinct movements:
         - Added Ginny Hendry (Episode 12, 'A Legacy of Learning: Community Hospitality, RailsBridge & In Memoriam')
           with delicate, honorable focus on her lifelong mentorship, 8th Light owner tribute, and Chicago RailsBridge leadership.
         - Added Leon Gersing (Episode 13, 'Hold Yourself to a Standard, But Let There Be Joy: Overcoming Developer Shame')
           with radical empathy, vulnerability, and developer joy framing from SCNA 2012.
         - Curated full 31-episode roadmap across 6 movements in obs/curation/sequence-manifest.json and rewatch-curation-sequence.md.
         - Updated YouTube rewatch playlist synchronization tool (bin/sync_youtube_rewatch_playlist.rb) with all 31 sessions.
         - Maintained 100% em-dash-free compliance and strict canonical contracts.
         - All validation gates passing cleanly: validate:obs (40/40 assertions), validate:fast, rspec (97/97),
           resume_quality, and benchmark:ats (88.2%).

       - MOVEMENT 1 BROADCAST STAGING & DETERMINISTIC THUMBNAILS (2026-10-06):
         Generated 1080p and 720p craftsmanship-theme thumbnails and scheduled live broadcasts
         for all 5 episodes of Movement 1 ('The Chicago Crucible'):
         - Episode 01: Sergio Pereira (eGXG7Qu4G1E, The First Room / Alt.NET)
         - Episode 02: Ray Hightower (rUH7UAeka4c, The Ambassador / Chicago Ruby & 1871)
         - Episode 03: Micah Martin & Mike Jansen (aCbqGDJ3BE4, Pair Friday in Libertyville / 8th Light)
         - Episode 04: Dave Hoover ( -ZnHI8BnyK4, The Apprenticeship Move / Obtiva & Dev Bootcamp)
         - Episode 05: Ryan Gerry & Jim Suchy (3UScVYlNnQg, The 17-Year Continuous Room / SCMC & Follett)
         Uploaded high-res 1080p editorial thumbnails to YouTube Live Studio for each broadcast,
         bound streams, and synced IDs into obs/curation/sequence-manifest.json.
         All gates passing: validate:obs (40/40 assertions), validate:fast, and rspec (97/97).



       - REWATCH SERIES LAUNCH & REPOSITORY TIDY (2026-10-06):
         Pre-flight audit and white-glove review complete for 'The Sound Above' rewatch broadcast.
         Enforced strict canonical casing for Alt.NET across data catalogs,
         career datalake, and style guide. Created series mirror page at
         series/the-sound-above/episode-01.html with Schema.org VideoObject
         linked to YouTube playlist PLVcmLmfz2uyA and interactive transcript.
         Clarified Gleacher Center historical venue and added a11y, heading
         hierarchy, and readability rules to style guide. Cleansed em dashes
         from 2026-10-02 post. Pruned repo hygiene allowed files and excluded
         AGENT.md from Jekyll build. Patched 5 NPM security vulnerabilities
         (npm audit 0 vulnerabilities) and updated bundle dependencies cleanly.
         Standardized CLI help options on validators (validate_repo_hygiene,
         validate_data_uniqueness, validate_data). Synchronized YouTube live
         metadata for playlist PLVcmLmfz2uyA and video qOHdZKz1WFw with verified
         13 chapters and Sears Tower Alt.NET context. Authored phased rollout
         recommendation in docs/phased-approach-rewatch-broadcast-rollout.md.
         Synthesized Isaac Asimov's Foundation knowledge preservation mandate into
         series documentation: stewarding oral history to shorten the interregnum
         between software eras. All validation gates passing (validate:fast,
         validate:obs 40/40 assertions, rspec 90/90, resume_quality, benchmark:ats 88.2%).
       - YOUTUBE CAPTION SYNC & OBS REWATCH AUDIT (2026-10-05):
         Audited YouTube captions pipeline against YouTube Data API v3.
         Diagnosed why Sergio Pereira (qOHdZKz1WFw) defaulted to YouTube ASR:
         the August 30 caption sync paused at video 48/207 due to API quota limits.
         Uploaded high-fidelity 44-turn WebVTT caption track to YouTube via
         bin/sync_youtube_captions.rb and verified serving status.
         Audited OBS Studio setup for Episode 1 rewatch (35 assertions passing,
         all 8 production scenes, 4-track audio capture routing, Golden Gate
         SCK audio capture, craftsmanship overlays cued to Episode 1).
         Audited Scott Seely interviews (CLQfARayJV0 and pzpyJMpCwso): identified
         collapsed turns, missing recording blocks, duplicate sentences, and
         Whisper hallucination loops in queue for remediation.
       - VIDEO PLAYER & CHAPTER TIMELINE RESTORATION (2026-10-05):
         Restored interactive timeline scrubber bars and deferred embed video seeking.
         Fixed player element lookup across video-stage.html, deferred-embed.html,
         interview-timeline.html, and video-asset-player.html.
         Exposed window.loadDeferredEmbed and window.seekDeferredEmbed in
         assets/js/deferred-embeds.js to allow seeking into deferred YouTube/Vimeo
         embeds directly from transcript turn timestamps and chapter links.
         Added 13 verified chapters to Sergio Pereira interview transcript and
         calibrated DHH RailsConf 2014 chapters across the full 928-second span.
         All gates clean (fast validation, rspec, obs, archive validation).
       - THE SOUND ABOVE OBS PROJECT (2026-10-04): Full OBS Studio project
         created at `obs/` for the UGtastic oral history rewatch series.
         8-scene collection (Apple M4 hardware profile, 1080p60, apple_h264),
         macOS Golden Gate native audio (DesktopAudioDevice1 + sck_audio_capture),
         5 HTML overlays with craftsmanship-theme palette, 21-episode sequence
         manifest across 5 eras. Automation: `bundle exec rake validate:obs`
         (35 assertions, 7 gates). Man page: `man/man1/obs-livestream.1`.
         New skill: `oral-history-broadcaster` in `.agents/skills/` and
         `.claude/agents/`. Repo hygiene updated (obs/ in allowed_directories
         + Jekyll exclude list). All validation gates clean.
       - VIDEO SERIES PLATFORM NARRATIVE (2026-10-02): 5-part series
         "The Observable Control Plane" blueprint approved. Capstone post drafted:
         `_posts/2026-10-02-without-zdots-there-was-nothing.md`
         (Tier 3 AI-augmented, routes to /ai/2026/10/02/..., Jekyll build
         clean). Series blueprint: /Users/mike/.gemini/antigravity-cli/brain/
           0e5b4dee-44a7-4486-846e-ebb7264cfcf6/video_series_blueprint.md
       Deep handoff (local-only, never commit):
         ~/.config/adots/handoffs/2026-10-07.md

     Close ritual: rewrite this block + commit; write the deep handoff for
     anything personal or unfinished. Reference impl: wwworkremote/core's
     docs/agents/session-handoff.md.
     ═══════════════════════════════════════════════════════════════════════ -->

# Project Agent Instructions

## Required Project Context

Before changing this repository:

1. Read `CONTEXT.md` for the public-canon, local-runtime, and publication
   contracts.
2. Read `CODEX.md` before evaluating or changing resume content, positioning,
   titles, or generated resume surfaces.
3. Read `docs/career-strategy-audhd-principal-engineering.md` for title-to-scale
   role calibration and interview positioning strategies.
4. Read `docs/style-guide-and-canonical-naming.md` for permanent canonical naming,
   casing, and compound word standards across all content, data, and transcripts.

Do not treat this repository as an isolated Jekyll checkout. Its installed
localhost site is part of Mike's local system and is a required verification
surface for user-facing changes.

## System Identity

You are operating in `just3ws.github.io`: Mike Hall's public resume and
portfolio Jekyll site, the public-facing half of a two-repo CareerOS
platform. Peer system: `wwworkremote.localhost` (career intelligence and job
search side), synchronized via `src/collaboration/peer_mutex.rb`
(`CareerOS::PeerMutex`) and `bin/sync_career_peer.rb`.

Cross-session and cross-repo comms run on the zdots message bus. This
repo's registered identity is `agent-just3ws`:

- `zdots-ctx bus-whoami`: confirm identity resolves; if not,
  `zdots-ctx bus-register agent-just3ws --kind agent` then
  `export ZDOTS_BUS_PARTICIPANT=agent-just3ws`.
- `job-leads` channel: just3ws <-> wwworkremote coordination.
- `general` channel: cross-cutting platform ops; also reaches Mike
  (`mike`) and `zdots` (formerly `claude-code-main`).
- Bus problems get filed as a `zdots-issue`; this repo's agents do not
  patch zdots infrastructure directly.

Every persona under `.claude/agents/` operates inside this same identity
and system context, not as an isolated actor.

## Panoramic View Labs (PVL) Platform Identity

Canonical naming is permanent. Read this before using any Panoramic View term in prose, code, or agent output.

- **Panoramic View** is a technique (the system-cartography method). It is not an initiative name.
- **Panoramic View Labs** (short code `PVL`, pronounced "Pavel") is the initiative name. Use it when referring to the organizational umbrella, not the method.
- **Pavel** is the name of the Panoramic View specialist agent. Named from the PVL pronunciation.
- **zdots** is the root local-system platform for the Panoramic View initiative. All PVL capabilities live in and depend on zdots, not just3ws or wwworkremote.

Full disambiguation rules: `docs/style-guide-and-canonical-naming.md` §7.

## Agent skills

### Issue tracker

GitHub issues. See `docs/agents/issue-tracker.md`.

### Triage labels
Standard triage workflow labels. See `docs/agents/triage-labels.md`.

### Domain docs
Single-context layout (root-level CONTEXT.md + docs/adr/). See `docs/agents/domain.md`.

### Agent RACI Matrix
Cross-persona task ownership, review obligations, and decision authority are defined in `docs/agents/agent-raci-matrix.md`. Mike Hall's SME working group delegation strategy (proven at OneMain Financial) and the multi-archive claim verification playbook are codified in `docs/sme-delegation-and-multi-archive-playbook.md`.

## Registered Skills
Use these skills by default for this repository. **Status**: 15 of the 28
below have active `SKILL.md` specifications in `.agents/skills/` (marked ✓; see
`docs/tooling-user-guide.md` §6), and 10 additional domain skills live in `skills/`
(26 verified workspace skills total via `validate_skills_spec`).
All 28 also have `.claude/agents/*.md` subagent persona coverage.

## Persona Review Council

Aneta is the trusted editorial and strategy lead for Mike's public identity.
The council definition and method map live in
`docs/persona-review-council.md`. Its independent reviewers protect methods,
provenance, professional audiences, practitioner audiences, accessibility,
prose, privacy, and public-boundary safety.

Use the council before publishing or revising a method, quote, diagram, title,
metric, named person, historical interpretation, or cross-link between archive
and professional surfaces. An unresolved authorship or public-safety concern is
a hold, not an invitation to invent a smoother explanation.

1. `gh-fix-ci` - Diagnose and fix failing GitHub Actions checks.
2. `gh-address-comments` - Process and resolve PR review comments.
3. `playwright` - Run browser-based smoke checks and regression checks.
4. `screenshot` - Capture visual evidence for UI regressions.
5. `security-best-practices` - Run focused security reviews (JS/TS/Ruby-adjacent patterns).
6. `security-threat-model` - Produce threat models for pipeline/content flows.
7. `transcript-import-batch` - Batch ingest transcript files from outbox with dry-run/apply + validation workflow.
8. `transcript-review-gate` - Review low-confidence transcript mappings before apply.
9. `transcript-quality-check` - Audit transcript integrity and content quality in canonical data.
10. `transcript-ops-report` - Summarize transcript ingestion throughput and corpus growth.
11. `site-refresh-director` - Audit a site surface and produce a bounded, evidence-backed refresh brief.
12. `site-refresh-builder` - Implement an approved refresh brief in the existing Jekyll/Liquid/SCSS stack.
13. `site-refresh-reviewer` - Independently gate visual, accessibility, SEO, and public-archive quality.
14. `system-cartographer` ✓ - Audit, structure, and generate 4-dimensional System Cartography case studies.
15. `executive-brief-generator` ✓ - Generate tailored 1-page executive pitch briefs for target Principal Engineer roles.
16. `job-lead-evaluator` ✓ - Evaluate job leads from wwworkremote against personal OS context and canonical resume data.
17. `prose-humanity-auditor` ✓ - Audit technical prose across site Markdown, YAML data, and resume surfaces for plain language, neuroinclusive readability, cognitive load, and zero AI jargon.
18. `no-em-dashes` ✓ - Enforce em-dash-free writing across prose, case studies, briefs, and documentation to eliminate machine-writing cadence and maintain authentic human voice.
19. `public-surface-auditor` ✓ - Audit the rendered public boundary for privacy, provenance, quarantine, and internal topology leaks before publication.
20. `tmi-auditor` ✓ - Audit public-facing content for oversharing, discrimination-vector signals, and PII/PHI exposure.
21. `canonical-surface-steward` ✓ - Keep canonical identity, shorthand, agents, skills, documentation, CLI help, validators, and generated surfaces synchronized.
22: `oral-history-broadcaster` / `technical-rewatch-broadcaster` ✓ - Direct, validate, cue, and audit live UGtastic technical rewatch broadcasts, OBS Studio production scene contracts, dynamic HTML overlays, and commentary arcs across the UGtastic and Chicago Software Craftsmanship corpus.
23. `patreon-integrator` ✓ - Connect to Patreon API v2, manage campaign tiers, track recurring compute funding, and format closing credit attributions for The Sound Above broadcasts.
24. `ponytail` ✓ - Audit code, designs, and architectural proposals against premature technical debt, cutting speculative abstractions and enforcing explicit "# ponytail:" markers.
25. `media-pipeline-operator` ✓ - Operate, monitor, and audit the zero-disk-waste media intake and YouTube publishing pipeline across all channels and playlists, managing Maildir queues, Concurrency Locks, FIFO order, SSE telemetry, SwiftBar status, and BPMN SLO compliance.
26. `technical-scriptwriter` ✓ - Author and structure authentic spoken teleprompter rundowns, narrative plotting, intro hooks, and actionable outro takeaways across all media archetypes.
27. `editorial-fact-checker` ✓ - Audit and verify technical claims, historical dates, conference venues, software names, and audio/DSP contracts against ground truth across video scripts, dossiers, and site documentation.
28. `career-datalake-researcher` ✓ - Query the local knowledge system, video transcripts, and CareerOS datalake across 218 transcribed interviews, 28 engineering roles, 185 writings, and 132 technologies.
29. `ecosystem-datalake-steward` ✓ - Manage, query, and maintain the ecosystem datalake across SQLite3 FTS5, DuckDB analytical views, JSONL streams, and timeline events spanning all 4 GitHub organizations (@just3ws, @ugtastic, @wwworkremote, @phalanxduel).


## Career Datalake & MCP Server Interface

This repository provides full-corpus deterministic query interfaces over the career archive (29 positions, 136 skills, 156 blog posts, 211 interviews, and 402 knowledge graph nodes):

* **CLI Query Engine:** `ruby bin/query_career_datalake.rb [options]` (supports `--tech`, `--company`, `--search`, `--archetype`, `--era`, `--interviewee`, `--json`, and `--man`).
* **MCP Server:** `ruby bin/career_datalake_mcp_server.rb` registered in `mcp.json` (tools: `query_career_history`, `get_technology_provenance`, `get_position_dossier`, `get_archetype_strategy`, `query_oral_history`, `query_transcript`).
* **HTTP Endpoints:** `https://just3ws.localhost/career_datalake.json` and `https://just3ws.localhost/career_datalake.jsonl`.
* **Guides:** See `docs/career-datalake-and-mcp-guide.md` and `docs/mcp-setup-guide.md`.

## Automated Resume Quality & ATS Benchmarking Suite

This repository maintains continuous ATS parseability, keyword match density, and structural data validation:

* **Resume Quality Validator:** `bundle exec rake validate:resume_quality` (`bin/validate_resume_quality.rb`) - Simulates ATS plain-text parsing, checks Schema.org `Person` JSON-LD linked data, action verb ratios, and enforces strict zero em dashes.
* **ATS Keyword Benchmark Engine:** `bundle exec rake benchmark:ats` (`bin/benchmark_ats_keywords.rb`) - Benchmarks resume exports against 5 target Staff+/Principal role profiles (Huntress Rails/SOC, Coder Platform, Enterprise Telemetry, Fintech Modernizer, Founding Staff AI).
* **Automated CI/CD Gating:** `bundle exec rake validate:ats_benchmarks` asserts composite match score >= 85.0% and minimum archetype floor >= 75.0%.
* **Guides:** See `docs/resume-narrative-and-storytelling-guide.md`, `docs/resume-quality-and-ats-benchmarking-guide.md`, and `docs/tooling-user-guide.md` (§8, §9).

## Executive Pitch Briefs & Direct Outreach Tooling ("Wayfinder")

This repository provides automated generation of tailored 1-page executive pitch briefs, interview calibration scripts, and high-signal outreach copy:

* **Executive Brief Generator:** `ruby bin/generate_executive_brief.rb [options]` (supports `--company`, `--role`, `--domain`, `--tier`, `--comp`, `--mandate`, `--html`, `--pdf`, `--json`).
* **MCP Tool Integration:** `generate_executive_brief` in `bin/career_datalake_mcp_server.rb` callable by `wwworkremote.localhost` and any agent tool.
* **Direct Outreach Playbook:** `docs/direct-hiring-manager-outreach-playbook.md` (cold hiring manager, warm peer, and founder/CTO outreach archetypes).
* **Protocol & Specifications:** `docs/executive-brief-generator-protocol.md` and `docs/career-strategy-audhd-principal-engineering.md`.
* **Rendered Briefs Hub:** `https://just3ws.localhost/exports/briefs/` with downloadable vector PDFs.


## Site Refresh Agent Workflow

For visual refresh work, use the three roles in order:

1. `$site-refresh-director` outputs a Refresh Brief and does not edit code.
2. `$site-refresh-builder` implements one authorized slice and outputs Build Evidence.
3. `$site-refresh-reviewer` inspects rendered desktop and mobile output and returns `pass` or `changes requested`.

Do not let the builder self-approve a visual change. Preserve routes, navigation labels, canonical content, analytics hooks, accessibility wins, and archive provenance unless the user explicitly expands scope.

## GitHub Pages / Pipeline Focus
For this site, prioritize:

1. CI reliability and reproducibility (Ruby/Bundler parity).
2. Jekyll build + internal link validation as required checks.
3. Smoke testing key pages via Playwright before merge.

## SEO + HTML Standards Guidance
There is no dedicated curated skill currently installed for HTML standards or SEO architecture.
Use this stack instead:

1. `playwright` for navigation/indexability smoke tests.
2. Jekyll plugins and templates (`jekyll-seo-tag`, sitemap, metadata includes) for structured SEO output.
3. CI checks (`html-proofer` + targeted assertions) for broken links and markup regressions.

<!-- BACKLOG.MD MCP GUIDELINES START -->

<CRITICAL_INSTRUCTION>

## BACKLOG WORKFLOW INSTRUCTIONS

This project uses Backlog.md MCP for all task and project management activities.

**CRITICAL GUIDANCE**

- If your client supports MCP resources, read `backlog://workflow/overview` to understand when and how to use Backlog for this project.
- If your client only supports tools or the above request fails, call `backlog.get_backlog_instructions()` to load the tool-oriented overview. Use the `instruction` selector when you need `task-creation`, `task-execution`, or `task-finalization`.

- **First time working here?** Read the overview resource IMMEDIATELY to learn the workflow
- **Already familiar?** You should have the overview cached ("## Backlog.md Overview (MCP)")
- **When to read it**: BEFORE creating tasks, or when you're unsure whether to track work

These guides cover:
- Decision framework for when to create tasks
- Search-first workflow to avoid duplicates
- Links to detailed guides for task creation, execution, and finalization
- MCP tools reference

You MUST read the overview resource to understand the complete workflow. The information is NOT summarized here.

</CRITICAL_INSTRUCTION>

<!-- BACKLOG.MD MCP GUIDELINES END -->

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Only skip graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).

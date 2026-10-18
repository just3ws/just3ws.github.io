<!-- ═══════════════════════════════════════════════════════════════════════
     CURRENT FOCUS - last updated 2026-10-18
     Cold-start resume state, canonical for every agent tool. Whoever closes
     a session rewrites this block in place - step one, before the wrap-up.
     Backlog + git log are truth for exact task status / SHAs; if this block
     contradicts them, trust them and fix the block.

     THIS REPO IS PUBLIC. This block is committed and world-readable - keep
     it to "what content/feature is being built". Anything about employment
     status, targeting, or career narrative goes ONLY in the local deep
     handoff, never here.

       In flight: verify against Backlog (`backlog/tasks/`).
       - FACTUAL CITATION GROUNDING & ATTRIBUTION AUDIT (2026-10-18):
         Audited historical attributions and grounded claims against primary sources and verified evidence:
         - Chicago Alt.NET Presentation Citation:
           - Grounded Mike Hall's first user group presentation at Chicago Alt.NET on November 12, 2008 at Redpoint Technologies (84th Floor Sears Tower) on the NHaml alternative view engine for ASP.NET MVC, presenting alongside Adam Tybor on Spark.
           - Primary source: `https://web.archive.org/web/20081101091417/http://www.chicagoalt.net/Home`
         - Chicago Code Camp Role Calibration:
           - Corrected attribution across all data, portfolio, and datalake surfaces: Chicago Code Camp was an existing regional conference; Mike Hall volunteered and assisted for a couple years and built the conference website (`just3ws/ccs`) for at least three conferences (2010-2012), authoring the custom speaker management and printable 9-track Haml schedule matrix.
         - Ecosystem & Career Datalake Synchronization:
           - Rebuilt `lake/ecosystem/` (SQLite3, DuckDB, JSONL, manifest) and regenerated `career_datalake.json` and `exports/portfolio.md` to reflect verified facts.
         - Verification:
           - 290/290 specs passing, fast validation passing cleanly, zero em dashes.

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
             2. *Carrying the Camera Alone: The Solitary Listener in Crowded Hallways* (hauling 35 pounds of camera gear through SCNA, GOTO Chicago, and RailsConf alone; the contrast between 800 animated engineers and the quiet solitude behind the lens).
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

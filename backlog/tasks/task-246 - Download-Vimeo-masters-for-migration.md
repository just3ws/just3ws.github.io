---
id: TASK-246
title: Download Vimeo masters for migration
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
updated_date: '2026-07-04 14:27'
labels:
  - pipeline
  - vimeo
milestone: Interview Archive Pipeline
dependencies:
  - TASK-243
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
For each asset in the migration manifest, download the Vimeo source master into the archive for re-upload to YouTube. Verify integrity (duration/size) against the expected metadata so nothing corrupt gets re-uploaded.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Vimeo masters are downloaded for all manifest entries
- [ ] #2 An integrity check (duration/size) passes against the expected metadata
- [ ] #3 Downloads are resumable and idempotent (already-fetched files are skipped)
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Download Vimeo masters for the migration manifest (TASK-243)

### Input / output
- Input: `_data/vimeo_migration_manifest.yml` (27 entries). Iterate `items[]`, skip any with `migration_state` past `pending`.
- Output: masters land in `videos/` (already gitignored: `.gitignore` has `videos/*` + `!videos/index.html`), one file per asset named by id, e.g. `videos/masters/<asset_id>__<vimeo_id>.mp4`. Do NOT commit binaries.

### Download mechanism
- Requires an authenticated Vimeo original-file download. **Prerequisite risk to flag:** original/master download requires the account own the videos with download enabled (Vimeo Pro/API `download` scope); the public player URL is not a master. Confirm access on 1 asset before batching.
- Prefer a resumable HTTP GET of the API-provided download link (supports `Range`/`Content-Length`); `yt-dlp`/`vimeo-dl` as fallback for the highest-progressive rendition.

### Idempotency + resumability
- Fingerprint per asset = `<asset_id>__<vimeo_id>`. Before downloading: if the target file exists AND passes integrity (below), skip (idempotent). If a `.part`/partial exists, resume via HTTP Range rather than restart.
- Write to `videos/masters/.tmp/<fp>.part`, atomically rename to final path only after integrity passes. Record outcome back into the manifest by flipping `migration_state: pending → downloaded` (a review-surface update, not raw content).

### Integrity checks (be honest about what is verifiable)
- **Duration**: probe with `ffprobe` and compare to the manifest's `duration_seconds` (sourced from the vimeo platform entry in `video_assets.yml`) within a tolerance (±2s). This is the authoritative expected value.
- **Resolution**: compare `ffprobe` width/height to `context/interviews-history/metadata/*___<vimeo_id>.json` (`width`/`height`) where available.
- **Size**: there is NO stored byte-size baseline anywhere (metadata JSON has width/height only, no duration/size). Do NOT promise a size match. Instead assert: file is non-zero, `Content-Length` fully received (bytes == server length), and a plausible-bitrate sanity check (size vs duration×resolution not absurdly low → catches truncated/corrupt).
- A master failing any check is quarantined (kept as `.part`, `migration_state` stays `pending`) and reported; never promoted.

### Acceptance mapping
- AC#1: all 27 manifest masters downloaded into `videos/masters/`.
- AC#2: each passes duration (vs `duration_seconds`) + resolution (vs metadata JSON) + full-length/non-zero sanity; failures quarantined & listed.
- AC#3: re-running skips already-verified files and resumes partials (fingerprint + Range). Idempotent.

### Boundary
Read-only against repo data; writes only to gitignored `videos/` + manifest state field. No upload here (TASK-253). No API calls performed during planning.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

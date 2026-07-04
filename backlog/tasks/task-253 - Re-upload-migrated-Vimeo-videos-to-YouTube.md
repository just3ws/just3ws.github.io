---
id: TASK-253
title: Re-upload migrated Vimeo videos to YouTube
status: To Do
assignee: []
created_date: '2026-07-04 09:24'
updated_date: '2026-07-04 14:28'
labels:
  - pipeline
  - vimeo
milestone: Interview Archive Pipeline
dependencies:
  - TASK-246
  - TASK-249
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upload the downloaded Vimeo masters (TASK-246) to YouTube via the upload pipeline (TASK-249), then update _data platform records so YouTube becomes primary. Newly-on-YouTube videos then re-enter transcription backfill (TASK-250) and caption/metadata (TASK-252/TASK-248). Outward-facing: private/unlisted first, public only on approval.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All migration-set masters are uploaded to YouTube (private/unlisted first)
- [ ] #2 _data/video_assets.yml is updated with new youtube ids and platform set to primary
- [ ] #3 Explicit human approval is required before each video goes public
- [ ] #4 Migrated videos are enqueued for transcription backfill and captions
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Re-upload migrated Vimeo masters to YouTube + update platform records

### Inputs / dependencies
- Masters from TASK-246 in `videos/masters/` (27, integrity-passed).
- Upload pipeline from TASK-249 (do NOT reimplement the uploader here; call it).
- Manifest `_data/vimeo_migration_manifest.yml` drives ordering + carries `caption_readiness` (19 caption-ready / 8 needs-transcription).

### Upload flow (outward-facing safety)
1. Upload each master via TASK-249's pipeline with **privacyStatus = unlisted** (never public on first upload). Set title/description/tags from the existing asset record (content is owner-provided; do not rewrite).
2. Capture the returned YouTube video id; write it into the manifest (`youtube_id`, `migration_state: unlisted`).
3. **Per-video human-approval gate before public:** publishing to public is a separate, explicit, per-asset step (e.g. approving in the manifest / a `--publish <asset_id>` action gated on `migration_state == unlisted`). No batch flip-all-public. Only on approval does the pipeline set privacy public and `migration_state: public`.

### Update `_data/video_assets.yml` (structure/data only)
- For each migrated asset, APPEND a `platform: youtube` entry to `platforms[]` (`asset_id`, `url: https://www.youtube.com/watch?v=<id>`, `embed_url: https://www.youtube.com/embed/<id>`, carry duration/thumbnail as available) and set `primary_platform: youtube`.
- KEEP the existing vimeo platform entry for now — removal is TASK-256's job, gated on migration-complete. This makes the change reversible and lets templates (which bias to youtube; see `_includes/video-stage.html`, `schema-factory.html`, `video-asset-player.html`) auto-repoint the embed the moment the youtube entry exists.

### Transcription backfill + captions (do NOT blanket-enqueue)
- 19 caption-ready assets already have `_data/transcripts/<transcript_id>.yml` with structured turns → they need only a **caption track** (TASK-252): push the existing transcript to the new YouTube id as a caption/subtitle track. Do not re-transcribe.
- 8 needs-transcription assets have no transcript → enqueue for transcription backfill (TASK-250). Reuse `bin/batch_ztranscribe.rb`'s existing selection logic (`transcript_id` empty AND a youtube platform id present) — post-upload those exact 8 become eligible automatically, so no custom re-enqueue of the 19. Enqueue via `zdots-ctx enqueue transcription '{"url":"https://www.youtube.com/watch?v=<id>","video_asset_id":"<id>"}'` (fingerprint-idempotent; worker drains).

### Acceptance mapping
- AC#1: all 27 masters uploaded, unlisted first.
- AC#2: `_data/video_assets.yml` gains youtube ids + `primary_platform: youtube` (vimeo entry retained until 256).
- AC#3: public transition is per-asset, explicit, human-approved — enforced by the migration_state gate.
- AC#4: 8 enqueued for transcription (reusing batch_ztranscribe selection); 19 handed to captions (TASK-252) from existing transcripts.

### Boundary
No content rewriting. No public publish without explicit approval. Planning only — no uploads/API calls performed now.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

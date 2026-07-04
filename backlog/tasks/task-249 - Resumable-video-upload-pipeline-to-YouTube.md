---
id: TASK-249
title: Resumable video upload pipeline to YouTube
status: To Do
assignee: []
created_date: '2026-07-04 03:24'
updated_date: '2026-07-04 14:28'
labels:
  - pipeline
  - youtube
milestone: Interview Archive Pipeline
dependencies:
  - TASK-245
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Resumable upload of local video files to YouTube (used by the Vimeo migration and any new content), including thumbnail, initial metadata, and playlist assignment. Uploads default to private/unlisted pending review. Outward-facing: nothing is made public without explicit approval.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Resumable upload handles large files and survives interruption
- [ ] #2 Uploaded videos default to private/unlisted
- [ ] #3 Each video is gated by explicit human approval before it is made public
- [ ] #4 The new youtube asset id is written back to _data/video_assets.yml
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Resumable video upload pipeline (Vimeo migration + new content)

### Scopes / client
- Uses `youtube.upload` (insert) + `youtube.force-ssl` (set status/snippet) via `bin/lib/youtube_client.rb` (TASK-245).

### Resumable upload (AC#1 — survives interruption)
- Use YouTube's **resumable upload protocol**: POST `videos.insert?uploadType=resumable` to get a session URI, then PUT the file in chunks; on interruption, re-PUT with `Content-Range: bytes */TOTAL` to query the last received byte and continue. `faraday-multipart` is available for the multipart metadata part.
- Persist the session URI + bytes-sent to a gitignored scratch state file (keyed by source path / video_asset id) so a restarted `youtube_upload` zdots job resumes instead of restarting. Fingerprint-idempotent job key = source file sha + target video_asset id.

### Default privacy (AC#2/#3)
- `videos.insert` sets `status.privacyStatus = "private"` (or `unlisted`). Videos are NEVER inserted public. Making a video public is a **separate approved step**: a `youtube_metadata`/status apply job (per TASK-245 two-phase gate) flips privacy only after explicit human approval per video.

### Data write-back (AC#4)
- On successful insert, capture the returned video `id` and write it back into `_data/video_assets.yml`: add/append a `platforms:` entry `{ platform: youtube, asset_id: <new id>, url, embed_url }` on the matching item (this is the one repo-write this pipeline owns; keep it minimal, structure-only). Downstream 248 (metadata) + 252 (captions) then target the new asset_id.

### Dry-run + approval gate
- Dry-run job: validate source file exists/encodes, resolve target video_asset, render the planned snippet + privacy + playlist assignment, and report — **no insert**. Human approves. Apply job performs the resumable insert (always private). A second approval gates the later public flip.

### Endpoints + quota
- `videos.insert` = **1600 units** each. With the 10k/day default that is **~6 uploads/day**; the 28 vimeo-primary (136 vimeo occurrences) migration set spans multiple days — batch across days or request a quota increase. Optional `thumbnails.set` (50) + playlist add handled in 258.

### Verification
- After apply, re-read the video via `videos.list` → confirm privacyStatus=private and id matches the value written to `_data/video_assets.yml`; confirm a killed-and-resumed upload completes without a duplicate video.

### Files
Writes: `_data/video_assets.yml` (new youtube asset_id only). Uses `bin/lib/youtube_client.rb`. Reads local master files (from TASK-246 Vimeo downloads / new content).
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

---
id: TASK-258
title: Publish playlists and Shorts from insights
status: To Do
assignee: []
created_date: '2026-07-04 09:24'
updated_date: '2026-07-04 14:28'
labels:
  - pipeline
  - youtube
milestone: Interview Archive Pipeline
dependencies:
  - TASK-245
  - TASK-257
  - TASK-249
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Turn approved content opportunities (TASK-257) into YouTube playlists (topic/conference/era groupings) and Shorts (cut from approved quote timestamps, uploaded via TASK-249). Outward-facing: dry-run and explicit human approval before anything publishes; published items link back into _data for site rendering.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Playlists are created/curated from approved groupings
- [ ] #2 Shorts are cut from approved quote timestamps and uploaded
- [ ] #3 A dry-run and explicit human approval precede any publish
- [ ] #4 Published items are linked back into _data for site rendering
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Publish playlists + Shorts from approved insights

### Scopes / client
- Playlists/items via `youtube.force-ssl`; Shorts upload via `youtube.upload` (reuses TASK-249). All through `bin/lib/youtube_client.rb` (245).

### Playlists (AC#1)
- Grouping sources: (a) the **existing `playlist:` field already on `_data/video_assets.yml` platform entries** (e.g. "RailsConf 2014 Interviews", "GOTO Conference 2014 Interviews", "WindyCityRails 2011 Interviews") — a ready-made conference/era grouping to seed from; plus (b) approved topic/era groupings from TASK-257's content-opportunity backlog.
- Flow: resolve each grouping to an ordered list of youtube asset_ids → `playlists.list` (find existing by title) → `playlists.insert` if absent → `playlistItems.insert` for members not already present (dedupe by videoId within the playlist).

### Shorts (AC#2) — NO special Shorts API
- A "Short" is just a normal `videos.insert` of a short **vertical** clip (≤60s, 9:16, `#Shorts` in title/description); YouTube auto-classifies it. There is no Shorts endpoint. So the only NEW work here vs 249 is a pre-upload **ffmpeg clip-extraction step**: cut the source master at the approved quote `start/end` (from TASK-257 approved quote timestamps) → vertical crop/pad → hand the clip to the **TASK-249 upload pipeline** unchanged (resumable, default private/unlisted, id written back).

### Endpoints + quota
- `playlists.insert` 50 · `playlistItems.insert` 50 each · `playlists.list` 1. `videos.insert` (each Short) **1600** — same ~6/day ceiling as 249, batch across days. A dozen playlists + their items ≈ low hundreds of units.

### Dry-run + approval gate (per TASK-245 two-phase pattern, AC#3)
- Dry-run job: render the full plan — playlists to create, exact ordered items to add, and each Short's source+cut window+resulting file — as an artifact + live-state fingerprint (existing playlist ids/contents). **No writes.** Human approves. Apply job re-verifies fingerprint, then creates playlists/items and enqueues the Short uploads (which themselves stay private pending the 249 public-flip approval). Abort on drift.

### Idempotency
- Playlists keyed by title (no duplicate playlist); items deduped by videoId; Shorts keyed by (source asset_id + cut window) so re-runs don't re-cut/re-upload.

### Write-back for site rendering (AC#4)
- Persist published playlist ids + the `playlist:`/`platforms[youtube].asset_id` links (and Short asset_ids from 249) back into `_data/video_assets.yml` so the Jekyll archive can render the groupings/Shorts. Structure-only, per the primary directive.

### Verification
- Re-run dry-run after apply → no-op (playlists present, items deduped, Shorts already uploaded).

### Files
Reads: TASK-257 output, `_data/video_assets.yml` (`playlist:` field). Writes: `_data/video_assets.yml` (playlist ids + Short asset_ids). Uses `bin/lib/youtube_client.rb` (245) + TASK-249 upload pipeline + ffmpeg.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

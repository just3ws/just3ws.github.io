---
id: TASK-252
title: Publish diarized transcripts as YouTube captions
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
  - TASK-247
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Convert diarized transcripts to .vtt (speaker turns + timestamps) and publish them as caption tracks on the matching YouTube videos via the Data API. Outward-facing: gated by an approved dry-run.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Diarized transcript converts to .vtt with speaker turns and timestamps
- [ ] #2 The caption track uploads to the matching youtube asset id
- [ ] #3 A dry-run diff is produced and requires explicit human approval before publishing
- [ ] #4 Idempotent — replaces the existing track without creating duplicates
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Publish diarized transcripts as YouTube caption tracks

### Prerequisite: timestamps come from diarization, not today's transcripts
Current `_data/transcripts/*.yml` `turns` carry only `speaker` + `text` — **no per-turn start/end timestamps** (only chapter-level `youtube.chapters[].timestamp` mm:ss exists, which is too coarse for cues). Real .vtt cues need per-segment start/end, which the diarized schema from **TASK-244 → TASK-247** adds (hence this task's dep on 247). Do NOT attempt VTT from the current timestamp-less turns; build against the diarized turn schema (speaker segments + start/end).

### VTT generation (AC#1)
- For each diarized transcript: emit WebVTT — one cue per speaker turn (or sub-split long turns), `HH:MM:SS.mmm --> HH:MM:SS.mmm`, prefixing the cue text with the speaker name from `speaker_map` (e.g. `Mike Hall: ...`). Language `en`.
- Join to the live video the same way as 248: transcript stem = `transcript_id` → `_data/video_assets.yml` item → `platforms[youtube].asset_id`.

### Scopes / endpoints (captions REQUIRE force-ssl)
- `captions.list(part=snippet, videoId=<asset_id>)` = 50 units — find existing `en` track.
- `captions.insert(part=snippet, sync=false)` with the .vtt body = 400 units — when no `en` track exists.
- `captions.update` = 450 units — replace body of the existing `en` track (in place, same track id).
- Never delete+insert the standard flow (avoids a duplicate-track window); reserve `captions.delete` (50) only for cleanup.

### Idempotency (AC#4 — replace, no dupes)
- Keyed on (videoId, language=`en`): if an `en` track exists → `captions.update` that track id; else `captions.insert`. Re-running with unchanged VTT is a no-op (compare a stored hash of the last-published VTT / fetch+compare). Never creates a second `en` track.

### Dry-run + approval gate (per TASK-245 two-phase pattern)
- Dry-run job: generate VTT, `captions.list` live tracks, report insert-vs-replace decision + a VTT diff/preview + live-state fingerprint (existing track id + etag). **No write.** Human approves. Apply job re-verifies the fingerprint (track not changed underneath) then insert/update. Abort on drift.

### Quota
- Per video ~450–500 units (list + insert/update). A full-corpus caption pass across the youtube set will exceed 10k/day → batch across days or request an increase. Dry-run (list only, 50/video) is cheap.

### Verification
- After apply, `captions.list` shows exactly one `en` track; re-run dry-run → no-op (idempotent replace confirmed).

### Files
Reads: diarized `_data/transcripts/*.yml` (post TASK-247), `_data/video_assets.yml`. Uses `bin/lib/youtube_client.rb`. VTT written to gitignored scratch, not the repo. No repo writes.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

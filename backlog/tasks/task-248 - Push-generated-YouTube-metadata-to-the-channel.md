---
id: TASK-248
title: Push generated YouTube metadata to the channel
status: To Do
assignee: []
created_date: '2026-07-04 03:24'
updated_date: '2026-07-04 14:27'
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
The audit skill already generates youtube title/description/tags/chapters into _data/interviews.yml and _data/video_assets.yml. This task pushes that existing metadata to the live YouTube videos via the Data API — generation is out of scope here, this is sync only. Outward-facing: nothing goes live without an approved diff.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Reads title/description/tags/chapters from _data
- [ ] #2 Diffs against live YouTube state and produces a dry-run report of changes
- [ ] #3 Applies updates only after explicit human approval of the diff
- [ ] #4 Idempotent — re-running with no changes is a no-op
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Sync already-generated YouTube metadata to the channel (no generation)

### Source-of-truth discrepancy (READ THIS)
The task text says metadata lives in `_data/interviews.yml` + `_data/video_assets.yml`. **Investigation shows it actually lives in `_data/transcripts/*.yml` under the `youtube:` block** (`title`, `description`, `tags`, `chapters`). `chapters` exist ONLY there. Read from the transcripts, not from interviews/video_assets. (`video_assets.yml` per-platform `description` is stale platform copy, not the generated metadata.)

### Data flow / join
1. For each `_data/transcripts/<stem>.yml` with a `youtube:` block → `transcript_id = <stem>`.
2. Resolve `_data/video_assets.yml` item where `transcript_id == <stem>` → `platforms[] where platform == youtube → asset_id` (the live YouTube video id). Skip assets with no youtube platform.
3. Desired video snippet: `title` → snippet.title; `description` + **chapters** → snippet.description; `tags` → snippet.tags.
   - **Chapters are NOT a field.** YouTube renders chapters from timestamped lines in the description BODY. Append/merge the `chapters` list as lines (`00:00 Title`) into the description text; first line must be `00:00`, need ≥3 chapters, each ≥10s apart — validate and warn if the generated set violates this.

### Endpoints + quota
- Read: `videos.list(part=snippet, id=<asset_id>)` = 1 unit each.
- Write: `videos.update(part=snippet)` = 50 units each.
- **Corpus aggregate:** ~178 primary-youtube assets × (1 + 50) ≈ **9.1k units** for a full pass — nearly the entire 10k/day default; the full 367 youtube occurrences would exceed it. So: dry-run is list-only (cheap, ~few hundred units) and can run whole-corpus; **apply must batch across days or request a quota increase.**

### Dry-run + approval gate (per TASK-245 two-phase pattern)
- `youtube_metadata` dry-run job: list live snippet, diff desired-vs-live (normalize whitespace/tag order), emit a per-video diff artifact + live-state fingerprint (hash of live title+description+tags). No writes.
- Human approves. Apply job re-fetches, confirms fingerprint unchanged, then `videos.update`. Abort on drift.

### Idempotency (AC#4)
- Desired snippet is deterministic from `_data`. Skip any video whose live snippet already equals desired (no-op). Fingerprint-idempotent job key = `asset_id + sha(desired_snippet)`.

### Verification
- Re-run dry-run after apply → zero diffs (proves no-op idempotency + successful push).

### Files
Reads: `_data/transcripts/*.yml`, `_data/video_assets.yml`. Uses `bin/lib/youtube_client.rb` (245). No repo writes.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

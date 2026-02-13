---
name: transcript-review-gate
description: Review gate workflow for transcript mapping results to approve/reject low-confidence mappings and keep imports deterministic.
---

# Transcript Review Gate

## Purpose
Prevent bad transcript-to-video mappings by reviewing uncertain matches.

## Use When
- `tmp/transcript-import-report.md` shows low-confidence rows or collisions.
- A batch import has ambiguous file names.

## Workflow
1. Read `tmp/transcript-import-report.json`.
2. Focus on `low_confidence` and `collisions`.
3. Build a short decision list:
   - approve mapping
   - reject mapping
   - defer for manual verification
4. Re-run ingest with stricter threshold if needed:
   - `./bin/transcripts ingest --min-confidence 0.95`

## Decision Criteria
- Prefer explicit platform ID matches.
- Prefer exact `video_assets.id` slug matches.
- Reject mappings with name-only similarity if event/year context conflicts.

---
id: TASK-250
title: Backfill diarized transcripts across the corpus
status: To Do
assignee: []
created_date: '2026-07-04 03:24'
updated_date: '2026-07-05 17:07'
labels:
  - pipeline
  - transcription
milestone: Interview Archive Pipeline
dependencies:
  - TASK-247
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Run the diarization + labeling pipeline (TASK-244 + TASK-247) across all pending and broken transcripts. This coordinates existing work rather than duplicating it: it executes the backfill behind TASK-124 (transcription automation), resolves TASK-022–025 (broken-transcript repairs) and TASK-125 (QC review), and unblocks the ~60 Canonical Review tasks (TASK-031–115) by giving them acoustic-grounded turns to review.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All pending video_assets with a youtube id have diarized transcripts
- [ ] #2 TASK-022–025 broken transcripts are repaired via the new pipeline
- [ ] #3 Loop/corruption QC (TASK-125) is clean across the corpus
- [ ] #4 The Canonical Review queue (TASK-031–115) is unblocked with diarized turns available
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## This is a batch RUN, not a new tool

250 executes the 244+247 pipeline across the corpus by driving the **existing** machinery. Build nothing new here:
- Enqueue: `bin/batch_ztranscribe.rb` (+ `bin/batch_ztranscribe_other.rb` for non-YouTube) — the same discovery/enqueue TASK-124 already uses.
- Drain: `zdots-ctx worker --type transcription < /dev/null &` (stdin redirect per doc-041 to avoid the ffmpeg hang).
- Stage/import: `bin/stage_completed_transcripts.rb` → `./bin/transcripts ingest` (now carrying the 244 `diarization` sidecar).
- Label/structure: `rake audit:prepare[slug]` → fused audit (247) → `rake audit:ingest[slug]`.
- QC gate: `bin/report_transcript_loops.rb` → `_data/transcript_retranscribe_queue.yml`.

## Coordination — how each existing task is advanced, not duplicated

- **TASK-124 (transcription automation, In Progress) = the engine; 250 = run-to-green.** 124 owns the discovery loop (`video_assets` missing `transcript_id` with a YouTube id) and the resumable worker. 250 does NOT re-implement discovery or the worker — it runs 124's loop to completion with diarization now enabled, then pushes each completed transcript through the 247 fused audit. When 250's backfill is green, 124's remaining ACs (#2-#4) close as a byproduct.
- **TASK-125 (QC) = the exit gate criteria; 250 executes it.** 125 defines "re-review legacy transcripts for diarization + phonetic drift." 250 operationalizes it: the backfill is not done until `bin/report_transcript_loops.rb` reports zero high-severity entries in `_data/transcript_retranscribe_queue.yml` (currently 87 flagged items, head scores 2211/1146/1004/871). Loop/corrupt files are re-transcribed on the whisper.cpp `standard` (Turbo) profile per the archive-forensics loop note.
- **TASK-022–025 (broken repairs) = the first slice of the high-severity queue.** These four map to real retranscribe-queue entries (verified: `dave-hoover-geekfest-geekfest` score 871 = TASK-024; `ethan-gunderson-ryan-briones-...` score 269 = TASK-022; plus `jonathan-baltz-chicagowebconf-2012` = TASK-023, `ashe-dryden-general` = TASK-025). 250 repairs them as the leading batch via diarized re-transcription; each closes when its loop score clears and the linkage chain (Interview→Asset→Transcript) validates.
- **TASK-031–115 (~60 Canonical Reviews) = unblocked, NOT consumed.** 250 stops at "acoustic-grounded diarized turns exist for every interview in the review queue." It does not perform the reviews; it hands 031–115 real diarization (speaker_map bound to acoustic_id) to review instead of the old M1/S1-only heuristic guesses.

## Batch plan (phased)

1. **Repair slice:** run the high-severity retranscribe queue first (022–025 + the top loop-score files) through 244 re-transcribe → 247 audit. Clears the worst corruption early and proves the pipeline on the hardest cases.
2. **Pending slice:** `bin/batch_ztranscribe.rb` for all YouTube video_assets still missing `transcript_id`; drain the worker; stage/import (diarization sidecars land via 244); run 247 audit per slug.
3. **Legacy re-review slice (TASK-125):** the remaining pre-v3 structured transcripts that lack a `diarization` block — re-transcribe to attach acoustics, then 247 audit.
4. **Migrated-Vimeo re-entry:** videos re-uploaded by TASK-253 re-enter this same backfill (they arrive with new YouTube ids); no special-casing.

## Verification / exit gates

- Every pending YouTube `video_asset` has a `transcript_id` and its transcript carries a `diarization` block (AC#1).
- `_data/transcript_retranscribe_queue.yml` regenerates with zero high-severity entries (AC#3, satisfies TASK-125).
- TASK-022–025 transcripts pass loop QC and linkage validation (AC#2).
- Spot-check that Canonical Review slugs (031–115) resolve to transcripts with acoustic-bound speaker_maps (AC#4).
- `bin/validate_data`, `bundle exec rake transcript:audit`, and `bin/pipeline ci` all green.

## Coordination

Depends on TASK-247 (fused labeling). Blocks/unblocks TASK-031–115; feeds TASK-252 (captions). Advances TASK-124/125/022–025 to Done by executing them, not by re-scoping them.
<!-- SECTION:PLAN:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: claude
created: 2026-07-05 17:07
---
Re-transcription pilot (2 HIGH-severity loop-flagged files, identical 16k-mono WAV + bare whisper-cli, model the ONLY variable) — result flips the model choice:

- **large-v3 (max precision) made loops DRAMATICALLY WORSE**: 265-line consecutive repeat, 65% duplicate lines, ended on the 'Subtitles by the Amara.org community' hallucination (272 hits in streaming stdout — genuine, not a write artifact). Confirms the archive-forensics warning about max-accuracy looping on Apple Silicon. Also ~4x slower (305s vs turbo's ~79-116s/file).
- **turbo (standard) was CLEAN on both**: max consecutive run 1-2, stored loop phrases 0 occurrences, natural endings.

Conclusion: the stored loops are artifacts of the OLD transcription run; **re-running turbo on freshly-downloaded audio fixes them.** DECISION for the backfill of the ~86 flagged entries: use the STANDARD/turbo profile, NOT large-v3. Run serial (GPU contention) — total turbo compute is well under an hour. Then re-run `bin/report_transcript_loops.rb` to confirm scores drop, and re-apply normalize/split/validate before writing back. NB: the #1 queue item `vimeo-38936294` and other `vimeo-*` entries are Vimeo-hosted — they need the Vimeo URL path, not YouTube (ties into the Vimeo migration track). Pilot artifacts: scratchpad/retranscribe-pilot/PILOT_FINDINGS.md.
---
<!-- COMMENTS:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

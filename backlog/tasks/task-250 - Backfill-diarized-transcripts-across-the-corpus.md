---
id: TASK-250
title: Backfill diarized transcripts across the corpus
status: To Do
assignee: []
created_date: '2026-07-04 03:24'
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

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

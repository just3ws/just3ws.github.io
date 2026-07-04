---
id: TASK-252
title: Publish diarized transcripts as YouTube captions
status: To Do
assignee: []
created_date: '2026-07-04 09:24'
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

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

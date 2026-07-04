---
id: TASK-246
title: Download Vimeo masters for migration
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
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

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

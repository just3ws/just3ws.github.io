---
id: TASK-248
title: Push generated YouTube metadata to the channel
status: To Do
assignee: []
created_date: '2026-07-04 03:24'
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

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

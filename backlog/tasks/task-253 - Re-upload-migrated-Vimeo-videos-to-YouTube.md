---
id: TASK-253
title: Re-upload migrated Vimeo videos to YouTube
status: To Do
assignee: []
created_date: '2026-07-04 09:24'
labels:
  - pipeline
  - vimeo
milestone: Interview Archive Pipeline
dependencies:
  - TASK-246
  - TASK-249
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upload the downloaded Vimeo masters (TASK-246) to YouTube via the upload pipeline (TASK-249), then update _data platform records so YouTube becomes primary. Newly-on-YouTube videos then re-enter transcription backfill (TASK-250) and caption/metadata (TASK-252/TASK-248). Outward-facing: private/unlisted first, public only on approval.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All migration-set masters are uploaded to YouTube (private/unlisted first)
- [ ] #2 _data/video_assets.yml is updated with new youtube ids and platform set to primary
- [ ] #3 Explicit human approval is required before each video goes public
- [ ] #4 Migrated videos are enqueued for transcription backfill and captions
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

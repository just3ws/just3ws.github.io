---
id: TASK-249
title: Resumable video upload pipeline to YouTube
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
Resumable upload of local video files to YouTube (used by the Vimeo migration and any new content), including thumbnail, initial metadata, and playlist assignment. Uploads default to private/unlisted pending review. Outward-facing: nothing is made public without explicit approval.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Resumable upload handles large files and survives interruption
- [ ] #2 Uploaded videos default to private/unlisted
- [ ] #3 Each video is gated by explicit human approval before it is made public
- [ ] #4 The new youtube asset id is written back to _data/video_assets.yml
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

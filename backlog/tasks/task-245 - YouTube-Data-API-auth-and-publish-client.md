---
id: TASK-245
title: YouTube Data API auth and publish client
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
labels:
  - pipeline
  - youtube
milestone: Interview Archive Pipeline
dependencies:
  - TASK-242
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Stand up OAuth credentials and a thin YouTube Data API client, exposed as zdots publish jobs (following the queue pattern). This is the foundation for captions, metadata sync, video upload, and playlist/shorts publishing. No live writes beyond an authenticated read/quota check in this task.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 OAuth flow completes and refresh credentials for the channel are stored securely
- [ ] #2 A thin client wraps the captions/videos/playlists endpoints
- [ ] #3 Publish actions run as zdots jobs (retry/idempotent)
- [ ] #4 An authenticated dry-run (read channel + quota) is verified; no live writes in this task
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

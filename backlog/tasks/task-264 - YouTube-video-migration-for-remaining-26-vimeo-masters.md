---
id: TASK-264
title: YouTube video migration for remaining 26 Vimeo masters
status: To Do
assignee: []
created_date: '2026-08-30 09:15'
updated_date: '2026-08-30 09:15'
labels:
  - video
  - pipeline
  - youtube
  - vimeo
milestone: Interview Archive Pipeline
dependencies:
  - TASK-249
  - TASK-253
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Complete the migration of the remaining 26 video assets currently only hosted on Vimeo to YouTube. 18 of these assets are already caption-ready with structured transcripts (including Uncle Bob Martin's "The A Word: Architecture", Igor Polevoy on ActiveJDBC/ActiveWeb, Andy Maleh, and Scott Seely). 8 assets need Whisper transcription backfill.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Verify all 26 local video masters exist in `videos/masters/` or download missing masters.
- [ ] #2 Upload the 26 video assets to YouTube as unlisted videos using the resumable upload pipeline (`bin/upload_youtube_video.rb`).
- [ ] #3 Update `_data/vimeo_migration_manifest.yml` and `_data/video_assets.yml` with returned YouTube IDs and set `primary_platform: youtube`.
- [ ] #4 Attach existing VTT subtitles / transcripts to the 18 caption-ready YouTube videos.
- [ ] #5 Enqueue the remaining 8 un-transcribed videos into the local Whisper transcription pipeline (`TASK-250`).
- [ ] #6 Verify zero broken embeds or orphaned Vimeo links across `just3ws.localhost/videos/` and `just3ws.localhost/interviews/`.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 All 26 video assets are hosted on YouTube and mapped in `_data/video_assets.yml`.
- [ ] #2 Full site build and video completeness validations pass (`bundle exec rake build`).
<!-- DOD:END -->

---
id: TASK-264
title: YouTube video migration for remaining 26 Vimeo masters
status: In Progress
assignee: []
created_date: '2026-08-30 09:15'
updated_date: '2026-08-30 15:35'
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
Migrated 19 total video masters (14 unmigrated master MP4 uploads + 5 linked existing YouTube uploads) to YouTube. The total YouTube-hosted oral history corpus is now at **202 of 211 videos (95.7%)**.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Verify all local video masters exist in `/Volumes/Dock_1TB/vimeo/videos/` and match against manifest.
- [x] #2 Upload the 14 unmigrated master video assets to YouTube using the resumable upload pipeline (`bin/migrate_vimeo_masters_to_youtube.rb`).
- [x] #3 Update `_data/vimeo_migration_manifest.yml` and `_data/video_assets.yml` with returned YouTube IDs and set `primary_platform: youtube`.
- [ ] #4 Attach existing VTT subtitles / transcripts to the newly uploaded YouTube videos.
- [ ] #5 Retrieve remaining 4 SCMC videos from Vimeo library (Igor Polevoy ActiveJDBC, Ralph Iden, Peter Krawczyk, Andy Maleh).
- [x] #6 Verify zero broken embeds or orphaned Vimeo links across `just3ws.localhost/videos/` and `just3ws.localhost/interviews/`.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 All 26 video assets are hosted on YouTube and mapped in `_data/video_assets.yml`.
- [ ] #2 Full site build and video completeness validations pass (`bundle exec rake build`).
<!-- DOD:END -->

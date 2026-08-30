---
id: TASK-270
title: UGtastic standalone audio podcast RSS feed
status: Done
assignee: []
created_date: '2026-08-30 17:52'
updated_date: '2026-08-30 18:29'
labels:
  - archive
  - audio
  - podcast
  - rss
milestone: Editorial Content Studio
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Generate an Apple Podcasts / Spotify compliant static podcast RSS feed (`/podcast.xml`) from the 200+ clean MP3 audio stems preserved in the S3 audio vault (`/Volumes/Dock_1TB/WITC/consolidated/...`). Enables developers and listeners to subscribe to the complete UGtastic oral history archive on any modern podcast player.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Verify audio file paths and URLs for 200+ interview MP3 tracks.
- [x] #2 Create Jekyll template `podcast.xml` generating valid RSS 2.0 / iTunes podcast namespace XML.
- [x] #3 Include episode show notes, speaker bios, and links to interactive transcripts on just3ws.com.
- [x] #4 Add podcast subscribe links and badges across `/interviews/` and footer navigation.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 `/podcast.xml` passes feed validation with 0 XML errors.
- [x] #2 `bundle exec jekyll build` builds cleanly.
<!-- DOD:END -->

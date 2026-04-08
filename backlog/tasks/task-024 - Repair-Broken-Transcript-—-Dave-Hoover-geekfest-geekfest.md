---
id: TASK-024
title: Repair Broken Transcript — Dave Hoover (geekfest-geekfest)
status: To Do
assignee: []
created_date: '2026-04-08 03:10'
labels:
  - transcript
  - interview
  - archive
dependencies: []
references:
  - 'interview_id: dave-hoover-geekfest-geekfest'
  - 'video_asset_id: dave-hoover-geekfest-geekfest'
  - 'transcript_file: _data/transcripts/dave-hoover-geekfest-geekfest.yml'
  - 'vimeo: https://vimeo.com/41101410'
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The transcript for `dave-hoover-geekfest-geekfest.yml` is corrupted with a loop score of 168.27. It contains repetitive segments that prevent publication.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Source audio/video re-transcribed using high-confidence model.
- [ ] #2 Transcript content replaced in _data/transcripts/dave-hoover-geekfest-geekfest.yml.
- [ ] #3 Transcript normalization protocol (TRANSCRIPTION_PROMPT.md) successfully executed.
- [ ] #4 Site build validates without transcript integrity errors.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
- [ ] #2 Valid transcript content exists.
- [ ] #3 Linkage chain (Interview -> Asset -> Transcript) is verified.
- [ ] #4 Task updated to 'Ready' or 'Done'.
<!-- DOD:END -->

---
id: TASK-023
title: Repair Broken Transcript — Jonathan Baltz (jonathan-baltz-chicagowebconf-2012)
status: To Do
assignee: []
created_date: '2026-04-08 03:10'
labels:
  - transcript
  - interview
  - archive
dependencies: []
references:
  - 'interview_id: jonathan-baltz-chicagowebconf-2012'
  - 'video_asset_id: jonathan-baltz-chicagowebconf-2012'
  - 'transcript_file: _data/transcripts/jonathan-baltz-chicagowebconf-2012.yml'
  - 'vimeo: https://vimeo.com/ugtastic/jonathan-baltz'
  - 'youtube: https://www.youtube.com/watch?v=QJKSzUCcob4'
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The transcript for `jonathan-baltz-chicagowebconf-2012.yml` is severely corrupted with a high loop score (621.41). It contains repetitive hallucinated segments that prevent publication.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Source audio/video re-transcribed using high-confidence model.
- [ ] #2 Transcript content replaced in _data/transcripts/jonathan-baltz-chicagowebconf-2012.yml.
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

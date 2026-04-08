---
id: TASK-025
title: Repair Broken Transcript — Ashe Dryden (ashe-dryden-general)
status: To Do
assignee: []
created_date: '2026-04-08 03:10'
labels:
  - transcript
  - interview
  - archive
dependencies: []
references:
  - 'interview_id: ashe-dryden-general'
  - 'video_asset_id: ashe-dryden-general'
  - 'transcript_file: _data/transcripts/ashe-dryden-general.yml'
  - 'vimeo: https://vimeo.com/65153113'
  - 'youtube: https://www.youtube.com/watch?v=Ef2CKqC6l2I'
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The transcript for `ashe-dryden-general.yml` is corrupted with a loop score of 197.25. It contains repetitive segments that prevent publication.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Source audio/video re-transcribed using high-confidence model.
- [ ] #2 Transcript content replaced in _data/transcripts/ashe-dryden-general.yml.
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

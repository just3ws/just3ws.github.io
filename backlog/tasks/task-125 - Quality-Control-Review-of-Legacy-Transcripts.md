---
id: TASK-125
title: Quality Control Review of Legacy Transcripts
status: To Do
assignee: []
created_date: '2026-05-15 01:58'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
With the new `max-accuracy` whisper.cpp pipeline running, we need to go back and do a Quality Control (QC) review on the older, previously transcribed interviews. Some of the legacy transcripts may lack proper speaker diarization or suffer from phonetic drift.

This task involves identifying those older transcripts, determining if they just need a `transcript-conversational-audit` re-run or a full re-transcription, and applying the fixes.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Identify legacy transcripts generated prior to the Whisper v3 pipeline
- [ ] #2 Re-run them through the transcript-conversational-audit or re-transcribe if quality is severely lacking
- [ ] #3 Update the speaker maps and ensure phonetic accuracy (e.g. library names, frameworks)
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

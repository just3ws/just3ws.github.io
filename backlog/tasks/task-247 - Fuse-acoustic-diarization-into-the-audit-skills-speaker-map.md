---
id: TASK-247
title: Fuse acoustic diarization into the audit skill's speaker map
status: To Do
assignee: []
created_date: '2026-07-04 03:24'
labels:
  - pipeline
  - transcription
milestone: Interview Archive Pipeline
dependencies:
  - TASK-244
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The transcript-conversational-audit skill already produces speaker_map (M1 interviewer / S1,S2 guests) and turns, but heuristically. Ground those turns on the acoustic boundaries from TASK-244 and have the LLM label each acoustic speaker → M1/S1/S2 using the interviewee metadata. This is a delta on the existing skill / rake audit path, not a new engine — the speaker_map/turns output must stay schema-compatible with the current ingest.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The audit skill consumes acoustic segments (TASK-244) as turn boundaries
- [ ] #2 The LLM labels acoustic speakers as the interviewer vs the named interviewees
- [ ] #3 speaker_map/turns output stays schema-compatible with the existing rake audit:ingest
- [ ] #4 Verified against 2-3 known-good interviews (e.g. the Jez Humble reference layout)
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

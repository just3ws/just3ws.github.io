---
id: TASK-251
title: Extend the interview insight schema
status: To Do
assignee: []
created_date: '2026-07-04 03:24'
labels:
  - pipeline
  - insights
milestone: Interview Archive Pipeline
dependencies:
  - TASK-247
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The audit skill already emits `insights` (durable/time-bound). Extend that schema to capture the richer analysis requested: historical/era context (the 2010-2015 moment), conference + topic context, interviewee context, "lessons for now," followup questions, short-worthy quote timestamps, and cross-interview link anchors. Update the audit prompt (backlog/audit/outbox generation) to produce the extended fields, keeping backward compatibility with already-ingested insights.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The insight schema is extended with the new fields and validated
- [ ] #2 The audit prompt is updated to generate them
- [ ] #3 Existing ingested insights remain valid (backward-compatible)
- [ ] #4 Verified end-to-end on 2-3 interviews
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

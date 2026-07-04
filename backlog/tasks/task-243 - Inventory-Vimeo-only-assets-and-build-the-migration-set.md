---
id: TASK-243
title: Inventory Vimeo-only assets and build the migration set
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
labels:
  - pipeline
  - vimeo
milestone: Interview Archive Pipeline
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Identify every video_asset hosted only on Vimeo (no youtube platform id) and produce a migration manifest — asset id, vimeo id, title, interview slug, current transcript/caption status. This is the discovery gate for the Vimeo→YouTube re-upload; nothing migrates until this set is known and reviewed.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A manifest of all Vimeo-only assets is generated from _data
- [ ] #2 Each entry maps vimeo id → interview slug → current transcript/caption status
- [ ] #3 The manifest is committed as a review surface (yml or backlog doc) for sign-off before migration
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

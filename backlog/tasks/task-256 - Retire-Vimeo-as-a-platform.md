---
id: TASK-256
title: Retire Vimeo as a platform
status: To Do
assignee: []
created_date: '2026-07-04 09:24'
labels:
  - pipeline
  - vimeo
milestone: Interview Archive Pipeline
dependencies:
  - TASK-253
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Once content lives on YouTube, repoint the site off Vimeo: update embeds/players to YouTube, reconcile or remove the Vimeo thumbs (assets/vimeo/thumbs/*), and drop Vimeo from the platform records in _data. Structure/presentation cleanup — the final step of the migration.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Site players/embeds point at YouTube, not Vimeo
- [ ] #2 Vimeo thumbs are reconciled or removed
- [ ] #3 Vimeo is dropped from platform records in _data
- [ ] #4 No broken links/images; rake build and repo hygiene are green
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

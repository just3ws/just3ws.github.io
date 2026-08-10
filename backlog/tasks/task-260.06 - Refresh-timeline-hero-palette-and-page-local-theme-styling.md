---
id: TASK-260.06
title: Refresh timeline hero palette and page-local theme styling
status: In Progress
assignee:
  - Codex
created_date: '2026-08-10 19:55'
labels:
  - site-refresh
  - timeline
  - visual-regression
dependencies: []
references:
  - 'https://just3ws.localhost/timeline/'
documentation:
  - CONTEXT.md
  - docs/adr/0001-public-archive-publication-contract.md
parent_task_id: TASK-260
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Correct the public /timeline/ hero so its color system matches the refreshed just3ws editorial site in the default and Kanagawa themes. The current hero still uses an older hard-coded navy/blue palette that conflicts with the warmer archive and Panoramic View surfaces. Preserve the timeline scrubber, era filtering, archive content, and interview links.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The /timeline/ hero uses the refreshed site palette in the default theme with readable title, badge, and supporting copy.
- [ ] #2 The /timeline/ hero remains coherent and readable after switching to the Kanagawa theme.
- [ ] #3 Timeline scrubber controls and generated era/interview cards remain readable, focused, and functional.
- [ ] #4 Desktop and 375px browser checks cover hero colors, theme switching, filtering, and layout bounds.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

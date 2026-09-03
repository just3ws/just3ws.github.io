---
id: TASK-284.01
title: Make timeline conceptually accessible
status: In Progress
assignee:
  - '@agent-just3ws'
created_date: '2026-09-03 05:06'
updated_date: '2026-09-03 05:07'
labels:
  - timeline
  - ux
  - accessibility
dependencies: []
documentation:
  - timeline/index.html
  - _sass/_p_timeline.scss
  - docs/witc-temporal-timeline.md
parent_task_id: TASK-284
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Reframe the archive timeline so a visitor can understand its purpose, reading order, and evidence model before encountering advanced controls. Preserve the expansive temporal canvas while making the UGtastic story primary and career, technology, and industry context optional.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The timeline introduces one plain-language question that the visualization answers.
- [ ] #2 The default view presents no more than four clearly named primary story lanes.
- [ ] #3 Career, technology, life, domains, practices, and industry context are optional overlays rather than default reading requirements.
- [ ] #4 Events, active spans, uncertain dates, and quiet periods have distinct text-supported meanings that do not rely on color alone.
- [ ] #5 Every visible selectable timeline item is individually operable by keyboard and exposed with an understandable accessible name.
- [ ] #6 The interface provides an equivalent concise text summary and evidence path without requiring hover or horizontal scrolling.
- [ ] #7 Focused browser regression checks and the installed localhost verification pass.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

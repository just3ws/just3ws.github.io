---
id: TASK-284
title: Stabilize timeline inspection and layer navigation
status: In Progress
assignee:
  - agent-just3ws
created_date: '2026-09-03 02:22'
labels:
  - timeline
  - ux
  - accessibility
dependencies: []
modified_files:
  - timeline/index.html
  - _sass/_p_timeline.scss
  - tests/layout.spec.js
priority: medium
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Improve human navigability of the wide historical timeline. The hover/selection inspector must remain spatially stable while the user scrolls the expansive canvas, and the archive needs clear layer-level clustering so a reader can focus on one kind of history at a time without losing orientation.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The quick-inspection rail is outside the horizontal timeline scroller and has stable reserved space so changing hover content does not move the canvas.
- [ ] #2 Readers can filter the timeline into clearly named Community, Archive, Career, Technology, Life and tools, and Domains layers, with an All layers option.
- [ ] #3 Selecting a layer updates the visible lanes, preserves the wide horizontal time scale, and does not change the current scroll geometry unexpectedly.
- [ ] #4 The timeline remains accessible through labeled controls and the existing evidence ledger.
- [ ] #5 The Jekyll build and timeline browser regression coverage pass, or any environment limitation is recorded explicitly.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

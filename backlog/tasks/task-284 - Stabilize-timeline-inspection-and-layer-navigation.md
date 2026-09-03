---
id: TASK-284
title: Stabilize timeline inspection and layer navigation
status: Done
assignee:
  - agent-just3ws
created_date: '2026-09-03 02:22'
updated_date: '2026-09-03 02:24'
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
- [x] #1 The quick-inspection rail is outside the horizontal timeline scroller and has stable reserved space so changing hover content does not move the canvas.
- [x] #2 Readers can filter the timeline into clearly named Community, Archive, Career, Technology, Life and tools, and Domains layers, with an All layers option.
- [x] #3 Selecting a layer updates the visible lanes, preserves the wide horizontal time scale, and does not change the current scroll geometry unexpectedly.
- [x] #4 The timeline remains accessible through labeled controls and the existing evidence ledger.
- [x] #5 The Jekyll build and timeline browser regression coverage pass, or any environment limitation is recorded explicitly.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Move the hover/selection preview out of `.timeline-visual-shell`, keep a fixed-height reading rail, and retain the existing graph/evidence links.
2. Add a layer filter tablist that maps to the existing `series.kind` taxonomy, with All layers as the reset state.
3. Apply the filter in the existing render path and reset it with the existing Reset view control, preserving zoom and horizontal canvas sizing.
4. Add regression assertions for the inspector location, filter count, and career-layer filtering.
5. Build the site, run focused browser coverage if the sandbox permits the configured test server, and run static diff checks.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Jekyll build passed at 1,182 pages with zero accessibility warnings and git diff --check passed. Focused Playwright could not complete: the configured browser run launched but hung in this environment and was interrupted. Static build confirms the inspector is outside the scroller and layer controls are present; user should rebuild/install locally for visual verification.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Stabilized the wide timeline interaction model. The quick-inspection rail now sits outside the horizontal scroller with fixed reserved height, preventing hover content from shifting the canvas. Added accessible layer filters for All layers, Community, Archive, Career, Technology, Life and tools, and Domains, wired to the existing series taxonomy and reset behavior. Added focused Playwright assertions for inspector placement and layer filtering. Jekyll build passed with 1,182 pages and zero accessibility warnings; git diff --check passed. Browser execution launched but hung in the agent environment and was interrupted, so local visual verification remains with the user after rebuilding and installing the site.
<!-- SECTION:FINAL_SUMMARY:END -->

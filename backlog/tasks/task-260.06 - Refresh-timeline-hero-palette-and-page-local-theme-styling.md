---
id: TASK-260.06
title: Refresh timeline hero palette and page-local theme styling
status: Done
assignee:
  - '@Antigravity'
created_date: '2026-08-10 19:55'
updated_date: '2026-08-10 20:11'
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
- [x] #1 The /timeline/ hero uses the refreshed site palette in the default theme with readable title, badge, and supporting copy.
- [x] #2 The /timeline/ hero remains coherent and readable after switching to the Kanagawa theme.
- [x] #3 Timeline scrubber controls and generated era/interview cards remain readable, focused, and functional.
- [x] #4 Desktop and 375px browser checks cover hero colors, theme switching, filtering, and layout bounds.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Complexity: L1 bounded visual-system correction.

Context-hunter micro-brief:
- Closest analogs: _sass/_p_taxonomy.scss for the warm paper-and-ink archive surface and scoped Kanagawa variables; _sass/_p_panoramic_view.scss and _sass/_p_home_refresh.scss for editorial hero hierarchy and token naming.
- Current issue: timeline/index.html embeds a legacy navy/slate/bright-blue palette in an unscoped inline style. The hero and the scrubber/cards therefore ignore the refreshed site tokens and do not harmonize with the archive surfaces.
- Main risk: broad Kanagawa !important selectors can override timeline text and controls unless the page gets explicit scoped overrides; preserve the existing data-rendering and era filter behavior.

Implementation:
1. Add timeline-page body class and move the page-local inline presentation into _sass/_p_timeline.scss, using scoped --timeline-* tokens derived from the taxonomy/Panoramic View patterns.
2. Recompose only the presentation: warm paper hero with editorial rule/field-note feel, readable default copy, ruled scrubber, era headers, and register-like interview cards; retain all existing labels/data and links.
3. Add focused Kanagawa timeline overrides in _sass/_p_theme_kanagawa.scss; keep category/status colors accessible.
4. Import the focused stylesheet in assets/css/site.scss; remove the stale inline style block.
5. Extend tests/layout.spec.js with timeline desktop/mobile, default/Kanagawa hero color checks, era filtering, visible focus, and no document overflow.
6. Build, run focused/full layout tests, inspect screenshots, publish to localhost, and submit the finished slice to the required independent site-refresh reviewer before finalizing.

Authorized files:
- timeline/index.html
- _sass/_p_timeline.scss
- _sass/_p_theme_kanagawa.scss
- assets/css/site.scss
- tests/layout.spec.js

Exclusions:
- No timeline data, JS rendering/filter algorithm, routes, dependencies, or unrelated pages.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Discovery confirmed the hero is still a legacy inline block: #0f172a/#1e293b navy, #0284c7 blue, #94a3b8 slate, plus white card surfaces. Nearby refreshed pages use scoped tokens and editorial rules, so a page-local timeline stylesheet is the native correction. Browser runtime inspection was unavailable in this session; source and served HTML inspection are supplemented by the repository's Playwright smoke path.
<!-- SECTION:NOTES:END -->

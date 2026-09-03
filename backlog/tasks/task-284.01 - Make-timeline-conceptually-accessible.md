---
id: TASK-284.01
title: Make timeline conceptually accessible
status: In Progress
assignee:
  - '@agent-just3ws'
created_date: '2026-09-03 05:06'
updated_date: '2026-09-03 12:39'
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

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Refresh Brief accepted from the site-refresh director.

1. Reframe the exhibit around one visitor question: how UGtastic grew from community conversations into a preserved, rediscoverable archive.
2. Render exactly four primary story lanes by default: Community activity; Interviews and events; Publishing and preservation; Return and curation.
3. Move career, technology, projects/domains, industry, and curated personal context into combinable, off-by-default overlays with correct button or checkbox semantics.
4. Replace lane-wide transparent hit targets with one keyboard-operable control per visible event or span. Give each control a name containing its type, title, date/range, confidence, and lane. Support equivalent hover and focus previews plus directional keyboard navigation.
5. Add a visible concise summary and plain-language visual key before the horizontal canvas. Keep the evidence ledger as the non-hover verification path.
6. Remove visitor-facing layout jargon and the heuristic zeitgeist tail. Preserve uncertainty and quiet-space meaning without claiming unsupported continuity.
7. Replace the local absolute source path in docs/witc-temporal-timeline.md with a neutral source identifier.
8. Update focused layout/browser assertions, build, install locally, and gather desktop/mobile evidence.
9. Hand Build Evidence to an independent site-refresh reviewer.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Builder completed the approved slice.

Changed files: timeline/index.html; _sass/_p_timeline.scss; docs/witc-temporal-timeline.md; tests/layout.spec.js.

Build evidence: four default story lanes; five off-by-default combinable context overlays; visible purpose, summary, instructions, evidence links, and semantic key; individual keyboard-operable marks; Arrow/Home/End navigation; equivalent hover/focus previews; sticky lane labels; text-supported time semantics; removed track/zeitgeist visitor language; neutralized absolute source path. Jekyll build passed with 928 pages and zero markup warnings. Focused Playwright checks passed 2 of 2 before two final style-only corrections; final repeat was interrupted. Independent review required.
<!-- SECTION:NOTES:END -->

---
id: TASK-260.05
title: Correct taxonomy visual system and theme colors
status: In Progress
assignee:
  - Codex
created_date: '2026-08-10 18:34'
updated_date: '2026-08-10 18:39'
labels:
  - site-refresh
  - taxonomy
  - visual-regression
dependencies: []
references:
  - 'https://just3ws.localhost/taxonomy/'
documentation:
  - CONTEXT.md
  - docs/adr/0001-public-archive-publication-contract.md
parent_task_id: TASK-260
priority: high
type: bug
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bring the public `/taxonomy/` knowledge-graph page into the refreshed just3ws visual system. The page currently presents a disconnected hard-coded palette and inconsistent light/Kanagawa theme behavior, making the broader site refresh appear incomplete.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The taxonomy page uses a coherent palette consistent with the refreshed professional site in the default theme.
- [ ] #2 The taxonomy page remains coherent and readable in the Kanagawa theme, including hero, metrics, controls, graph, inspector, legend, table, badges, links, and buttons.
- [ ] #3 Text, controls, and graph labels preserve accessible contrast and visible focus states.
- [ ] #4 Graph interaction, entity filtering, taxonomy search, and entity links continue to work.
- [ ] #5 Desktop and 375px mobile browser checks cover layout bounds and the two theme states.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add a focused Playwright regression check that proves the current default-theme hero contrast failure and covers Kanagawa surfaces, taxonomy interactions, and 375px bounds.
2. Replace the page-local hard-coded presentation block with a scoped taxonomy stylesheet that uses the site's design tokens and a restrained Nord/Kanagawa categorical palette across the hero, metrics, controls, graph, inspector, legend, table, badges, links, and focus states.
3. Make the graph and dynamically generated badges read the same CSS palette and refresh it when the theme toggle changes.
4. Rebuild and run focused browser tests, inspect desktop/mobile screenshots in both themes, run broader validation, then publish the current `_site` build to the static localhost webroot and verify the refreshed homepage and taxonomy page are actually served.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
L1 context-hunter micro-brief: closest analogs are `_sass/_p_home_refresh.scss` and `_sass/_p_panoramic_view.scss`, which scope page tokens locally and defer Kanagawa overrides to `_sass/_p_theme_kanagawa.scss`. The taxonomy page instead embeds a separate slate/blue/pink CSS block and repeats those colors in graph JavaScript. Main risks are the broad Kanagawa `!important` selectors, keeping categorical graph colors distinguishable, and preserving table/graph behavior while consolidating presentation.

Diagnosis reproduced from the user URL: the default-theme taxonomy title renders dark on a dark hero, the graph/legend/badges use unrelated saturated colors, and the table is visually cramped. Separately, `https://just3ws.localhost/` serves an August 9 static build; `/home/` still contains `Architect & Creator`, so the completed refresh is not visible there.
<!-- SECTION:NOTES:END -->

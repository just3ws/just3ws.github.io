---
id: TASK-260.05
title: Correct taxonomy visual system and theme colors
status: In Progress
assignee:
  - Codex
created_date: '2026-08-10 18:34'
updated_date: '2026-08-10 18:34'
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

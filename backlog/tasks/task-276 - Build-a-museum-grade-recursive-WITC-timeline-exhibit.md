---
id: TASK-276
title: Build a museum-grade recursive WITC timeline exhibit
status: In Progress
assignee:
  - '@Codex'
created_date: '2026-09-02 20:57'
updated_date: '2026-09-02 20:57'
labels:
  - timeline
  - visualization
  - witc
  - site-refresh
dependencies: []
references:
  - 'https://just3ws.localhost/timeline/'
documentation:
  - CONTEXT.md
  - docs/witc-temporal-timeline.md
  - docs/witc-corpus.md
  - docs/witc-archive-atlas.json
  - >-
    backlog/tasks/task-260.06 -
    Refresh-timeline-hero-palette-and-page-local-theme-styling.md
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Transform the public /timeline/ surface into a rich, evidence-led interactive history of UGtastic, UGl.st, and the WHOIS Tech Community archive. The experience should support data-oriented readers who want temporal precision, parallel activity lanes, provenance, corpus scale, and drill-down context while retaining a humane narrative for readers encountering the history for the first time. It may use the full available page width and should express the long arc from the original vision through recording, preservation, and current curation without presenting inferred dates as facts.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The timeline presents an expansive, responsive visual overview of the archive with multiple temporal layers or lanes and a clear distinction between event dates and archive evidence dates.
- [ ] #2 Readers can move from a broad cosmic or epoch-level view into eras, series, and individual evidence records without losing their place.
- [ ] #3 The page surfaces corpus scale, provenance, uncertainty, and source links in the interface rather than hiding them in implementation details.
- [ ] #4 The interaction is keyboard accessible, supports reduced motion, and remains usable at desktop and mobile widths without clipping or unreadable overlap.
- [ ] #5 The page links the timeline back to UGtastic, UGl.st, archive records, transcripts, and relevant external preservation sources where evidence exists.
- [ ] #6 The implementation preserves existing routes and data contracts, adds tests for key interactions and layout bounds, and passes the site build and prose checks.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Complexity: L2 interactive information design and archive visualization.

Research findings:
- /timeline/ currently renders 184 interview items from _data/timeline_archive.json, grouped into five editorial eras.
- docs/witc-archive-atlas.json provides separate temporal series, provenance fields, timestamp kinds, evidence paths, and archive layers from the WITC corpus.
- The existing timeline stylesheet already permits a full-width page but only presents era buttons and cards. The new surface should preserve its route and data contracts while adding a richer overview.

Design direction:
1. Use an expansive full-width museum composition with an editorial hero, a cosmic-scale orientation field, and a readable evidence ledger below it.
2. Make the primary visual a responsive SVG timeline with a shared time axis and parallel lanes for recording, community/events, preservation, transcript/caption work, and current curation. Use existing atlas data and visibly label date precision and timestamp semantics.
3. Add recursive drill-down: selecting an epoch focuses the timeline, selecting a lane reveals its evidence, and selecting a record links to the public archive. Preserve the reader's selected state in one detail region and provide a reset/orientation control.
4. Surface data-nerd essentials directly: corpus totals, date range, layer counts, evidence count, precision caveat, source path, timestamp kind, and external preservation search. Avoid invented certainty or metrics.
5. Add a lightweight constellation/fractal motif using deterministic archive relationships only. It should support orientation and wonder, not replace the evidence view or introduce decorative noise.
6. Keep keyboard access, focus states, reduced-motion behavior, responsive stacking, and a text alternative for the SVG. Update timeline page markup/scripts/styles and focused layout tests only.
7. Build, run timeline and layout tests, inspect desktop and mobile screenshots, run prose and diff checks, and verify the installed localhost route when the site runtime is available.

Primary files: timeline/index.html, _sass/_p_timeline.scss, tests/layout.spec.js. Reuse docs/witc-archive-atlas.json and _data/timeline_archive.json without changing their schemas.
<!-- SECTION:PLAN:END -->

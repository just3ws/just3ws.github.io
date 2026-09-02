---
id: TASK-276
title: Build a museum-grade recursive WITC timeline exhibit
status: In Progress
assignee: []
created_date: '2026-09-02 20:57'
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

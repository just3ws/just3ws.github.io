---
id: TASK-278.07
title: Build provenance and temporal confidence records
status: To Do
assignee: []
created_date: '2026-09-02 22:43'
labels:
  - oral-history
  - archive
  - research
  - knowledge-graph
dependencies: []
references:
  - docs/witc-temporal-timeline.md
  - /timeline/
  - /docs/witc-archive-atlas.json
  - /assets/data/knowledge_graph.json
parent_task_id: TASK-278
priority: medium
type: docs
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Define the evidence chain for each entity and relationship, including source kind, date kind, precision, archive capture, publication date, recording date, transcript date, and current curation date. Make uncertainty queryable.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Every enriched entity has provenance metadata or an explicit missing-evidence state.
- [ ] #2 Historical dates, inferred dates, and archive processing dates cannot be conflated.
- [ ] #3 Wayback and Internet Archive references are attached to the relevant entity rather than only a general archive page.
- [ ] #4 Temporal confidence supports timeline filtering and human review.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

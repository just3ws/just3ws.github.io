---
id: TASK-294
title: Close Remaining Archive Knowledge Graph Coverage Gaps (Posts, Positions, Case Studies, Transcripts & Engagements)
status: To Do
assignee: []
created_date: '2026-10-16 11:40'
updated_date: '2026-10-16 11:40'
labels:
  - knowledge-graph
  - architecture
dependencies:
  - TASK-274.03
  - TASK-291
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Extend `bin/generate_knowledge_graph.rb` and `bin/audit_knowledge_graph.rb` per `docs/architecture/knowledge-graph-contract.md` so that all 185 Posts, 28 Positions, 2 Case Studies, 4 Engagements, 76 Interview Topics, and 218 Transcripts are indexed as first-class graph nodes with `EXTRACTED` provenance and zero orphans, while keeping client-side vis-network rendering fast on `/taxonomy/` and `/timeline/` via default cluster filtering.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Register all 28 Positions, 2 Case Studies, 4 Engagements, 185 Posts, 76 Technical Topics, and 218 Transcripts in bin/generate_knowledge_graph.rb with namespaced IDs and legacy_id compatibility
- [ ] #2 Add cluster filtering in taxonomy/index.html so vis-network defaults to core community clusters while allowing full-corpus inspection
- [ ] #3 Update spec/bin/audit_knowledge_graph_spec.rb to assert zero coverage_gaps and zero orphan_node_ids in _data/knowledge_graph_audit.json
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 ruby bin/audit_knowledge_graph.rb reports 0 coverage gaps, 0 orphans, and 0 missing edge endpoints
<!-- DOD:END -->

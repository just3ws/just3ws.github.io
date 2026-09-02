---
id: TASK-274.03
title: Define canonical knowledge graph contract and coverage audit
status: To Do
assignee: []
created_date: '2026-09-02 16:49'
labels:
  - knowledge-graph
  - architecture
  - validation
dependencies: []
references:
  - 'https://skills.sh/graphify-labs/graphify/graphify'
documentation:
  - bin/generate_knowledge_graph.rb
  - bin/generate_semantic_cross_links.rb
  - bin/visualize_semantic_graph.rb
  - Rakefile
parent_task_id: TASK-274
priority: high
type: feature
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create the repository-owned graph contract and deterministic audit for public content, source provenance, routes, relationships, unresolved references, duplicate IDs, and orphan nodes. Reconcile the existing knowledge graph, semantic cross-links, JSON-LD graph, and generated archive data without silently discarding edges.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A graph contract documents node kinds, relationship kinds, stable IDs, provenance fields, and source-of-truth files.
- [ ] #2 A deterministic audit reports node and edge counts by kind, unresolved references, duplicate identifiers, and orphans.
- [ ] #3 The audit can run without an LLM or external service and exits nonzero for structurally invalid output.
- [ ] #4 Focused tests cover representative post, interview, transcript, speaker, topic, position, and engagement relationships.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

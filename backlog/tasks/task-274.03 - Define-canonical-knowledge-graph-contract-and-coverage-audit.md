---
id: TASK-274.03
title: Define canonical knowledge graph contract and coverage audit
status: In Progress
assignee:
  - agent-just3ws
created_date: '2026-09-02 16:49'
updated_date: '2026-09-02 17:13'
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

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Inspect existing graph JSON shapes, public data collections, JSON-LD output, and representative specs.
2. Define a source-provenance graph schema in docs with stable IDs and explicit EXTRACTED, INFERRED, and AMBIGUOUS edge confidence.
3. Implement a deterministic Ruby generator/auditor that reads source collections and rendered JSON-LD where available, emits graph JSON plus a human-readable audit summary, and never reads secret files.
4. Add a primary pipeline command and focused RSpec coverage for representative content relationships and invalid graph structures.
5. Run targeted graph tests, Jekyll build, generated freshness, Markdown/YAML/prose checks, and record evidence.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Research baseline: existing graph generation is split across bin/generate_knowledge_graph.rb, bin/generate_semantic_cross_links.rb, and bin/visualize_semantic_graph.rb. The existing taxonomy graph is regex-driven and has fixed node categories. Graphify extraction found 1,014 code, 1,541 docs, 15 papers, and 155 images, but semantic extraction could not complete because the local llama endpoint exits after binding. Deterministic graph work will proceed independently.

Implemented docs/architecture/knowledge-graph-contract.md with source layers, stable IDs, relationships, confidence, provenance, and integrity rules.

Implemented bin/audit_knowledge_graph.rb and _data/knowledge_graph_audit.json. Baseline is structurally valid at 403 nodes and 615 edges, with 2 orphan user-group nodes, 0 duplicate IDs, and 0 dangling endpoints. Coverage gaps are now explicit: transcripts, posts, positions, engagements, case studies, and most topics are not first-class graph nodes yet.

Added ./bin/pipeline knowledge-graph and focused RSpec coverage in spec/bin/audit_knowledge_graph_spec.rb.

Added bin/www-graphify with local endpoint http://127.0.0.1:11500/v1, model alias local, one worker, and 12,000-token default budget. Local llama is currently unstable and exits after binding, so semantic extraction remains pending.

Added graph-aware Cmd+K loading of assets/data/knowledge_graph.json. Search now considers graph node labels, types, descriptions, and neighboring relationship context, then deduplicates graph results against the catalog.

Added the lived-orienteering origin story to docs/organizers-perspective-programming-the-human-communication-layer.md: Eagle Scout background, Illinois Army National Guard 91B and EMT-A path, 1993 Fort Leonard Wood Basic Training, team-lift behavior, OpFor initiative, calibrated exercise difficulty, and the painted-rock clarity cadence for AI workflows. Vale, Markdown lint, and diff checks pass.
<!-- SECTION:NOTES:END -->

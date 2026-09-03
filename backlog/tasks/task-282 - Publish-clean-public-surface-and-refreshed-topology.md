---
id: TASK-282
title: Publish clean public surface and refreshed topology
status: In Progress
assignee:
  - agent-just3ws
created_date: '2026-09-03 01:26'
updated_date: '2026-09-03 01:26'
labels:
  - release
  - public-surface
  - topology
  - editorial-safety
dependencies: []
references:
  - docs/architecture/knowledge-graph-contract.md
  - docs/public-artifact-curation-policy.md
  - 'https://openai.com/index/chatgpt/'
  - 'https://ai.meta.com/blog/large-language-model-llama-meta-ai/'
documentation:
  - CONTEXT.md
  - docs/style-guide-and-canonical-naming.md
modified_files:
  - timeline/index.html
  - _data/knowledge_graph.json
  - assets/data/knowledge_graph.json
  - _data/knowledge_graph_audit.json
  - bin/audit_public_surface.rb
  - docs/public-artifact-curation-policy.md
priority: high
type: chore
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Rebuild the public Jekyll surface after the editorial safety and topology updates, rerun deterministic relationship-graph generation, verify that local audit reports remain isolated from the served site, and publish only the validated build. Preserve unresolved high-risk or quarantined findings for human editorial review.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The canonical knowledge graph regenerates successfully and its integrity audit reports no missing edge endpoints or duplicate node IDs.
- [ ] #2 The timeline includes separately sourced ChatGPT and LLaMA historical gates with clear dates and primary-source links.
- [ ] #3 The site builds successfully with generated metadata and AI disclosure validation.
- [ ] #4 The built site passes internal-link validation and has no critical public-surface findings.
- [ ] #5 The local public-surface review queue remains outside the generated and deployed site.
- [ ] #6 The release report clearly distinguishes published evidence from unresolved high-risk or quarantined material.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Regenerate the canonical relationship graph and run its integrity audit.
2. Run the deterministic Graphify code update; record the local inference failure separately rather than treating it as semantic evidence.
3. Add and verify the ChatGPT and LLaMA timeline gates with primary sources.
4. Rebuild the Jekyll site and run metadata, disclosure, Markdown, link, graph, and public-surface checks.
5. Verify the ignored local review queue is absent from the rendered site.
6. Install the validated build to the configured localhost publication surface only if the release checks pass; report any external-production limitation explicitly.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Started release-gate work. Deep Graphify semantic extraction was attempted with the local configured backend but the endpoint returned connection errors for all 321 chunks. Deterministic Graphify code extraction succeeded with 8,107 nodes and 11,759 edges. Canonical knowledge graph generation and audit succeeded with 422 nodes, 672 edges, and no missing endpoints or duplicate IDs.
<!-- SECTION:NOTES:END -->

---
id: TASK-282
title: Publish clean public surface and refreshed topology
status: To Do
assignee: []
created_date: '2026-09-03 01:26'
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

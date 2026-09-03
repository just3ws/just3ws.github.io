---
id: TASK-282
title: Publish clean public surface and refreshed topology
status: Done
assignee:
  - agent-just3ws
created_date: '2026-09-03 01:26'
updated_date: '2026-09-03 01:30'
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
- [x] #1 The canonical knowledge graph regenerates successfully and its integrity audit reports no missing edge endpoints or duplicate node IDs.
- [x] #2 The timeline includes separately sourced ChatGPT and LLaMA historical gates with clear dates and primary-source links.
- [x] #3 The site builds successfully with generated metadata and AI disclosure validation.
- [x] #4 The built site passes internal-link validation and has no critical public-surface findings.
- [x] #5 The local public-surface review queue remains outside the generated and deployed site.
- [x] #6 The release report clearly distinguishes published evidence from unresolved high-risk or quarantined material.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
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

Release verification completed: Jekyll build produced 1,179 pages with zero accessibility markup warnings; last-modified validation passed for 181 posts; AI disclosure validation passed for 39 flagged articles; Markdown lint passed across 451 files; focused public-surface specs passed 7/7; HTML-Proofer passed on 1,160 files, 1,270 internal links, and 1,156 hash-link files; git diff --check passed.

Public-surface audit scanned 2,674 files with 0 critical findings. It still reports 908 high-risk and 1,875 quarantine findings, so the strict editorial gate remains intentionally blocked pending human review. The local queue is ignored and absent from _site.

Published build copied to /opt/homebrew/var/www/just3ws.github.io. Nginx reload could not be completed because the environment requires an interactive sudo password; installed files contain the refreshed timeline, but live HTTPS smoke verification remains pending service reload.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Regenerated the canonical knowledge graph and refreshed the historical timeline with separately sourced ChatGPT and LLaMA inflection-point gates. Rebuilt the Jekyll site, validated generated metadata, AI disclosures, Markdown, internal links, focused public-surface behavior, and graph integrity, then copied the validated build to the configured localhost publication directory. The release contains no critical public-surface findings. The strict editorial gate remains intentionally unresolved because high-risk and quarantined findings still require human review. Nginx could not be reloaded non-interactively, so the installed files are ready but live HTTPS verification awaits the local service reload.
<!-- SECTION:FINAL_SUMMARY:END -->

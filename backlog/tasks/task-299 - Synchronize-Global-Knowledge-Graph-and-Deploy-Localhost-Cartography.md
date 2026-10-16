---
id: TASK-299
title: Synchronize Global Knowledge Graph & Deploy Localhost Cartography
status: Done
assignee: []
created_date: '2026-10-16 14:30'
updated_date: '2026-10-16 14:42'
labels:
  - knowledge-graph
  - graphify
  - deployment
  - verification
dependencies:
  - TASK-297
  - TASK-298
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Incorporate the newly published long-form article, the Fluffle Errata episode dossier, and the April 2023 timeline entry into the global knowledge graph and AST cartography. Run `./bin/pipeline data graph` to update `_data/knowledge_graph.json` (verifying 0 orphans and 0 duplicate IDs) and incrementally refresh `graphify-out/graph.json`. Build and deploy the full site to localhost (`bundle exec jekyll build && bin/install-localhost`) and verify all pages and live telemetry endpoints.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Regenerate _data/knowledge_graph.json with 0 orphans and 0 duplicate IDs
- [x] #2 Update graphify AST and markdown nodes via graphify update .
- [x] #3 Build and install localhost site across all 1,030+ pages
- [x] #4 Verify live HTTP 200 responses on article URL and dashboard tabs
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 Full validation suite passing cleanly (validate fast, validate all, rspec) and localhost site deployed
<!-- DOD:END -->

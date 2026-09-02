---
id: TASK-275
title: Add WITC corpus to the queryable career datalake
status: In Progress
assignee: []
created_date: '2026-09-02 20:21'
labels: []
dependencies: []
references:
  - /Volumes/Dock_1TB/WITC
  - career_datalake.json
  - bin/query_career_datalake.rb
  - bin/career_datalake_mcp_server.rb
documentation:
  - CONTEXT.md
  - docs/career-datalake-and-mcp-guide.md
  - docs/corpus-metrics.md
priority: high
type: feature
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Build a provenance-preserving, manifest-driven ingestion path for the public-safe material under /Volumes/Dock_1TB/WITC. The resulting WITC corpus must be queryable through the same deterministic interfaces used for the ChatGPT-derived career archive, while keeping source boundaries explicit and excluding secrets, credentials, private work material, binary media, and unverified claims.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The WITC source inventory reports counts, formats, date ranges, and source paths without reading excluded secret or credential files
- [ ] #2 A deterministic corpus artifact preserves source path, source repository or project identity, timestamps when available, content hash, and provenance metadata
- [ ] #3 The query interface can search WITC records separately and in a combined corpus without silently deduplicating or overwriting existing career data
- [ ] #4 The MCP interface exposes WITC corpus discovery and query operations with bounded result sizes
- [ ] #5 The importer supports dry-run and validation before any generated datalake artifact is replaced
- [ ] #6 Documentation describes the source contract, exclusion rules, reproducibility, and known limitations
- [ ] #7 Automated tests cover supported formats, exclusion rules, provenance fields, duplicate handling, and query behavior
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

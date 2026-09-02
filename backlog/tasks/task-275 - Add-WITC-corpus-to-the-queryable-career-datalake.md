---
id: TASK-275
title: Add WITC corpus to the queryable career datalake
status: In Progress
assignee:
  - agent-just3ws
created_date: '2026-09-02 20:21'
updated_date: '2026-09-02 20:28'
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

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Define a manifest-driven WITC source contract with safe text/metadata formats, hard exclusions for credentials, secrets, VCS internals, media, caches, generated outputs, and other non-contextual noise, plus relative-path provenance.
2. Implement a deterministic importer that scans the configured WITC root, supports dry-run and apply/validation, records source path, project/repository identity, source kind, timestamps, SHA-256, size, and stable document/thread IDs, and preserves duplicates as distinct provenance records.
3. Produce a local SQLite corpus matching the existing archive-search contract: documents, FTS5, threads, and corpus metadata. Keep the generated database out of git and avoid embedding the absolute volume path in committed content.
4. Add a repo-local query interface with WITC-only and additive combined search modes, bounded result limits, date filters, stats, and source inspection. Reuse the existing query semantics where practical.
5. Extend the CareerOS MCP server with bounded WITC discovery/query operations and a resource describing the corpus contract.
6. Add fixtures and tests for supported formats, temporal metadata, exclusions, duplicate handling, provenance, dry-run/apply validation, query behavior, and bounded results.
7. Document reproducible commands, temporal interpretation, source limitations, privacy boundary, local-cache behavior, and how to use the corpus with the existing local-LLM ask workflow.

8. Extend the temporal artifact into an evidence-linked archive atlas model: eras, event/conference series, local evidence records, site routes, and verified external archive links, with explicit citation status and no invented URLs.

9. Provide an interactive-friendly JSON representation and documented overlay semantics so a site timeline can render parallel series without collapsing recording, publication, preservation, and curation time.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Discovery completed. WITC is a 174G mixed archive with existing _output catalog/inventory artifacts. The reference ChatGPT archive mechanism is /Users/mike/my/lib/archive_search.py: SQLite documents + FTS5 + optional threads, local cache, deterministic retrieval, and optional local-LLM synthesis. Use a separate WITC corpus rather than merging raw WITC into career_datalake.json. Temporal fields must distinguish source/event/upload/file timestamps and must not imply that a later archive/conversion date is the event date.

User expanded the goal to a visual, rich, interactive archive atlas with horizontal timeline overlays for conferences and series, links back to eras/context, and attributed local/external evidence including Wayback/Internet Archive targets. Treat external links as verified-or-unknown metadata, never inferred fact.
<!-- SECTION:NOTES:END -->

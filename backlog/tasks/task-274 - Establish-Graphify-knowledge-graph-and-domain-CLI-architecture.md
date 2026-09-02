---
id: TASK-274
title: Establish Graphify knowledge graph and domain CLI architecture
status: In Progress
assignee:
  - agent-just3ws
created_date: '2026-09-02 16:45'
updated_date: '2026-09-02 16:46'
labels:
  - architecture
  - knowledge-graph
  - tooling
  - refactor
dependencies: []
references:
  - >-
    /Users/mike/ai/inbox/inspiration/agentic-platform-lessons-2026-08-12/AGENT-MAP-AND-NAVIGATION-GUIDE.md
  - >-
    /Users/mike/ai/inbox/inspiration/agentic-platform-lessons-2026-08-12/extractive-tooling-playbook.md
  - >-
    /Users/mike/ai/inbox/inspiration/agentic-platform-lessons-2026-08-12/skills-and-agents-synthesis.md
documentation:
  - AGENTS.md
  - CONTEXT.md
  - CODEX.md
  - bin/README.md
  - Rakefile
priority: high
type: feature
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a durable, complete relationship graph for the public knowledgebase and reorganize repository tooling around explicit domain commands that follow the surrounding zdots/www-* conventions. The work must preserve existing site routes and generation behavior, make graph coverage measurable, and provide a safe migration path from the current mixed bin directory.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A documented graph contract identifies node types, relationship types, canonical identifiers, source-of-truth files, generated artifacts, and unresolved-link policy.
- [ ] #2 All public content domains and their relationships are represented in a generated graph with coverage and orphan reports.
- [ ] #3 Graph generation and validation are available through the repository's primary pipeline interface and have deterministic, testable outputs.
- [ ] #4 Repository tools are grouped by domain with consistent www-* or equivalent domain naming, compatibility shims where needed, and no silent breakage of existing documented commands.
- [ ] #5 The bin directory has an inventory, ownership/status classification, and explicit deprecation or retention decision for every tool.
- [ ] #6 Agent navigation guidance documents how to discover capabilities, select tools, query the graph, and validate changes.
- [ ] #7 The implementation passes the repository build, test, Markdown/YAML/prose checks, generated freshness checks, and targeted graph/tooling tests.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Current plan

1. Establish the graph contract from the existing knowledge graph, semantic JSON-LD graph, cross-link output, public content collections, and canonical naming guide.
2. Add a graph coverage audit that reports nodes, typed relationships, unresolved references, duplicate identifiers, and orphans without mutating source content.
3. Unify graph generation, audit, and snapshot commands under the primary pipeline, with deterministic output checks and focused specs.
4. Inventory every bin tool by domain, runtime, lifecycle, and status. Define a migration taxonomy based on existing local conventions, including www-* names where the tool is a public/archive domain surface and explicit archive/transcript/semantic domains where that is more accurate.
5. Introduce compatibility shims and a documented migration map before moving or deleting commands. Do not break current documented invocations.
6. Update agent navigation documentation with the graph query path, capabilities discovery path, tool selection rules, and validation probes.
7. Run targeted graph/tooling tests followed by the full repository quality gates and record evidence.

## Architecture decisions to validate before implementation

- Treat Graphify as the graph capability contract, not as an unavailable external skill. No Graphify skill package is currently registered or discoverable in the local skill roots.
- Use canonical content IDs and site routes as stable graph identifiers, while preserving source provenance for every node and edge.
- Keep generated graph artifacts separate from hand-authored source data and make unresolved links visible in reports rather than silently dropping them.
- Prefer domain-oriented wrappers and compatibility shims over a mass rename of all bin files in one change. The first migration slice should make the structure discoverable and reversible.
<!-- SECTION:PLAN:END -->

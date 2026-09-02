---
id: TASK-274
title: Establish Graphify knowledge graph and domain CLI architecture
status: To Do
assignee: []
created_date: '2026-09-02 16:45'
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

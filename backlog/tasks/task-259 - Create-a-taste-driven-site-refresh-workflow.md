---
id: TASK-259
title: Create a taste-driven site refresh workflow
status: In Progress
assignee:
  - Codex
created_date: '2026-08-10 15:27'
updated_date: '2026-08-10 15:27'
labels:
  - agent-skills
dependencies: []
references:
  - 'https://github.com/Leonxlnx/taste-skill'
documentation:
  - CONTEXT.md
  - CODEX.md
  - docs/adr/0001-public-archive-publication-contract.md
priority: medium
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Give maintainers a repo-native, repeatable way to audit and refresh just3ws.com without importing framework assumptions or generic AI design patterns. The workflow must preserve the public archive contract, current Jekyll architecture, accessibility, and Mike's established editorial voice.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A repo-local skill can guide an agent from current-site audit through a bounded visual refresh and verification.
- [ ] #2 Specialized agent interfaces cover visual direction, implementation, and independent quality review with clear handoff artifacts.
- [ ] #3 The workflow encodes just3ws.com-specific design, content, accessibility, and public-safety constraints.
- [ ] #4 The new capabilities are discoverable from the repository agent instructions.
- [ ] #5 All new skill packages pass structural validation and the repository's relevant documentation and build checks pass.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

---
id: TASK-274.02
title: Inventory and domain-map repository CLI tools
status: To Do
assignee: []
created_date: '2026-09-02 16:49'
labels:
  - tooling
  - architecture
  - cleanup
dependencies: []
references:
  - >-
    /Users/mike/ai/inbox/inspiration/agentic-platform-lessons-2026-08-12/extractive-tooling-playbook.md
documentation:
  - bin/README.md
  - bin/pipeline
  - Rakefile
  - AGENTS.md
parent_task_id: TASK-274
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Produce a complete inventory of every bin tool with domain, runtime, lifecycle, executable status, primary owner, replacement or compatibility path, and retention decision. Introduce a domain-oriented command map that follows surrounding www-* conventions where appropriate without mass-renaming or breaking existing commands.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Every tracked bin file is represented in the inventory.
- [ ] #2 The inventory identifies duplicate, legacy, generated, library, and primary-driver tools.
- [ ] #3 A domain command map defines stable entry points and compatibility behavior for existing invocations.
- [ ] #4 Repository checks detect undocumented or newly added bin tools.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

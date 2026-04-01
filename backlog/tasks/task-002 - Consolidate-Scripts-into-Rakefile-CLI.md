---
id: TASK-002
title: Consolidate Scripts into Rakefile/CLI
status: In Progress
assignee: []
created_date: '2026-04-01 15:29'
updated_date: '2026-04-01 19:09'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The `bin/` directory contains over 20 independent scripts with overlapping logic (YAML loading, text normalization). This makes the pipeline hard to maintain and slow due to redundant operations.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Create a unified `Rakefile` or Ruby CLI tool that encapsulates all generator and validator logic.
- [ ] #2 Shared logic (e.g., loading `_data/*.yml`) is moved to a central module.
- [ ] #3 Implement a command-runner that allows execution of subsets of tasks (e.g., `rake generate:interviews`).
- [ ] #4 Deprecate individual scripts in `bin/` once consolidated.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

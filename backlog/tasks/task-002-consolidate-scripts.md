# Task-002: Consolidate Scripts into Rakefile/CLI

**Status:** To Do
**Priority:** High

## Description
The `bin/` directory contains over 20 independent scripts with overlapping logic (YAML loading, text normalization). This makes the pipeline hard to maintain and slow due to redundant operations.

## Acceptance Criteria
- [ ] Create a unified `Rakefile` or Ruby CLI tool that encapsulates all generator and validator logic.
- [ ] Shared logic (e.g., loading `_data/*.yml`) is moved to a central module.
- [ ] Implement a command-runner that allows execution of subsets of tasks (e.g., `rake generate:interviews`).
- [ ] Deprecate individual scripts in `bin/` once consolidated.

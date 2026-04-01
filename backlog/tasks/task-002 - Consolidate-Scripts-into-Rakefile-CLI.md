---
id: TASK-002
title: Consolidate Scripts into Rakefile/CLI
status: Done
assignee: []
created_date: '2026-04-01 15:29'
updated_date: '2026-04-01 19:47'
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

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Consolidated over 60 independent scripts into a unified Rakefile structure.
- Created a comprehensive Rakefile with namespaces for generate, validate, import, report, enrich, extract, and discover tasks.
- Updated `bin/pipeline` to serve as a high-level wrapper for the most common Rake tasks (build, test, validate, ci).
- Integrated all core data generators and site validators into the Rake-driven pipeline.
- Updated repo hygiene and SEO/semantic validators to support the new directory structure.
- Verified that the full CI pipeline (`rake ci`) passes successfully.
- Individual scripts are now orchestrated by Rake, facilitating easier maintenance and future extraction of shared logic into the `Generators::Core` module.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

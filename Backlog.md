# Backlog - Mike Hall's Archive & Resume Project

## Project Status Overview

Current operating status: **Maintenance & Optimization Phase**.

The project has stabilized its build pipeline, data integrity, and SEO foundations. The current focus is on architectural modernization and archive completeness.

### Critical Constraints
- **Root Route Semantics:** `/` is the root resume route; `/home/` is homepage content.
- **Resume Integrity:** `/`, `/resume.txt`, and `/resume.md` must render correctly on every build.
- **CI Guardrails:** Runtime parity, uniqueness, and integrity checks are blocking gates.

---

## Decisions

Individual Architectural Decision Records (ADRs) are stored in `backlog/decisions/`.

| ID | Decision | Status | Date |
| :--- | :--- | :--- | :--- |
| [DEC-001](backlog/decisions/dec-001-move-build-pipeline-to-gha.md) | Move build pipeline to GitHub Actions | Accepted | 2026-04-01 |
| [DEC-002](backlog/decisions/dec-002-consolidate-scripts.md) | Consolidate 20+ scripts into unified CLI | Accepted | 2026-04-01 |
| [DEC-003](backlog/tasks/task-003-upgrade-jekyll-4.md) | Upgrade to Jekyll 4.x | Proposed | 2026-04-01 |
| [DEC-004](backlog/tasks/task-004-jekyll-generators.md) | Implement Jekyll Generator Plugins | Proposed | 2026-04-01 |

---

## Active Backlog (Architectural Modernization)

These tasks are derived from recent architectural reviews to improve system maintainability and performance.

| Task ID | Title | Status | Priority |
| :--- | :--- | :--- | :--- |
| [task-001](backlog/tasks/task-001-modernize-build-pipeline.md) | Move build to GHA & ignore `_site` | To Do | High |
| [task-002](backlog/tasks/task-002-consolidate-scripts.md) | Consolidate scripts into Rakefile/CLI | To Do | High |
| [task-003](backlog/tasks/task-003-upgrade-jekyll-4.md) | Upgrade to Jekyll 4.x | To Do | Medium |
| [task-004](backlog/tasks/task-004-jekyll-generators.md) | Implement Jekyll Generator Plugins | To Do | High |
| [task-005](backlog/tasks/task-005-template-logic-separation.md) | Separate templates from generator logic | To Do | Medium |
| [task-006](backlog/tasks/task-006-declarative-validation.md) | Implement declarative data validation | To Do | Medium |
| [task-007](backlog/tasks/task-007-scss-migration.md) | Convert CSS to SCSS/SASS | To Do | Medium |
| [task-008](backlog/tasks/task-008-generator-unit-tests.md) | Add unit tests for generators | To Do | High |
| [task-009](backlog/tasks/task-009-transcript-pipeline-consolidation.md) | Consolidate Transcript Pipeline | To Do | Medium |
| [task-010](backlog/tasks/task-010-image-optimization.md) | Implement Image Optimization | To Do | Low |

---

## Maintenance & Content Backlog

Consolidated from legacy `docs/tasks.md`.

### Archive Completeness
- **Transcript Coverage Expansion:** Continue onboarding new source transcript files as they are produced.
- **Metadata Completion:** Fill missing `video_assets` fields (`description`, `topic`) in prioritized batches.
- **Interview Topics:** Fill missing `interviews` `topic` values where conference/community context is known.

### Quality & SEO
- **SEO Metadata Quality:** Monitor `tmp/seo-metadata-report.json` and tune head-level title/description normalization.
- **Structured Data Object Model:** Continue monitoring and tuning richer entity relationships in JSON-LD.
- **Validator Hardening:** Continue periodic validator hardening where drift is indicated.

---

## Documentation

All documentation is consolidated under the `backlog/docs/` directory.

- **[Backlog Structure Overview](backlog/docs/backlog-structure.md):** Explanation of the task and decision system.
- **[Workflow Guide](backlog/docs/workflow-guide.md):** Working with site data and the build pipeline.
- **[Architecture](backlog/docs/architecture/):** High-level system design and data models.
- **[Retrospectives](backlog/docs/retrospectives/):** Historical implementation cycle reviews.
- **[Wayback Archives](backlog/docs/wayback/):** Documentation on imported content from various sources.

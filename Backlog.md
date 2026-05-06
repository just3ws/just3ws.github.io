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

## Active Backlog (System Transformation - Phase 2)

These tasks are derived from the 2026-04-07 System Transformation Plan to harden the site into a senior technical leadership platform.

| Task ID | Title | Status | Priority |
| :--- | :--- | :--- | :--- |
| [T-1000](backlog/tasks/t-1000-consolidate-json-ld.md) | Consolidate JSON-LD Templating | To Do | High |
| [T-1010](backlog/tasks/t-1010-normalize-resume-yaml.md) | Normalize Resume YAML Schema | To Do | High |
| [T-1020](backlog/tasks/t-1020-signal-grouping-engine.md) | Implement Signal Grouping Engine | To Do | Medium |
| [T-1030](backlog/tasks/t-1030-export-parity.md) | Enforce Export Parity (JSON/TXT/HTML) | To Do | High |
| [T-1040](backlog/tasks/t-1040-css-token-audit.md) | Clean up and Audit CSS Tokens | To Do | Low |

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
| [task-011](backlog/completed/task-011-repair-broken-transcript-igor-polevoy.md) | Repair Broken Transcript (Igor Polevoy) | Done | High |
| [task-021](backlog/completed/task-021-repair-broken-transcript-chet-and-ron.md) | Repair Broken Transcript (Chet & Ron) | Done | High |
| [task-022](backlog/tasks/task-022%20-%20Repair-Broken-Transcript-%E2%80%94-Ethan-Gunderson-Ryan-Briones-gathers-us.md) | Repair Broken Transcript (Ethan & Ryan) | To Do | High |
| [task-023](backlog/tasks/task-023%20-%20Repair-Broken-Transcript-%E2%80%94-Jonathan-Baltz-jonathan-baltz-chicagowebconf-2012.md) | Repair Broken Transcript (Jonathan Baltz) | To Do | High |
| [task-024](backlog/tasks/task-024%20-%20Repair-Broken-Transcript-%E2%80%94-Dave-Hoover-geekfest-geekfest.md) | Repair Broken Transcript (Dave Hoover) | To Do | High |
| [task-025](backlog/tasks/task-025%20-%20Repair-Broken-Transcript-%E2%80%94-Ashe-Dryden-ashe-dryden-general.md) | Repair Broken Transcript (Ashe Dryden) | To Do | High |

---

## Archive Canonical Review (Phase 1)

This milestone tracks the canonical review and optimization of all 197 interview transcripts according to the `TRANSCRIPTION_PROMPT.md` protocol.

| Task ID | Title | Status | Priority |
| :--- | :--- | :--- | :--- |
| [task-027](backlog/tasks/task-027%20-%20Canonical-Review-%E2%80%94-Aaron-Bedra-aaron-bedra-general.md) | Canonical Review (Aaron Bedra) | To Do | Medium |
| [task-026](backlog/tasks/task-026%20-%20Canonical-Review-%E2%80%94-Aaron-Holbrook-aaron-holbrook-general.md) | Canonical Review (Aaron Holbrook) | To Do | Medium |
| [task-029](backlog/tasks/task-029%20-%20Canonical-Review-%E2%80%94-Andrea-Magnorsky-andrea-magnorsky-general.md) | Canonical Review (Andrea Magnorsky) | To Do | Medium |
| [task-030](backlog/tasks/task-030%20-%20Canonical-Review-%E2%80%94-Angelique-Martin-angelique-martin-general.md) | Canonical Review (Angelique Martin) | To Do | Medium |
| [task-028](backlog/tasks/task-028%20-%20Canonical-Review-%E2%80%94-Arthur-Kay-arthur-kay-general.md) | Canonical Review (Arthur Kay) | To Do | Medium |
| [task-101](backlog/tasks/task-101%20-%20Canonical-Review-%E2%80%94-Angelique-Martin-interview-with-angelique-martin-general.md) | Canonical Review (Angelique Martin) | To Do | Medium |
| [task-102](backlog/tasks/task-102%20-%20Canonical-Review-%E2%80%94-Dickinson-Beehler-interview-with-dickinson-beehler.md) | Canonical Review (Dickinson & Beehler) | To Do | Medium |
| [task-103](backlog/tasks/task-103%20-%20Canonical-Review-%E2%80%94-Dave-Thomas-dave-thomas-goto-conference-and-community.md) | Canonical Review (Dave Thomas) | To Do | Medium |
| [task-104](backlog/tasks/task-104%20-%20Canonical-Review-%E2%80%94-Gil-Tene-interview-with-gil-tene.md) | Canonical Review (Gil Tene) | To Do | Medium |
| [task-105](backlog/tasks/task-105%20-%20Canonical-Review-%E2%80%94-Chris-Whitaker-interview-with-chris-whitaker-general.md) | Canonical Review (Chris Whitaker) | To Do | Medium |
| [task-106](backlog/tasks/task-106%20-%20Canonical-Review-%E2%80%94-Dean-Wampler-interview-with-dean-wampler-general.md) | Canonical Review (Dean Wampler) | To Do | Medium |
| [task-107](backlog/tasks/task-107%20-%20Canonical-Review-%E2%80%94-Hadi-Hariri-interview-with-hadi-hariri-general.md) | Canonical Review (Hadi Hariri) | To Do | Medium |
| [task-108](backlog/tasks/task-108%20-%20Canonical-Review-%E2%80%94-Carina-C.-Zona-interview-with-carina-c-zona-general.md) | Canonical Review (Carina C. Zona) | To Do | Medium |
| [task-109](backlog/tasks/task-109%20-%20Canonical-Review-%E2%80%94-Zinni-Buda-Howe-interview-with-zinni-buda-howe.md) | Canonical Review (Zinni, Buda, Howe) | To Do | Medium |
| [task-110](backlog/tasks/task-110%20-%20Canonical-Review-%E2%80%94-Eric-Kingery-interview-with-eric-kingery-general.md) | Canonical Review (Eric Kingery) | To Do | Medium |
| [task-111](backlog/tasks/task-111%20-%20Canonical-Review-%E2%80%94-Giles-Bowkett-interview-with-giles-bowkett-general.md) | Canonical Review (Giles Bowkett) | To Do | Medium |
| [task-112](backlog/tasks/task-112%20-%20Canonical-Review-%E2%80%94-Dan-North-interview-with-dan-north-general.md) | Canonical Review (Dan North) | To Do | Medium |
| [task-113](backlog/tasks/task-113%20-%20Canonical-Review-%E2%80%94-Anna-Lear-interview-with-anna-lear-general.md) | Canonical Review (Anna Lear) | To Do | Medium |
| [task-114](backlog/tasks/task-114%20-%20Canonical-Review-%E2%80%94-James-Edward-Gray-II-interview-with-james-edward-gray-ii.md) | Canonical Review (James Edward Gray II) | To Do | Medium |
| [task-115](backlog/tasks/task-115%20-%20Canonical-Review-%E2%80%94-Giles-Bowkett-Rails-interview-with-giles-bowkett-rails.md) | Canonical Review (Giles Bowkett - Rails) | To Do | Medium |
| [task-116](backlog/tasks/task-116%20-%20Canonical-Review-%E2%80%94-Charley-Baker-interview-with-charley-baker-general.md) | Canonical Review (Charley Baker) | To Do | Medium |

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

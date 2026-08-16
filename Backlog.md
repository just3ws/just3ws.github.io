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

## Active Backlog (Site Enhancement & Career Alignment DAG)

| Task ID | Title | Status | Priority |
| :--- | :--- | :--- | :--- |
| [T-DAG-1](backlog/completed/t-dag-1-career-archive-cross-linking.md) | Canonical Career-to-Archive Cross-Linking Model | Done | High |
| [T-DAG-2](backlog/completed/t-dag-2-position-page-generator.md) | Position Detail Page Generator & Metadata Enhancement | Done | High |
| [T-DAG-3](backlog/completed/t-dag-3-speaker-directory-enrichment.md) | Speaker Directory & Voice Matrix Annotations | Done | High |
| [T-DAG-4](backlog/completed/t-dag-4-active-state-layout-audit.md) | Contextual Active State & Uniform Layout Audit | Done | High |
| [T-DAG-5](backlog/completed/t-dag-5-topic-architectural-theme-filters.md) | Topic & Architectural Theme Surface Filters | Done | High |
| [T-DAG-6](backlog/completed/t-dag-6-multiformat-export-alignment.md) | Multi-Format Export Package Alignment (/exports/) | Done | High |
| [T-DAG-7](backlog/completed/t-dag-7-ci-playwright-validation-suite.md) | Automated CI & Playwright Validation Suite | Done | Medium |
| [T-DAG-8](#) | System Cartography Case Studies (OneMain / EMR-Bear) | Done | High |
| [T-DAG-9](#) | Resume Layout & 50/50 Seam Alignment Audit | Done | High |

## Active Backlog (System Transformation - Phase 2)

These tasks are derived from the System Transformation Plan to harden the site into a senior technical leadership platform.

| Task ID | Title | Status | Priority |
| :--- | :--- | :--- | :--- |
| [T-1000](backlog/completed/t-1000-consolidate-json-ld.md) | Consolidate JSON-LD Templating | Done | High |
| [T-1010](backlog/completed/t-1010-normalize-resume-yaml.md) | Normalize Resume YAML Schema | Done | High |
| [T-1020](backlog/completed/t-1020-signal-grouping-engine.md) | Implement Signal Grouping Engine | Done | Medium |
| [T-1030](backlog/completed/t-1030-export-parity.md) | Enforce Export Parity (JSON/TXT/HTML) | Done | High |
| [T-1040](backlog/completed/t-1040-css-token-audit.md) | Clean up and Audit CSS Tokens | Done | Low |

## Active Backlog (Architectural Modernization)

These tasks are derived from recent architectural reviews to improve system maintainability and performance.

| Task ID | Title | Status | Priority |
| :--- | :--- | :--- | :--- |
| [task-001](backlog/tasks/task-001-modernize-build-pipeline.md) | Move build to GHA & ignore `_site` | Done | High |
| [task-002](backlog/completed/task-002-consolidate-scripts.md) | Consolidate scripts into Rakefile/CLI | Done | High |
| [task-003](backlog/completed/task-003-upgrade-jekyll-4.md) | Upgrade to Jekyll 4.x | Done | Medium |
| [task-004](backlog/completed/task-004-jekyll-generators.md) | Implement Jekyll Generator Plugins | Done | High |
| [task-005](backlog/tasks/task-005-template-logic-separation.md) | Separate templates from generator logic | Done | Medium |
| [task-006](backlog/completed/task-006-declarative-validation.md) | Implement declarative data validation | Done | Medium |
| [task-007](backlog/tasks/task-007-scss-migration.md) | Convert CSS to SCSS/SASS | Done | Medium |
| [task-008](backlog/completed/task-008-generator-unit-tests.md) | Add unit tests for generators | Done | High |
| [task-009](backlog/tasks/task-009-transcript-pipeline-consolidation.md) | Consolidate Transcript Pipeline | Done | Medium |
| [task-010](backlog/completed/task-010-image-optimization.md) | Implement Image Optimization | Done | Low |
| [task-011](backlog/completed/task-011-repair-broken-transcript-igor-polevoy.md) | Repair Broken Transcript (Igor Polevoy) | Done | High |
| [task-021](backlog/completed/task-021-repair-broken-transcript-chet-and-ron.md) | Repair Broken Transcript (Chet & Ron) | Done | High |
| [task-022](backlog/tasks/task-022%20-%20Repair-Broken-Transcript-%E2%80%94-Ethan-Gunderson-Ryan-Briones-gathers-us.md) | Audit & Queue Transcript (Ethan & Ryan) | Done | High |
| [task-023](backlog/tasks/task-023%20-%20Repair-Broken-Transcript-%E2%80%94-Jonathan-Baltz-jonathan-baltz-chicagowebconf-2012.md) | Audit & Queue Transcript (Jonathan Baltz) | Done | High |
| [task-024](backlog/tasks/task-024%20-%20Repair-Broken-Transcript-%E2%80%94-Dave-Hoover-geekfest-geekfest.md) | Audit & Queue Transcript (Dave Hoover) | Done | High |
| [task-025](backlog/tasks/task-025%20-%20Repair-Broken-Transcript-%E2%80%94-Ashe-Dryden-ashe-dryden-general.md) | Audit & Queue Transcript (Ashe Dryden) | Done | High |

---

## Archive Canonical Review (Phase 1)

This milestone tracks the canonical review and optimization of all 197 interview transcripts according to the `TRANSCRIPTION_PROMPT.md` protocol.

| Task ID | Title | Status | Priority |
| :--- | :--- | :--- | :--- |
| [task-027](backlog/completed/task-027-canonical-review-aaron-bedra.md) | Canonical Review (Aaron Bedra) | Done | Medium |
| [task-026](backlog/completed/task-026-canonical-review-aaron-holbrook.md) | Canonical Review (Aaron Holbrook) | Done | Medium |
| [task-029](backlog/completed/task-029-canonical-review-andrea-magnorsky.md) | Canonical Review (Andrea Magnorsky) | Done | Medium |
| [task-030](backlog/completed/task-030-canonical-review-angelique-martin.md) | Canonical Review (Angelique Martin) | Done | Medium |
| [task-050](backlog/completed/task-050-canonical-review-jen-myers.md) | Canonical Review (Jen Myers) | Done | Medium |
| [task-051](backlog/completed/task-051-canonical-review-james-edward-gray-ii.md) | Canonical Review (James Edward Gray II) | Done | Medium |
| [task-052](backlog/completed/task-052-canonical-review-ken-auer.md) | Canonical Review (Ken Auer) | Done | Medium |
| [task-053](backlog/completed/task-053-canonical-review-giles-bowkett.md) | Canonical Review (Giles Bowkett author "Rails) | Done | Medium |
| [task-054](backlog/completed/task-054-canonical-review-hadi-hariri.md) | Canonical Review (Hadi Hariri) | Done | Medium |
| [task-055](backlog/completed/task-055-canonical-review-chris-whitaker.md) | Canonical Review (Chris Whitaker) | Done | Medium |
| [task-056](backlog/completed/task-056-canonical-review-katrina-owen.md) | Canonical Review (Katrina Owen) | Done | Medium |
| [task-057](backlog/completed/task-057-canonical-review-matt-ruby.md) | Canonical Review (Matt Ruby creator of Vooza) | Done | Medium |
| [task-058](backlog/completed/task-058-canonical-review-kresten-thorup.md) | Canonical Review (Kresten Thorup) | Done | Medium |
| [task-059](backlog/completed/task-059-canonical-review-mandi-walls.md) | Canonical Review (Mandi Walls) | Done | Medium |
| [task-060](backlog/completed/task-060-canonical-review-dean-wampler.md) | Canonical Review (Dean Wampler) | Done | Medium |
| [task-028](backlog/completed/task-028-canonical-review-arthur-kay.md) | Canonical Review (Arthur Kay) | Done | Medium |
| [task-101](backlog/completed/task-101-canonical-review-angelique-martin-duplicate.md) | Canonical Review (Angelique Martin - Duplicate) | Done | Medium |
| [task-102](backlog/completed/task-102-canonical-review-dickinson-beehler.md) | Canonical Review (Dickinson & Beehler) | Done | Medium |
| [task-103](backlog/completed/task-103-canonical-review-dave-thomas.md) | Canonical Review (Dave Thomas) | Done | Medium |
| [task-104](backlog/completed/task-104-canonical-review-gil-tene.md) | Canonical Review (Gil Tene) | Done | Medium |
| [task-105](backlog/completed/task-105-canonical-review-chris-whitaker.md) | Canonical Review (Chris Whitaker) | Done | Medium |
| [task-106](backlog/completed/task-106-canonical-review-dean-wampler.md) | Canonical Review (Dean Wampler) | Done | Medium |
| [task-107](backlog/completed/task-107-canonical-review-hadi-hariri.md) | Canonical Review (Hadi Hariri) | Done | Medium |
| [task-108](backlog/completed/task-108-canonical-review-carina-c-zona.md) | Canonical Review (Carina C. Zona) | Done | Medium |
| [task-109](backlog/completed/task-109-canonical-review-zinni-buda-howe.md) | Canonical Review (Zinni, Buda, Howe) | Done | Medium |
| [task-110](backlog/completed/task-110-canonical-review-eric-kingery.md) | Canonical Review (Eric Kingery) | Done | Medium |
| [task-111](backlog/tasks/task-111%20-%20Canonical-Review-%E2%80%94-Giles-Bowkett-interview-with-giles-bowkett-general.md) | Canonical Review (Giles Bowkett) | Done | Medium |
| [task-112](backlog/completed/task-112-canonical-review-dan-north.md) | Canonical Review (Dan North) | Done | Medium |
| [task-113](backlog/completed/task-113-canonical-review-anna-lear.md) | Canonical Review (Anna Lear) | Done | Medium |
| [task-114](backlog/completed/task-114-canonical-review-james-edward-gray-ii.md) | Canonical Review (James Edward Gray II) | Done | Medium |
| [task-115](backlog/tasks/task-115%20-%20Canonical-Review-%E2%80%94-Giles-Bowkett-Rails-interview-with-giles-bowkett-rails.md) | Canonical Review (Giles Bowkett - Rails) | Done | Medium |
| [task-116](backlog/completed/task-116-canonical-review-charley-baker.md) | Canonical Review (Charley Baker) | Done | Medium |

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

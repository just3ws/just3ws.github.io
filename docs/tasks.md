---
layout: minimal
title: Tasks
description: Prioritized technical tasks for pipeline reliability, data integrity, and SEO hardening.
breadcrumb: Tasks
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Tasks

This task list is prioritized to protect pipeline correctness first, then data integrity, then non-visual SEO improvements.

## Historical Context

### Theme 1: Build and CI reliability foundation
- Standardized the pipeline around `bin/pipeline` as the canonical entrypoint.
- Removed deprecated wrapper scripts and aligned docs/CI to canonical commands.
- Kept runtime parity checks, resume artifact checks, and deterministic CI validation as hard gates.

### Theme 2: Data integrity and generation quality
- Added strong data validation for uniqueness and required fields.
- Normalized generated interview/video metadata to remove duplication and low-quality copy.
- Kept data checks in the CI path to fail fast on structural regressions.

### Theme 3: SEO/semantic policy hardening
- Enforced explicit canonical semantics (`/` as root resume route, `/home/` as homepage route).
- Added output validators for canonical/indexability and semantic/schema coverage.
- Added CI artifacts for observability (`seo-metadata-report`, `schema-coverage-report`).

### Theme 4: Build-time last-modified workflow
- Implemented build-time last-modified generation and graduated it from experimental to default behavior.
- Added verification checks to ensure rendered `dateModified` parity across article pages.
- Established template/data contract to keep metadata generation and rendered output in sync.

## Retrospective Process

- Use the standard retrospective format in `docs/retrospectives/index.md` for each meaningful implementation cycle.
- Every retrospective must explicitly capture:
  - what worked
  - what did not work
  - what went well
  - what could be better
  - process improvements with owners, checkpoints, and validation methods
- The next retrospective must evaluate prior improvements with status (`upheld`, `improved`, `maintained`, `regressed`, `dropped`) and evidence.

## Critical Constraint

- Root route semantics: `/` is the default root route and resume page; `/home/` is homepage content.
- Resume artifacts (`/`, `/resume.txt`, `/resume.md`) must render correctly on every build.
- Any task affecting resume or homepage routing/canonical behavior must include automated pass/fail criteria.

## Current Operating Plan

### Phase 1: Configuration + Pipeline Correctness
- Status: complete and stable.
- Ongoing expectation: keep runtime parity and resume guardrails as blocking CI checks.

### Phase 2: Structural Integrity of Data
- Status: complete and stable.
- Ongoing expectation: keep uniqueness/integrity checks in the default CI path.

### Phase 3: Technical SEO Optimizations (Non-Visual)
- Status: implemented, now in maintenance mode.
- Ongoing expectation: preserve canonical/schema contracts and artifact-based observability.

## Logged Recommendations (Current)

1. Keep plan text synchronized with implementation in the same commit series.
2. Preserve sitemap-driven smoke scope and avoid reintroducing hardcoded route lists.
3. Keep `SITEMAP_MAX_URLS=100` unless explicit publication-scope expansion is approved.
4. If publication model changes, define canonical/robots policy first, then implement validation.
5. Keep JSON-LD required-field rules in lockstep with template/schema changes.

## Short-Term Backlog

1. Continue periodic validator hardening only where reports indicate drift.
2. Keep command/documentation grammar aligned to `bin/pipeline` subcommands.
3. Track retrospective follow-through as first-class process work, not post-hoc cleanup.

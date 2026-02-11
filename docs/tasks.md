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
3. Keep `SITEMAP_MAX_URLS=5000` unless explicit publication-scope expansion is approved.
4. If publication model changes, define canonical/robots policy first, then implement validation.
5. Keep JSON-LD required-field rules in lockstep with template/schema changes.

## Short-Term Backlog

1. Transcript Coverage Expansion
   - Status: deferred (work in progress).
   - Notes: transcript onboarding should continue as new source transcript files are produced; avoid blocking other metadata/SEO work on transcript completeness.

2. Metadata Completion at Scale (Active Candidate)
   - Fill missing `video_assets` fields (`description`, `topic`) in prioritized batches.
   - Fill missing `interviews` `topic` values where conference/community context is known.
   - Keep topic/description conventions consistent with canonical slugs and transcript-derived phrasing.

3. SEO Metadata Quality Cleanup (Active Candidate)
   - Reduce `title_outliers`, `desc_outliers`, `duplicate_titles`, and `duplicate_descs` reported by `tmp/seo-metadata-report.json`.
   - Prioritize canonical pages first (`/`, `/home/`, `/interviews/`, `/videos/`, high-traffic interview/video routes).
   - Preserve current canonical/indexability contracts while improving metadata quality.

4. Data Model Documentation Alignment (Active Candidate)
   - Update docs to reflect per-file transcripts in `_data/transcripts/*.yml` as canonical transcript storage.
   - Clarify `_data/transcripts.yml` is legacy/placeholder and not the active content source.
   - Keep docs synchronized with generators/templates in the same commit series.

5. Ongoing Maintenance
   - Continue periodic validator hardening only where reports indicate drift.
   - Keep command/documentation grammar aligned to `bin/pipeline` subcommands.
   - Track retrospective follow-through as first-class process work, not post-hoc cleanup.

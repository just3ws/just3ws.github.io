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

## Progress Log

- 2026-02-09: `P1-01` implemented.
  - Runtime parity checks added to `bin/cibuild` (Ruby + Bundler).
  - Commit: `756f258`, follow-up parser fix `959d6ef`.
- 2026-02-09: `P1-02` implemented.
  - Resume render guardrails added to `bin/cibuild`.
  - Commit: `5f4892d`.
- 2026-02-09: `P1-03` implemented.
  - Manual sitemap override removed; sitemap floor check added to `bin/cibuild`.
  - Commit: `364de44`, guardrail in `5f4892d`.
- 2026-02-09: `P1-04` implemented.
  - Playwright smoke script added and wired into CI.
  - Commits: `fc39521`, `77dccbc`, `7983f61`.
- 2026-02-09: CI workflow corrected to run full site validation.
  - Broken missing-script validation replaced with `bin/cibuild` on Ruby `3.4.8`.
  - Commit: `18bee27`.
- 2026-02-09: `P2-01` implemented.
  - Normalized generated interview/video SEO metadata to remove repeated phrasing.
  - Commit: `fb865d3`.
- 2026-02-09: `P2-02` implemented.
  - Added canonical ID and slug collision validation (`bin/validate_data_dedupe.rb`) in `bin/cibuild`.
  - Commit: `723be78e`.
- 2026-02-09: `P2-03` implemented.
  - Added required-field/reference validation (`bin/validate_data_required_fields.rb`) in `bin/cibuild`.
  - Fixed orphan `interview_id` references for two non-interview assets.
  - Commit: `0a00a809`.
- 2026-02-09: Build output hygiene follow-up.
  - Excluded AGENTS instructions from published-site checks and escaped literal Liquid in tasks doc.
  - Commits: `5b680d98`, `29d9ebd5`.
- 2026-02-09: `P3-01` implemented.
  - Added deterministic canonical/OG/Twitter head tags in shared layout and enforced production URL context in build pipeline.
  - Commit: `67ec144c`.
- 2026-02-09: `P3-02` implemented.
  - Added SEO output validator for canonical host coverage and redirect/noindex hygiene.
  - Commit: `dc1fd9a2`.
- 2026-02-09: `P3-03` implemented.
  - Scoped `Person` schema to resume pages; added `Article` schema for posts and `VideoObject` schema for video pages.
  - Commit: `34d113ff`.
- 2026-02-09: `P3-04` implemented.
  - Added metadata length clamping for generated interview/video pages and SEO quality reporting in pipeline output.
  - Commit: `f59c4663`.
- 2026-02-09: Legacy-path deprecation policy applied.
  - Resume (`/`) set as sole indexable canonical target; legacy pages now default to `noindex,nofollow` with canonical pointing to resume.
  - Build checks updated for resume-canonical mode behavior and reporting.
  - Commit: `abdcefa6`.
- 2026-02-09: Resume-canonical mode made a hard CI gate.
  - Added output validator to fail builds unless every page canonical resolves to root resume URL and only `index.html` remains indexable.
  - Commit: `3bbc750b`.
- 2026-02-09: Smoke checks expanded for legacy-path deprecation behavior.
  - Playwright smoke now asserts legacy routes (`/history/`, `/writing/`, `/interviews/`, `/videos/`) keep root canonical and `noindex`.
  - Commit: `7c6c3e83`.
- 2026-02-09: CI reliability and smoke stability fixes.
  - Added Linux platform to lockfile for GitHub-hosted Ubuntu runners and stabilized Playwright smoke session/cache handling.
  - Commits: `edb8a7d3`, `507f968a`, `2766a47b`, `1b1b767b`.
- 2026-02-09: Legacy-path hard deprecation enabled.
  - Non-resume/noindex legacy pages now immediately redirect to resume root while preserving root canonical target policy.
  - Playwright smoke now validates legacy route redirect behavior.
  - Commit: `7177c97d`.

## Critical Constraint

- The resume (`/`, `/history/`, `/resume.txt`, `/resume.md`) is the highest-priority surface and must render correctly on every build.
- Any task that can affect resume rendering must include automated checks and explicit pass/fail criteria.

## Phase 1: Configuration + Pipeline Correctness

### P1-01 Lock runtime parity for local/CI builds
- Priority: P0
- Goal: Ensure Jekyll builds use Ruby `3.4.8` and Bundler `4.0.3` consistently.
- Tasks:
  - Update CI workflow to enforce `.tool-versions` runtime.
  - Add explicit runtime/bundler preflight in `bin/cibuild`.
- Acceptance criteria:
  - `./bin/cibuild` succeeds in CI and on clean local setup without falling back to system Ruby.

### P1-02 Resume render guardrail in CI
- Priority: P0
- Goal: Prevent regressions on critical resume pages.
- Tasks:
  - Add build-time assertions for: `/index.html`, `/history/index.html`, `/resume.txt`, `/resume.md`.
  - Verify each exists and contains expected identity markers (`Mike Hall`, `Staff Software Engineer`).
- Acceptance criteria:
  - CI fails if any critical resume artifact is missing or malformed.

### P1-03 Preserve generated sitemap correctness in pipeline
- Priority: P0
- Goal: Ensure sitemap represents the full canonical indexable set.
- Tasks:
  - Remove or replace manual `sitemap.xml` that currently shadows plugin output.
  - Add CI check asserting sitemap URL count is above a configured threshold.
- Acceptance criteria:
  - Built sitemap includes archive pages (interviews/videos/etc.), not only top-level + posts.

### P1-04 Add browser smoke check for critical routes
- Priority: P1
- Goal: Catch runtime regressions that static checks can miss.
- Tasks:
  - Add Playwright smoke checks for `/`, `/history/`, `/writing/`, `/interviews/`, `/videos/`.
  - Assert HTTP 200, visible `<h1>`, and non-empty `<title>`.
  - Assert `/` stays indexable while legacy routes remain `noindex` and canonicalize to root resume URL.
- Acceptance criteria:
  - Required smoke check passes before merge.

## Phase 2: Structural Integrity of Data

### P2-01 Metadata quality normalization for generated pages
- Priority: P1
- Goal: Remove low-quality generated copy and duplication patterns.
- Tasks:
  - Eliminate duplicated phrasing like `Interview with Interview with ...`.
  - Normalize title/description generators for interview and video pages.
- Acceptance criteria:
  - No generated page includes repeated prefixes in title/description.

### P2-02 Canonical identity and dedupe checks
- Priority: P1
- Goal: Maintain one stable identity per interview/video asset and prevent accidental duplicates.
- Tasks:
  - Add validation for unique IDs across `_data/interviews.yml` and `_data/video_assets.yml`.
  - Add check for duplicate slugs generated from different records.
- Acceptance criteria:
  - CI fails on duplicate IDs/slugs.

### P2-03 Data integrity lints for required fields
- Priority: P2
- Goal: Guarantee minimum viable metadata for pages and structured data.
- Tasks:
  - Define required keys per record type (title, description, platform/source ID, date context).
  - Enforce via script run in `bin/cibuild`.
- Acceptance criteria:
  - CI fails on missing required fields.

## Phase 3: Technical SEO Optimizations (Non-Visual)

### P3-01 Enable standard SEO head generation
- Priority: P0
- Goal: Emit canonical and social metadata consistently without visual changes.
- Tasks:
  - Add shared canonical/OG/Twitter head generation to the minimal layout path.
  - Keep existing custom fields only where needed and non-conflicting.
- Acceptance criteria:
  - Canonical present on indexable pages.
  - `og:title`, `og:description`, and Twitter card tags emitted consistently.

### P3-02 Canonical strategy and redirect hygiene
- Priority: P1
- Goal: Ensure one canonical URL per resource and correct treatment of redirects.
- Tasks:
  - Keep redirect-only pages `noindex`.
  - Verify canonical points to final preferred URL for indexable pages.
- Acceptance criteria:
  - No canonical loops/conflicts; redirects do not appear as canonical destinations unless intended.

### P3-03 Schema alignment by page type
- Priority: P1
- Goal: Keep structured data accurate and context-specific.
- Tasks:
  - Keep `Person` schema on resume-oriented pages.
  - Emit `Article` for writing posts and `VideoObject` for video asset pages.
- Acceptance criteria:
  - Structured data type matches page intent for sampled critical routes.

### P3-04 Metadata length and duplication budgets
- Priority: P2
- Goal: Improve snippet quality at scale.
- Tasks:
  - Add generator constraints for title/description length windows.
  - Add report of duplicate titles/descriptions in CI output.
- Acceptance criteria:
  - Outlier/duplication counts trend down release over release.

## Logged Recommendations (Current)

1. Remove manual `sitemap.xml` override and rely on generated sitemap output.
2. Add SEO tag generation in shared layout (`_layouts/minimal.html`) to restore canonical + OG coverage.
3. Add CI assertions specifically for resume page existence/content because resume is the critical asset.
4. Add deterministic runtime checks in pipeline to prevent accidental system Ruby/Bundler usage.
5. Normalize generated interview/video metadata text and add dedupe checks to prevent repeated or low-quality snippets.
6. Keep SEO changes strictly technical/head-level; do not alter visual layout or page content structure unless explicitly requested.
7. When resume-only mode remains active, move legacy routes from soft deprecation (`200 + noindex`) to explicit deprecation (`301` to `/` or `410`) to reduce crawl waste and strengthen canonical clarity.
8. Add a sitemap strict-mode gate that fails when URL count exceeds the allowed resume-only threshold to prevent accidental recrawl expansion.
9. Add a small SEO artifact in CI (e.g., JSON summary from validators) and upload it for trend tracking across commits.
10. If true HTTP status redirects are required (instead of HTML/JS redirects), add an edge/CDN redirect layer in front of GitHub Pages for `/history/*`, `/writing/*`, `/interviews/*`, and `/videos/*`.

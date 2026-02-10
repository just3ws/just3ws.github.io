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

- 2026-02-10: Pure Jekyll runtime migration implemented (core).
  - Removed `github-pages` gem and pinned explicit Jekyll/plugin gems in `Gemfile`.
  - Added explicit `jekyll-sitemap` plugin registration in `_config.yml`.
  - Lockfile refreshed with local dependency resolution (`bundle lock --local`) due network-restricted environment.
- 2026-02-10: Experimental build-time last-modified path implemented.
  - Added `bin/generate_last_modified.rb` (initially behind `EXPERIMENT_LAST_MODIFIED=1` feature flag).
  - Wired generation into `bin/pipeline build` before Jekyll render.
  - `Article` JSON-LD now consumes generated metadata with safe fallback to existing values.
- 2026-02-10: Build-time last-modified graduated from experimental to standard pipeline behavior.
  - Removed feature flag; metadata now generated on every build.
  - Added `bin/validate_last_modified_output.rb` to verify post coverage and rendered `dateModified` parity across built article pages.
- 2026-02-10: Bin tool naming normalized with compatibility wrappers.
  - `build_interviews.rb` -> `sync_interview_asset_links.rb`
  - `generate_interview_group_pages.rb` -> `generate_interview_taxonomy_pages.rb`
  - `validate_data_dedupe.rb` -> `validate_data_uniqueness.rb`
  - `validate_data_required_fields.rb` -> `validate_data_integrity.rb`
  - `bin/pipeline` now calls normalized names; legacy script names remain as deprecation wrappers.
- 2026-02-10: Deprecated compatibility wrappers removed.
  - Removed: `bin/build_interviews.rb`, `bin/generate_interview_group_pages.rb`, `bin/validate_data_dedupe.rb`, `bin/validate_data_required_fields.rb`, `bin/cibuild`.
  - Canonical entrypoint is now `bin/pipeline`.
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
- 2026-02-09: SEO observability + sitemap budget gates improved.
  - CI now emits a machine-readable SEO metadata JSON report and uploads it as a workflow artifact.
  - Build now enforces a configurable sitemap URL budget (`SITEMAP_MAX_URLS`) as a hard gate.
  - Commits: `4e04d11c`, `da544667`.
- 2026-02-09: Sitemap-budget ratchet completed with CI checkpoints.
  - Generated interview/video/group pages now explicitly opt out of sitemap indexing.
  - Sitemap budget ratcheted in controlled steps from `600 -> 300 -> 100`, with GitHub Actions validation at each step.
  - Commits: `66bfefb1`, `c7aaf87b`, `c0391a9c`.
- 2026-02-09: Legacy-path maintenance pruning.
  - Removed layout-level legacy redirect mechanics and shifted smoke checks to sitemap-discovered published routes.
  - CI resume guardrails now focus on canonical resume artifacts (`/`, `resume.txt`, `resume.md`) without hardcoded legacy path dependency.
  - Commits: `5c62650d`, `0550432f`.
- 2026-02-09: Canonical semantics clarified for homepage vs root resume.
  - `/` remains the default root route and canonical resume page.
  - `/home/` is treated as homepage and now canonicalizes to itself.
  - Commit: `311e44b1`.
- 2026-02-09: Semantic/a11y quality gates expanded.
  - Smoke checks now enforce semantic landmarks and structured-data contracts for `/` and `/home/`.
  - Build pipeline now validates semantic output for all built HTML plus required `Person`/`VideoObject`/`Article` JSON-LD coverage and required schema fields.
  - Commits: `86356c9d`, `23722a79`, `5153ffca`.
- 2026-02-10: `P3-03` hardening follow-up implemented.
  - Semantic validator now enforces route-level schema contracts for `/` and `/home/`, and rejects placeholder values in required JSON-LD fields.
  - Commit: `9da40f4d`.
- 2026-02-10: `P3-05` implemented.
  - CI now emits a machine-readable schema coverage report and uploads it as a workflow artifact.
  - Commits: `9da40f4d`, `516f7465`.

## Retrospective (2026-02-09)

### What Went Well
- CI became deterministic and actionable via runtime parity, build gates, and clear failure messages.
- Resume-critical regressions are now guarded by explicit artifact/content checks in `bin/cibuild`.
- SEO policy became testable via canonical/indexability validators and report artifacts.
- Ratcheting strategy worked safely by using small commits and CI checkpoints.

### What Could Have Gone Better
- Earlier assumptions over-constrained canonical policy before homepage semantics were explicitly clarified.
- Task documentation drifted during rapid iteration and needed cleanup afterward.
- Playwright smoke reliability required multiple corrective iterations due to CI/runtime edge cases.

### Keep Doing
- Keep changes small, isolated, and commit-scoped with immediate CI validation.
- Keep checks derived from published state (sitemap-driven) rather than hardcoded historical route lists.
- Keep resume reliability as the first-order guardrail in every pipeline change.

### Stop Doing
- Stop encoding architecture assumptions without explicit policy confirmation.
- Stop hardcoding legacy route behavior into validation logic.
- Stop allowing task-plan text to lag behind implemented behavior.

## Retrospective (2026-02-10)

### Context Since Last Retro
- Scope reviewed: post-retro execution focused on practical path items only: stronger semantic-data enforcement and policy-text alignment.
- Commits in interval: `5153ffca` (required JSON-LD field validation), `dc4799f0` (tasks/policy alignment updates).
- CI outcomes in interval: `Build and Validate Site` passed (`21845300030`), GitHub Pages deploy passed (`21845299805`).

### Sequential Review Against 2026-02-09 Actions
1. Keep changes small, isolated, and commit-scoped with immediate CI validation.
   - Status: upheld.
   - Evidence: two narrowly scoped commits, each validated with full `./bin/cibuild` and remote CI.
2. Keep checks derived from published state (sitemap-driven) rather than hardcoded historical route lists.
   - Status: upheld.
   - Evidence: no reintroduction of hardcoded legacy path assertions; current checks remain sitemap/published-output oriented.
3. Keep resume reliability as the first-order guardrail in every pipeline change.
   - Status: upheld.
   - Evidence: resume guardrails unchanged and continuously exercised in `bin/cibuild` during both interval commits.
4. Stop encoding architecture assumptions without explicit policy confirmation.
   - Status: improved.
   - Evidence: docs alignment commit updated policy text to match implemented root/home semantics rather than inferred alternatives.
5. Stop hardcoding legacy route behavior into validation logic.
   - Status: maintained.
   - Evidence: semantic validator changes were schema-quality focused and did not add legacy-route coupling.
6. Stop allowing task-plan text to lag behind implemented behavior.
   - Status: improved.
   - Evidence: tasks doc now reflects required-field schema enforcement and removes already-completed recommendations.

### Interval Assessment
- Interval feel: short, high-signal, and stable.
- Progress quality: strong. Work converted one partially complete task into enforced CI behavior and reduced policy/documentation drift.
- Remaining pressure points: keep progress-log dates/entries synchronized as work crosses day boundaries, and continue treating docs alignment as same-series work for behavior changes.

## Retrospective Protocol

- Use the standard retrospective format in `docs/retrospectives/index.md` for every meaningful implementation cycle.
- Ensure each retrospective includes:
  - what worked
  - what did not work
  - what went well
  - what could be better
  - explicit process improvements with owners, checkpoints, and validation methods
- In the following retrospective, review prior improvements with status (`upheld`, `improved`, `maintained`, `regressed`, `dropped`) and evidence.

## Critical Constraint

- Root route semantics: `/` is the default root route and resume page; `/home/` is homepage content.
- Resume artifacts (`/`, `/resume.txt`, `/resume.md`) must render correctly on every build.
- Any task that can affect resume or homepage routing/canonical behavior must include automated pass/fail criteria.

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
  - Add build-time assertions for: `/index.html`, `/resume.txt`, `/resume.md`.
  - Verify each exists and contains expected identity markers (`Mike Hall`, `Staff Software Engineer`).
- Acceptance criteria:
  - CI fails if any critical resume artifact is missing or malformed.

### P1-03 Preserve generated sitemap correctness in pipeline
- Priority: P0
- Goal: Ensure sitemap reflects currently published crawl scope without accidental expansion.
- Tasks:
  - Keep generated content marked with explicit sitemap intent (`sitemap: false` for non-published archives).
  - Enforce sitemap URL budget with `SITEMAP_MAX_URLS` in CI.
  - Ensure root URL presence in sitemap as a hard requirement.
- Acceptance criteria:
  - CI fails if sitemap count exceeds budget or root URL entry is missing.

### P1-04 Add browser smoke check for critical routes
- Priority: P1
- Goal: Catch runtime regressions that static checks can miss.
- Tasks:
  - Discover smoke routes from built sitemap and validate each published route.
  - Assert HTTP 200, visible `<h1>`, and non-empty `<title>`.
  - Assert root route `/` canonical and robots behavior remains correct.
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
  - Keep canonical host constrained to `https://www.just3ws.com`.
  - Keep `/` canonicalized to root resume URL.
  - Keep `/home/` canonicalized to homepage URL.
- Acceptance criteria:
  - Canonical validation passes with explicit root/home semantics and no host drift.

### P3-03 Schema alignment by page type
- Priority: P1
- Goal: Keep structured data accurate and context-specific.
- Tasks:
  - Keep `Person` schema on resume-oriented pages.
  - Emit `Article` for writing posts and `VideoObject` for video asset pages.
  - Enforce required schema fields for each type during CI validation.
- Acceptance criteria:
  - Structured data type and required fields match page intent across generated output.

### P3-04 Metadata length and duplication budgets
- Priority: P2
- Goal: Improve snippet quality at scale.
- Tasks:
  - Add generator constraints for title/description length windows.
  - Add report of duplicate titles/descriptions in CI output.
- Acceptance criteria:
  - Outlier/duplication counts trend down release over release.

### P3-05 Structured-Data Quality Gates + Coverage Reporting
- Priority: P1
- Goal: Keep JSON-LD contracts durable, route-aware, and observable in CI.
- Tasks:
  - Enforce route contracts: `/` must expose valid `Person`; `/home/` must not expose `Person`.
  - Enforce required JSON-LD fields as non-empty and non-placeholder values.
  - Emit schema coverage report artifact with type counts and route contract status.
- Acceptance criteria:
  - CI fails on route contract drift or schema placeholder regressions.
  - CI uploads `schema-coverage-report` artifact on every run.

## Logged Recommendations (Current)

1. Keep plan text synchronized with implementation after every policy change (same commit series).
2. Preserve sitemap-driven smoke scope and avoid reintroducing hardcoded path lists.
3. Keep `SITEMAP_MAX_URLS` at `100` unless intentional publication-scope expansion is approved.
4. If publication model changes again, define canonical and robots policy first, then implement validation.
5. Keep JSON-LD required-field rules in lockstep with template/schema changes to avoid drift.

## Reboot Handoff (2026-02-10)

### Current State Snapshot
- Branch: `master` synced to `origin/master` after commit `01b7aeb0`.
- Resume-critical contract: active and passing in `bin/cibuild` (`/`, `/resume.txt`, `/resume.md` checks).
- Canonical/indexability policy: `/` canonical root resume, `/home/` canonical self + noindex; enforced by validators and smoke checks.
- Semantic/a11y policy: landmark checks + schema type/required-field/placeholder checks active in `bin/validate_semantic_output.rb`.
- CI observability artifacts:
  - `seo-metadata-report` (`tmp/seo-metadata-report.json`)
  - `schema-coverage-report` (`tmp/schema-coverage-report.json`)
- Latest verified runs:
  - Build and Validate Site: `21847820237` (success)
  - pages-build-deployment: `21847819770` (success)

### Plan Status
- Phase 1: complete and stable.
- Phase 2: complete and stable.
- Phase 3:
  - `P3-01` to `P3-05`: implemented.
  - Ongoing posture: maintenance/hardening, not net-new policy shifts.

### Reboot Sequence (First 30-60 Minutes)
1. Sync and verify baseline:
   - `git pull`
   - `./bin/cibuild`
   - confirm no local drift.
2. Confirm latest CI health on `master`:
   - check `Build and Validate Site`
   - check `pages-build-deployment`
3. Review artifacts from latest successful run:
   - `seo-metadata-report` for metadata outliers/duplication drift.
   - `schema-coverage-report` for schema type/route contract drift.
4. If all green, proceed only with scoped hardening tasks and same-series docs updates.

### Guardrails For Next Iteration
- Do not change root/home canonical semantics without explicit policy decision.
- Keep resume reliability checks as first-order, blocking gates.
- Keep new validation/reporting changes paired with docs/tasks updates in the same commit series.

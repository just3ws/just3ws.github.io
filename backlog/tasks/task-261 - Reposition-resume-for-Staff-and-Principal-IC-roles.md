---
id: TASK-261
title: Reposition resume for Staff and Principal IC roles
status: In Progress
assignee:
  - Codex
created_date: '2026-08-15 17:10'
updated_date: '2026-08-15 17:13'
labels: []
dependencies: []
documentation:
  - _data/resume/
  - resume.html
  - resume-minimal.html
  - resume-markdown.liquid
  - exports/resume.md
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Rewrite the public resume’s positioning and evidence so it presents Mike as a hands-on senior technical individual contributor focused on production systems, reliability, legacy modernization, cross-team technical leadership, and responsible AI leverage. Preserve formal employment facts and avoid unsupported claims. The resume should stop routing readers primarily toward people-management roles.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The primary headline and summary clearly target Staff or Principal technical IC work without presenting engineering management as the desired job family
- [ ] #2 Formal company names, job titles, employment dates, and factual accomplishments remain unchanged unless a correction is supported by existing repository evidence
- [ ] #3 Recent experience emphasizes hands-on system diagnosis, architecture, reliability, observability, modernization, and cross-team technical influence
- [ ] #4 Skills and ATS-facing content use coherent Staff or Principal IC terminology and retain relevant platform, backend, cloud, data, and AI keywords
- [ ] #5 Management experience remains visible as supporting organizational fluency without dominating the professional identity
- [ ] #6 Main resume, minimal resume, ATS content, history views, and generated exports build successfully with no schema or link regressions
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Keep `_data/resume` as the single source of truth for professional identity, SEO copy, summary, ATS keywords, capabilities, and role evidence; Jekyll pages and structured data must derive from it.
2. Rewrite the shared summary, ATS keywords, skills taxonomy, and recent-role copy so technical IC evidence leads while formal employment facts remain intact.
3. Keep management and community leadership as supporting organizational fluency rather than the primary target role.
4. Correct the generated Markdown export to consume the flat ATS skill list instead of serializing the structured skills hash, and make export validation load the expected identity from resume YAML rather than hardcoding it.
5. Regenerate all resume surfaces, run targeted resume/export checks followed by the project build and relevant tests, then inspect rendered desktop/mobile output and the final diff.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Context Hunter classification: L1 (bounded resume data and output-path change). Closest analog: the Staff-oriented resume immediately before commit 938eb491, combined with the current plain, evidence-first copy style from 5134d6e7.

Silent convention/risk: shared resume YAML fans out to root HTML, /resume.html, TXT, JSON, two Markdown outputs, JSON-LD, and generated position pages. Title assertions are hardcoded in bin/validate_exports.rb and tests/layout.spec.js. Existing untracked logs and playwright-report belong to the user and must remain untouched.

Scope boundary: /home/ and the product-marketing context still target Director roles. This task intentionally changes resume surfaces only; broader site positioning is a potential follow-up, not an implicit scope expansion.

User refinement: the resume must remain data-driven by Jekyll. Resume identity and SEO copy will live under `_data/resume`; root and resume pages, JSON-LD, exports, validators, and tests will consume generated data instead of becoming parallel sources of truth.
<!-- SECTION:NOTES:END -->

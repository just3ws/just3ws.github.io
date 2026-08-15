---
id: TASK-261
title: Reposition resume for Staff and Principal IC roles
status: Done
assignee:
  - Codex
created_date: '2026-08-15 17:10'
updated_date: '2026-08-15 18:15'
labels: []
dependencies: []
documentation:
  - _data/resume/
  - resume.html
  - resume-minimal.html
  - resume-markdown.liquid
  - exports/resume.md
modified_files:
  - .gitignore
  - AGENTS.md
  - CODEX.md
  - CONTEXT.md
  - _config.yml
  - _data/resume/ats.yml
  - _data/resume/leadership.yml
  - _data/resume/positions/emr-bear.yml
  - _data/resume/positions/onemain.yml
  - _data/resume/profile.yml
  - _data/resume/skills.yml
  - _data/resume/summary.yml
  - _includes/head/base.html
  - _includes/json-ld.html
  - _includes/resume/ats-content.html
  - _includes/resume/intro.html
  - _includes/resume/profile-header.html
  - _includes/schema-factory.html
  - _plugins/markdown_export.rb
  - _sass/_p_resume.scss
  - bin/validate_exports.rb
  - exports/resume.md
  - history.html
  - index.html
  - resume.html
  - resume/positions/emr-bear/index.html
  - resume/positions/onemain/index.html
  - skills/site-refresh-director/references/direction-contract.md
  - tests/layout.spec.js
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Rewrite the public resume’s positioning and evidence so it presents Mike as a hands-on senior technical individual contributor focused on production systems, reliability, legacy modernization, cross-team technical leadership, and responsible AI leverage. Preserve formal employment facts and avoid unsupported claims. The resume should stop routing readers primarily toward people-management roles.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The primary headline and summary clearly target Staff or Principal technical IC work without presenting engineering management as the desired job family
- [x] #2 Formal company names, job titles, employment dates, and factual accomplishments remain unchanged unless a correction is supported by existing repository evidence
- [x] #3 Recent experience emphasizes hands-on system diagnosis, architecture, reliability, observability, modernization, and cross-team technical influence
- [x] #4 Skills and ATS-facing content use coherent Staff or Principal IC terminology and retain relevant platform, backend, cloud, data, and AI keywords
- [x] #5 Management experience remains visible as supporting organizational fluency without dominating the professional identity
- [x] #6 Main resume, minimal resume, ATS content, history views, and generated exports build successfully with no schema or link regressions
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Keep `_data/resume` as the single source of truth for professional identity, SEO copy, summary, ATS keywords, capabilities, and role evidence; Jekyll pages and structured data must derive from it.
2. Rewrite the shared summary, ATS keywords, skills taxonomy, and recent-role copy so technical IC evidence leads while formal employment facts remain intact.
3. Keep management and community leadership as supporting organizational fluency rather than the primary target role.
4. Correct the generated Markdown export to consume the flat ATS skill list instead of serializing the structured skills hash, and make export validation load the expected identity from resume YAML rather than hardcoding it.
5. Regenerate all resume surfaces, run targeted resume/export checks followed by the project build and relevant tests, then inspect rendered desktop/mobile output and the final diff.

Document the resume positioning and installed-localhost publication contract in `AGENTS.md`, `CONTEXT.md`, and `CODEX.md` so future agents do not reopen settled decisions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Context Hunter classification: L1 (bounded resume data and output-path change). Closest analog: the Staff-oriented resume immediately before commit 938eb491, combined with the current plain, evidence-first copy style from 5134d6e7.

Silent convention/risk: shared resume YAML fans out to root HTML, /resume.html, TXT, JSON, two Markdown outputs, JSON-LD, and generated position pages. Title assertions are hardcoded in bin/validate_exports.rb and tests/layout.spec.js. Existing untracked logs and playwright-report belong to the user and must remain untouched.

Scope boundary: /home/ and the product-marketing context still target Director roles. This task intentionally changes resume surfaces only; broader site positioning is a potential follow-up, not an implicit scope expansion.

User refinement: the resume must remain data-driven by Jekyll. Resume identity and SEO copy will live under `_data/resume`; root and resume pages, JSON-LD, exports, validators, and tests will consume generated data instead of becoming parallel sources of truth.

Positioning refinement from user evidence: Staff candidates in Mike's interviewing experience skewed younger, creating an age/seniority interpretation risk at 50. The public master resume will lead with `Principal Software Engineer — Production Systems & Reliability`; OneMain's exact Staff title remains unchanged. This presents a deliberate terminal-IC specialization, avoids a hedged dual-level headline, and keeps older experience compressed on the main resume.

OMF title interpretation clarified: `Associate Director` was the corporate grade and `Staff Engineer` was the technical job function; the role was not people management. Preserve the exact formal title, describe the work as a `senior technical IC`, and treat Principal as current market positioning rather than a claim about OMF's internal promotion decision.

OMF leadership evidence clarified by Mike: no direct reports. He led software architecture for the Acquisition lane, helped realign team responsibilities with business organizational realities, founded and technically led ACQ Enablement, and led the OpenTelemetry initiative. Resume language now distinguishes technical authority and team topology from people management.

Final title decision: use exactly `Principal Software Engineer` as the single professional identity. Production systems, reliability, modernization, observability, and AI augmentation remain specializations in summary/skills rather than additions to the title. Employer-assigned titles remain unchanged in chronology.

Final verification: Jekyll built 1,040 pages with zero markup warnings; 70 RSpec examples passed; resume data and JSON/TXT/Markdown export validators passed; SEO, semantic-output, index-mode, metadata-budget, and repo-hygiene validators passed. Installed-localhost Playwright exercised desktop/mobile root and `/history/` views with 4/4 passing. The independent site-refresh reviewer returned PASS after the resume text accent was darkened to an AA-compliant 5.47:1 contrast. Whole-site HTML-Proofer is clean when excluding the pre-existing `/home/` link to the not-yet-published `/panoramic-view/` route; that unrelated broken link is outside this resume slice.
<!-- SECTION:NOTES:END -->

## Comments

<!-- COMMENTS:BEGIN -->
created: 2026-08-15 17:31
---
Repository context now records the durable single-title decision (`Principal Software Engineer`), the OneMain corporate-grade/technical-function distinction, canonical resume data sources, and the required `bin/install-localhost` verification at `https://just3ws.localhost/`.
---

created: 2026-08-15 18:15
---
The user expanded the visual slice to make `/` and `/history/` share one data-driven Principal-IC presentation system. Root remains the curated three-role resume; `/history/` retains all 25 timeline positions. Independent reviewer verdict: PASS.
---
<!-- COMMENTS:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Repositioned the public resume around the single identity `Principal Software Engineer`, preserving employer-assigned titles and clarifying OneMain as a no-direct-report senior technical IC role. Rewrote canonical Jekyll resume data to foreground system diagnosis, architecture, reliability, observability, modernization, cross-team influence, and responsible AI leverage; management experience remains supporting context. Added a shared data-driven resume hero for the concise root page and complete `/history/` timeline, corrected Markdown export serialization and data-driven title validation, aligned metadata/JSON-LD, and documented the settled title plus installed-localhost workflow for future agents.

Verification included a 1,040-page Jekyll build with zero markup warnings, 70 passing RSpec examples, passing data/export/SEO/semantic validators, four passing installed-localhost desktop/mobile Playwright checks, and an independent visual/accessibility review with a final PASS. The existing `/home/` link to unpublished `/panoramic-view/` remains a separate pre-existing issue.
<!-- SECTION:FINAL_SUMMARY:END -->

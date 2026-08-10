---
id: TASK-260
title: Refresh just3ws professional presence around Panoramic View
status: In Progress
assignee:
  - '@Codex'
created_date: '2026-08-10 17:11'
updated_date: '2026-08-10 18:23'
labels:
  - site-refresh
  - career-positioning
  - panoramic-view
dependencies: []
references:
  - 'https://github.com/Leonxlnx/taste-skill'
documentation:
  - CONTEXT.md
  - docs/adr/0001-public-archive-publication-contract.md
modified_files:
  - .agents/product-marketing-context.md
  - docs/site-refresh/panoramic-view-positioning.md
  - _data/resume/profile.yml
  - _data/resume/summary.yml
  - _data/resume/ats.yml
  - _data/resume/skills.yml
  - _data/resume/timeline.yml
  - _data/resume/earlier_experience.yml
  - _data/resume/positions/emr-bear.yml
  - _data/resume/positions/onemain.yml
  - _data/resume/positions/sk-holdings.yml
  - _data/resume/positions/phalanx-duel.yml
  - index.html
  - resume.html
  - history.html
  - resume/positions/emr-bear/index.html
  - resume/positions/onemain/index.html
  - resume/positions/sk-holdings/index.html
  - _includes/json-ld.html
  - _includes/schema-factory.html
  - bin/validate_exports.rb
  - _data/panoramic_view.yml
  - panoramic-view/index.html
  - _sass/_p_panoramic_view.scss
  - _data/repo_hygiene.yml
  - _data/home.yml
  - home/index.html
  - _data/navigation.yml
  - _sass/_p_home_refresh.scss
  - _sass/_p_theme_modern.scss
  - _sass/_p_theme_kanagawa.scss
  - assets/css/site.scss
  - _config.yml
  - _includes/head/base.html
  - tests/layout.spec.js
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Reframe just3ws.com for hiring managers, recruiters, and AI-assisted hiring evaluation around Mike Hall's current identity as a hands-on Director of Engineering. Present Panoramic View as Mike's original, evidence-backed methodology; use recent transition work as a later application; retain career depth through progressive disclosure rather than an exhaustive homepage chronology. Preserve the site's public-archive purpose, existing URLs, accessibility, provenance discipline, and confidential-source boundaries.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The site presents a coherent hands-on Director of Engineering identity grounded in systems leadership, modernization, and team capability.
- [x] #2 Panoramic View is presented with accurate authorship, chronology, scope, evidence, limitations, and distinction from subordinate tooling.
- [x] #3 The resume, homepage, methodology material, and case evidence use public-safe claims traceable to the supplied evidence packages.
- [x] #4 More than 25 years of experience remains available through progressive disclosure without overwhelming the primary hiring-decision path.
- [x] #5 Existing public URLs and archive behavior are preserved or deliberately redirected, and relevant Jekyll, link, accessibility, and browser checks pass.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-08-10: Mike directed that proof-of-method examples default to organization archetype, scale, situation, need, and questions answered. Company names and internal labels should be used only when necessary and explicitly appropriate.

Private source-package paths and implementation-organization names are intentionally omitted from public planning records. Evidence remains behind the Publication Gate.

All four subtasks are complete: public positioning/claim ledger, Director-level resume, Panoramic View field guide and anonymized case evidence, and hiring-evaluator homepage/navigation/visual refresh.

The final framing defines Panoramic View as business-to-system reconciliation: what the business believes the system does, what evidence shows it actually does, and where vision and reality align, diverge, or remain unknown. Scope may extend from supply chain to archival cold storage only as time and mandate permit.

Final evidence: 1,038-page Jekyll build with zero accessibility-hook warnings; eight Playwright smoke/visual tests passed; 375px mobile content and navigation bounds passed; default and Kanagawa themes reviewed; all required professional/archive routes retained; JSON/TXT resume exports validated; full repository validation and HTML-Proofer passed over 1,018 files and 832 internal links.

Publication review found no implementation employers on methodology/home surfaces and no private paths, coworker names, customer details, proprietary repository names, infrastructure counts, or internal political narrative. Conventional employer names remain only where appropriate in the résumé record.

No changes were committed or pushed. Existing untracked export material and archived logs were preserved untouched. Existing Jekyll warnings about generated export destination collisions remain unchanged.

Follow-up refinement in progress: make Panoramic View explicitly actor-agnostic, add the stakeholder-understanding/domain-model/runtime-behavior reconciliation triangle, and identify complex Rails platforms as the flagship proving ground without limiting broader applicability.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Completed the just3ws professional-presence refresh around a focused hands-on Director of Engineering identity. The site now leads with Stabilize–Understand–Innovate, presents Panoramic View as Mike Hall's original and evidence-bounded business-to-system reconciliation method, uses anonymized practical proof across enterprise and small-organization contexts, retains the complete career and public archive through progressive disclosure, and provides clear evaluator paths across home, resume, method, work, history, and contact. Mobile navigation clipping is resolved, both visual themes are supported, structured data and exports are current, and the full build/link/accessibility/browser suite passes.
<!-- SECTION:FINAL_SUMMARY:END -->

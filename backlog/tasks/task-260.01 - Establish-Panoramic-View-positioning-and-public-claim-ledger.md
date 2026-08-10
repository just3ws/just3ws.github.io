---
id: TASK-260.01
title: Establish Panoramic View positioning and public claim ledger
status: In Progress
assignee:
  - '@Codex'
created_date: '2026-08-10 17:11'
updated_date: '2026-08-10 17:14'
labels:
  - site-refresh
  - panoramic-view
dependencies: []
modified_files:
  - .agents/product-marketing-context.md
  - docs/site-refresh/panoramic-view-positioning.md
parent_task_id: TASK-260
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create the durable narrative foundation for the site refresh: audience and proof hierarchy, master career narrative, evidence-backed public/private claim ledger, content distribution, page hierarchy, and diagram recommendations. Preserve authorship categories, explicit unknowns, and confidentiality boundaries.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A product-marketing context document identifies the hiring audience, hands-on Director of Engineering positioning, proof hierarchy, objections, vocabulary, and conversion action.
- [ ] #2 A one-paragraph master career narrative and resume-ready evidence language are drafted without invented business-impact metrics.
- [ ] #3 A public/private claim ledger identifies what may be published, generalized, anonymized, or omitted and records provenance and confidence.
- [ ] #4 A content and site-architecture brief maps homepage, resume, Panoramic View methodology, case study, archive, and internal links while preserving existing URLs.
- [ ] #5 Recommended diagrams demonstrate the methodology without exposing proprietary systems or operational details.
- [ ] #6 Case evidence describes the organization archetype, scale and constraints, situation and need, and questions answered while omitting proper names and internal labels unless naming is necessary, public, and explicitly approved.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create `.agents/product-marketing-context.md` as the shared source for audience, hands-on Director of Engineering positioning, proof hierarchy, objections, vocabulary, voice, and conversion goals.
2. Create `docs/site-refresh/panoramic-view-positioning.md` as the Publication Gate artifact containing the master career narrative, public-safe resume bullet bank, homepage/project-card copy, methodology and case-study outlines, claim ledger, content pillars, information architecture, internal-link plan, and diagram recommendations.
3. Default every case example to an organization archetype, scale/constraints, situation/need, questions answered, evidence produced, and bounded outcome. Keep employer/person names, internal labels, proprietary paths, precise infrastructure details, and unapproved metrics out of methodology content.
4. Preserve the current route contract in the planned architecture: root remains the primary recruiter-facing profile/resume surface; `/history/`, `/portfolio/`, `/home/`, and archive routes remain intact; Panoramic View is introduced as a new first-class method page in a later task.
5. Validate the foundation for private-path leakage, restricted organization/person names, unsupported certainty, and required deliverable coverage. No public page or stylesheet changes occur in this first subtask.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-08-10: Public proof should emphasize organizational type and operating context so Panoramic View demonstrates enterprise and small-business applicability without exposing where specific concepts were proven out.

L2 context brief
- Analogous files reviewed: `index.html`, `home/index.html`, `history.html`, `portfolio.html`, `about/index.html`, `contact/index.html`, `_data/navigation.yml`, `_data/resume/{profile,summary,ats,timeline,earlier_experience,leadership,skills}.yml`, selected `_data/resume/positions/*.yml`, `_includes/resume/ats-content.html`, `_includes/resume/profile-header.html`, `_includes/position.html`, `_layouts/{base,resume}.html`, `_sass/_p_resume.scss`, and `tests/layout.spec.js`.
- Native patterns: canonical public resume content lives in `_data/resume/`; root `/` is the canonical ATS resume; `/history/` provides progressive disclosure; navigation comes from one YAML source; pages use Jekyll front matter plus Liquid includes; browser checks capture home/resume/mobile evidence.
- Reusable surfaces: existing profile header, position include, resume subnav/exports, skills dashboard, history timeline, portfolio cards, breadcrumbs, shared navigation, and schema factory.
- Main risks: leaking private package paths or named internal implementation context; laundering user-attested or AI-inferred claims into fact; overstating implementation maturity; spotlighting a 52-day role without context; changing established URLs; failing to regenerate derived resume exports; and amplifying the existing clipped mobile navigation.
- Unknowns retained: exact public end-date language for the recent role; which precise internal scope counts Mike will approve; whether corroborating recommendations will be published; systems-hypercube and decision-registry implementation status; production-traffic validation; and final visual expression of the Panoramic wave.
- Naming evidence: lower-case hyphenated routes and docs are established (`/archive-status/`, `docs/site-refresh` follows that pattern). `Panoramic View` is the methodology; `Electric Panoramic` is only its visualization pillar. A future `/panoramic-view/` route is a no-direct-analog addition but follows existing URL conventions.
<!-- SECTION:NOTES:END -->

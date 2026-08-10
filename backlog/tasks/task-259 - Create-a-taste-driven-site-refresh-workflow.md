---
id: TASK-259
title: Create a taste-driven site refresh workflow
status: In Progress
assignee:
  - Codex
created_date: '2026-08-10 15:27'
updated_date: '2026-08-10 15:32'
labels:
  - agent-skills
dependencies: []
references:
  - 'https://github.com/Leonxlnx/taste-skill'
documentation:
  - CONTEXT.md
  - CODEX.md
  - docs/adr/0001-public-archive-publication-contract.md
priority: medium
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Give maintainers a repo-native, repeatable way to audit and refresh just3ws.com without importing framework assumptions or generic AI design patterns. The workflow must preserve the public archive contract, current Jekyll architecture, accessibility, and Mike's established editorial voice.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A repo-local skill can guide an agent from current-site audit through a bounded visual refresh and verification.
- [ ] #2 Specialized agent interfaces cover visual direction, implementation, and independent quality review with clear handoff artifacts.
- [ ] #3 The workflow encodes just3ws.com-specific design, content, accessibility, and public-safety constraints.
- [ ] #4 The new capabilities are discoverable from the repository agent instructions.
- [ ] #5 All new skill packages pass structural validation and the repository's relevant documentation and build checks pass.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Distill the upstream project into a just3ws design contract: preserve its audit-first redesign mode, design-read statement, variance/motion/density dials, anti-repetition rules, and pre-flight checks; reject forced React/Tailwind/GSAP, randomization, placeholder imagery, universal dark-mode, and AIDA assumptions.
2. Add three repo-local skill packages with agent interfaces: site-refresh-director (current-state audit and refresh brief), site-refresh-builder (bounded Jekyll/Liquid/SCSS implementation), and site-refresh-reviewer (independent visual, accessibility, SEO, and public-safety gate).
3. Register the skills and their audit -> build -> review handoff contract in AGENTS.md, reusing CONTEXT.md, the publication ADR, the Guild Chronicler voice, existing token/theme files, and current Playwright/pipeline checks.
4. Validate all skill packages, build the Jekyll site, run the focused layout smoke test where the environment permits, and record objective evidence.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
L2 context brief: closest local analogs are skills/guild-chronicler-copywriter and the transcript skills, all using compact SKILL.md plus agents/openai.yaml. Site architecture is Jekyll/Liquid with SCSS modules, canonical navigation data, shared base/header includes, and Playwright layout smoke tests. Reuse existing Kanagawa/modern theme tokens and accessibility wins. Main risks are importing upstream React/Tailwind/GSAP assumptions, changing IA/SEO/copy while styling, and adding subjective rules without verifiable gates. New names follow existing lowercase-hyphen skill folders and the agents/openai.yaml interface pattern.

Applied the new workflow to the current rendered baseline. Design read: personal portfolio and public-archive hub for hiring managers and technical peers, with a sober editorial/technical language that should preserve the Phalanx Duel focal treatment, direct voice, real historical assets, and Kanagawa theme lineage. Home dials read approximately VARIANCE 3 / MOTION 2 / DENSITY 5; a targeted evolution could move toward 5 / 3 / 4 without turning the archive into a marketing landing page. Evidence: desktop home has clear hierarchy and a strong Phalanx callout but falls back to a generic equal-card exploration grid with an orphaned third card; the 375px screenshot shows the primary nav extending beyond the viewport and clipping multiple links. Recommended first implementation slice is the shared mobile navigation containment/interaction, reviewed separately before home-page recomposition. Visual evidence: tmp/screenshots/home.png, tmp/screenshots/mobile-home.png, tmp/screenshots/resume.png.
<!-- SECTION:NOTES:END -->

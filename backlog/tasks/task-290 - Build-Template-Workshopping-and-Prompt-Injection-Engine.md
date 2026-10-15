---
id: TASK-290
title: Build Template Workshopping and Prompt Injection Engine
status: In Progress
assignee:
  - '@antigravity'
created_date: '2026-10-15 01:46'
updated_date: '2026-10-15 02:05'
labels: []
dependencies:
  - TASK-287
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Creators need the ability to adjust episode framing, inject custom storytelling prompts, and workshop scripts interactively without losing prior research or manually editing compiled teleprompter files. A modular template engine allows prompt-based regeneration and parameter tuning.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Create modular liquid/erb template engine for 6-act teleprompter scripts in bin/templates/
- [ ] #2 Support prompt overrides and narrative direction parameters in episode dossiers
- [ ] #3 Support workshop command in bin/episode_workbench.rb to re-evaluate and regenerate copy based on prompt instructions
- [ ] #4 Preserve human notes and story blocks across automated template regenerations
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create modular ERB templates for 6-act teleprompter scripts in bin/templates/teleprompter/.
2. Integrate ERB template compilation into bin/episode_workbench.rb.
3. Build workshop command in bin/episode_workbench.rb to inject prompt overrides and regenerate scripts while preserving human stories.
4. Add unit and contract tests in spec/youtube/episode_workbench_spec.rb.
5. Verify 100% em-dash cleanliness and pass all validation suites.
<!-- SECTION:PLAN:END -->

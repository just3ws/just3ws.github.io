---
id: TASK-290
title: Build Template Workshopping and Prompt Injection Engine
status: To Do
assignee: []
created_date: '2026-10-15 01:46'
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

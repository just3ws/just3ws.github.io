---
id: TASK-290
title: Build Template Workshopping and Prompt Injection Engine
status: Done
assignee:
  - '@antigravity'
created_date: '2026-10-15 01:46'
updated_date: '2026-10-15 02:35'
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
- [x] #1 Create modular liquid/erb template engine for 6-act teleprompter scripts in bin/templates/
- [x] #2 Support prompt overrides and narrative direction parameters in episode dossiers
- [x] #3 Support workshop command in bin/episode_workbench.rb to re-evaluate and regenerate copy based on prompt instructions
- [x] #4 Preserve human notes and story blocks across automated template regenerations
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create modular ERB templates for 6-act teleprompter scripts in bin/templates/teleprompter/.
2. Integrate ERB template compilation into bin/episode_workbench.rb.
3. Build workshop command in bin/episode_workbench.rb to inject prompt overrides and regenerate scripts while preserving human stories.
4. Add unit and contract tests in spec/youtube/episode_workbench_spec.rb.
5. Verify 100% em-dash cleanliness and pass all validation suites.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
- Created modular ERB templates under `bin/templates/teleprompter/` for Acts 1 through 6 (`act_01_cold_open.erb`, `act_02_setting.erb`, `act_03_inquiry.erb`, `act_04_rewatch.erb`, `act_05_workbench.erb`, `act_06_outro.erb`).
- Integrated ERB renderer into `bin/episode_workbench.rb` via `render_template_act` with robust fallbacks.
- Built `workshop` subcommand allowing creators to inject prompts (e.g. `bin/episode_workbench.rb workshop 1 --prompt "..."`) which automatically appends prompts to `human_marginalia.workshop_prompts` and regenerates teleprompter copy while preserving host recollections and research citations.
- Incorporated Patreon archive callout (`patreon.com/whoistechcmty`) into Act 6 outro template and rundown generator.
- Verified cleanly with 13/13 passing specs in `spec/youtube/episode_workbench_spec.rb`, 134/134 passing specs across the full test suite, 46/46 OBS assertions, and zero em-dash violations.
<!-- SECTION:NOTES:END -->

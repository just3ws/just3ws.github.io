---
id: TASK-287
title: Build Episode Semantic Dossier schema and workbench CLI
status: In Progress
assignee:
  - '@antigravity'
created_date: '2026-10-15 01:45'
updated_date: '2026-10-15 01:47'
labels: []
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Episode planning currently relies on raw interview metadata and hardcoded teleprompter acts. Creators need a structured, versioned file format for each episode capturing narrative plot, tone, theme, key concepts, human story marginalia, and research attachments, completely decoupled from the UI so it can be automated and scripted.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Define YAML dossier schema in _data/episodes/ supporting narrative metadata, semantic lexicon, human stories, and evidence attachments
- [ ] #2 Create bin/episode_workbench.rb CLI supporting create, show, edit, compile, and validate commands
- [ ] #3 Ensure compile merges automated transcript facts with human marginalia into 6-act teleprompter rundowns
- [ ] #4 Verify zero em dashes in all generated dossiers and scripts
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Research existing sequence and transcript data structures in _data/sound_above_sequence.json, _data/transcripts/, and _data/interviews.yml.
2. Define the Episode Semantic Dossier YAML schema and generate baseline dossiers in _data/episodes/ seeded from _data/sound_above_sequence.json.
3. Build bin/episode_workbench.rb CLI supporting list, show, init, compile, and validate commands.
4. Hook bin/episode_workbench.rb into bin/pipeline as 'episode' subcommand.
5. Write unit and contract tests in spec/youtube/episode_workbench_spec.rb.
6. Verify zero em dashes and ensure all validation gates pass.
<!-- SECTION:PLAN:END -->

---
id: TASK-287
title: Build Episode Semantic Dossier schema and workbench CLI
status: To Do
assignee: []
created_date: '2026-10-15 01:45'
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

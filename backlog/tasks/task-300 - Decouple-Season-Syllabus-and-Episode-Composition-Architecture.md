---
id: TASK-300
title: Decouple Season, Syllabus and Episode Composition Architecture
status: To Do
assignee: []
created_date: '2026-10-16 16:45'
updated_date: '2026-10-16 16:45'
labels:
  - architecture
  - media-pipeline
  - episodes
  - syllabus
  - seasons
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Decouple episode identity and sequence indices from hardcoded numeric ordinals across sound_above_sequence.json, youtube_pipeline.rb, youtube/dashboard.html, and _data/episodes/*.yml.

Currently, episode tooling expects 1-based integer indices (e.g. 1..38) or ad-hoc prefixes, creating brittle naming collisions when adding ad-hoc errata broadcasts (such as errata-fluffle-precursor), field dispatches, or separate seasons.

This task establishes a declarative season and syllabus manifest architecture where:
1. Episodes use semantic slugs as primary keys.
2. Syllabi and seasons define ordered sequences of episode references rather than defining episode identity.
3. Dashboards and teleprompters render discrete tracks (Curriculum Seasons, Errata Deep Dives, Field Dispatches) dynamically from declarative manifests.
4. Telemetry and staging scripts resolve episodes by semantic identifier with backward-compatible numeric aliases.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Design declarative season and syllabus manifest schema in _data/
- [ ] #2 Refactor bin/youtube_pipeline.rb and bin/episode_workbench.rb to resolve episodes via semantic slugs and manifest manifests
- [ ] #3 Update youtube/dashboard.html to group teleprompter and cueing selectors by syllabus track
- [ ] #4 Preserve backward compatibility with existing 38 numeric episodes of The Sound Above
- [ ] #5 Add automated tests verifying multi-track season and errata composition
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 All RSpec tests passing with zero regressions on existing 38 episodes
- [ ] #2 Zero em dashes across all new and modified schemas and documentation
<!-- DOD:END -->

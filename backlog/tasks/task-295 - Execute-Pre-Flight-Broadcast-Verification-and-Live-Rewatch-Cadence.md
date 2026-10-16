---
id: TASK-295
title: Execute Pre-Flight Broadcast Verification & Live Rewatch Cadence (Episode 00 Pilot & Movement 1)
status: To Do
assignee: []
created_date: '2026-10-16 11:40'
updated_date: '2026-10-16 11:40'
labels:
  - broadcast
  - obs
  - the-sound-above
dependencies:
  - TASK-291
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Execute live OBS Studio pre-flight verification and broadcast execution for Episode 00 ("The Mirage of Competence: AI Slop & Domain Boundaries") and Movement 1 ("The Chicago Workshop", Episodes 01 to 05), validating Textream teleprompter pacing, browser-source overlays, and post-broadcast replay handoff.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Cue Episode 00 in OBS via /api/live/pipeline/cue_obs?episode=0 (or ./bin/broadcast cue 0) and verify Textream 6-act pacing
- [ ] #2 Record/stream Episode 00 Pilot and verify automated caption and metadata sync
- [ ] #3 Execute Movement 1 broadcast cadence (Episodes 01 to 05: Sergio Pereira, Ray Hightower, Micah Martin & Mike Jansen, Dave Hoover, Ryan Gerry & Jim Suchy)
- [ ] #4 Link live replay video IDs in _data/episodes/episode-00.yml..episode-05.yml and _data/sound_above_sequence.json
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 Episode 00 and Movement 1 replays published with verified WebVTT captions and linked on /series/the-sound-above/
<!-- DOD:END -->

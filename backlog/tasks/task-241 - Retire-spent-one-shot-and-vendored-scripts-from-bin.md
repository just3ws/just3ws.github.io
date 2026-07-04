---
id: TASK-241
title: Retire spent one-shot and vendored scripts from bin/
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
labels:
  - pipeline
  - cleanup
milestone: Interview Archive Pipeline
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove spent one-shot repair/split scripts (repair_dave_thomas{,_2015}, manual_split_dave, split_erik{,_advanced}, restructure_{dean_wampler,erik_meijer}, fix_gary_flip — ~494 lines, each named after a single person/event with the fix already baked into the data) and the zdots platform CLI vendored into this repo (bin/zdots-brain-{local,debug}, ~818 lines, hard-coding /Users/mike absolute requires — belongs in the zdots repo, not the site). Resolve the three stale Rakefile tasks pointing at missing scripts (generate_interview_pages, generate_video_asset_pages, generate_interview_taxonomy_pages). Foundation cleanup from the ponytail audit; unblocks a clean base for the rest of the pipeline.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The 8 named one-shot scripts are removed from bin/
- [ ] #2 bin/zdots-brain-local and bin/zdots-brain-debug are removed (or relocated to the zdots repo)
- [ ] #3 The three stale Rakefile tasks are removed or repaired to point at real scripts
- [ ] #4 rake build and the test suite are green after removal
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

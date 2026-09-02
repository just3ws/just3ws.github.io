---
id: TASK-278.02
title: Resolve speakers and build presentation profiles
status: To Do
assignee: []
created_date: '2026-09-02 22:43'
labels:
  - oral-history
  - archive
  - research
  - knowledge-graph
dependencies: []
references:
  - /data/interviewees_index.yml
  - /data/speakers_index_full.json
  - /interviews/
parent_task_id: TASK-278
priority: medium
type: docs
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Research each speaker entity and connect their profile to the presentations, talks, interviews, organizations, and official biographies represented in the archive. Handle aliases, spelling variants, group speakers, and Mike as presenter for presentation-mode recordings.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Speaker aliases resolve to canonical entities without merging distinct people.
- [ ] #2 Speaker profiles link to specific presentations and recordings where evidence exists.
- [ ] #3 Interviewer, interviewee, presenter, panelist, and group speaker roles are represented separately.
- [ ] #4 Unresolved identity matches are flagged for human review.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

---
id: TASK-239
title: Implement archive transcript state module
status: To Do
assignee: []
created_date: '2026-06-28 16:24'
labels:
  - implementation
dependencies: []
modified_files:
  - src/generators/archive_state.rb
  - spec/src/generators/archive_state_spec.rb
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a reusable native Ruby archive transcript state module for Jekyll archive data. The archive has migrated from legacy transcript content to structured turns, but callers still need one conservative state interface that treats either content or structured turns as transcript text. Scope is limited to src/generators/ and corresponding specs under spec/src/generators/. Do not edit bin scripts or Liquid templates.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Module reports parseable/load status for transcript path or id without writing to _data.
- [ ] #2 has_transcript? is true for legacy content or structured turns, and false for missing or invalid transcript data.
- [ ] #3 transcript_format returns structured, content, missing, or invalid as appropriate.
- [ ] #4 Module exposes transcript text and word_count from content or turns joined in order.
- [ ] #5 Module exposes validated?/validation_error and enriched?/indexed? from known transcript fields.
- [ ] #6 Module returns structured summary data suitable for later summary generation.
- [ ] #7 Focused RSpec coverage exists for content-only, turns-only, missing, invalid YAML, validation_error, enriched, and indexed states.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

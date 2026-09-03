---
id: TASK-283
title: Standardize canonical dates as ISO 8601
status: In Progress
assignee:
  - agent-just3ws
created_date: '2026-09-03 01:57'
updated_date: '2026-09-03 01:57'
labels:
  - data-integrity
  - timeline
  - public-surface
dependencies: []
modified_files:
  - _data/resume/positions/*.yml
  - _plugins/date_display.rb
  - _plugins/markdown_export.rb
  - _plugins/resume_signals.rb
  - timeline/index.html
  - src/validators/site_schema.rb
  - bin/validate_position_dates.rb
  - CODEX.md
  - CLAUDE.md
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Repair the persistent date-model inconsistency across the public site. Career position source data must store dates in a machine-readable ISO 8601 form, while templates, exports, timeline labels, and generated compatibility artifacts format dates for people. Ongoing intervals must remain explicitly open-ended without storing the display word Present in canonical source data. Preserve known date precision rather than implying unsupported day-level certainty.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Canonical resume position start_date and end_date values use quoted ISO 8601 calendar dates or null for an ongoing interval.
- [ ] #2 Human-facing templates, Markdown exports, generated resume artifacts, and timeline labels format canonical dates for readers and display Present only for open-ended intervals.
- [ ] #3 Date precision is represented explicitly where a normalized date does not carry original day-level certainty.
- [ ] #4 A focused validator fails on non-ISO position dates, invalid null handling, or invalid precision metadata.
- [ ] #5 The Jekyll build and relevant data, link, Markdown, and public-surface checks pass after the change.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Keep canonical position dates as quoted ISO 8601 calendar-date strings (`YYYY-MM-DD`) with null for ongoing intervals. Use adjacent `date_precision` metadata (`month` or `year`) where normalization represents an interval boundary rather than a known day.
2. Add one shared date formatter for Liquid and Ruby generators, formatting ISO source values as `Month YYYY` and rendering null as `Present` only at display time.
3. Update timeline JavaScript, Liquid templates, Markdown exports, resume generators, and compatibility datalake code to consume the canonical form without leaking raw ISO dates to readers.
4. Add focused position-date validation and schema/documentation guidance so non-ISO strings, invalid nulls, and invalid precision values fail clearly.
5. Build and run the existing data, Markdown, accessibility, link, and public-surface checks; inspect the generated output for both correct human formatting and absence of legacy date strings.
<!-- SECTION:PLAN:END -->

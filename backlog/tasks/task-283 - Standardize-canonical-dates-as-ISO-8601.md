---
id: TASK-283
title: Standardize canonical dates as ISO 8601
status: Done
assignee:
  - agent-just3ws
created_date: '2026-09-03 01:57'
updated_date: '2026-09-03 02:02'
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
- [x] #1 Canonical resume position start_date and end_date values use quoted ISO 8601 calendar dates or null for an ongoing interval.
- [x] #2 Human-facing templates, Markdown exports, generated resume artifacts, and timeline labels format canonical dates for readers and display Present only for open-ended intervals.
- [x] #3 Date precision is represented explicitly where a normalized date does not carry original day-level certainty.
- [x] #4 A focused validator fails on non-ISO position dates, invalid null handling, or invalid precision metadata.
- [x] #5 The Jekyll build and relevant data, link, Markdown, and public-surface checks pass after the change.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Keep canonical position dates as quoted ISO 8601 calendar-date strings (`YYYY-MM-DD`) with null for ongoing intervals. Use adjacent `date_precision` metadata (`month` or `year`) where normalization represents an interval boundary rather than a known day.
2. Add one shared date formatter for Liquid and Ruby generators, formatting ISO source values as `Month YYYY` and rendering null as `Present` only at display time.
3. Update timeline JavaScript, Liquid templates, Markdown exports, resume generators, and compatibility datalake code to consume the canonical form without leaking raw ISO dates to readers.
4. Add focused position-date validation and schema/documentation guidance so non-ISO strings, invalid nulls, and invalid precision values fail clearly.
5. Build and run the existing data, Markdown, accessibility, link, and public-surface checks; inspect the generated output for both correct human formatting and absence of legacy date strings.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Research confirmed the prior inconsistency was concentrated in 28 resume position records and their display/generator consumers. The source had month-name and year-only values, while some derived artifacts assumed Present.

Implemented ISO date plus explicit precision metadata. Chose adjacent metadata instead of an object shape to preserve existing Jekyll, Liquid, JSON, and CLI consumers.

Objective verification: position validator passed for 28 files; declarative data validation passed; Jekyll built 1,182 pages with 0 accessibility warnings; last-modified validation passed; Markdown lint passed across 452 files; focused RSpec passed 11/11; HTML-Proofer passed on 1,163 files with 1,273 internal links; git diff --check passed.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Standardized the canonical resume timeline date contract. All 28 position records now use quoted ISO 8601 calendar dates, null for ongoing intervals, and explicit month/year precision metadata where the source recollection does not establish a day. Added a shared Ruby/Liquid formatter so reader-facing pages and exports render Month YYYY or Present without leaking machine values. Updated timeline parsing and labels, resume templates, Markdown and archetype generators, taxonomy cards, query output, and machine datalake generation. Added schema enforcement and bin/validate_position_dates.rb with a Rake validation task. Build and validation evidence: Jekyll 1,182 pages with zero accessibility warnings, declarative data validation, last-modified validation, Markdown lint on 452 files, focused RSpec 11/11, HTML-Proofer on 1,163 files and 1,273 internal links, and git diff --check all passed. Local web-root installation was not repeated from the restricted agent environment; rerun bin/install-localhost from the privileged shell to refresh the installed localhost copy.
<!-- SECTION:FINAL_SUMMARY:END -->

---
id: TASK-239
title: Implement archive transcript state module
status: Done
assignee:
  - codex
created_date: '2026-06-28 16:24'
updated_date: '2026-06-28 16:27'
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
- [x] #1 Module reports parseable/load status for transcript path or id without writing to _data.
- [x] #2 has_transcript? is true for legacy content or structured turns, and false for missing or invalid transcript data.
- [x] #3 transcript_format returns structured, content, missing, or invalid as appropriate.
- [x] #4 Module exposes transcript text and word_count from content or turns joined in order.
- [x] #5 Module exposes validated?/validation_error and enriched?/indexed? from known transcript fields.
- [x] #6 Module returns structured summary data suitable for later summary generation.
- [x] #7 Focused RSpec coverage exists for content-only, turns-only, missing, invalid YAML, validation_error, enriched, and indexed states.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Inspect existing generator naming, YAML loading, and transcript-shape conventions in the requested files plus nearby specs/data samples.
2. Add `Generators::ArchiveState` under `src/generators/archive_state.rb` with a small read-only API for path/id loading, transcript presence/format, text/word count, validation, enrichment, indexing, and summary-friendly structured output.
3. Add focused RSpec coverage under `spec/src/generators/archive_state_spec.rb` for content-only, turns-only, missing, invalid YAML, validation_error, enriched, and indexed cases.
4. Run targeted specs: `bundle exec rspec spec/src/generators/core/yaml_io_spec.rb spec/src/generators/archive_state_spec.rb`.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented `Generators::ArchiveState` as a read-only transcript state wrapper with `for_path`, `for_id`, and `from_data` entry points. The module treats legacy `content` and structured `turns` as transcript text, exposes load/parse status and invalid YAML errors, keeps `validated_at` separate from `validation_error`, and reports `enriched_at`/`indexed_at` flags. Targeted specs passed: `bundle exec rspec spec/src/generators/core/yaml_io_spec.rb spec/src/generators/archive_state_spec.rb` (10 examples, 0 failures).
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented the core archive transcript state module only.

Changed files:
- `src/generators/archive_state.rb`
- `spec/src/generators/archive_state_spec.rb`

Summary:
- Added `Generators::ArchiveState.for_path`, `.for_id`, and `.from_data`, returning a `TranscriptState` object.
- Added load status handling for loaded, missing, and invalid transcript YAML, including parse/load error capture.
- Added transcript state methods for `has_transcript?`, `transcript_format`, `text`, `word_count`, `validated?`, `validation_error`, `enriched?`, `indexed?`, `turn_count`, `speakers`, and `to_h`.
- Covered content-only, turns-only, missing, invalid YAML, validation-error, enriched/indexed, id-based loading, and already-loaded data cases.

Tests:
- `bundle exec rspec spec/src/generators/core/yaml_io_spec.rb spec/src/generators/archive_state_spec.rb` passed with 10 examples, 0 failures.

Risks:
- Caller migration is intentionally left to the separate archive report task; this task does not edit bin scripts, Liquid templates, or existing caller code.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

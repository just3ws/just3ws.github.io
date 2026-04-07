---
id: TASK-017
title: 'T-1030: Enforce Export Parity (JSON/TXT/HTML)'
status: Done
assignee: []
created_date: '2026-04-07 13:39'
updated_date: '2026-04-07 17:52'
labels: []
milestone: System Transformation Phase 2
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ensure perfect parity between the HTML resume, JSON export, and plain text version by centralizing the export logic around the normalized YAML schema.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 resume.json export is perfectly idempotent with _data/resume source of truth
- [x] #2 resume.txt export matches normalized content without custom override drift
- [x] #3 Build fails if exports diverge from source data structures
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Enforced export parity between HTML, JSON, and TXT resume formats.
1. Restored missing metadata fields (company, title, dates) in all 24 position files that were lost in a previous partial transformation.
2. Verified that resume.json includes expanded position data and is idempotent with the source of truth (AC #1).
3. Verified that resume.txt correctly renders the new context-action-impact structure and labeled highlights (AC #2).
4. Implemented bin/validate_exports.rb to programmatically assert parity across generated artifacts and integrated it into the Rakefile validate:all task (AC #3).
5. All validations passed against a full site build.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

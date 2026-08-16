---
id: TASK-006
title: Implement Declarative Data Validation
status: Done
assignee: []
created_date: '2026-04-01 15:29'
updated_date: '2026-04-02 01:21'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Custom validation scripts like `validate_data_integrity.rb` are manual and hard to update. Using a declarative schema will make it easier to maintain and enforce rules.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Implement `dry-validation` or JSON Schema for validating `_data/*.yml` files.
- [ ] #2 Define schemas for `interviews.yml`, `video_assets.yml`, and `taxonomy.yml`.
- [ ] #3 Ensure that existing data passes the new validation schemas.
- [ ] #4 Integrate validation into the build pipeline as a pre-build step.
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented a robust, declarative data validation system using the `dry-validation` gem.
- Created `src/validators/site_schema.rb` containing schema contracts for Interviews, VideoAssets, Conferences, and Communities.
- Developed `bin/validate_data.rb` to load YAML data, execute schema validation, and perform cross-collection referential integrity checks.
- Replaced the manual and hard-to-maintain `bin/validate_data_integrity.rb` with the new declarative system in the `Rakefile`.
- Updated `_data/repo_hygiene.yml` to reflect recent structural changes.
- Verified that all existing data passes the new validation schemas.
- Integrated the new validation step into the `rake ci` pipeline.
- This fulfills all acceptance criteria for TASK-006.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

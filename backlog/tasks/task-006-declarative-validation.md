---
id: task-006
title: Implement Declarative Data Validation
status: To Do
assignee: []
created_date: '2026-04-01 15:29'
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

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

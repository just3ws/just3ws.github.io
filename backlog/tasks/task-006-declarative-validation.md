# Task-006: Declarative Data Validation

**Status:** To Do
**Priority:** Medium

## Description
Custom validation scripts like `validate_data_integrity.rb` are manual and hard to update. Using a declarative schema will make it easier to maintain and enforce rules.

## Acceptance Criteria
- [ ] Implement `dry-validation` or JSON Schema for validating `_data/*.yml` files.
- [ ] Define schemas for `interviews.yml`, `video_assets.yml`, and `taxonomy.yml`.
- [ ] Ensure that existing data passes the new validation schemas.
- [ ] Integrate validation into the build pipeline as a pre-build step.

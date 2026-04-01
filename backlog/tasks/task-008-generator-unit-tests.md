---
id: task-008
title: Add Unit Tests for Generators
status: To Do
assignee: []
created_date: '2026-04-01 15:29'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Existing tests in `spec/` only cover basic logic. The complex transformations from YAML to HTML in the generator scripts are mostly untested and rely on integration-style validation.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Implement unit tests for all custom generator plugins and CLI tools.
- [ ] #2 Test edge cases (e.g., missing YAML fields, malformed dates, large datasets).
- [ ] #3 Use mocks and fixtures for YAML data to ensure deterministic tests.
- [ ] #4 Integrate unit tests into the CI build as a blocking check.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

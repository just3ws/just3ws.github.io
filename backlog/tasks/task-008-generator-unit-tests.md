# Task-008: Generator Unit Tests (RSpec)

**Status:** To Do
**Priority:** High

## Description
Existing tests in `spec/` only cover basic logic. The complex transformations from YAML to HTML in the generator scripts are mostly untested and rely on integration-style validation.

## Acceptance Criteria
- [ ] Implement unit tests for all custom generator plugins and CLI tools.
- [ ] Test edge cases (e.g., missing YAML fields, malformed dates, large datasets).
- [ ] Use mocks and fixtures for YAML data to ensure deterministic tests.
- [ ] Integrate unit tests into the CI build as a blocking check.

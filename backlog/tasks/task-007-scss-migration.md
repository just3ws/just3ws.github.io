---
id: task-007
title: Convert CSS to SCSS/SASS
status: To Do
assignee: []
created_date: '2026-04-01 15:29'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Current CSS uses `@import` which has performance impacts and limits styling flexibility. Migrating to SCSS will allow for better variables, nesting, and organization.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Rename existing `.css` files to `.scss`.
- [ ] #2 Move shared styles into a `_sass/` directory.
- [ ] #3 Implement variables for colors (using existing Nord theme), typography, and spacing.
- [ ] #4 Ensure compiled CSS output matches the previous styling.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

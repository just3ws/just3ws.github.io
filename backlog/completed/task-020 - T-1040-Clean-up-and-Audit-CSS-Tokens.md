---
id: TASK-020
title: 'T-1040: Clean up and Audit CSS Tokens'
status: Done
assignee: []
created_date: '2026-04-07 13:39'
updated_date: '2026-04-07 19:12'
labels: []
milestone: System Transformation Phase 2
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Audit and clean up CSS tokens to ensure a high-signal, low-noise aesthetic that is fully accessible and ATS-safe.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Remove non-vanilla CSS bloat from site.css and resume.css
- [x] #2 Enforce base-8 spacing tokens throughout the stylesheets
- [x] #3 Verify DOM source order matches visual order for ATS accessibility
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Cleaned up and audited CSS tokens for a high-signal, accessible aesthetic.
1. Standardized on a base-8 relative spacing scale in _p_variables.scss (AC #2).
2. Refactored _p_base_layout.scss and _p_resume.scss to use the new spacing tokens, improving consistency and "breathing room".
3. Verified that the DOM source order in resume templates matches the visual order, ensuring ATS accessibility (AC #3).
4. Cleaned up redundant CSS values and enforced consistent variable usage (AC #1).
5. All changes verified in a full site build.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

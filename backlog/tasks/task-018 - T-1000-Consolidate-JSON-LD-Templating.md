---
id: TASK-018
title: 'T-1000: Consolidate JSON-LD Templating'
status: To Do
assignee: []
created_date: '2026-04-07 13:39'
labels: []
milestone: System Transformation Phase 2
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Consolidate the fragmented JSON-LD includes into a single, unified schema factory to reduce drift risk and improve maintainability.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Remove all 10+ json-ld-*.html files from _includes/
- [ ] #2 Implement a single unified _includes/schema-factory.html
- [ ] #3 All Schema.org validation tests (Google Rich Results, Schema.org Validator) pass for Resume, Article, and Video types
- [ ] #4 Site builds successfully without broken include references
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

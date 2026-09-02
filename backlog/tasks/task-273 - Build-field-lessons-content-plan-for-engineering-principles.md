---
id: TASK-273
title: Build field lessons content plan for engineering principles
status: Done
assignee: []
created_date: '2026-09-02 04:26'
updated_date: '2026-09-02 04:28'
labels: []
dependencies: []
documentation:
  - CONTEXT.md
  - docs/content-strategy.md
  - docs/career-narrative-drop-in-engineering-ethos.md
  - docs/style-guide-and-canonical-naming.md
modified_files:
  - docs/content-strategy.md
  - docs/field-lessons-content-plan.md
priority: medium
type: docs
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a durable editorial plan that surfaces Mike's evidence-backed engineering principles as material lessons from the field. Organize the lessons into content pillars and a connected topic cluster, with priority, audience, format, evidence source, publication classification, and editorial safeguards.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A content plan defines three to five coherent pillars grounded in the archive and public site strategy.
- [x] #2 Each priority lesson has a working title, audience, format, searchable or shareable purpose, evidence source, and publication status.
- [x] #3 The plan shows how the lessons connect as a hub-and-spoke or equivalent topic cluster.
- [x] #4 The plan distinguishes public-safe evidence from claims requiring verification and keeps private archive material out of canonical content.
- [x] #5 The plan includes an editorial workflow for drafting, fact checking, human revision, and publication.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Archive mining identified four pillars: mentorship as a feedback system, communication architecture for organizational change, observability as shared understanding, and durable systems and communities.

Created docs/field-lessons-content-plan.md and linked it from docs/content-strategy.md. The plan distinguishes verified public-safe evidence, current firsthand clarification, interpretation, and open questions.

Verification: ruby bin/audit_prose_humanity.rb docs/field-lessons-content-plan.md docs/content-strategy.md passed; git diff --check passed; bundle exec jekyll build --trace passed; bundle exec rake validate:all passed.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Created a durable field-lessons editorial plan for Mike's engineering principles. It defines four content pillars, a hub-and-spoke topic map, twelve prioritized lessons, evidence and publication classifications, a phased sequence, a reusable lesson template, and an editorial workflow. Updated docs/content-strategy.md to link the program and establish its publication rule. Verified with the prose humanity audit, em-dash scan, Jekyll build, git diff check, and the complete validate:all suite. No private archive content was added to the public plan.
<!-- SECTION:FINAL_SUMMARY:END -->

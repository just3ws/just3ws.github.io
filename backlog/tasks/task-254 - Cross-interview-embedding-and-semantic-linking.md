---
id: TASK-254
title: Cross-interview embedding and semantic linking
status: To Do
assignee: []
created_date: '2026-07-04 09:24'
labels:
  - pipeline
  - insights
milestone: Interview Archive Pipeline
dependencies:
  - TASK-251
  - TASK-242
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Use zdots `embed` jobs + pgvector to embed the extended insights/transcripts and compute cross-interview links (shared topics, people, and threads across conferences and eras). Surface a semantic query/index by reusing the existing `zdots-brain query --semantic`, not by rebuilding search. This is the one place a batch job (not the interactive audit skill) owns the output — per-interview insight text stays in the audit skill; this task owns only linking/search.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Insights/transcripts are embedded via zdots embed jobs
- [ ] #2 Cross-interview links are computed (topic / person / thread)
- [ ] #3 Semantic search over the corpus works via the existing zdots query, not a new engine
- [ ] #4 Links are stored back into the insight data for rendering
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

---
id: TASK-278
title: Build an evidence-linked oral history research program
status: To Do
assignee: []
created_date: '2026-09-02 22:42'
labels:
  - oral-history
  - archive
  - research
  - knowledge-graph
  - speaker-profiles
dependencies: []
references:
  - /interviews/
  - /videos/
  - /scmc/
  - /timeline/
  - /assets/data/knowledge_graph.json
documentation:
  - docs/career-datalake-and-mcp-guide.md
  - docs/pipeline-continuity.md
  - docs/style-guide-and-canonical-naming.md
  - docs/witc-temporal-timeline.md
priority: high
type: docs
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Audit the full public interview and presentation history and create a durable research program that connects speakers, presentations, conferences, communities, topics, official event pages, YouTube or Vimeo recordings, transcripts, subtitles, and archival evidence. The goal is a human-readable and graph-friendly record where each speaker profile can point to the specific presentations they gave and each presentation can point back to the strongest available evidence. Preserve historical context, single-speaker presentation mode, uncertainty, and AI-assisted archival disclosure.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A current inventory reconciles interviews, video assets, transcripts, subtitles, conferences, topics, speakers, and graph entities.
- [ ] #2 Research work is divided into independently deliverable work orders for entity resolution, speaker profiles, presentations, conferences, topics, official links, transcript quality, and provenance.
- [ ] #3 Each researched relationship has a confidence level and at least one evidence path or an explicit unresolved status.
- [ ] #4 The resulting data model supports speaker-to-presentation, presentation-to-event, presentation-to-topic, and presentation-to-recording links.
- [ ] #5 Public pages can expose the relationships through accessible links without confusing interviewers, interviewees, presenters, or single-speaker talks.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

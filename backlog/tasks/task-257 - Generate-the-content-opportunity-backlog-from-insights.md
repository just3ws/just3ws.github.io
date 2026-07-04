---
id: TASK-257
title: Generate the content-opportunity backlog from insights
status: To Do
assignee: []
created_date: '2026-07-04 09:24'
updated_date: '2026-07-04 14:30'
labels:
  - pipeline
  - insights
milestone: Interview Archive Pipeline
dependencies:
  - TASK-254
  - TASK-255
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Derive concrete content candidates from the enriched, cross-linked insights: article ideas, playlist groupings, Shorts candidates (with quote timestamps), historical-context pieces, and further-research/followup threads. Emit as a review surface (and optionally draft backlog tasks) that feeds existing content work (TASK-236/237/238). A human curates before anything is committed or published.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Candidate articles/playlists/shorts/research threads are generated from the insights
- [ ] #2 Each candidate cites its source interviews and timestamps
- [ ] #3 Output is a review surface for human curation
- [ ] #4 Approved candidates can be promoted to backlog tasks/docs
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Pattern to mirror
`rake semantic:snapshot` → `bin/generate_semantic_snapshot_page.rb` (generated data file + rendered page). Inputs: 251 `quote`/`timestamp`, 254 `cross_links`, 255 `context`/`lessons_for_now`/`followup_questions`.

## Generator
`bin/generate_content_opportunities.rb` + `rake generate:content_opportunities` (add to `generate:all`). Reads all transcript YAMLs, emits `_data/content_opportunities.yml`. Candidate categories aligned to downstream tasks:
- `articles` — long-form/historical, grouped by shared `cross_links` thread → feeds **TASK-237** (History of Software Craftsmanship in Chicago).
- `playlists` — conference/topic groupings from `cross_links` kind=topic/person → feeds **TASK-258**.
- `shorts` — each insight with `quote`+`timestamp` → feeds **TASK-258**. Timestamp requires TASK-247 diarization; OMIT any short lacking a real timestamp (no fake MM:SS).
- `linkedin_durable_wisdom` — `type: durable` insights + `lessons_for_now` → feeds **TASK-238** (Durable Wisdom).
- `ai_discovery` — Founders-series angles → feeds **TASK-236**.
- `research_threads` — `followup_questions` clustered across interviews.

Candidate schema: `{id (stable hash of kind+sources), title, kind, rationale, sources: [{slug, timestamp?}], feeds_task, status: proposed}`. AC#2: every candidate cites ≥1 source slug (+ timestamp for shorts).

## Review surface (AC#3)
Rendered page (new `pages/content-opportunities.html`, or reuse the semantic-snapshot page style) grouping candidates by category, each showing sources/timestamps + a `status` field the human edits (`proposed` → `approved`/`rejected`). Nothing publishes; explicit human-approval gate per DAG rule.

## Idempotency / merge (review-surface trap — critical)
Stable candidate `id`s + merge-preserve: regeneration KEEPS the human's `status` on existing ids and only ADDS new candidates. Never wipe curation on rerun — this is what makes it a review surface, not a throwaway report.

## Promotion (AC#4)
`bin/promote_content_opportunities.rb` (or documented `backlog task_create`) turns `status: approved` rows into backlog tasks/docs linked to TASK-236/237/238/258. Runs ONLY on human-approved rows.

## Verify
Run generator on corpus; every candidate has ≥1 source slug (+timestamp for shorts); page renders + `rake build`/htmlproofer clean; set a `status` to approved, rerun generator → status preserved; promotion creates a task only for approved rows. Output quality is bounded by upstream insight/context quality (out of scope).
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

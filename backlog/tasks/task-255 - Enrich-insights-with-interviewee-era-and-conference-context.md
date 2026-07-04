---
id: TASK-255
title: 'Enrich insights with interviewee, era, and conference context'
status: To Do
assignee: []
created_date: '2026-07-04 09:24'
updated_date: '2026-07-04 14:29'
labels:
  - pipeline
  - insights
milestone: Interview Archive Pipeline
dependencies:
  - TASK-251
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Layer external/historical context onto each interview: who the interviewee was at the time, the conference and its moment, the state of the topic in that era (2010-2015), and how it reads now. This feeds the "lessons for now" framing and followup questions. Context must be sourced/citable, not hallucinated — flag where uncertain.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each interview carries interviewee + era + conference context fields
- [ ] #2 A "lessons for now" framing is derived per interview
- [ ] #3 Context is sourced/citable and flagged where uncertain
- [ ] #4 It renders on the interview/interviewee pages (structure/presentation only)
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Hard constraints
- Generation routes ONLY through the extended audit prompt (TASK-251) OR a zdots `distill` job — NEVER a new `bin/*enrichment.rb` (that is the exact direct-LLM anti-pattern TASK-242 retires).
- Primary directive: user owns content. External "who they were in 2012 / state of the field then" context WILL hallucinate. 255 delivers the cited CONTAINER + `uncertain:true` slots + rendering; the USER supplies/verifies external prose + citations. Every external claim must carry `sources:[]` OR `uncertain:true` — never assert unsourced fact.

## Work
1. **Populate the `context:` block 251 defined (AC#1)** — `era`/`conference`/`topic`/`interviewee`, each `{summary, sources:[], uncertain}`, plus `lessons_for_now` (AC#2).
   - Transcript-grounded parts come from the audit pass (251).
   - External/historical parts: draft via a zdots `distill` job (allowed job type) that emits CANDIDATES flagged `uncertain:true` with empty `sources` for human verification — a scaffold, not asserted fact (AC#3).
2. **Validator (AC#3):** wire into `validate:all` — every `context.*.summary` must have `sources.size > 0` OR `uncertain:true`.
3. **Idempotency / merge (review-surface trap):** the context block is human-curated (user adds sources, clears `uncertain`). Regeneration MUST merge by field — never overwrite a field the user has verified (`uncertain:false` or has sources). Preserve human edits on rerun.
4. **Rendering — structure/presentation only (AC#4):**
   - `_layouts/interview.html` (data already wired L7-13 via `site.data.all_archive_items` + transcript): new "Context & Lessons" `<section>` — era/conference/topic summaries, "Lessons for now" list, followup questions; each summary shows citation links from `sources`; render a visible "unverified" marker when `uncertain:true`.
   - `_layouts/interviewee_detail.html`: person-scoped interviewee-context blurb with the same citation/uncertain treatment.
   - Honor CLAUDE.md: semantic markup, WCAG, print/ATS-friendly; never render an unsourced claim as fact — uncertain items visibly flagged.

## Verify
Run distill draft on 2-3 slugs; validator green (no unsourced-unflagged claim); interview + interviewee pages render era/conf/topic/interviewee + lessons with citations + uncertain badges; rerun preserves a manually-verified field; `rake build` + htmlproofer clean.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

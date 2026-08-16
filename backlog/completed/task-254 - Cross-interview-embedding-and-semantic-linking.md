---
id: TASK-254
title: Cross-interview embedding and semantic linking
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

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Reuse, do not rebuild
`bin/archive/modules/index.rb` ALREADY: (a) builds lesson text from summary+insights (L37-43), (b) `zdots-ctx add-lesson`, (c) enqueues an `embed` job `{table:lessons,id,text}` (L66-72), (d) stores `zdots_lesson_id`+`indexed_at` into the transcript YAML (L76-77). `zdots-brain query --semantic` (bin/zdots-brain-local L291-305) already does the pgvector `embedding <=> ?` cosine nearest-neighbor over the `lessons` table.

→ **AC#3 (semantic search over corpus) is ALREADY satisfied** by `zdots-brain query --semantic` over the lessons table. 254 VERIFIES it; it builds no new search engine.

## Net-new work
1. **Embed the richer signal (AC#1):** extend `index.rb` content builder (L37-43) to append 251's `quote`s + `lessons_for_now` so links reflect the extended insights; re-enqueue via `zdots-brain enqueue --force` (L336-341) to re-embed changed lessons idempotently. Drain with `zdots-ctx worker --type embed`.
2. **Linking step (AC#2):** new `bin/archive/modules/link.rb` + a `rake` task (mirror the enrich/index module wiring). Build reverse map `zdots_lesson_id → slug` from all transcript YAMLs. For each indexed lesson run the SAME pgvector op `query --semantic` uses, but NEIGHBOR-to-NEIGHBOR (not query-to-corpus), reusing STORED embeddings (no re-embedding at link time):
   `SELECT id, embedding <=> :target AS score FROM lessons WHERE embedding IS NOT NULL AND id <> :target ORDER BY embedding <=> :target LIMIT N`
   against `postgresql:///my` (same DB index.rb writes to) — via `bin/zdots-brain-local`'s Sequel models or raw SQL. Map neighbor lesson_ids → slugs.
3. **Classify link `kind` (AC#2):** `person` = shared interviewee (interviews.yml `interviewees`), `topic` = shared `topics`/`tags`, else `thread` (pure semantic).
4. **Write back (AC#4):** populate each transcript YAML `cross_links[].related: [{slug, lesson_id, score, kind}]` (fills the shape 251 reserved). Idempotent via a `linked_at` timestamp.

## Design guardrails
- All async stays on the zdots queue (embed job type) per DAG rule — no hand-rolled LLM calls.
- Linker is read-only against pgvector + write-back to YAML; it does not re-implement embedding or search.

## Verify
`zdots-ctx worker --type embed` drains; `zdots-brain query --semantic "clojure koans"` returns interview lessons (proves AC#3 reuse); run link task on 2-3 slugs → `cross_links.related` populated with scores + kinds; rerun is idempotent (`linked_at` skip). Link quality is bounded by upstream insight quality (out of scope here).
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

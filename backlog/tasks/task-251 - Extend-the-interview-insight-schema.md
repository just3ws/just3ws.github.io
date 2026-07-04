---
id: TASK-251
title: Extend the interview insight schema
status: To Do
assignee: []
created_date: '2026-07-04 03:24'
updated_date: '2026-07-04 14:29'
labels:
  - pipeline
  - insights
milestone: Interview Archive Pipeline
dependencies:
  - TASK-247
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The audit skill already emits `insights` (durable/time-bound). Extend that schema to capture the richer analysis requested: historical/era context (the 2010-2015 moment), conference + topic context, interviewee context, "lessons for now," followup questions, short-worthy quote timestamps, and cross-interview link anchors. Update the audit prompt (backlog/audit/outbox generation) to produce the extended fields, keeping backward compatibility with already-ingested insights.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The insight schema is extended with the new fields and validated
- [ ] #2 The audit prompt is updated to generate them
- [ ] #3 Existing ingested insights remain valid (backward-compatible)
- [ ] #4 Verified end-to-end on 2-3 interviews
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Scope
Extend the ONE canonical audit path only. Leave `bin/archive/modules/enrich.rb` and `bin/cerebral_enrichment.rb` untouched — they are direct-LLM scripts TASK-242 is retiring; do not spread the schema onto engines about to be deleted.

## Investigation findings
- Canonical audit prompt = `src/generators/transcript_processor.rb` `SYSTEM_PROMPT` (OUTPUT SCHEMA lines 33-48). `bin/prepare_audit_prompt.rb` extracts it into `backlog/audit/outbox/<slug>.md`; `rake transcript:process` uses it directly. Single source of truth.
- Ingest `bin/ingest_audit.rb` copies ONLY `speaker_map`/`turns`/`insights`/`youtube` (lines 53-56); new top-level keys are dropped unless added here.
- Current insight shape: `insights: [{statement, type: durable|time-bound, confidence: high|medium}]`.
- TIMECODE CHECK (verified corpus-wide): 196/196 transcripts have NO `content`, NO timecoded turns. So `timestamp` has NO source until TASK-247 diarization lands (this is why 251 deps on 247). The field is RESERVED/optional, populated later from diarized turns — the LLM must NEVER invent MM:SS.

## Extended schema (all additive/optional → backward compatible; add `schema_version: 2`, absence = v1)
- Per `insights[]` item, add: `quote` (verbatim short-worthy line, audit-selected), `timestamp` (MM:SS — reserved, filled from 247 diarized turns, OMIT until available), `anchor` (stable id e.g. `insight-1`, the cross-link target 254 references).
- New top-level `context:` block — subkeys `era`, `conference`, `topic`, `interviewee`, each `{summary, sources: [], uncertain: bool}`. 251 defines the container + the audit emits a transcript-grounded first pass; TASK-255 fills the citable/sourced external layer.
- New `lessons_for_now:` `[{statement, from_anchor}]` — "reads now" framing.
- New `followup_questions:` `[string]`.
- New `cross_links:` `[{anchor, related: []}]` — shape reserved; TASK-254 populates `related`.

## Files to touch
1. `src/generators/transcript_processor.rb` — extend SYSTEM_PROMPT OUTPUT SCHEMA + rules: `quote` verbatim only; DO NOT invent `timestamp` (leave absent unless diarized turns supplied); context summaries grounded in transcript, mark `uncertain: true` for anything not directly stated.
2. `.gemini/skills/transcript-conversational-audit/SKILL.md` — update step 2 generated-field list.
3. `bin/ingest_audit.rb` — persist new top-level keys (`context`, `lessons_for_now`, `followup_questions`, `cross_links`, `schema_version`) alongside existing four.
4. Rakefile `transcript:process` apply block (~L335) — same additive persistence.
5. Validator — extend `rake validate:audit_transcripts` (`Generators::ArchiveManager::TranscriptAuditor`) or add `bin/validate_insight_schema.rb` wired into `validate:all`: new fields well-formed when present; v1 records (statement/type/confidence only) still pass (AC#3 backward compat); assert no `timestamp` present unless a diarized turn exists.

## Verify
`rake audit:prepare[slug]` → generate → `rake audit:ingest[slug]` on 2-3 FRESHLY audit-processed slugs (not the stale near-duplicate `enrich.rb` output). Validator green on both new + existing v1 files. `rake build` clean.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

---
id: TASK-247
title: Fuse acoustic diarization into the audit skill's speaker map
status: To Do
assignee: []
created_date: '2026-07-04 03:24'
updated_date: '2026-07-04 14:28'
labels:
  - pipeline
  - transcription
milestone: Interview Archive Pipeline
dependencies:
  - TASK-244
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The transcript-conversational-audit skill already produces speaker_map (M1 interviewer / S1,S2 guests) and turns, but heuristically. Ground those turns on the acoustic boundaries from TASK-244 and have the LLM label each acoustic speaker → M1/S1/S2 using the interviewee metadata. This is a delta on the existing skill / rake audit path, not a new engine — the speaker_map/turns output must stay schema-compatible with the current ingest.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The audit skill consumes acoustic segments (TASK-244) as turn boundaries
- [ ] #2 The LLM labels acoustic speakers as the interviewer vs the named interviewees
- [ ] #3 speaker_map/turns output stays schema-compatible with the existing rake audit:ingest
- [ ] #4 Verified against 2-3 known-good interviews (e.g. the Jez Humble reference layout)
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Goal — ground the audit skill's heuristic turns on TASK-244's acoustic segments

This is a **delta on the existing `rake audit:*` path**, not a new engine. Today the turn split is heuristic in two places, both of which hardcode M1/S1 and never emit S2:
- `bin/structure_transcript_heuristics.rb` — deterministic regex splitter (question marks, "Hi, it's Mike" markers).
- `src/generators/transcript_processor.rb` `SYSTEM_PROMPT` — the LLM forensic prompt used via `bin/prepare_audit_prompt.rb`.

Replace the *guessing of turn boundaries* with the acoustic `diarization.segments` from 244; the LLM's only speaker job becomes **labeling** each acoustic `SPEAKER_xx` as the interviewer (M1) or a named interviewee (S1/S2…), using `interviews.yml.interviewees`.

## Pre-work wrinkle to repair (blocks the audit path on the current corpus)

`bin/prepare_audit_prompt.rb` line 34-35 reads `transcript_payload['content']`, but all 196 files are now structured (`turns`, no `content`) — so the prompt currently ships an empty transcript. 247 must fix the text source regardless of diarization:
- Source the raw text from `turns` (join `text`) when `content` is absent.
- Inject the acoustic segments so the LLM sees real boundaries + timing.

## Files to touch

- **`bin/prepare_audit_prompt.rb`**: (a) fall back to `turns`-joined text when `content` is nil; (b) add a `### ACOUSTIC DIARIZATION` section rendering `diarization.segments` (speaker, start, end, text) into the outbox prompt.
- **`src/generators/transcript_processor.rb`** (`SYSTEM_PROMPT`): change the turn instruction from "infer speakers via semantic role" to "**use the provided acoustic segments as turn boundaries**; map each `SPEAKER_xx` to M1/S1/S2 using the interviewee list; M1 is the interviewer (Mike Hall / UGtastic)." Extend the output schema to include per-speaker `acoustic_id` in `speaker_map` and to allow S2+ for multi-guest interviews.
- **`bin/structure_transcript_heuristics.rb`**: when a `diarization` block exists, build `turns` by walking acoustic segments (one turn per contiguous same-speaker run) instead of the regex heuristics, and support N speakers (`interviewees.length + 1`) rather than the hardcoded M1/S1. This becomes the non-LLM/offline path that still benefits from acoustic grounding.
- **`.gemini/skills/transcript-conversational-audit/SKILL.md`**: document that step 2 now consumes acoustic segments and only labels speakers.

## Schema compatibility (AC#3) — the load-bearing proof

`bin/ingest_audit.rb` loads the existing transcript payload and overwrites **only** four keys: `speaker_map`, `turns`, `insights`, `youtube` (lines 52-56). Therefore:
- `turns` stay exactly `{speaker, text}` — byte-identical shape to today. **Do not** put float timestamps on turns (the LLM would drop/mangle them); all timing already lives in the top-level `diarization` block from 244.
- The `diarization` block is NOT one of the four overwritten keys, so it **survives `audit:ingest` verbatim** — turns and timestamps stay linkable via `speaker_map[*].acoustic_id`.
- Only additive change to the four keys: each `speaker_map` entry may carry `acoustic_id: SPEAKER_xx`. `ingest_audit` copies `speaker_map` wholesale, so this passes through with zero ingest changes.

## Verification (AC#4)

Run against 2-3 known-good interviews, including the reference layout fixture **`_data/transcripts/jez-humble-goto-conference-2014.yml`**, plus one multi-guest interview (e.g. `steve-kim-jim-suchy-...`) to prove S2 labeling. Confirm: `speaker_map` binds each M1/S1/S2 to an `acoustic_id`, turn count roughly matches acoustic segment runs, `rake audit:ingest[slug]` writes cleanly, the `diarization` block is still present after ingest, and `bin/validate_data` + `bin/pipeline ci` pass.

## Coordination

Depends on TASK-244 (acoustic block + schema). Feeds TASK-250 (corpus backfill), TASK-251 (insight schema), and TASK-252 (captions from diarized turns). This task changes only the audit-skill/rake path — no new transcription engine.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

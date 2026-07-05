---
id: TASK-242
title: >-
  Extract generic AI capabilities into zdots; keep only interview-unique
  orchestration
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
updated_date: '2026-07-05 00:44'
labels:
  - pipeline
  - cleanup
milestone: Interview Archive Pipeline
dependencies: []
references:
  - >-
    zdots repo companion: Z-199 (Expose generic transcript-AI transforms as
    tenant-consumable zdots services)
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Target architecture (per the user): zdots is the transcription/AI **service provider** — it owns the generic heavy lifting (ASR transcription, acoustic diarization, distillation, embedding, semantic search). This repo is a **consumer** that orchestrates zdots jobs and evaluates/automates on the results. Audit the direct-LLM enrichment scripts (cerebral_enrichment, lexical_enrichment, generate_pivotal_metadata, local_perfect_transcript, archive/modules/{enrich,restructure}) and split by ownership: generic transformations move INTO zdots as service capabilities/job types; interview-unique logic (UGtastic brand normalization, interviewee/turn structuring) stays here and consumes zdots output.

NOTE: the original ponytail-audit premise ("route scripts onto the queue") was wrong — these scripts read/write the site's `_data` while zdots jobs operate on the zdots side (Downloads .txt + Postgres). This is a capability-boundary refactor, not a mechanical swap. `ruby_llm` is not a dependency (nothing to shed; scripts POST raw JSON to a local endpoint). The restructure trio that also calls the LLM is in TASK-241's deletion set, not in scope here. Spans two repos (this repo + the zdots platform repo).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each direct-LLM enrichment script is classified: generic capability (→ zdots) vs interview-unique (→ stays here, consumes zdots)
- [ ] #2 Generic transformations are implemented as zdots service capabilities/job types in the zdots repo
- [ ] #3 This repo's remaining scripts are thin orchestrators that enqueue to zdots and write results back to _data
- [ ] #4 The repo⇄zdots ownership boundary is documented (what is unique to the interview archive vs a reusable zdots capability)
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## TASK-242 Implementation Plan — route direct-LLM scripts onto the zdots queue

### CRITICAL FINDING — the premise needs correction before coding
I read the actual worker job contracts (`~/.config/zsh/lib/zdots/jobs/*.rb`, read-only). "Replace all 7 direct calls with distill/embed enqueues" does NOT hold: the queue jobs write to the **zdots side** (Downloads dir + zdots Postgres), while all 7 target scripts read AND write structured content back into the site repo's `_data/*.yml`. They are different pipelines with different output targets.

Also: no script uses the RubyLLM gem — all seven POST raw JSON to `http://127.0.0.1:8080/v1/chat/completions` via `Net::HTTP`. **AC #4 is already satisfied**: `ruby_llm` is not in the Gemfile/Gemfile.lock and nothing references the gem. No Gemfile change needed.

### Worker contracts (ground truth)
- **distill.rb**: payload `{"url": "..."}` → derives `<vid>` → reads `~/Downloads/transcripts/<vid>/<vid>.txt` (raises if absent) → fixed `distill.txt` prompt → creates a **zdots Lesson (LessonIntake)**. Does NOT accept site YAML, custom prompts, or write insights/turns/SEO back into `_data`.
- **embed.rb**: payload `{"table","id","text"}` → embeds `text`, writes vector into `<table>.<id>.embedding` in zdots Postgres. This is exactly what `bin/archive/modules/index.rb:72` already enqueues (canonical reuse pattern, with `Shellwords.escape` + priority `10`).
- **base.rb `Jobs.for`** raises `ArgumentError: unknown job type` — enqueuing a type the worker doesn't implement creates permanently-failing jobs. Do NOT invent type strings.
- **enqueue contract**: `zdots-ctx enqueue [--force] <type> <payload_json> [priority]`; fingerprint = `MD5(type + payload_json)`, deduped via `insert_conflict(target: :fingerprint)`. Idempotency/resumability come free IF the payload is deterministic (no timestamps/volatile keys).

### Per-script mapping (grounded, not tidy)
| Script | Purpose | Site output | Fits existing job? |
|---|---|---|---|
| cerebral_enrichment.rb | insights + youtube_description | writes `_data/transcripts`, `_data/video_assets` | distill is *lesson-shaped* but writes a zdots Lesson, NOT the site YAML → partial fit |
| lexical_enrichment.rb | near-duplicate of cerebral | same | same partial fit |
| archive/modules/enrich.rb | summary + topics + insights (idempotent via `enriched_at`) | writes `_data/transcripts` | same partial fit |
| forensic_restructure.rb | raw text → speaker `turns:` | writes `_data/transcripts` | NO existing job type |
| archive/modules/restructure.rb | same restructure (idempotent via `restructured_at`) | writes `_data/transcripts` | NO existing job type |
| local_perfect_transcript.rb | raw content → `turns:` | writes `_data/transcripts` | NO existing job type |
| generate_pivotal_metadata.rb | YouTube SEO title/description/chapters | writes `_data/interviews`, `_data/video_assets` | NO existing job type |
| (reference) archive/modules/index.rb | vectorize distilled text | zdots Postgres | **embed** — already correct, no change |

### Recommended approach (three buckets)
**Bucket A — lesson/insight extraction (cerebral, lexical, archive/modules/enrich): route to `distill`.**
- Reuse the `batch_ztranscribe.rb` pattern verbatim: scan `_data/interviews.yml` + `_data/video_assets.yml`, derive the YouTube URL from the `youtube` platform `asset_id`, then `system("zdots-ctx enqueue distill #{Shellwords.escape(payload)} 10")` where `payload = {"url":"https://www.youtube.com/watch?v=<yt_id>"}.to_json` (use `Shellwords.escape` per index.rb, not batch_ztranscribe's fragile single-quote interpolation).
- The three near-duplicate scripts collapse into ONE enqueue script (e.g. `bin/batch_zdistill.rb`); delete cerebral/lexical, and replace the AI body of `archive/modules/enrich.rb`.
- Idempotent/resumable via fingerprint on the deterministic `{url}` payload; re-running is a safe no-op.
- HARD CAVEAT to confirm with task author: distill's output is a **zdots Lesson** (semantic-search corpus), NOT the site's `insights`/`summary`/`topics`/`youtube_description` fields. Routing to distill DROPS the site-YAML write-back these scripts currently perform. Precondition: distill needs `~/Downloads/transcripts/<vid>/<vid>.txt`, which the `transcription` job produces — so distill is the natural downstream of the existing transcription enqueue, keyed by the same URL.

**Bucket B — transcript structuring (forensic_restructure, local_perfect_transcript, archive/modules/restructure) + SEO metadata (generate_pivotal_metadata): NO existing job type.**
- These produce site-YAML `turns:` / SEO metadata that no distill/embed/transcription/docs_sync job consumes or emits. Options:
  1. Define new job types (e.g. `restructure`, `seo_metadata`) that accept `{"transcript_id"}` and write back to the site — **but that worker code lives in the zdots repo, out of scope for this site repo** (and CLAUDE.md's structure-only directive). File a companion task against zdots; until those types are registered, do NOT enqueue them (worker raises unknown-type).
  2. Leave inline for now (mark this sub-scope blocked-on-zdots), routing only Bucket A in TASK-242.
- Recommendation: split TASK-242 — land Bucket A now; move Bucket B to a follow-up gated on new zdots job types.

**Bucket C — embed: already done.** `archive/modules/index.rb` already enqueues `embed {table,id,text}` correctly. Keep as the reference; no change.

### Primary-directive note
These scripts author CONTENT into `_data` (summaries, insights, YouTube descriptions, restructured turns). CLAUDE.md scopes this repo to structure/presentation, user owns content. Routing = mechanism refactor (in scope), but the behavior change in Bucket A (dropping site-YAML write-back) touches content ownership — confirm with the user before implementing.

### Order
1. Confirm the Bucket-A behavior change (lessons vs site-YAML write-back) with task author.
2. Implement Bucket A: create `bin/batch_zdistill.rb` (batch_ztranscribe clone → distill), delete cerebral_enrichment.rb + lexical_enrichment.rb, replace AI body in archive/modules/enrich.rb with an enqueue.
3. Bucket B: open zdots-repo companion task for `restructure`/`seo_metadata` job types; keep the 3 restructure scripts + generate_pivotal_metadata inline or mark out-of-scope here.
4. Bucket C: no change.

### Verify
- None of the 7 scripts are wired into `rake build` / `generate:all` / `validate:all` (verified against Rakefile) — so `bundle exec rake build` + `bundle exec rspec` stay GREEN regardless; the refactor is orthogonal to the build.
- Enqueue verification is deferred to implementation (worker not run here): dry-check idempotency by enqueuing twice and confirming the second is an idempotent skip via `zdots-ctx jobs`.
- AC #4: confirm `git grep -i ruby_llm` returns nothing and Gemfile is unchanged (already true).

### Addendum — complete job-type survey (grounds the "no existing job type" claim)
Surveyed ALL registered worker job types in `~/.config/zsh/lib/zdots/jobs/`, not just the ones the task named:
- **distill** → url → Downloads `.txt` → zdots Lesson (fixed prompt).
- **embed** → `{table,id,text}` → zdots Postgres vector.
- **transcription** → url → runs yt-transcribe recipe → Downloads.
- **docs_sync** → `{trace_id}` → rewrites a FIXED list of zdots-repo docs (README.md / docs/architecture.md / GEMINI.md under `Zdots::ZDOTDIR`) from a `SessionResidue`. Does not touch site `_data`, does not restructure transcripts, does not emit SEO → not a fit.
- **pattern_analysis** → analyzes operational-feedback rows into Recommendations; pure Sequel heuristics, no AI call → unrelated.
- **ingest_media / transcribe_chunk** → media/transcription-specific (skipped by purpose).

CONCLUSION CONFIRMED: no registered type consumes site-YAML transcript text to produce `turns:` (Bucket B restructure trio) or YouTube SEO metadata (generate_pivotal_metadata). Bucket B recommendation stands — new job types belong in the zdots repo (out of this site repo's scope), or keep those four inline / split TASK-242.

Wording correction on Bucket A: `distill` is the NEAREST-ADJACENT existing type, NOT a clean fit — it shares Bucket B's mismatch shape (reads a Downloads `.txt` not site YAML, fixed prompt, emits a zdots Lesson not the site's `insights`/`youtube_description`). Route to it only for the lesson/semantic-search purpose, with the site-YAML write-back explicitly dropped (per the hard caveat above). It is not a mechanical call-swap.
<!-- SECTION:PLAN:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: claude
created: 2026-07-04 14:57
---
Companion task created in the zdots repo (github.com/just3ws/zdots): **Z-199** — "Expose generic transcript-AI transforms as tenant-consumable zdots services". Its ACs cover the generic structured-distill job type + tenant-facing contract this task's AC#2/#3 depend on. Z-199 is uncommitted in the zdots repo (auto_commit is off there).
---

author: claude
created: 2026-07-05 00:44
---
Consumer path is now concrete: the zdots `transform` job type landed (Z-199, commit 15b162d) — enqueue `transform` with `{text, profile}`, fetch `{status, result:{output}}` via `zdots-ctx result <job_id>`; profiles are prompt files at `etc/prompts/jobs/transform/<name>.txt` (no code). So AC#2 (generic transforms as zdots job types) is satisfied platform-side. This repo's remaining work shrinks to: (1) author the transcript profiles (insights, SEO, cleanup) in the zdots prompts dir, and (2) thin orchestrators that enqueue `transform` and write the fetched result into `_data`, post-processing tenant-unique bits (UGtastic normalization, speaker_map M1/S1/S2) here. No new zdots job type needed for the enrichment bucket; diarization (TASK-244) remains the one genuine platform gap.
---
<!-- COMMENTS:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

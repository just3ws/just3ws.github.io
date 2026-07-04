---
id: TASK-242
title: Route direct-LLM enrichment scripts onto the zdots queue
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
labels:
  - pipeline
  - cleanup
milestone: Interview Archive Pipeline
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Several bin scripts call the LLM directly (RubyLLM / local endpoint) with no retry, idempotency, or dedup: cerebral_enrichment, lexical_enrichment, forensic_restructure, generate_pivotal_metadata, local_perfect_transcript, and archive/modules/{enrich,restructure}. Move them onto the durable zdots queue as `distill`/`embed` jobs (fingerprint-deduped, retried, resumable), reusing the existing batch_ztranscribe.rb enqueue pattern. This establishes the canonical async pipeline that the transcription, insight, and publishing tracks all build on.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Direct RubyLLM calls in the listed scripts are replaced with zdots enqueue (distill/embed)
- [ ] #2 Jobs are idempotent (fingerprint) and resumable after interruption
- [ ] #3 The batch_ztranscribe.rb enqueue pattern is reused, not reinvented
- [ ] #4 ruby_llm is removed from the site Gemfile if nothing calls it directly anymore
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

# task-011: Repair Broken Transcript — Igor Polevoy (igor-polevoy-general)

## Status
- **Status:** Blocked
- **Priority:** High
- **Owner:** Archive Operations
- **Date Created:** 2026-04-07

## Context
The transcript for `igor-polevoy-general.yml` is severely corrupted. It contains a repetitive loop ("I think that's where I learned a lot from you") that replaces the original conversation after the first few paragraphs. This prevents normalization and publication.

## References
- **Interview ID:** igor-polevoy-general
- **Video Asset ID:** igor-polevoy-general
- **Transcript File:** `_data/transcripts/igor-polevoy-general.yml`
- **Video URL:** https://vimeo.com/51479402

## Acceptance Criteria
- [ ] Source audio/video re-transcribed using high-confidence model.
- [ ] Transcript content replaced in `_data/transcripts/igor-polevoy-general.yml`.
- [ ] Transcript normalization protocol (TRANSCRIPTION_PROMPT.md) successfully executed.
- [ ] Site build validates without transcript integrity errors.

## Definition of Done
- [ ] Valid transcript content exists.
- [ ] Linkage chain (Interview -> Asset -> Transcript) is verified.
- [ ] Task updated to 'Ready' or 'Done'.

---
name: transcript-quality-check
description: Transcript hygiene checks for imported files, including empty content detection, malformed caption cleanup, and canonical YAML integrity checks.
---

# Transcript Quality Check

## Purpose
Verify transcript corpus quality before and after imports.

## Use When
- Large batches are imported.
- Validation fails or transcript rendering looks broken.

## Checks
- Missing transcript files for referenced `transcript_id`
- Empty or missing `content` blocks
- Invalid YAML structure
- Orphan transcript files not referenced by assets

## Commands
- `./bin/transcripts audit`
- `ruby ./bin/audit_transcripts.rb`

## Cleanup Guidance
- Prefer `.txt` source when duplicate stem exists (`.txt` + `.srt`).
- Keep transcript formatting readable; remove timing lines from caption formats.

---
name: archive-forensics
description: "Transform phonetic-heavy legacy transcripts into high-fidelity structured archives. Use when working with technical interview transcripts, repairing 'Whisper loops', applying 'UGtastic' brand normalization, or performing speaker diarization and turn-taking segmentation."
---

# Archive Forensics

Expert workflow for repairing and structuring legacy technical interview transcripts (2010-2015 era).

## Quick start

1. **Audit**: `bundle exec rake transcript:audit` to find missing content or loops.
2. **Normalize**: `./bin/apply_perfect_transcript_rules.rb <file>` to fix brand names (UGtastic) and tech jargon.
3. **Structure**: `./bin/structure_transcript_heuristics.rb <file>` to convert "wall-of-text" to speaker turns.
4. **Conversational Audit**: Use the `transcript-conversational-audit` skill for deep semantic analysis and insight extraction.

## Workflows

### 1. Phased Improvement
Don't try to make it perfect in one pass. Sequence your work:
1. **Clean**: Fix formatting and obvious brand errors (UGtastic).
2. **Structure**: Break into turns using heuristics.
3. **Enrich**: Use the `transcript-conversational-audit` skill to extract insights and fix complex technical jargon.

### 2. Branding (UGtastic)
Whisper often mishears "UGtastic" as "Uketastic", "Ute TASC", etc. 
- Use `./bin/apply_perfect_transcript_rules.rb` to apply global regex rules.
- This script is safe to run on both structured (turns) and legacy (content) transcripts.

### 3. Turn-Taking Segmentation (iMessage Style)
To convert a monolithic transcript into the "perfect" layout (like Jez Humble):
- Ensure `_data/interviews.yml` has the correct `interviewees`.
- Run `./bin/structure_transcript_heuristics.rb _data/transcripts/<slug>.yml`.
- Verify `speaker_map` and `turns` in the output YAML.

### 4. Loop Recovery (Whisper Artifacts)
If a transcript has infinite repetitions:
- Enqueue for re-transcription using the `standard` (Turbo) profile in `zdots-ctx`.
- Avoid the `max-accuracy` profile on current Apple Silicon hardware if looping persists.

## Quality Standards
- **Brand**: Always `UGtastic` (capitalization matters).
- **Conferences**: `GOTO Conference`, `RailsConf`, `SCNA`, `WindyCityRails`.
- **Formatting**: Clean paragraphs, no erratic word-wrapping, no leading spaces.

## Task Review Guidance
When reviewing a task from the backlog (e.g., `task-031 - Canonical-Review-—-How-to-say-UGtastic`):
- Check if the transcript is still in the legacy `content:` format.
- If so, the primary goal is **structuring** into turns.
- If it has loops, the primary goal is **re-transcription**.
- Always finish with **normalization** rules.

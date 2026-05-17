---
name: archive-forensics
description: Transform phonetic-heavy legacy transcripts into high-fidelity structured archives. Use when working with technical interview transcripts, repairing "Whisper loops", applying "UGtastic" brand normalization, or performing speaker diarization and turn-taking segmentation.
---

# Archive Forensics

Expert workflow for repairing and structuring legacy technical interview transcripts (2010-2015 era).

## Quick start

1. **Audit**: `bundle exec rake transcript:audit` to find missing content or loops.
2. **Normalize**: `./bin/perfect_transcripts.rb` to fix brand names (UGtastic) and tech jargon.
3. **Structure**: `./bin/structure_transcript_heuristics.rb <file>` to convert "wall-of-text" to speaker turns.

## Workflows

### 1. Phonetic Repair & Branding
Whisper often mishears "UGtastic" as "Uketastic", "Ute TASC", etc. 
- Use `./bin/perfect_transcripts.rb` to apply global regex rules.
- Maintain rules in the script to catch new phonetic drift variations.

### 2. Turn-Taking Segmentation (iMessage Style)
To convert a monolithic transcript into the "perfect" layout (like Jez Humble):
- Ensure `_data/interviews.yml` has the correct `interviewees`.
- Run `./bin/structure_transcript_heuristics.rb _data/transcripts/<slug>.yml`.
- Verify `speaker_map` and `turns` in the output YAML.

### 3. Loop Recovery (Whisper Artifacts)
If a transcript has infinite repetitions:
- Enqueue for re-transcription using the `standard` (Turbo) profile in `zdots-ctx`.
- Avoid the `max-accuracy` profile on current Apple Silicon hardware if looping persists.

## Quality Standards
- **Brand**: Always `UGtastic` (capitalization matters).
- **Conferences**: `GOTO Conference`, `RailsConf`, `SCNA`, `WindyCityRails`.
- **Formatting**: Clean paragraphs, no erratic word-wrapping, no leading spaces.

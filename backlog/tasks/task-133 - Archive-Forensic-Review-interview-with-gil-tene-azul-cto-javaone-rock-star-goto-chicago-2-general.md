# Archive Forensic Review: Interview with Gil Tene  Azul CTO & JavaOne Rock Star @ GOTO Chicago 2

## Metadata
- **Interview ID**: interview-with-gil-tene-azul-cto-javaone-rock-star-goto-chicago-2-general
- **Transcript ID**: interview-with-gil-tene-azul-cto-javaone-rock-star-goto-chicago-2-general
- **Status**: To Do
- **Priority**: Medium
- **Labels**: interview, archive-forensics

## Description
Perform a full archive forensic review on this interview to transform it from a raw transcript into a high-fidelity structured dialogue.

## Guidance
Use the `archive-forensics` skill. This interview is currently in the legacy `content:` format.

1. **Normalize**: Run `./bin/apply_perfect_transcript_rules.rb _data/transcripts/interview-with-gil-tene-azul-cto-javaone-rock-star-goto-chicago-2-general.yml`
2. **Structure**: Run `./bin/structure_transcript_heuristics.rb _data/transcripts/interview-with-gil-tene-azul-cto-javaone-rock-star-goto-chicago-2-general.yml`
3. **Enrich**: Use the `transcript-conversational-audit` skill for deep semantic analysis and insight extraction.

## Acceptance Criteria
- [ ] Brand name "UGtastic" is perfectly normalized.
- [ ] Monolithic content is converted into `speaker_map` and `turns`.
- [ ] Speakers (M1: Mike Hall, S1: Gil Tene) are correctly attributed.
- [ ] Technical jargon is corrected.
- [ ] Key engineering insights are extracted.
- [ ] Site rebuild confirms the "iMessage-style" thread layout is active.

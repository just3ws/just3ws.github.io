# Skill: Transcript Auditor

Expert guidance for auditing technical interview transcriptions to ensure structural integrity, diarization accuracy, and data preservation.

## Core Audit Metrics

### 1. Diarization Ratio
- **Interviewer (M1) vs. Guest (S1):** A healthy interview typically has a 20:80 or 30:70 word count ratio.
- **Red Flag:** If the interviewer has >50% of the words, the guest's turns may have been incorrectly attributed or collapsed.

### 2. Word Count Drift (The "Bork" Detector)
- **Baseline Comparison:** Compare the word count of the raw transcript (`.txt`) vs. the structured YAML (`.yml`).
- **Tolerance:** A drift of >10% suggests data loss (AI "summarizing" instead of transcribing) or hallucinations being stripped.
- **Critical Failure:** A 1000-word source reduced to 100 words in YAML.

### 3. Turn Density
- **Count:** Number of `speaker:` flips.
- **Red Flag:** A 30-minute interview with only 2-3 turns suggests a "Monolithic Block" error.

## Mike Hall Host Rule & Diarization Anchors

**Non-negotiable Domain Rule:** Mike Hall (`M1`) is ALWAYS the interviewer. If there is ambiguity in speaker attribution:
1. **Intro Framing (`M1`):** High-confidence host anchor. Opening turns usually feature: *"Hi, I'm Mike with UGtastic,"* establishing location (*"Here at GOTO Chicago / RailsConf"*), introducing who he is standing with, and framing the discussion topic.
2. **Asking Questions & Interacting (`M1`):** Short prompts, clarifying questions (*"What inspired you to..."*, *"Is there a common problem..."*), and active listening interjections (*"Right," "Exactly"*).
3. **Outro Sign-off (`M1`):** Closing turns feature: *"Thank you for taking the time to speak with me,"* *"I really appreciate you taking the time,"* and *"Find out more at UGtastic.com."*

---

## Audit Workflow

### Phase 1: Structural Scan
Check the physical properties of the YAML file.
- Are `speaker_map` and `turns` present?
- Does every turn have a valid speaker ID?

### Phase 2: Continuity Audit
Check the "Flip-Flop" of the conversation.
- **Consecutive Speakers:** Same speaker twice in a row usually indicates a missed split.
- **Turn Length:** Any turn >3000 characters is a candidate for forensic re-splitting.

### Phase 3: Hallucination Detection
Identify common AI "artifacts."
- **Repeating Loops:** "Thank you. Thank you. Thank you."
- **Out-of-Context CTAs:** "Subscribe to my channel," "Hit the bell."
- **Diarization Drift:** Guest suddenly speaking as the interviewer.

## Advanced Forensic Checks

-   **Lexical Presence:** Does the transcript contain the technical keywords defined in the metadata (e.g., "ActiveJDBC")?
-   **Silence Markers:** Are long pauses or [Music] jingles correctly handled?
-   **Ending Integrity:** Did the transcript cut off before the "Find out for yourself today at UGtastic.com" sign-off?

## Remediation Strategies

1.  **Minor Drift:** Re-run `normalize` stage via `bin/archive/pipeline.rb`.
2.  **Turn Length & Interviewer Overload:** Run `bin/forensic_repair.rb <id>` for automated sentence boundary turn-splitting.
3.  **Cross-Dataset ID Typos:** Run `bin/rename_transcript_id.rb <old_id> <new_id>` for verified cross-dataset updates.
4.  **Major Structural Failure:** Run `bin/diarize` (`pyannote.audio` 3.1) with guest count hints (`num_speakers = interviewees + 1`).

## Tools & Automation

- `./bin/transcript_ops.rb`: Primary CLI tool (`--status`, `--seed-context`, `--backfill-boundaries`, `--index-enriched`, `--forensic-audit`, `--all`).
- `bin/forensic_repair.rb`: Automated forensic turn-splitting tool.
- `bin/rename_transcript_id.rb`: Cross-dataset ID renaming tool.
- `rake transcript:pipeline`: Full archive ETLT pipeline check.
- `rake transcript:index`: PostgreSQL RAG vector indexing via `zdots-ctx`.
- `rake transcript:boundaries`: Theme song intro/outro boundary sidecar generation.
- `rake transcript:forensic_audit`: Run complete validation audit across all transcripts.
- `bin/archive/modules/validate.rb`: Automated schema, turn-length, and hallucination checks.
- `zdots-ctx query "<query>"`: Live semantic search over the `my` database vector store.

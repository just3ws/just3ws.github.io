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

1.  **Minor Drift:** Re-run `normalize` stage.
2.  **Major Structural Failure:** Run `forensic_restructure` using local AI with smaller chunk sizes (500 words).
3.  **Diarization Chaos:** Manual split using `bin/repair_...` script based on the raw text baseline.

## Tools
- `bin/archive/pipeline.rb --status`: High-level health check.
- `bin/archive/modules/validate.rb`: Automated schema and hallucination checks.
- `wc -w`: Command-line word count verification.

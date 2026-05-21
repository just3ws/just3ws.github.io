# Skill: Lexical Auditor

Expert guidance for high-efficiency technical spelling audits and identification of phonetic misspellings in transcript data.

## Initial Assessment

Before starting a lexical audit, define the **Target Lexicon**:
1.  **Product Names:** (e.g., ActiveJDBC, Rubinius, JRuby)
2.  **Person Names:** (e.g., Dmitriy Setrakyan, Igor Polevoy, Gil Tene)
3.  **Communities:** (e.g., Alt.NET, ChiPy, SCNA)
4.  **Common Hallucinations:** (e.g., "Closure" instead of "Clojure")

## Audit Workflow

### 1. Identify Phonetic Variances
Transcripts (especially from Whisper) often fail on technical jargon. Use fuzzy searching to find potential variances.
```bash
# Search for phonetic neighbors
grep -riE "JTBC|GDPC|JTBC" .
```

### 2. Frequency Analysis
Check how often a term appears to determine if it's a systemic error.
```bash
grep -ri "target_word" . | wc -l
```

### 3. Risk-Averse Correction (The Pipeline Pattern)
Instead of global `sed`, follow the ETLT pipeline pattern:
1.  **Extract:** List all files containing the misspelling.
2.  **Transform:** Update `bin/apply_perfect_transcript_rules.rb` with the new regex rule.
3.  **Load:** Run the pipeline stage for normalization.
4.  **Verify:** Check for boundary edge cases (e.g., ensuring "closures" isn't changed to "Clojure").

## Safety Rules

-   **Boundary Checks:** Always use `\b` in regex to avoid partial word replacements.
-   **Case Sensitivity:** Use case-insensitive matches `//i` but normalize to the canonical casing.
-   **Context Preservation:** Never apply a rule that replaces a generic word (e.g., "in closure") if it might refer to a valid non-technical concept.
-   **Verification Build:** Always run `bundle exec jekyll build` and `grep` the `_site/` directory to ensure the fix propagated to the UI.

## Tools

-   `grep -ri`: Fast searching.
-   `bin/archive/pipeline.rb --stage=normalize`: Safe, idempotent transformation.
-   `bin/apply_perfect_transcript_rules.rb`: The central technical lexicon engine.

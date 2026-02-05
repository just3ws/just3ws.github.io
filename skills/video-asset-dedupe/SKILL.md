---
name: video-asset-dedupe
description: Report-only duplicate analysis for video_assets and interviews, using title/entity matching and metadata correlation to produce ranked candidates, stats, and a top-10 review list. Use when dedupe/compression analysis is needed without modifying data.
---

# Video Asset Dedupe (Report-Only)

## Purpose
Generate a non-destructive duplicate analysis report for `video_assets` and `interviews`.

## Inputs
- `_data/video_assets.yml`
- `_data/interviews.yml`
- Optional transcripts (`_data/transcripts/*.yml`)
- Optional legacy context (`context/interviews-history/`)

## Output
Create report artifacts only (no data changes):
- Markdown report
- TSV report

### Report must include
- Counts: interviews analyzed, assets analyzed
- Rules executed
- Scoring weights
- Duplicate candidate list with scores and signals
- Top 10 candidates by confidence
- Low-confidence review queue

## Non-Destructive Rule
- Do **not** modify `video_assets` or `interviews`.
- Only create report files.

## Workflow
1. **Normalize**
   - Normalize titles and interviewee names.
   - Extract interviewees/entities from titles if missing.
   - Pull conference and year from `interviews` when available (stronger than title parsing).
2. **Compute signals**
   - Title similarity (token/Jaccard + edit distance)
   - Entity overlap (interviewee match)
   - Duration proximity (if available)
   - Published date proximity (if available)
   - Platform ID match (exact)
3. **Score candidates**
   - Weighted score: title similarity + entity overlap + metadata proximity.
4. **Classify**
   - Exact duplicate
   - Same content, different platform
   - Same guest, different interview
   - Likely false positive
5. **Report**
   - Output ranked list + top 10.

## Scoring Heuristics (Default)
- Platform ID match = 1.0 (exact)
- Same interviewee + title similarity >= 0.80 = likely duplicate
- Duration within ±10% = boost
- Published date within 90 days = boost
- Conflicting interviewees = downrank
- **Conference year mismatch**: if both interviews have a year (from `interviews`) and years differ, strongly downrank (likely not duplicate).
- **Conference name mismatch**: if both interviews have a conference name (from `interviews`) and they differ, strongly downrank.
  - Fall back to title parsing only if interview data is missing.

## Conference Rules
- Recognize conference tokens in titles:
  - `software-craftsmanship-north-america` / `scna`
  - `windycityrails`
  - `chicagowebconf`
  - `goto-chicago` / `goto`
- If both titles include a conference token and they do not match, treat as low-probability duplicate.

## Safety
- Prefer false negatives over false positives.
- Any ambiguity goes to the review queue.

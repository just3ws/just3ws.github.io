---
name: job-lead-evaluator
description: Evaluates job leads from wwworkremote.localhost against zdots-ctx personal context and canonical resume data to produce calibrated, zero-fluff job fit assessments.
---

# Job Lead Evaluator Skill

Use this skill when evaluating a job lead, posting, or career opportunity from `wwworkremote.localhost` to determine strategic alignment, role fit, and evidence coverage.

## Tone & Calibration Rules

- **Zero Hype / Zero Fluff**: Prohibit promotional adjectives ("visionary," "groundbreaking," "revolutionary").
- **Understated Fact-Density**: State context, constraint, concrete engineering action, and verified outcome.
- **Realistic Level Matching**: Assess role level (Staff vs. Principal) against actual scope, blast radius, and technical leverage required.

## Workflow Protocol

1. **Run the real scorer**: `ruby bin/evaluate_job_lead.rb --lead <LEAD_ID> [--escalate]` (wraps `bin/wwwr match` in
   `wwworkremote/core`, i.e. `LLM::ProfileMatcher` -- the same scorer the wwworkremote web UI's "analyze match" button
   calls). No `--escalate`: prints whatever analysis is already on file, free. With `--escalate`: runs a fresh LLM
   scan and persists it (costs tokens). **Do not** hand-build a fit matrix from `_data/resume/positions/*.yml` here --
   that's a different, unscored copy of the resume; the scorer is keyed off `wwworkremote`'s own `CareerProfile`, and
   a second hand-derived assessment just drifts from it. Don't curl `admin/leads/:id` directly either; the script
   already resolves lead -> posting internally.

2. **Query Personal OS Context (`zdots-ctx`)**:
   - Execute `/Users/mike/.config/zsh/bin/zdots-ctx query "<topic>"` for environmental/strategy signal the scorer
     doesn't know about (e.g. AuDHD environmental criteria, async documentation culture). This layers on top of the
     match output -- it doesn't replace it.

3. **Output Calibrated Fit Assessment**:
   - **Target Lead Summary**: Title, Company, Source Link.
   - **Match Analysis**: the `LLM::ProfileMatcher` output verbatim (score, tags, structured assessment) -- don't
     re-derive or restate it as a new table.
   - **Environmental & Strategic Fit**: zdots-ctx signal layered on top.
   - **Action Recommendation**: Pursue (generate Executive Brief) vs. De-prioritize (explain gap).

---
name: executive-brief-generator
description: Generates custom, tailored 1-page executive pitch briefs for target Staff/Principal Software Engineer roles using canonical resume data, zdots-ctx, and wwworkremote leads.
---

# Executive Brief Generator Skill

Use this skill when preparing tailored application briefs, pitch documents, or cover notes for specific target companies and roles.

## Tone & Level Calibration Rules

- **Zero Hype / Zero Fluff**: Prohibit promotional adjectives ("visionary," "transformational," "industry-leading").
- **Understated Fact-Density**: State context, constraint, concrete engineering action, and verified outcome (e.g. reduced MTTR by 60%, realigned acquisition domain boundaries, standardized OpenTelemetry across the service mesh).
- **Skeptical Peer Filter**: Write for an experienced Staff/Principal hiring manager who penalizes puffery and rewards crisp, quiet engineering signal.

## Workflow Protocol

1. **Get the real match analysis first**: `ruby bin/evaluate_job_lead.rb --lead <LEAD_ID> [--escalate]`. This wraps
   `bin/wwwr match` in `wwworkremote/core` (`LLM::ProfileMatcher`) -- the same scorer the wwworkremote web UI uses,
   keyed off its own `CareerProfile`. Use its score/tags/analysis as the evidence base for the brief. Don't fetch
   `admin/leads/:id` or `api/v0/job_postings/:id` directly and don't re-derive fit from `_data/resume/positions/*.yml`
   by hand -- that's a second, drifting scorer.

2. **Query Personal OS & Canonical Corpus (`zdots-ctx` + `_data/resume/`)**:
   - Query `/Users/mike/.config/zsh/bin/zdots-ctx query "<topic>"` for strategy guidelines and engineering lessons the
     scorer doesn't know about.
   - Pull supporting quotes/highlights from `_data/resume/positions/*.yml` and `_data/interviews.yml` for the case
     studies and technical-conversation sections below -- as source material for prose, not as a re-scoring input.

3. **Generate Tailored 1-Page Executive Pitch Brief**:
   - **Header**: Target Role, Company Profile, Lead Record Link, Tone Calibration statement.
   - **Strategic Alignment (3 Bullet Points)**: Match Mike's direct experience (Ruby/Rails, distributed systems, OpenTelemetry, domain isolation) to target company challenges.
   - **Proven Case Studies (2 Bullet Points)**: Detail system cartography and platform outcomes (OneMain Acquisition lane, EMR-Bear 90-day risk assessment).
   - **Relevant Technical Conversations**: 2 curated links to recorded technical discussions from `_data/interviews.yml`.

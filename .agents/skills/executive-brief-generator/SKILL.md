---
name: executive-brief-generator
description: Generates custom, tailored 1-page executive pitch briefs for target Staff/Principal Software Engineer roles using canonical resume data, zdots-ctx, and wwworkremote leads.
---

# Executive Brief Generator Skill

Use this skill when preparing tailored application briefs, pitch documents, or cover notes for specific target companies and roles.

## Tone & Level Calibration Rules

- **Zero Hype / Zero Fluff**: Prohibit promotional adjectives ("visionary," "transformational," "industry-leading").
- **Understated Fact-Density**: State context, constraint, concrete engineering action, and verified outcome (e.g. reduced MTTR by 60%, realigned acquisition domain boundaries, standardized OpenTelemetry across 36+ services).
- **Skeptical Peer Filter**: Write for an experienced Staff/Principal hiring manager who penalizes puffery and rewards crisp, quiet engineering signal.

## Workflow Protocol

1. **Query Job Market Context (`wwworkremote.localhost`)**:
   - Fetch job posting or lead data from `http://localhost:31000/api/v0/job_postings/:id` or `http://localhost:31000/admin/leads/:id`.
   - Identify core platform stack, domain requirements, scale bottlenecks, and level expectations.

2. **Query Personal OS & Canonical Corpus (`zdots-ctx` + `_data/resume/`)**:
   - Query `/Users/mike/.config/zsh/bin/zdots-ctx query "<topic>"` for strategy guidelines and engineering lessons.
   - Match role requirements against canonical resume positions (`_data/resume/positions/*.yml`), skills (`_data/resume/ats.yml`), and interview corpus (`_data/interviews.yml`).

3. **Generate Tailored 1-Page Executive Pitch Brief**:
   - **Header**: Target Role, Company Profile, Lead Record Link, Tone Calibration statement.
   - **Strategic Alignment (3 Bullet Points)**: Match Mike's direct experience (Ruby/Rails, distributed systems, OpenTelemetry, domain isolation) to target company challenges.
   - **Proven Case Studies (2 Bullet Points)**: Detail system cartography and platform outcomes (OneMain Acquisition lane, EMR-Bear 90-day risk assessment).
   - **Relevant Technical Conversations**: 2 curated links to recorded technical discussions from `_data/interviews.yml`.

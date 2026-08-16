---
name: executive-brief-generator
description: Generates custom, tailored 1-page executive pitch briefs for specific target Principal/Staff Software Engineer roles using the canonical resume and interview corpus.
---

# Executive Brief Generator Skill

Use this skill when preparing tailored application packages, cover letters, or executive briefs for specific target companies and roles.

## Workflow Protocol

1. **Ingest Job Context**: Analyze the target company's job description, key bottlenecks, scale challenges, and platform stack.
2. **Query Canonical Corpus**: Match the job description requirements against:
   - Recent high-impact positions (`_data/resume/positions/onemain.yml`, `emr-bear.yml`, `sk-holdings.yml`).
   - Relevant community craftsmanship interviews (`_data/interviews.yml`).
   - Core capabilities (`_data/resume/ats.yml`).
3. **Generate 1-Page Executive Pitch Brief**:
   - **Headline**: Mike Hall — Principal Software Engineer & Platform Architect.
   - **Strategic Alignment**: 3 bullet points matching Mike's direct experience to the target company's specific legacy tech debt or platform scaling challenges.
   - **Proven Case Studies**: 2 bullet points detailing system cartography outcomes (e.g. OneMain Acquisition lane, EMR-Bear 90-day risk assessment).
   - **Relevant Interviews**: 2 curated links to recorded technical discussions from `_data/interviews.yml`.

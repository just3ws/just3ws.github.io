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

1. **Query Canonical 3-Act Narrative & Datalake via MCP or CLI**:
   - Query CareerOS MCP tool `get_narrative_synthesis_baseline` (or `ruby bin/query_career_datalake.rb --narrative --json`) to retrieve the baseline 3-act narrative and proof points:
     * **Act 1 (The Foundation):** Autodidact, Software Craftsmanship, TDD, Community Leadership (Groupon, Obtiva, WindyCityRails).
     * **Act 2 (The Crucible):** High-Consequence Stabilizer (OneMain Acquisition Lane Architect, Speedfunds, 5-phase PII remediation engine, 4% traffic loss fix, 3-year OTel WG enablement arc).
     * **Act 3 (The Offering):** Calm, deterministic systems leadership for modern distributed platforms (local AI orchestration, pgvector search, property-based verification gates).

2. **Get Match Analysis & Company Pain from wwworkremote**:
   - Run `ruby bin/evaluate_job_lead.rb --lead <LEAD_ID> [--escalate]` to obtain the match analysis from `wwworkremote/core`.
   - Identify the company's core platform risk: legacy monolith refactoring, high concurrency, data privacy compliance, or distributed tracing.

3. **Query Personal OS & Canonical Corpus (`zdots-ctx` + `_data/resume/`)**:
   - Query `/Users/mike/.config/zsh/bin/zdots-ctx query "<topic>"` for personal strategy guidelines and lessons.
   - Pull supporting highlights from `_data/resume/positions/*.yml` and `_data/interviews.yml`.

4. **Synthesize Tailored 1-Page Executive Pitch Brief or Cover Memo**:
   - **Hook (Act 3 Offering):** Anchor as the Principal Software Engineer specializing in de-risking their specific platform transition.
   - **Proven Proof Points (Act 2 Crucible):** Select 2 to 3 matching historical outcomes (OneMain Acquisition lane, 5-phase PII engine, 4% traffic loss fix, enterprise OTel trace).
   - **Operating Philosophy (Act 1 Foundation):** Ground in System Cartography (mapping state before code changes), automated verification gates, and team enablement.
   - **Direct Call to Action:** Offer a 20-minute peer-level technical conversation on architecture and platform stability.

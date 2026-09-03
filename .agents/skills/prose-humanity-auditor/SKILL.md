---
name: prose-humanity-auditor
description: Audits technical prose across site Markdown, YAML data, resume, and case studies for plain language, neuroinclusive readability, cognitive load, and zero AI jargon.
---

# Prose Humanity & Neuroinclusive Readability Auditor Skill

Use this skill whenever authoring, editing, or evaluating resume content, case studies, technical summaries, executive pitch briefs, or website copy on `just3ws.com`. It ensures all writing is **human-centered, neuroinclusive, plain-spoken, and free of hyper-clinical AI jargon**.

Treat the archive and the hiring surface differently. A personal passage can be
TMI without being harmful or improper. Preserve the author's voice and the
historical record when the detail is theirs to tell. Recommend subtraction or
generalization when a detail adds exposure but not meaning. Escalate only when it
creates a concrete privacy, consent, health, identification, or professional
reputation risk.

---

## 🎯 Core Principles of Humane Technical Writing

### 1. Neuroinclusive Cognitive Load Reduction
* **Target Audience**: Write assuming a neurotypical, busy executive, founder, recruiter, or peer engineer reader.
* **Front-Load Bottom Lines**: Put the concrete action and outcome in the first 5-8 words.
* **Sentence Length Limit**: Keep sentences under 20-25 words. Split long compound sentences.
* **Scannable Structure**: Use clear, sequential H2/H3 headers and bulleted lists instead of dense walls of text.

### 2. Zero AI Jargon & Zero Hyper-Clinical Packaging
* **Prohibited AI Terms**: Reject over-intellectualized jargon (e.g., *"arithmetic witnesses"*, *"formal combat assurance"*, *"vector execution"*, *"synergistic alignment"*, *"thought leadership paradigm"*).
* **Grounded Translations**:
  - Instead of *"arithmetic witnesses"* &rarr; *"step-by-step combat logs for live damage previews and replays"*.
  - Instead of *"formal combat assurance"* &rarr; *"100% deterministic game state across WebSockets"*.
  - Instead of *"supply chain exposure"* (for open source) &rarr; *"open-source AGPLv3 license with OpenTelemetry tracing"*.

### 3. Active Voice & Descriptive Accessibility
* **Active Voice**: Use *"Subject performed action"* (e.g., *"Cut MTTR by 60% with OpenTelemetry"*) instead of passive voice (*"MTTR was reduced by 60%..."*).
* **Descriptive Link Anchors**: Never write *"click here"* or *"this link"*. Use descriptive target titles like *"Explore 4D System Cartography"*.

---

## 🛠️ Automated Audit Workflow

1. **Run the Prose Humanity Auditor Script**:
   ```bash
   ruby bin/audit_prose_humanity.rb [files...]
   ```
2. **Review Metrics**:
   - **AI Jargon**: Target `0`.
   - **Avg Words/Sentence**: Target `< 20.0`.
   - **Flesch-Kincaid Grade**: Target `8.0 - 12.0` (accessible high school to undergraduate readability).

3. **Refactor & Verify**:
   - Rewrite any flagged jargon or high-cognitive-load sentences into plain, grounded language.
   - Run `verify_site_contracts` to ensure formatting and link parity pass 100% clean.

## Editorial boundary pass

Before changing a passage, classify its destination:

- **Archive:** Keep meaningful dates, quotations, and technical history when the
  source is public and the detail is yours to publish.
- **Hiring surface:** Lead with current capability, outcomes, and scope. Remove
  unnecessary graduation dates, total-career-year claims, and exact tenure.
- **Personal essay:** Keep the lesson and voice. Generalize family, health,
  financial, and life-stage details that do not carry the lesson.
- **Third-party remembrance or interview:** Confirm that names, health details,
  family details, and contact information are appropriate to reproduce. A public
  source does not require reproducing every detail from it.

Run a rotated read before publication. Read the passage as the author, a busy
reader, a person named in it, a recruiter, and a search or social preview. Ask
whether each view can find the context, evidence, correction path, and a clear
way to connect. Do not confuse emotional vividness with reader value, and do not
confuse personal awkwardness with an ethical violation.

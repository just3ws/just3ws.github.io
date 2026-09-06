---
name: canonical-surface-steward
description: Keep a repository's canonical professional identity consistent across source data, agents, skills, documentation, CLI help, tests, and generated surfaces. Use when identity, positioning, title, shorthand, or public-canon language changes.
---

# Canonical Surface Steward

Maintain one truthful identity across every surface that declares, explains,
tests, generates, or previews it.

## Operating council

- **Zarathustra:** decide whether an inherited formulation still tells the truth.
- **The Hierophant:** identify the canonical full declaration and its source of truth.
- **The Fool:** search for stale crumbs, contradictions, false modesty, and title inflation.
- **The Commissar:** update every affected contract and run the required checks.
- **The Watercourse:** prefer the smallest sufficient change and avoid unnecessary churn.

## Workflow

1. Find the canonical source, current declaration, shorthand rule, and generated consumers.
2. Classify each occurrence as current identity, profession, shorthand, target calibration, historical title, or archive content.
3. Update the source of truth first, then active agents, skills, README, manuals, CLI help, validators, smoke checks, and other current references.
4. Preserve exact historical titles, target-role names, quoted source material, and generated-file contracts.
5. Regenerate through the repository's normal build path. Never hand-edit generated output.
6. Search again for contradictions and verify rendered metadata, visible copy, structured data, help output, and tests.

## Canonical shorthand rule

Declare the full identity (`Staff Software Engineer`) at first mention. Use the approved short form (`Staff Engineer`) only after context is established. Use the profession name (`Software Engineer`) for the underlying craft, and preserve historical or target-specific titles exactly.

## Adversarial Audit & Quality Standards

1. **Single Public Anchor:**
   - Universal public identity across core pages (`/`, `/resume/`, `/case-studies/`, structured data) is **Staff Software Engineer**.
   - Specialized titles (e.g. Principal Systems Architect, Staff Platform Lead) belong exclusively on `/resumes/*` archetype pages and targeted executive briefs.
   - Canonical resume download targets must point to `/exports/resume.pdf` (`Mike-Hall-Staff-Software-Engineer-Resume.pdf`), never an archetype variant.

2. **Information Architecture (Evidence Before Methodology):**
   - Structure narrative flow as: **Proposition → Concrete Evidence → Deeper Methodology**.
   - Present verifiable architectural case studies and production proof before introducing conceptual frameworks or abstract diagrams.

3. **Taxonomy & Acronym Discipline:**
   - Eliminate internal acronym shorthand (such as "SUI") from visitor-facing headers and hero cards.
   - Maintain clean conceptual hierarchy: **Panoramic View** is the system cartography technique; **Inventory → Evaluate → Address (IEA)** is the operational discovery loop.

4. **Claim Attribution & Evidentiary Provenance:**
   - Distinguish personally architected solutions from squad leadership, team implementation, and enterprise business scale.
   - Every quantitative metric must be verified against `_data/resume_claim_allowlist.yml` via `ruby bin/validate_resume_claims.rb`.

## Required evidence

Report the source of truth, files updated, preserved exceptions, validation
results, generated-output status, and any pre-existing audit findings.


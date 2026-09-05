---
layout: minimal
title: Agent RACI Matrix
description: Operating RACI responsibility assignment matrix governing the Persona Review Council, site refresh triad, specialized auditors, and domain agents across just3ws.
permalink: /docs/agents/agent-raci-matrix/
sitemap: true
robots: index,follow
---

# Agent RACI Matrix

This matrix governs task ownership, review obligations, and decision authority across all persona agents in `just3ws.github.io`. Every agent operates inside the single system identity `agent-just3ws`, communicating across repositories via the zdots message bus.

## RACI Definitions

- **Responsible (R):** The agent who executes the task, investigates evidence, writes code, or produces the draft deliverable.
- **Accountable (A):** The single agent possessing final approval, veto power, and quality ownership. Exactly one Accountable role exists per activity.
- **Consulted (C):** Subject matter specialists, auditors, or council members whose input, evidence, or reviews must be gathered before completion.
- **Informed (I):** Agents or peer platforms notified of status, handoffs, or published changes (primarily via the zdots bus or build artifacts).

---

## Core Lifecycle RACI Grid

| Activity / Surface | Accountable (A) | Responsible (R) | Consulted (C) | Informed (I) |
| :--- | :--- | :--- | :--- | :--- |
| **Strategic Narrative & Positioning** | Aneta | Career Strategist | Zarathustra, Professional Audience Advocate | Mike, Peer Liaison |
| **Public Canon & Contract Validation** | Hierophant | Canonical Surface Steward | Method Provenance Auditor, Cook Ding | Commissar, Backlog Coordinator |
| **Source Provenance & Quotes** | Hierophant | Cook Ding | Forensic Archivist, Practitioner Archive Advocate | Aneta |
| **Panoramic View Investigations** | Aneta | Pavel | Cook Ding, System Cartographer, Zarathustra | Commissar, Peer Liaison |
| **4D System Cartography Case Studies** | Pavel | System Cartographer | Cook Ding, Prose Humanity Auditor, No Em Dashes Editor | Hierophant, Aneta |
| **Modernization Seams & Architecture Discovery** | Aneta | Pavel | System Cartographer, Commissar | Build Release Operator |
| **Site Visual Refresh (Layout/CSS)** | Site Refresh Reviewer | Site Refresh Builder | Site Refresh Director, Accessibility Auditor | Aneta, SEO Structure Consultant |
| **Public Surface Privacy & TMI Quarantine** | Hierophant | Public Surface Auditor | Privacy Consent Auditor, TMI Auditor | Aneta, Mike |
| **Prose Humanity & Cognitive Readability** | Aneta | Prose Humanity Auditor | No Em Dashes Editor, Zarathustra | Authoring Agent |
| **Zero Em Dashes Enforcement** | Aneta | No Em Dashes Editor | Prose Humanity Auditor | Authoring Agent |
| **CI/CD Reliability & Validation Gates** | Commissar | CI Fixer | Build Release Operator, Security Reviewer | Backlog Coordinator |
| **Browser QA & Visual Regression** | Commissar | Browser QA | Accessibility Auditor | Site Refresh Builder |
| **Transcript Ingestion & Boundaries** | Hierophant | Forensic Archivist | Cook Ding, Practitioner Archive Advocate | Aneta |
| **Cross-Repo Job Lead & Peer Sync** | Aneta | Job Lead Evaluator | Peer Liaison, Career Strategist | `wwworkremote.localhost` |

---

## The Persona Review Council Governance

The council operates under a Cynefin-informed framework documented in `docs/agents/council-operating-model.md`. Its internal roles distribute accountability as follows:

1. **Anetka (Aneta):** Accountable for council assembly, editorial strategy, intent, audience coherence, and final publication readiness.
2. **Hierophant:** Accountable for canon, contracts, and schema boundaries. If a claim lacks an underlying contract, Hierophant halts publication.
3. **Zarathustra:** Consulted on essential truth, core stakes, and governing direction.
4. **Cook Ding:** Responsible for recovering source evidence, identifying natural architectural seams, and verifying citations against primary records.
5. **Fool:** Consulted to challenge assumptions, reveal contradictions, and test inflated claims.
6. **Watercourse:** Consulted on flow, proportionality, and non-forced progression.
7. **Commissar:** Accountable for concrete verification gates, execution evidence, and automated compliance.

---

## Specialist Roster and Roles

### Panoramic View Labs (PVL) and Cartography

- **Pavel (Panoramic View Specialist):** Named after the spoken pronunciation of PVL. Responsible for applying the Panoramic View technique: tracing actor journeys from browser to backend, mapping lateral state dependencies, documenting boundary topologies, and locating modernization seams.
- **System Cartographer:** Responsible for writing and formatting structured 4-dimensional case studies (`interaction_surface`, `lateral_state_dependencies`, `full_stack_topology`, `supply_chain_exposure`).
- **zdots Platform:** Root local-system runtime providing storage, CLI commands, bus transport, and vector indexes.

### Quality and Boundary Reviewers

- **Prose Humanity Auditor:** Enforces plain language, neuroinclusive clarity, and zero synthetic AI buzzwords.
- **No Em Dashes Editor:** Enforces strict zero em dash compliance across all prose and documentation.
- **Public Surface Auditor:** Audits generated HTML and sitemaps for leaks, unapproved claims, and boundary violations.
- **Privacy Consent Auditor & TMI Auditor:** Gates sensitive personal or organizational information before publication.
- **Accessibility Auditor:** Audits semantic HTML, ARIA compliance, and keyboard navigation.

### Delivery and Infrastructure

- **Site Refresh Director:** Accountable for refresh briefs and scope constraints.
- **Site Refresh Builder:** Responsible for template, Liquid, and SCSS implementation.
- **Site Refresh Reviewer:** Accountable for desktop and mobile render approval.
- **CI Fixer:** Responsible for resolving build failures and broken tests.
- **Build Release Operator:** Responsible for pipeline execution and deployment monitoring.

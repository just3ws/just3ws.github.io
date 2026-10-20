---
layout: minimal
title: LinkedIn Profile Mapping Guide
description: Authoritative mapping from canonical resume data and sovereign portfolio surfaces to LinkedIn profile concepts.
permalink: /docs/linkedin-profile-mapping-guide/
---

# LinkedIn Profile Mapping Guide

This guide defines the authoritative mapping from Mike Hall's canonical resume sources (`_data/resume/`), portfolio evidence, and sovereign root domain (`just3ws.com`) into LinkedIn's standard profile concepts.

It reflects the evolution of the system:
1. Sovereign identity and canonical URLs rooted at `https://just3ws.com`.
2. EMR-Bear Approach A compliance: strictly omitted from public resume and LinkedIn profile (disclosed only on formal post-offer background checks if requested).
3. Independent Project Rule: strictly two current independent projects (*Phalanx Duel* and *Technical Conversation Archive*), with local AI runtime experiments (`agent-tooling`) purged from public positioning.
4. Flagship Portfolio Features: anchoring *The Sovereign Verification Project* and *The Sound Above* oral history rewatch series in the Featured section.
5. Terminal IC Positioning: targeted as Staff Software Engineer or Principal Software Engineer across platform architecture, production systems, and observability.

---

## 1. LinkedIn Headline (220-Character Limit)

LinkedIn's headline is the single most indexed search field. It must clearly anchor technical domain authority without ambiguous management titles or buzzwords.

### Primary Recommended Headline (Staff Positioning)
```text
Staff Software Engineer | Platform Architecture, Production Systems & Reliability | OpenTelemetry & Legacy Modernization | just3ws.com
```
*Length: 133 / 220 characters.*

### Alternative Headline (Principal Systems Architect Positioning)
```text
Principal Software Engineer | Systems Architecture, Production Reliability & Observability | Distributed Systems & Incident Leadership | just3ws.com
```
*Length: 147 / 220 characters.*

---

## 2. LinkedIn About / Summary Section (2,600-Character Limit)

Mapped from `_data/resume/summary.yml`, `docs/site-refresh/panoramic-view-positioning.md`, and `docs/career-strategy-audhd-principal-engineering.md`.

It follows the 3-level scan architecture:
- **Level 1 (The 15-Second Hook):** Value proposition and core engineering promise.
- **Level 2 (The Core Practice):** Technical competencies, scale, and operating loops.
- **Level 3 (Sovereign Verification & Community):** Long-term stewardship, open research, and portfolio links.

### Copy-Paste Text for LinkedIn About
```text
I make complex software systems easier to understand and safer to change.

I am a Staff Software Engineer rooted in the discipline of software engineering. I work across multiple levels of system architecture: from low-level runtime behavior and telemetry through distributed asynchronous workflows and cross-team organizational boundaries.

I stay close to the code while helping engineering teams agree on what the system actually does, who owns it, and how to change it safely under live customer load.

What I Do:
• Platform Architecture & Legacy Modernization: Reconstructing undocumented execution flows, untangling multi-step state machines, and executing zero-downtime database and framework migrations.
• Production Reliability & Incident Response: Serving as final escalation lead for high-severity production failures, diagnosing live system pathology, and turning outages into permanent organizational and operational safeguards.
• Systems Observability: Founding and scaling OpenTelemetry working groups, defining metric and trace semantics across polyglot microservices, and aligning telemetry with actual business transactions.
• Sovereign Verification & Systems Tooling: Building deterministic, offline-capable developer runtimes, UNIX pipeline tooling, and local-first evaluation harnesses that hold non-deterministic systems accountable.

Selected Work & Proof:
1. OneMain Financial (Staff Software Engineer): Led acquisitions platform architecture, resolved multi-step session state integrity failures, founded the enterprise OpenTelemetry Working Group, and modernized core Rails services under continuous production load.
2. The Sovereign Verification Project: A 3-part forensic systems investigation analyzing DSP audio restoration, dual-model generative divergence, and domain boundaries under 345,000-volt high-tension transmission lines (just3ws.com/series/ai-competence/).
3. The Sound Above: A 37-episode technical rewatch series examining twenty years of Software Craftsmanship history, community building, and engineering stewardship (just3ws.com/series/the-sound-above/).
4. Phalanx Duel: A tactical rules engine and zero-indirection state machine built in Go, TypeScript, and SwiftUI (just3ws.com/phalanx-duel/).

Full Resume & Technical Deep Dives: https://just3ws.com
Direct Contact: mike@just3ws.com
```
*Length: ~2,250 / 2,600 characters.*

---

## 3. LinkedIn Featured Section (Primary Presence Portfolio)

LinkedIn allows pinning links, media, and articles at the top of the profile. Pin the following 4 canonical surfaces:

1. **Canonical Interactive Resume**
   - **URL:** `https://just3ws.com/resume/`
   - **Title:** Mike Hall: Staff Software Engineer (Interactive Resume & Technical History)
   - **Description:** Complete chronological career history, technical taxonomy, verified outcomes, and ATS plain-text exports.

2. **The Sovereign Verification Project**
   - **URL:** `https://just3ws.com/series/ai-competence/`
   - **Title:** The Sovereign Verification Project: AI Competence, Forensics & The Digital Theremin
   - **Description:** A 3-part architectural investigation analyzing whether AI code synthesis produces durable tools or overfitted mirages beneath high-tension power lines.

3. **The Sound Above Technical Rewatch Series**
   - **URL:** `https://just3ws.com/series/the-sound-above/`
   - **Title:** The Sound Above: 37-Episode UGtastic Technical Rewatch Series
   - **Description:** Historical practitioner dialogues and contemporary systems commentary examining software craftsmanship, testing, and autonomy from 2011 to 2026.

4. **Systems Cartography & Architecture Retrospectives**
   - **URL:** `https://just3ws.com/case-studies/`
   - **Title:** 4D System Cartography: Case Studies in Production Modernization
   - **Description:** Forensic methods for mapping legacy monoliths, identifying failure modes, and establishing safe operational boundaries.

---

## 4. LinkedIn Experience Section (Positions)

Each entry is mapped from `_data/resume/positions/*.yml`. LinkedIn limits position descriptions to 2,000 characters.

### Policy Guards:
- **EMR-Bear:** Omit completely from public LinkedIn profile (Approach A).
- **agent-tooling:** Omit completely from LinkedIn experience.
- **OneMain Financial:** Lead with acquisitions platform architecture, session state integrity, OTel leadership, and incident response.

### 1. OneMain Financial (Staff Software Engineer)
- **Title:** Staff Software Engineer
- **Company:** OneMain Financial
- **Dates:** 2021 to 2024
- **Location:** Chicago, IL (Remote)
- **Description:**
```text
Owned architecture for the Acquisitions platform across customer flows, partner integrations, and legacy systems in a regulated financial environment. Senior IC accountable for architectural integrity, production stability, and cross-team execution, with authority built through incident leadership and system knowledge.

Key Outcomes:
• Final escalation point for high-severity incidents: led live diagnosis, coordinated investigations across teams, aligned system understanding, and drove action plans with verified ownership.
• Turned production failures into institutional learning: ensured major incidents yielded tightened monitoring, clarified ownership models, updated documentation, and corrected cross-system touchpoints.
• Reconstructed end-to-end acquisition flows by mapping execution from browser layers through application tiers, middleware, and downstream services, creating the operational model for risk review and change planning.
• Re-architected session state handling across multi-step acquisition workflows, eliminating a persistent integrity failure that compromised customer tracking, diagnosis, and recovery.
• Founded and led the OpenTelemetry Working Group: set telemetry and trace standards, trained engineering and cybersecurity teams, and transitioned ownership once adoption became self-sustaining.
• Led platform modernization under continuous load: executed staged framework and database upgrades while maintaining regulatory compliance and zero unplanned downtime.
• Founded an enablement function to isolate platform, risk, and remediation engineering from feature delivery, securing sustained progress on long-horizon stability.
```

### 2. SK Holdings, Inc. (Senior Backend Developer)
- **Title:** Senior Backend Developer
- **Company:** SK Holdings, Inc.
- **Dates:** 2019 to 2020
- **Location:** Chicago, IL
- **Description:**
```text
Led backend stability, performance, and platform modernization for high-traffic Ruby on Rails applications, improving full-text search, campaign delivery pipelines, and data layer reliability while systems remained under live customer load.

Key Outcomes:
• Search Infrastructure Modernization: Eliminated external cluster failure modes and reduced infrastructure operating footprint by migrating legacy Sphinx search to optimized MySQL full-text search and relational indices under live production traffic.
• Zero-Downtime Rails Upgrades: Led Ruby and Rails framework upgrades across core applications, sequencing database schema migrations to guarantee zero downtime during platform modernization.
• Asynchronous Pipeline Optimization: Streamlined Redis and Sidekiq background job processing, isolating high-volume email campaign queues to prevent worker starvation and delivery latency.
```

### 3. ActiveCampaign (Senior Software Developer)
- **Title:** Senior Software Developer
- **Company:** ActiveCampaign
- **Dates:** 2018 to 2018 (Contract)
- **Location:** Chicago, IL
- **Description:**
```text
Senior contract engagement on the Contacts team of a high-scale customer experience automation and CRM platform. Focused on testability, query performance, and change safety inside a tightly coupled legacy backend.

Key Outcomes:
• Legacy Query Modernization: Replaced ad-hoc global data access with structured, cacheable query patterns in the PHP backend, enabling unit testability and sub-second query execution across multi-million contact datasets.
• Automated Verification Gates: Hardened Ember.js automated test suites across core CRM contact workflows, creating safety gates that enabled non-breaking legacy backend refactoring.
```

### 4. Earlier Engineering Experience (Selected Summary)
For earlier positions on LinkedIn (BenchPrep, ReachLocal, Coderwall, Groupon, TicketsNow / Ticketmaster, Obtiva, Follett), keep descriptions concise (under 800 characters) emphasizing hands-on delivery, distributed systems, and software craftsmanship.

---

## 5. LinkedIn Projects Section

Per `CODEX.md`, strictly two independent projects are featured:

### Project 1: Phalanx Duel
- **Name:** Phalanx Duel: Tactical Rules Engine & State Machine
- **Associated With:** Independent Engineering
- **URL:** `https://just3ws.com/phalanx-duel/`
- **Description:**
```text
A deterministic, multiplayer tactical rules engine that translates physical board game mechanics into zero-indirection software architecture. Built with an immutable state machine, strict event sourcing, WebSocket synchronization, and OpenTelemetry instrumentation in Go, TypeScript, and SwiftUI.
```

### Project 2: Technical Conversation Archive & The Sound Above
- **Name:** Technical Conversation Archive & The Sound Above Rewatch Series
- **Associated With:** Independent Engineering / UGtastic
- **URL:** `https://just3ws.com/series/the-sound-above/`
- **Description:**
```text
A sovereign archival platform and 37-episode technical rewatch series spanning 218 transcribed developer dialogues recorded between 2006 and 2026. Features speech-to-text forensic transcription, an open SQLite/DuckDB datalake, interactive transcripts, and contemporary systems leadership commentary bridging historical craftsmanship with AI-era software architecture.
```

---

## 6. LinkedIn Skills & Endorsements (Top 5 Pinned)

LinkedIn permits up to 50 skills, but recruiters scan the top 5 pinned skills first:

### Pinned Top 5:
1. **Platform Architecture**
2. **Distributed Systems**
3. **Observability (OpenTelemetry)**
4. **Production Systems & Reliability**
5. **Ruby on Rails**

### Complete 30-Skill Set for Search Indexing:
- **Architecture & Reliability:** Platform Architecture, Distributed Systems, Software Craftsmanship, Incident Response, Root Cause Analysis, Legacy Modernization, System Cartography, Systems Architecture, Reliability Engineering.
- **Observability & Operations:** OpenTelemetry, Observability, Telemetry, Linux, UNIX, Docker, Kubernetes, Amazon Web Services (AWS), CI/CD, Infrastructure as Code.
- **Data & Backends:** Ruby on Rails, Ruby, PostgreSQL, SQL, Redis, Sidekiq, MySQL, Asynchronous Processing, Data Integrity.
- **AI & Modern Runtimes:** Model Context Protocol (MCP), Autonomous Agent Runtimes, Forensic Audio Engineering, Go (Golang), TypeScript.

---

## 7. Interactive Localhost Tooling

The live web tool at `https://just3ws.localhost/linkedin/` automatically generates formatted copy-paste blocks for all sections, computes live character counts against LinkedIn's field limits, and warns if any field exceeds boundaries.

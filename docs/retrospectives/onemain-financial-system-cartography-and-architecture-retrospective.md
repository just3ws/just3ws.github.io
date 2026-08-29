# OneMain Financial: 5-Year Career Retrospective & Architecture Portfolio

* **Company:** OneMain Financial (Regulated Consumer Lending & Digital Originations)
* **Tenure:** January 2021 to February 2026 (5 Years)
* **Role Progression:** Senior Software Engineer (Originations) -> Verification Squad Lead -> Software Architect (Acquisition Lane) -> Associate Director, Staff Engineer
* **Core Technical Domains:** System Cartography, OpenTelemetry Distributed Tracing, Legacy Modernization, PII Remediation, Developer Enablement

---

## 1. Executive Summary & The Leadership Mandate

When joining OneMain Financial in early 2021, the digital lending platform was undergoing rapid expansion. Over a decade of feature accretion had created implicit lateral state dependencies across distributed Ruby on Rails monoliths, MuleSoft API integration layers, and IBM mainframe core banking systems.

In 2022, Director Lance Smith appointed Mike Hall as **Software Architect for the Acquisition Lane** with an explicit executive mandate:
1. **Untangle the Monolith:** Map seven heterogeneous customer acquisition channels processing hundreds of millions in loan volume.
2. **Decouple Lane Boundaries:** Establish clean domain isolation between Acquisition and digital Originations.
3. **Eliminate Dark Failure Modes:** Diagnose and fix a persistent, unmonitored defect silently dropping 4% of loan applications during final e-signing.
4. **Deploy Enterprise Observability:** Build the Enterprise Trace connecting Rails, MuleSoft, and Mainframe backends.
5. **Foster Durable Enablement:** Create an internal community of practice to upskill cross-lane engineers and transition ongoing governance to SRE.

---

## 2. The 5 Architectural Chapters

```
+-------------------------------------------------------------------------+
| CHAPTER 1: ORIGINATIONS & SPEEDFUNDS (Instant Loan Funding)             |
| Architected instant funding to debit cards in minutes vs multi-day ACH. |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
| CHAPTER 2: SYSTEM CARTOGRAPHY ACROSS 7 ACQUISITION CHANNELS             |
| Mapped web, mobile, direct mail, affiliate APIs, and renewal workflows. |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
| CHAPTER 3: FORENSIC DATABASE ARCHAEOLOGY & 5-PHASE PII ENGINE           |
| Purged legacy clarity_ orphan data across 30+ tables safely.            |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
| CHAPTER 4: ILLUMINATING DARK TELEMETRY & THE 4% TRAFFIC FIX             |
| OpenTelemetry deployment across Rails, MuleSoft, and Mainframe.         |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
| CHAPTER 5: SUSTAINABLE COMMUNITY ENABLEMENT (Geekfest to SRE)           |
| 3-year enablement arc: weekly brown bags -> OTel WG -> SRE handoff.     |
+-------------------------------------------------------------------------+
```

---

### Chapter 1: Originations IC Delivery & Speedfunds
* **The Challenge:** Traditional loan funding relied on multi-day ACH transfers, causing friction and post-approval drop-off.
* **The Technical Intervention:** Led the Originations Verification squad through consecutive Exceeds Expectations ratings. Architected and shipped the **Speedfunds** instant disbursement pipeline, enabling real-time loan funding directly to borrower debit cards within minutes.
* **The Structural Result:** Shortened funding turnaround from 48 hours to under 5 minutes; established robust state machine verification gates preventing double-disbursement risks.

---

### Chapter 2: System Cartography Across 7 Acquisition Channels
* **The Challenge:** The Acquisition codebase handled seven disparate ingress paths (direct web, mobile apps, partner affiliate APIs, direct mail invitation codes, branch walk-in portal, and pre-approved renewal funnels). Business logic was scattered across hundreds of conditionals and untracked A/B test branches.
* **The Technical Intervention:** Founded the ACQ Enablement squad. Systematically inventoried customer entry points, API payloads, state transitions, and background Sidekiq jobs. Built empirical sequence diagrams and state charts reconciling business rules with runtime code execution.
* **The Structural Result:** Unblocked multiple parallel product feature squads, enabling safe refactoring of customer prequalification pipelines with zero regression outages.

---

### Chapter 3: Forensic Database Archaeology & The 5-Phase PII Engine
* **The Challenge:** Regulatory compliance required total purging of unneeded applicant personally identifiable information (PII). Legacy data structures contained unindexed 9-digit SSNs buried in `partial_applications.fragments` and orphan `clarity_` and `underwriting_` tables.
* **The Technical Intervention:** Executed deep database archaeology across 40+ applicant database tables. Designed an automated, 5-phase deletion and migration engine with strict transaction boundaries and idempotency keys.
* **The Structural Result:** Purged millions of sensitive orphan records across 30+ tables in production Rails code without locking tables or interrupting active loan applications.

---

### Chapter 4: Enterprise OpenTelemetry & Eliminating the 4% Silent Loss
* **The Challenge:** A persistent, dark failure mode silently corrupted application state and dropped 4% of loan applicants during final document preparation and electronic signing. Logs provided no cross-service causality between Rails and MuleSoft APIs.
* **The Technical Intervention:** Led the enterprise OpenTelemetry deployment across Rails services, MuleSoft middleware, and Mainframe backends. Partnered with Cybersecurity, SRE, Incident Command, and the Enterprise Monitoring Center (EMC) to establish the unified **Enterprise Trace**.
* **The Structural Result:** Reconstructed the causal event chain, isolated the race condition in the document preparation service, and eliminated the 4% traffic loss defect, protecting millions in annual origination volume.

---

### Chapter 5: Sustainable Community Enablement & SRE Handoff
* **The Challenge:** Engineering departments operated in isolated silos with minimal cross-lane architectural sharing.
* **The Technical Intervention:** Drove a 3-year cultural and technical enablement initiative:
  1. Founded **Geekfest@OMF** (weekly recorded technical brown-bag sessions across the enterprise for 1 full year).
  2. Evolved the forum into the weekly **OpenTelemetry Working Group (OTel WG)**, scaling voluntary weekly attendance to 40+ engineers across 6 lanes.
  3. Partnered with SRE leadership to transition ongoing operational facilitation, establishing a permanent, self-sustaining community of practice.
* **The Structural Result:** Institutionalized distributed tracing standards enterprise-wide, allowing Mike to return to core Acquisition Lane architecture representation.

---

## 3. Curated 8-Article Technical Publication Roadmap

These 8 article concepts translate the OneMain Financial architectural milestones into high-signal, public technical writing:

```
+-----------------------------------------------------------------------------------------------+
|                                  TECHNICAL ARTICLE ROADMAP                                    |
+-----------------------------------------------------------------------------------------------+
| 1. System Cartography: Mapping 10-Year Monoliths | 5. Instant Money: Real-Time Debit Pipelines|
| 2. Database Archaeology: Multi-Table PII Purging | 6. Conway's Law: Growth vs Enablement Teams|
| 3. Eliminating Dark Failure Modes (4% Bug Fix)   | 7. Communities of Practice: The 3-Year Arc |
| 4. Enterprise OTel: Rails to Mainframe Tracing   | 8. Practical Local AI for Legacy Discovery |
+-----------------------------------------------------------------------------------------------+
```

### Article 1: System Cartography: How to Map a 10-Year Monolith Without Losing Your Mind
* **Target Audience:** Staff Engineers, Principal Architects, Engineering Directors.
* **Core Thesis:** Before refactoring legacy software, you must build empirical system maps across 4 dimensions: interaction surfaces, lateral state dependencies, network topology, and supply chain exposure.
* **Key Proof Points:** Mapping 7 disparate acquisition funnels at OneMain Financial; identifying implicit state branches before touching code.

---

### Article 2: Database Archaeology: Safely Purging Millions of Sensitive Records from Active Schemas
* **Target Audience:** Database Administrators, Principal Backend Engineers, Security Leads.
* **Core Thesis:** Compliance deletion in live production relational databases requires a multi-phase deletion engine with strict transaction budgeting, orphan isolation, and idempotency.
* **Key Proof Points:** Designing a 5-phase deletion engine across 30+ tables; unearthing unindexed SSN fragments without locking tables.

---

### Article 3: Hunting the 4% Defect: How Distributed Tracing Solves Silent Multi-Service Failures
* **Target Audience:** SREs, Incident Commanders, Platform Architects.
* **Core Thesis:** The most dangerous software bugs are silent failure modes that drop traffic without throwing 500 errors. Only end-to-end distributed trace propagation illuminates these dark failure states.
* **Key Proof Points:** Reconstructing the e-signing document preparation causal chain across Rails, MuleSoft, and Mainframe tiers.

---

### Article 4: Rolling Out OpenTelemetry in the Real World: Lessons from Rails to Mainframe
* **Target Audience:** Platform Engineers, Observability Specialists.
* **Core Thesis:** Enterprise observability is not about installing a collector agent; it is about establishing W3C trace context standards across heterogeneous legacy runtimes.
* **Key Proof Points:** Bridging Rails distributed monoliths, MuleSoft API gateways, and IBM mainframe backends into unified trace spans.

---

### Article 5: Instant Money: Architecting Real-Time Debit Card Loan Disbursement Under Strict Compliance
* **Target Audience:** Fintech Engineers, Payments Architects.
* **Core Thesis:** Transitioning from multi-day ACH to sub-5-minute card disbursements requires deterministic state verification gates to eliminate double-spend and settlement race conditions.
* **Key Proof Points:** The Speedfunds pipeline architecture and transaction reconciliation mechanisms.

---

### Article 6: Conway's Law in the Trenches: Why We Split Growth and Enablement Squads
* **Target Audience:** VPs of Engineering, Engineering Managers, Principal Leaders.
* **Core Thesis:** When feature velocity grinds to a halt, code is rarely the primary culprit; misaligned team topologies are. Creating dedicated Enablement squads gives Growth teams the safety nets they need to move fast.
* **Key Proof Points:** Establishing ACQ Enablement at OneMain Financial; reducing cross-squad ticket blocking.

---

### Article 7: From Geekfest to SRE: The 3-Year Lifecycle of a Sustainable Engineering Community
* **Target Audience:** Engineering Culture Advocates, Staff+ Leaders.
* **Core Thesis:** Successful technical communities must follow a clear lifecycle: founder momentum -> focused working group -> formal handoff to operational stewards. If it cannot survive without the founder, it is not an enablement win.
* **Key Proof Points:** The evolution of Geekfest@OMF to the OTel WG to permanent SRE operational facilitation.

---

### Article 8: Pragmatic Local-First AI for Enterprise Code Discovery
* **Target Audience:** AI Engineers, Staff Software Engineers.
* **Core Thesis:** You do not need to send proprietary enterprise codebases to public cloud LLMs to gain AI leverage. Local-first runtimes and schema inference tools provide safe, privacy-compliant developer acceleration.
* **Key Proof Points:** Hackathon wins with Bonsai Buckaroos schema inference and local LLM developer tooling at Geekfest.

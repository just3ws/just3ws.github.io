---
layout: archetype-resume
body_class: ats-resume
archetype_key: observability_resilience_specialist
title: "Mike Hall - Staff Observability and Resilience Architect"
description: "Observability and Resilience Architect specializing in illuminating dark telemetry, enterprise OpenTelemetry rollouts, and deep incident root cause triage. Eliminates cross-service blind spots by engineering end-to-end distributed trace propagation across legacy microservices and modern cloud infrastructure."
canonical_url: https://www.just3ws.com/resumes/mike-hall-observability-resilience-specialist/
permalink: /resumes/mike-hall-observability-resilience-specialist/
sitemap: true
robots: index,follow
---

# Mike Hall

**Staff Observability & Resilience Architect**
Chicago, IL

- Email: [mike@just3ws.com](mailto:mike@just3ws.com)
- Phone: [(847) 877-3825](tel:+18478773825)
- Website: [just3ws.com](https://www.just3ws.com)
- LinkedIn: [linkedin.com/in/just3ws/](https://www.linkedin.com/in/just3ws/)
- GitHub: [github.com/just3ws](https://github.com/just3ws)

---

## Professional Summary

Observability and Resilience Architect specializing in illuminating dark telemetry,
enterprise OpenTelemetry rollouts, and deep incident root cause triage. Eliminates
cross-service blind spots by engineering end-to-end distributed trace propagation across
legacy microservices and modern cloud infrastructure.

---

## Core Competencies & Skills

OpenTelemetry Working Group Leadership & Governance, Distributed Trace Context
Propagation (W3C Trace Context), OTel Collector Pipeline Engineering (Receivers,
Processors, Exporters), Dark Telemetry Illumination & Latency Bottleneck Detection, Edge
PII Scrubbing, Masking & Sensitive Data Governance, Production Incident Triage for 100+
Person Bridge Calls, APM & Backend Integration (OpenObserve, Datadog, ELK, Prometheus),
High-Concurrency Distributed Systems Reliability

---

## Experience & Leadership

### Associate Director, Staff Engineer at OneMain Financial

**January 2021 - February 2026** | Remote

**Target Focus:** Founded and led the OpenTelemetry Working Group, establishing
distributed observability across application and integration boundaries and connecting
system signals to incident response and safer change.

**Key Outcomes:**
- Originations IC Delivery & Instant Disbursement: Led the Originations Verification
  squad through consecutive Exceeds Expectations ratings, architecting and shipping an
  instant loan disbursement pipeline (funding to debit cards in minutes). Appointed
  Software Architect for the Acquisition Lane, later converting to Associate Director,
  Staff Engineer.
- Acquisition Workflow Enablement & Architecture Discovery: Founded the Acquisition Lane
  enablement team; mapped the loan acquisition and origination pipeline end-to-end from
  visit to booked loan (desktop browser to mainframe and back again at each step) and
  the Affiliate API at the same depth, identifying seven distinct lending funnels with a
  tracking initiative; architected an automated 5-phase PII remediation deletion engine
  across 30+ tables.
- Enterprise Resilience & DynamoDB Session Remediation: Diagnosed and eliminated a
  critical session-cookie overflow defect that caused 4% silent traffic loss of digital
  loan applications during e-signing; architected zero-downtime blue/green migration to
  DynamoDB session store with zero incidents.
- Enterprise Trace & Operational Alignment: Architected distributed telemetry across
  Rails distributed monoliths, MuleSoft APIs, and IBM mainframe backends; partnered
  directly with Cybersecurity, EMC, SRE, and Incident Command to align monitoring with
  end-to-end distributed tracing.
- Community Enablement & SRE Handoff: Founded weekly Geekfest@OMF and scaled the
  enterprise OpenTelemetry Working Group to 40+ cross-lane engineers; mentored and
  partnered with SRE leads to transition ongoing operational facilitation, establishing
  a durable community of practice.
- Applied AI & Innovation Leadership: Placed in two corporate hackathons building
  conversational agents with Rasa and a schema inference prototype; pioneered local LLM
  orchestration and privacy-conscious AI developer tooling at Geekfest@OMF.

### Senior Backend Developer at SK Holdings, Inc.

**January 2019 - December 2020** | Chicago, IL

**Target Focus:** Standardized asynchronous Sidekiq error observability, queue latency
metrics, and automated deployment alerts.

**Key Outcomes:**
- Search Infrastructure Modernization: Eliminated external cluster failure modes and
  reduced operating footprint by migrating legacy Sphinx to optimized MySQL full-text
  search and relational indices under live production traffic.
- Zero-Downtime Rails Upgrades: Led Ruby and Rails framework upgrades across core
  applications, sequencing database migrations to ensure zero downtime during platform
  modernization.

### Principal Architect at Phalanx Duel

**January 2022 - Present** | Independent Project

**Target Focus:** Instrumented distributed WebSocket match transitions with
OpenTelemetry trace context, Sentry error telemetry, and property-based verification
gates across client-server boundaries.

**Key Outcomes:**
- Designed a deterministic engine with replayable action logs and server-authoritative
  state transitions, making complex outcomes reproducible and independently verifiable.
- Built replay validation, adversarial coverage, and CI verification gates so state
  transitions can be checked across the complete lifecycle.
- Uses controlled agent workflows with bounded tasks, acceptance criteria, automated
  checks, and human-reviewed outputs rather than treating model output as authority.

### Senior Software Developer at ActiveCampaign

**September 2018 - December 2018** | Chicago, IL

**Target Focus:** Made previously opaque PHP backend behavior observable through
structured query patterns and test coverage, improving change safety and developer
feedback loops.

**Key Outcomes:**
- Legacy Query Modernization: Replaced ad-hoc global data access with structured,
  cacheable query patterns in the PHP backend, enabling unit testability and sub-second
  query execution.
- Frontend Verification Gates: Hardened Ember.js automated test suites across core CRM
  contact workflows, creating safety gates that enabled non-breaking legacy PHP
  refactoring.

### Software Engineer & Technical Onboarding Lead (Fraud & Taxonomy Systems) at Groupon

**July 2011 - May 2013** | Chicago, IL

**Target Focus:** Engineered fraud detection queries in Vertica and conducted
exploratory anomaly detection spikes in Hadoop and Clojure.

**Key Outcomes:**
- Centralized Taxonomy Service: Implemented merchant taxonomy service in Java and MySQL,
  eliminating categorization drift across distributed product teams during hypergrowth.
- Analytical Fraud Detection: Built analytical fraud detection queries in Vertica and
  conducted exploratory spikes on Hadoop and Clojure for transaction anomaly scoring.
- Merchant Analytics Pipelines: Built high-throughput merchant analytics tools in Ruby
  and CouchDB, surfacing market insights for global sales operations.
- Global Engineering Enablement: Redesigned technical onboarding curricula,
  standardizing engineering practices and shortening time-to-first-commit for 100+
  global engineering hires.

---

## Selected Production Projects

### Principal Architect (Phalanx Duel)
**January 2022 - Present**

Designing and building a real-time tactical game platform as a current hands-on
laboratory for deterministic systems, product architecture, and controlled AI-assisted
engineering.

- Designed a deterministic engine with replayable action logs and server-authoritative
  state transitions, making complex outcomes reproducible and independently verifiable.
- Built replay validation, adversarial coverage, and CI verification gates so state
  transitions can be checked across the complete lifecycle.
- Uses controlled agent workflows with bounded tasks, acceptance criteria, automated
  checks, and human-reviewed outputs rather than treating model output as authority.

### Principal Engineer & Curator (Technical Conversation Archive)
**January 2011 - Present**

Recorded, and later restored, an archive of 214 technical interviews with practitioners
from the Ruby, JVM, and Software Craftsmanship movements, using a local-only AI pipeline
to transcribe, structure, and cross-link a longitudinal record of primary-source
material into a searchable knowledge graph.

- Local-Only AI Restoration Pipeline: Built a Whisper and local-LLM pipeline that
  transcribes, diarizes, and structures long-form interview audio entirely on-device,
  keeping a large private media corpus off third-party inference services.
- Schema-Validated Content Platform: Runs on a contract-validated data layer: every
  interview, asset, and transcript is checked against an explicit schema at build time,
  with referential-integrity checks that fail the build rather than publishing broken
  data.
- Semantic Cross-Linking & Taxonomy Generation: Generates a topic taxonomy, knowledge
  graph, and semantic cross-links across the corpus, turning an unstructured media
  archive into navigable, individually indexed pages.
- Primary-Source Capture: Conducted the original interviews on-site at GOTO Conference,
  Software Craftsmanship North America, RailsConf, and WindyCityRails, with
  practitioners including Dave Thomas, Stuart Halloway, Corey Haines, Sandro Mancuso,
  and Micah Martin.
- Digital Archaeology: Recovered and reconstructed material from defunct platforms and
  web archives, reconciling incomplete metadata across sources to restore provenance for
  recordings that would otherwise have been lost.

---

## Additional Experience

- **Senior Backend Developer**, SK Holdings, Inc. (January 2019 - December 2020): Led
  backend stability, performance, and modernization for high-traffic Rails products,
  improving full-text search, campaign delivery pipelines, and data layer reliability
  while systems remained under production load.
- **Senior Software Developer**, BenchPrep (March 2017 - February 2018): Owned
  enterprise assessment workflows, leading correctness and platform security in a
  high-concurrency environment.
- **Senior Software Developer**, ReachLocal (March 2015 - November 2016): Owned API
  design and modernization strategy, leading incremental legacy migration for a
  high-volume digital marketing platform.
- **Senior .NET Developer**, TicketsNow (November 2005 - March 2007): Owned real-time
  inventory systems, leading transactional integrity and iterative delivery for
  revenue-critical operations.

---

## Earlier Experience

**Selected earlier experience**

Built and operated enterprise integrations, transactional systems, and early web
products across consulting and product organizations, establishing the production
discipline and community-centered craftsmanship that inform my leadership today.

- **Revenue-critical commerce**: Designed real-time inventory, locking, and fulfillment
  services for a high-volume ticket marketplace later acquired by a major industry
  operator.
- **Consulting and software craftsmanship**: Delivered systems across client
  environments while mentoring engineers, adopting Ruby and Rails, and helping build
  Chicago's craftsmanship community.
- **Enterprise and operational systems**: Built integration and operational software
  across large organizations, grounded in .NET, SQL, messaging, production support, and
  direct user needs.

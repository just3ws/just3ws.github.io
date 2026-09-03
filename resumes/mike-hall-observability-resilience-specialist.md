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

Observability and Resilience Architect specializing in illuminating dark telemetry, enterprise OpenTelemetry rollouts, and deep incident root cause triage. Eliminates cross-service blind spots by engineering end-to-end distributed trace propagation across legacy microservices and modern cloud infrastructure.

---

## Core Competencies & Skills

OpenTelemetry Working Group Leadership & Governance, Distributed Trace Context Propagation (W3C Trace Context), OTel Collector Pipeline Engineering (Receivers, Processors, Exporters), Dark Telemetry Illumination & Latency Bottleneck Detection, Edge PII Scrubbing, Masking & Sensitive Data Governance, Production Incident Triage for 100+ Person Bridge Calls, APM & Backend Integration (OpenObserve, Datadog, ELK, Prometheus), High-Concurrency Distributed Systems Reliability

---

## Experience & Leadership

### Associate Director, Staff Engineer at OneMain Financial

**January 2021 - February 2026** | Remote

**Target Focus:** Established distributed observability across application and integration boundaries, connecting system signals to incident response and safer change.

**Key Outcomes:**
- Led modernization of high-consequence customer workflows, aligning engineering, product, and operations around explicit system boundaries.
- Built data-risk remediation and architecture-discovery practices that made legacy dependencies visible and safer to change.
- Diagnosed a production state-management defect affecting application completion and moved the system to a more durable session design without interrupting service.
- Established distributed observability across application and integration boundaries, improving the evidence available during incident response.
- Built communities of practice, mentoring loops, and handoff mechanisms that distributed technical ownership beyond a single engineer.

### Principal Architect at Local AI Orchestration & Developer Runtime

**January 2026 - Present** | Independent Project

**Target Focus:** Built telemetry-driven diagnosis MCP server exposing distributed traces and error budgets directly to AI agent runtimes.

**Key Outcomes:**
- Built tools that make technical context reusable across sessions without treating generated output as authority.
- Added observable diagnostics and bounded review steps to keep automated engineering work understandable and reversible.

### Principal Architect at WWWorkRemote

**January 2021 - Present** | Independent Project

**Target Focus:** Built comprehensive error tracking and validation guardrails for continuous document ingestion and model inference.

**Key Outcomes:**
- Unified fragmented sources into a searchable data model for downstream analysis.
- Designed local-first AI workflows with explicit safety boundaries around untrusted input and sensitive context.

### Senior Software Developer at ActiveCampaign

**September 2018 - December 2018** | Chicago, IL

**Target Focus:** Made previously opaque PHP backend behavior observable through structured query patterns and test coverage, improving change safety and developer feedback loops.

**Key Outcomes:**
- Replaced fragile data-access patterns with structured, testable queries and improved performance.
- Strengthened automated verification around core customer workflows, enabling safer refactoring.

### Software Engineer & Technical Onboarding Lead (Fraud & Taxonomy Systems) at Groupon

**July 2011 - May 2013** | Chicago, IL

**Target Focus:** Engineered fraud detection queries in Vertica and conducted exploratory anomaly detection spikes in Hadoop and Clojure.

**Key Outcomes:**
- Centralized Taxonomy Service: Implemented merchant taxonomy service in Java and MySQL, eliminating categorization drift across distributed product teams during hypergrowth.
- Analytical Fraud Detection: Built analytical fraud detection queries in Vertica and conducted exploratory spikes on Hadoop and Clojure for transaction anomaly scoring.
- Merchant Analytics Pipelines: Built high-throughput merchant analytics tools in Ruby and CouchDB, surfacing market insights for global sales operations.
- Global Engineering Enablement: Redesigned technical onboarding curricula, standardizing engineering practices and shortening time-to-first-commit for 100+ global engineering hires.

---

## Selected Production Projects

### Principal Architect (Local AI Orchestration & Developer Runtime)
**January 2026 - Present**

Built and operate three MCP (Model Context Protocol) servers that expose live system state as callable tools to any MCP client, alongside the Claude Code skills, context-isolated subagents, and commit-time checks that keep agent work bounded and reviewable.


- Bidirectional Knowledge Server: Built ctx-mcp, an MCP server fronting a PostgreSQL knowledge suite that agents both query and write back to, so methodologies and lessons learned in one session are retrievable in the next rather than re-derived.

- Telemetry-Driven Diagnosis: Built o2-mcp, exposing on-demand OpenObserve telemetry (errors, slow spans, failed jobs, distributed traces) as agent-callable tools, so an agent diagnoses a running system from observed behavior instead of inferring from source.

- Context as a Budgeted Resource: Designed context-isolated subagents that keep high-volume audit work out of the main conversation's context window, with per-client registration tooling and pre-commit hooks that reject any agent asset that isn't self-describing.


### Principal Engineer & Curator (Technical Conversation Archive)
**January 2011 - Present**

Recorded, and later restored, an archive of 214 technical interviews with practitioners from the Ruby, JVM, and Software Craftsmanship movements, using a local-only AI pipeline to transcribe, structure, and cross-link a longitudinal record of primary-source material into a searchable knowledge graph.


- Local-Only AI Restoration Pipeline: Built a Whisper and local-LLM pipeline that transcribes, diarizes, and structures long-form interview audio entirely on-device, keeping a large private media corpus off third-party inference services.

- Schema-Validated Content Platform: Runs on a contract-validated data layer: every interview, asset, and transcript is checked against an explicit schema at build time, with referential-integrity checks that fail the build rather than publishing broken data.

- Semantic Cross-Linking & Taxonomy Generation: Generates a topic taxonomy, knowledge graph, and semantic cross-links across the corpus, turning an unstructured media archive into navigable, individually indexed pages.

- Primary-Source Capture: Conducted the original interviews on-site at GOTO Conference, Software Craftsmanship North America, RailsConf, and WindyCityRails, with practitioners including Dave Thomas, Stuart Halloway, Corey Haines, Sandro Mancuso, and Micah Martin.

- Digital Archaeology: Recovered and reconstructed material from defunct platforms and web archives, reconciling incomplete metadata across sources to restore provenance for recordings that would otherwise have been lost.


---

## Additional Experience

- **Senior Backend Developer**, SK Holdings, Inc. (January 2019 - December 2020): Led backend stability, performance, and modernization for high-traffic Rails products, improving full-text search, campaign delivery pipelines, and data layer reliability while systems remained under production load.
- **Senior Software Developer**, BenchPrep (March 2017 - February 2018): Owned enterprise assessment workflows, leading correctness and platform security in a high-concurrency environment.
- **Senior Software Developer**, ReachLocal (March 2015 - November 2016): Owned API design and modernization strategy, leading incremental legacy migration for a high-volume digital marketing platform.
- **Senior .NET Developer**, TicketsNow (November 2005 - March 2007): Owned real-time inventory systems, leading transactional integrity and iterative delivery for revenue-critical operations.

---

## Earlier Experience

**Selected earlier experience**

Built and operated enterprise integrations, transactional systems, and early web products across consulting and product organizations, establishing the production discipline and community-centered craftsmanship that inform my leadership today.

- **Revenue-critical commerce**: Designed real-time inventory, locking, and fulfillment services for a high-volume ticket marketplace later acquired by a major industry operator.
- **Consulting and software craftsmanship**: Delivered systems across client environments while mentoring engineers, adopting Ruby and Rails, and helping build Chicago's craftsmanship community.
- **Enterprise and operational systems**: Built integration and operational software across large organizations, grounded in .NET, SQL, messaging, production support, and direct user needs.

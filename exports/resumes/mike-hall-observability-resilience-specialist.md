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

**Target Focus:** Founded and led enterprise OpenTelemetry Working Group (OTel WG); built the Enterprise Trace across the end-to-end loan application and origination lifecycle (Rails, MuleSoft, IBM Mainframe), diagnosing and resolving a multi-service defect impacting 4% of traffic.

**Key Outcomes:**
- Technical Leadership & Team Consolidation: Progressed from Digital Origination Team Lead to Software Architect for the Acquisition Lane, merging two attrition-impacted teams into a unified, high-functioning engineering unit before converting to Associate Director, Staff Engineer upon corporate architecture track restructuring.

- ACQ Enablement & Funnel State Mapping: Founded and technically led the ACQ Enablement team to establish systemic cartography across customer journeys: inventorying the intersection of business decisions, customer actions, system state transitions, and source code execution paths. Built high-fidelity funnel lifecycle signals (entry, exit, error) with complete runtime attribution (A/B test variants, feature flags, configuration states) to accelerate cybersecurity investigations and create safety gates for continuous legacy modernization.

- Observability & Enterprise Origination Trace: Founded and led the OpenTelemetry Working Group (OTel WG) to establish the Enterprise Trace across the end-to-end loan application and digital origination lifecycle, connecting a complex Rails distributed monolith, MuleSoft, and IBM mainframe backends. Leveraged distributed telemetry and state mapping to diagnose and resolve a persistent multi-service defect impacting 4% of traffic, eliminating silent application loss at final underwriting and e-sign stages.

- AI-Augmented Systems Investigation: Introduced privacy-conscious local AI workflows for legacy code analysis and engineering support, expanding investigative capacity while keeping human review, security constraints, and source evidence explicit.


### Principal Architect at Local AI Orchestration & Developer Runtime

**2026 - Present** | Independent Project

**Target Focus:** Built telemetry-driven diagnosis MCP server exposing distributed traces and error budgets directly to AI agent runtimes.

**Key Outcomes:**
- Bidirectional Knowledge Server: Built ctx-mcp, an MCP server fronting a PostgreSQL knowledge suite that agents both query and write back to, so methodologies and lessons learned in one session are retrievable in the next rather than re-derived.

- Telemetry-Driven Diagnosis: Built o2-mcp, exposing on-demand OpenObserve telemetry (errors, slow spans, failed jobs, distributed traces) as agent-callable tools, so an agent diagnoses a running system from observed behavior instead of inferring from source.

- Context as a Budgeted Resource: Designed context-isolated subagents that keep high-volume audit work out of the main conversation's context window, with per-client registration tooling and pre-commit hooks that reject any agent asset that isn't self-describing.


### Principal Architect at WWWorkRemote

**2021 - Present** | Independent Project

**Target Focus:** Built comprehensive error tracking and validation guardrails for continuous document ingestion and model inference.

**Key Outcomes:**
- Data Ingestion & Normalization: Built a multi-source Rails ingestion pipeline and PostgreSQL storage schema, unifying fragmented job market datasets for structured downstream analysis.

- Semantic Search & Matching: Implemented vector search embeddings via pgvector, enabling high-precision semantic matching between complex candidate profiles and job requirements.

- Local-First AI Orchestration: Designed a provider-agnostic LLM orchestration layer behind a YAML-driven model registry, local-first by default (llama.cpp/Ollama primary, hosted Claude as fallback), so routine inference never leaves the machine while a stronger hosted model can be selected per call site.

- Prompt Injection Defense: Built a four-stage guardrails pipeline (normalize, weighted heuristic scan, risk classify, output validate) screening every untrusted scraped document before it reaches a model, scoring known injection patterns plus an instruction-density heuristic to secure ingestion against hostile inputs.

- Browser Extension & Lifecycle Capture: Built an MV3 Chrome extension with 16 provider adapters that extracts postings from live ATS pages and captures the full application lifecycle (questions asked and answers given) back into the platform.

- Static Signal Integration: Injected static analysis rules and architectural constraints into model context windows, preventing drift between generated outputs and system security contracts.


### Senior Software Developer at ActiveCampaign

**September 2018 - December 2018** | Chicago, IL

**Target Focus:** Made previously opaque PHP backend behavior observable through structured query patterns and test coverage, improving change safety and developer feedback loops.

**Key Outcomes:**
- Testable Query Patterns: Replaced ad-hoc global data access functions with structured, cacheable query patterns in the PHP backend, improving performance and enabling reliable automated testing where none existed before.
- Legacy Boundary Isolation: Identified and isolated structural constraints in the core contact management subsystem, reducing risk for incremental change without requiring large-scale rewrites.
- Frontend Test Hardening & Boundary Verification: Hardened Ember.js frontend test coverage across core contact management workflows, creating verification gates that allowed safe refactoring of legacy PHP data paths without regression.
- Reusable Pagination Constructs: Refactored shared Ember.js pagination and interaction logic into reusable mixins, eliminating duplication across contact list views.

### Software Engineer & Technical Onboarding Lead (Fraud & Taxonomy Systems) at Groupon

**July 2011 - May 2013** | Chicago, IL

**Target Focus:** Engineered fraud detection queries in Vertica and conducted exploratory anomaly detection spikes in Hadoop and Clojure.

**Key Outcomes:**
- Built merchant analytics tools in Ruby and CouchDB, surfacing market insights for global sales operations.
- Designed analytical fraud detection queries in Vertica and conducted exploratory spikes on Hadoop and Clojure-based anomaly detection tools.
- Implemented a centralized merchant taxonomy service in Java (ActiveWeb/ActiveJDBC) and MySQL, eliminating categorization drift across distributed product teams.
- Redesigned the global engineering onboarding curriculum, standardizing technical practices and shortening time-to-first-commit for new hires.

---

## Selected Production Projects

### Principal Architect (Local AI Orchestration & Developer Runtime)
**2026 - Present**

Built and operate three MCP (Model Context Protocol) servers that expose live system state as callable tools to any MCP client, alongside the Claude Code skills, context-isolated subagents, and commit-time checks that keep agent work bounded and reviewable.


- Bidirectional Knowledge Server: Built ctx-mcp, an MCP server fronting a PostgreSQL knowledge suite that agents both query and write back to, so methodologies and lessons learned in one session are retrievable in the next rather than re-derived.

- Telemetry-Driven Diagnosis: Built o2-mcp, exposing on-demand OpenObserve telemetry (errors, slow spans, failed jobs, distributed traces) as agent-callable tools, so an agent diagnoses a running system from observed behavior instead of inferring from source.

- Context as a Budgeted Resource: Designed context-isolated subagents that keep high-volume audit work out of the main conversation's context window, with per-client registration tooling and pre-commit hooks that reject any agent asset that isn't self-describing.


### Principal Engineer & Curator (Technical Conversation Archive)
**2011 - Present**

Recorded, and later restored, an archive of 214 technical interviews with practitioners from the Ruby, JVM, and Software Craftsmanship movements, using a local-only AI pipeline to transcribe, structure, and cross-link two decades of primary-source material into a searchable knowledge graph.


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

## Career Foundations

**1999 - 2011**

Built and operated enterprise integrations, transactional systems, and early web products across consulting and product organizations, establishing the production discipline and community-centered craftsmanship that still shape my leadership.

- **Revenue-critical commerce**: Designed real-time inventory, locking, and fulfillment services for a high-volume ticket marketplace later acquired by a major industry operator.
- **Consulting and software craftsmanship**: Delivered systems across client environments while mentoring engineers, adopting Ruby and Rails, and helping build Chicago's craftsmanship community.
- **Enterprise and operational systems**: Built integration and operational software across large organizations, grounded in .NET, SQL, messaging, production support, and direct user needs.

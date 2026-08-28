# Mike Hall
Principal Software Engineer

## Summary
Principal Software Engineer specializing in high-consequence legacy modernization, distributed systems architecture, and platform resilience. Combines 20+ years across software engineering and platform architecture with OpenTelemetry distributed tracing, cross-lane boundary mediation, and zero-downtime data migrations across Ruby on Rails, PostgreSQL, and cloud infrastructure.

## Skills
- Cross-Team Technical Leadership
- Platform Architecture & Legacy Modernization
- Production Systems & Reliability
- Architecture Discovery & Technical Debt Reduction
- Incident Response & Root Cause Analysis
- Observability & OpenTelemetry
- Distributed Systems & Async Processing
- Data Integrity & Performance
- Platform Enablement & Developer Productivity
- AI-Augmented Engineering & Automation
- LLM Orchestration & MCP Tooling
- Ruby on Rails
- PostgreSQL & SQL
- Sidekiq & Redis
- AWS, Kubernetes & Docker
- CI/CD

## Experience

### Principal Architect at Local AI Orchestration & Developer Runtime
**2026 — Present**

Built and operate three MCP (Model Context Protocol) servers that expose live system state as callable tools to any MCP client, alongside the Claude Code skills, context-isolated subagents, and commit-time checks that keep agent work bounded and reviewable.


**Key Outcomes:**
- Bidirectional Knowledge Server: Built ctx-mcp, an MCP server fronting a PostgreSQL knowledge suite that agents both query and write back to, so methodologies and lessons learned in one session are retrievable in the next rather than re-derived.

- Telemetry-Driven Diagnosis: Built o2-mcp, exposing on-demand OpenObserve telemetry (errors, slow spans, failed jobs, distributed traces) as agent-callable tools, so an agent diagnoses a running system from observed behavior instead of inferring from source.

- Context as a Budgeted Resource: Designed context-isolated subagents that keep high-volume audit work out of the main conversation's context window, with per-client registration tooling and pre-commit hooks that reject any agent asset that isn't self-describing.


**Skills:** Model Context Protocol (MCP), Agentic Workflow Design, Claude Code, Anthropic API, LLM Tool Design, PostgreSQL, OpenTelemetry, OpenObserve, llama.cpp, whisper.cpp, Local Inference, PHI Scrubbing & Compliance, Ruby

### Principal Architect at Phalanx Duel
**2022 — Present**

Designing and building a real-time tactical game platform as a current hands-on laboratory for deterministic systems, product architecture, and controlled AI-assisted engineering.


**Key Outcomes:**
- Designed a deterministic engine with replayable action logs and server-authoritative state transitions, making complex outcomes reproducible and independently verifiable.

- Built replay validation, adversarial coverage, and CI verification gates so state transitions can be checked across the complete lifecycle.

- Uses controlled agent workflows with bounded tasks, acceptance criteria, automated checks, and human-reviewed outputs rather than treating model output as authority.


**Skills:** TypeScript, Node.js, PostgreSQL, WebSockets, API Design, Distributed Systems, Deterministic Simulation, CI/CD, System Verification, AI-Augmented Development

### Principal Architect at WWWorkRemote
**2021 — Present**

Rails 8 platform for multi-source job ingestion, semantic matching, and application automation, built as a working laboratory for local-first LLM orchestration and treating scraped third-party text as hostile input.


**Key Outcomes:**
- Data Ingestion & Normalization: Built a multi-source Rails ingestion pipeline and PostgreSQL storage schema, unifying fragmented job market datasets for structured downstream analysis.

- Semantic Search & Matching: Implemented vector search embeddings via pgvector, enabling high-precision semantic matching between complex candidate profiles and job requirements.

- Local-First AI Orchestration: Designed a provider-agnostic LLM orchestration layer behind a YAML-driven model registry, local-first by default (llama.cpp/Ollama primary, hosted Claude as fallback), so routine inference never leaves the machine while a stronger hosted model can be selected per call site.

- Prompt Injection Defense: Built a four-stage guardrails pipeline (normalize, weighted heuristic scan, risk classify, output validate) screening every untrusted scraped document before it reaches a model, scoring known injection patterns plus an instruction-density heuristic to secure ingestion against hostile inputs.

- Browser Extension & Lifecycle Capture: Built an MV3 Chrome extension with 16 provider adapters that extracts postings from live ATS pages and captures the full application lifecycle (questions asked and answers given) back into the platform.

- Static Signal Integration: Injected static analysis rules and architectural constraints into model context windows, preventing drift between generated outputs and system security contracts.


**Skills:** Ruby on Rails, PostgreSQL, pgvector, Vector Search & Embeddings, LLM Orchestration, Prompt Injection Defense, Local Inference, Chrome Extensions (MV3), API Design, Data Pipelines, System Design, OpenTelemetry, Distributed Systems

### Principal Engineer & Curator at Technical Conversation Archive
**2011 — Present**

Recorded, and later restored, an archive of 214 technical interviews with practitioners from the Ruby, JVM, and Software Craftsmanship movements, using a local-only AI pipeline to transcribe, structure, and cross-link two decades of primary-source material into a searchable knowledge graph.


**Key Outcomes:**
- Local-Only AI Restoration Pipeline: Built a Whisper and local-LLM pipeline that transcribes, diarizes, and structures long-form interview audio entirely on-device, keeping a large private media corpus off third-party inference services.

- Schema-Validated Content Platform: Runs on a contract-validated data layer: every interview, asset, and transcript is checked against an explicit schema at build time, with referential-integrity checks that fail the build rather than publishing broken data.

- Semantic Cross-Linking & Taxonomy Generation: Generates a topic taxonomy, knowledge graph, and semantic cross-links across the corpus, turning an unstructured media archive into navigable, individually indexed pages.

- Primary-Source Capture: Conducted the original interviews on-site at GOTO Conference, Software Craftsmanship North America, RailsConf, and WindyCityRails, with practitioners including Dave Thomas, Stuart Halloway, Corey Haines, Sandro Mancuso, and Micah Martin.

- Digital Archaeology: Recovered and reconstructed material from defunct platforms and web archives, reconciling incomplete metadata across sources to restore provenance for recordings that would otherwise have been lost.


**Skills:** Local-First AI Inference, Whisper & Speech-to-Text, LLM-Assisted Content Structuring, Knowledge Graph Construction, Semantic Search & Taxonomy, Schema Validation & Data Contracts, Digital Preservation, Ruby, Jekyll, SEO & Information Architecture

### Associate Director, Staff Engineer at OneMain Financial
**January 2021 — February 2026**

Served as Senior Technical IC and Software Architecture Lead for the Acquisition lane of a regulated financial enterprise, establishing system cartography and observability across the end-to-end loan application and origination lifecycle, while guiding legacy modernization, cybersecurity investigations, and cross-team platform reliability.


**Key Outcomes:**
- Technical Leadership & Platform Realignment: Progressed from Digital Origination Team Lead to Software Architect for the Acquisition Lane, merging two attrition-impacted teams into a unified delivery unit before converting to Associate Director, Staff Engineer upon corporate architecture track restructuring.

- ACQ Enablement & System Cartography: Founded and technically led the ACQ Enablement team to establish systemic cartography across customer journeys: inventorying the intersection of business decisions, customer actions, system state transitions, and source code execution paths. Drove PII remediation, cybersecurity forensic signal mapping, and platform infrastructure support to enable ACQ Growth teams to safely integrate with enterprise cloud modernization initiatives.

- Enterprise Trace & Operational Alignment: Architected distributed telemetry across Rails distributed monoliths, MuleSoft APIs, and IBM mainframe backends. Partnered directly with Cybersecurity, the Enterprise Monitoring Center (EMC), SRE, and Incident Command to align immediate operational monitoring with long-term distributed tracing, diagnosing and eliminating a persistent multi-service defect that caused 4% silent traffic loss at late-stage e-signing.

- Sustained Community Enablement & SRE Handoff: Drove a dedicated 3-year cultural and technical enablement initiative: founded Geekfest@OMF (weekly recorded technical brown-bag sessions across the enterprise for 1 year) before evolving the forum into the weekly OpenTelemetry Working Group (OTel WG), scaling voluntary attendance to 40+ cross-lane engineers. Mentored and partnered with SRE leads to transition ongoing operational facilitation, establishing a durable, self-sustaining community of practice while returning to Acquisition Lane architecture representation.

- Applied AI & Innovation Leadership: Placed in two corporate hackathons (building early conversational agents with Rasa and automated schema inference tools with Bonsai Buckaroos). Introduced local LLM orchestration and privacy-conscious AI developer workflows at Geekfest@OMF, establishing early evidence-based patterns for legacy code discovery and developer productivity.


**Skills:** Cross-Team Technical Leadership, Platform Architecture, Legacy Modernization, Architecture Discovery, Dependency Mapping, System Resilience, Incident Leadership, Observability, OpenTelemetry, Distributed Systems, Ruby on Rails, PostgreSQL, AWS

### Senior Backend Developer at SK Holdings, Inc.
**January 2019 — December 2020**

Led backend stability, performance, and modernization for high-traffic Rails products, improving full-text search, campaign delivery pipelines, and data layer reliability while systems remained under production load.


**Key Outcomes:**
- Search Modernization & Infrastructure De-Risking: Eliminated external cluster failure modes and lowered operating footprint by transitioning legacy Sphinx infrastructure to optimized MySQL full-text search and relational indices under live production traffic.

- Zero-Downtime Platform Upgrades: Led Ruby and Rails framework upgrades across multiple core applications, sequencing database migrations and dependency updates to maintain uptime during platform modernization.


**Skills:** Ruby on Rails, MySQL, Full-Text Search, Redis, Sidekiq, SendGrid Async Pipelines, Data Analytics & SQL, CI/CD, System Observability, Backend Architecture

### Senior Software Developer at ActiveCampaign
**September 2018 — December 2018**

Short-term senior contract on the Contacts team of a large-scale PHP/MySQL CRM platform. Focused on testability, performance, and change safety inside a tightly coupled legacy backend while extending the Ember.js frontend test suite.

**Key Outcomes:**
- Testable Query Patterns: Replaced ad-hoc global data access functions with structured, cacheable query patterns in the PHP backend, improving performance and enabling reliable automated testing where none existed before.
- Legacy Boundary Isolation: Identified and isolated structural constraints in the core contact management subsystem, reducing risk for incremental change without requiring large-scale rewrites.
- Frontend Test Hardening & Boundary Verification: Hardened Ember.js frontend test coverage across core contact management workflows, creating verification gates that allowed safe refactoring of legacy PHP data paths without regression.
- Reusable Pagination Constructs: Refactored shared Ember.js pagination and interaction logic into reusable mixins, eliminating duplication across contact list views.

**Skills:** PHP, MySQL, Ember.js, JavaScript, Legacy System Modernization, Backend System Architecture, Automated Testing, Performance Optimization

### Principal Consultant at Tandem
**August 2018 — August 2018**

Single-month engagement: brought in to an over-committed federal software program (DoD MEPS) following an engineering-team departure to conduct on-site operational assessment and deliver architectural recommendations directly to executive leadership.


**Key Outcomes:**
- Conducted an on-site, end-to-end operational walkthrough at military processing facilities (Des Plaines MEPS), identifying critical disconnects between enlistment workflows and proposed software models.

- Evaluated program viability and delivered definitive architectural recommendations directly to executive leadership, mitigating severe contractual and delivery risks.


**Skills:** System Resilience, Platform Architecture, Federal Software Assessment, Operational Field Research

### Senior Software Developer at BenchPrep
**March 2017 — February 2018**

Owned enterprise assessment workflows, leading correctness and platform security in a high-concurrency environment.

**Key Outcomes:**
- Critical assessment calculation errors were addressed by analyzing and optimizing complex PostgreSQL queries, improving accuracy and reducing response times.
- Vulnerable submission pipelines were addressed by implementing JWT-based response verification, preventing tampering and enforcing once-only processing.
- Unsafe third-party integrations were addressed by designing a secure cross-origin API for embedded clients, establishing explicit trust boundaries.
- High-concurrency performance bottlenecks were addressed by optimizing database interactions, reducing operational risk under heavy load.
- Rework and unclear requirements were addressed by introducing lightweight team practices, improving delivery reliability.

**Skills:** Ruby, Ruby on Rails, PostgreSQL, JWT Authentication, Backend System Architecture, Secure API Design, Database Performance Optimization, Observability and Logging

### Senior Software Developer at ReachLocal
**March 2015 — November 2016**

Owned API design and modernization strategy, leading incremental legacy migration for a high-volume digital marketing platform.

**Key Outcomes:**
- Evaluated technical feasibility and architected an incremental modernization roadmap, replacing a high-risk full rewrite with a safe Strangler-Fig migration.
- Designed a decoupled two-tier frontend architecture, isolating user experience delivery from legacy backend database constraints.
- Built an internal API Gateway to safely expose legacy services through standardized, authenticated interfaces.
- Introduced automated static analysis and security scanning into the CI/CD pipeline, raising overall codebase health.

**Skills:** Platform Architecture, API Gateway Design, Ruby on Rails, PostgreSQL, React, Redis, Legacy System Modernization, Secure API Design, Data Migration Strategy

### CTO at KloboMedia
**March 2014 — September 2016**

Owned end-to-end platform architecture, leading high-throughput data integration for an early-stage social media startup. The product, TheSocReport, ended when the upstream data taps closed — Twitter's firehose shutdown and the closing of Facebook's and Instagram's user-intelligence APIs removed the inputs the analytics depended on.

**Key Outcomes:**
- Architected a social analytics platform integrating Twitter, Facebook, and Instagram APIs, delivering unified audience engagement metrics.
- Designed an asynchronous ingestion pipeline using Sidekiq Enterprise and Redis, processing real-time social streams under burst traffic.
- Implemented a PostgreSQL JSONB document storage architecture, allowing fast schema evolution across heterogeneous third-party API payloads.
- Automated multi-cloud deployment pipelines across Heroku and AWS, establishing reproducible staging and production infrastructure.

**Skills:** Ruby, Ruby on Rails, PostgreSQL, Redis, Sidekiq, Amazon RDS, Heroku, DigitalOcean, Twitter API, Facebook Graph API, Instagram API

### Open-Source Transition Lead at Coderwall
**January 2014 — December 2014**

Hired as a contractor by the founder to lead the open-source transition of the Coderwall developer reputation platform, a Y Combinator-backed professional network for software engineers (856 GitHub stars, 304 forks). Delivered security hardening, proprietary service extraction, infrastructure modernization, and community leadership as the top contributor to the open-source codebase.

**Key Outcomes:**
- Security vulnerabilities were identified and closed before public release, including SQL injection in badge and opportunity models, DOS via Symbol injection in admin controllers, XSS through unwhitelisted comment parameters, and unsafe dynamic class generation from user input.
- Proprietary billing engines and badge-scoring algorithms were extracted into separate backend services with clean API stubs, enabling the platform core to go public without exposing private business logic or credentials.
- Platform data layer was migrated from MongoDB to PostgreSQL in a two-phase migration, simplifying the stack for incoming open-source contributors.
- Background processing was modernized by converting legacy Rake tasks and Clockwork jobs to Sidekiq workers, and replacing Resque, materially reducing Heroku operational costs.
- Open-source scaffolding was established including LICENSE, CONTRIBUTING.md, Travis CI integration, CodeClimate, Vagrant development environments, and ERD documentation for contributor onboarding.
- Developer evangelism and community management included merging 30+ community pull requests, writing contributor guidance, maintaining development environments, and coordinating with external developers learning the platform.

**Skills:** Ruby, Ruby on Rails, PostgreSQL, Redis, Sidekiq, ElasticSearch, AWS S3, Heroku, JavaScript, Backbone.js, MongoDB, Vagrant, Travis CI

### Senior Software Developer at Upcity
**October 2013 — February 2014**

Owned payment integrations and local development infrastructure, leading system modernization for an SOA-based marketing platform.

**Key Outcomes:**
- Integrated the Chargify subscription payment platform, launching self-service recurring billing and account management.
- Standardized local development environments using multi-VM Vagrant orchestration, eliminating developer environment drift against production.

**Skills:** Ruby, Ruby on Rails, PostgreSQL, Redis, Sidekiq, Riak, Vagrant, NGINX, Capistrano, Bash, Ubuntu

### Senior Software Developer at Viewpoints
**May 2013 — October 2013**

Owned core business system development, leading AWS deployment modernization and CI implementation.

**Key Outcomes:**
- Implemented custom tracking and analytics tools, enabling targeted monetization and direct platform revenue.
- Standardized automated testing and staging environments, establishing reliable continuous integration across the engineering team.
- Streamlined AWS deployment pipelines and server images, eliminating deployment downtime during peak consumer traffic spikes.

**Skills:** Ruby, Ruby on Rails, AWS EC2, AWS RDS, PostgreSQL, Redis, Resque, Capistrano, NGINX, Sidekiq, Logentries

### Software Engineer & Technical Onboarding Lead (Fraud & Taxonomy Systems) at Groupon
**July 2011 — May 2013**

Owned core backend systems for fraud and taxonomy, leading global engineering enablement during hyper-growth.

**Key Outcomes:**
- Built merchant analytics tools in Ruby and CouchDB, surfacing market insights for global sales operations.
- Designed analytical fraud detection queries in Vertica and conducted exploratory spikes on Hadoop and Clojure-based anomaly detection tools.
- Implemented a centralized merchant taxonomy service in Java (ActiveWeb/ActiveJDBC) and MySQL, eliminating categorization drift across distributed product teams.
- Redesigned the global engineering onboarding curriculum, standardizing technical practices and shortening time-to-first-commit for new hires.

**Skills:** Ruby, Java, Clojure, CouchDB, Vertica, Hadoop, MySQL, Redis, JavaScript, Bash

### Software Engineer at Obtiva
**August 2009 — July 2011**

Delivered backend systems and services as a consultant across multiple clients, including Sears, Leapfrog Online, and Groupon, supporting early-stage scaling and data-driven operations in high-growth environments.


**Key Outcomes:**
- Built self-service reporting platforms for Leapfrog Online, allowing business stakeholders to query and export data warehouse analytics without engineering bottlenecks.

- Developed commercial B2B sales and product catalog services for Sears, opening new enterprise revenue channels.

- Engineered deal-processing services and fraud analysis pipelines at Groupon, stabilizing backend transaction infrastructure during extreme hyper-growth.


**Skills:** C#, Ruby, Ruby on Rails, JavaScript, SQL Server, MySQL, Git, RSpec, Resque, NGINX

### Principal Developer at Business Decisions, Inc.
**October 2008 — August 2009**

Owned all technical strategy and system development, leading lifecycle modernization for multi-firm consulting teams.

**Key Outcomes:**
- Directed technical strategy and end-to-end software development across multi-firm consulting teams, establishing reliable delivery standards.
- Automated continuous integration pipelines using Subversion and CruiseControl.NET, eliminating manual build errors.
- Engineered standardized VMware development environments, reducing contractor onboarding time from days to hours.

**Skills:** C#, ASP.NET, Microsoft SQL Server, Subversion, CruiseControl.NET, VMWare, IIS, JavaScript, JSON

### Assistant Vice President, Application Developer at JPMorgan Chase & Co.
**April 2008 — October 2008**

Owned cross-system integration stability, leading defect resolution in regulated financial workflows.

**Key Outcomes:**
- Diagnosed and resolved complex distributed integration failures across SOAP-based web services, restoring reliability to high-value financial transaction workflows.
- Eliminated data desynchronization bugs between .NET middle-tier services and legacy mainframe accounting systems, ensuring exact reporting accuracy for institutional clients.

**Skills:** C#, ASP.NET, SOAP, XML, Microsoft SQL Server, Transact-SQL (T-SQL), Visual Basic .NET (VB.NET), JSON

### Senior .NET Developer at Brightstar Corporation
**March 2007 — April 2008**

Owned enterprise supply-chain integration, leading cross-system data unification for a global mobile device distributor.

**Key Outcomes:**
- Orchestrated an enterprise BizTalk integration unifying purchase orders, inventory, and financial systems across global distribution centers.
- Designed and built an operational dashboard giving leadership real-time visibility into global supply-chain throughput.
- Integrated Solomon accounting software with custom internal platforms using SubSonic ORM and T-SQL, eliminating manual accounting reconciliation.

**Skills:** C#, ASP.NET, Microsoft BizTalk Server, Microsoft SQL Server, SubSonic ORM, Solomon Accounting Software, Transact-SQL (T-SQL), XML, SOAP

### Senior .NET Developer at TicketsNow
**November 2005 — March 2007**

Owned real-time inventory systems, leading transactional integrity and iterative delivery for revenue-critical operations.

**Key Outcomes:**
- Architected a real-time inventory locking and transaction reconciliation service, preventing race conditions on concurrent ticket sales and generating $2M+ in protected revenue.
- Introduced and led Scrum agile practices for the core transaction engineering team, improving sprint delivery predictability.

**Skills:** C#, ASP.NET, Microsoft BizTalk Server, Microsoft SQL Server, Scrum, Transact-SQL (T-SQL), SOAP, CodeSmith API, JSON, JavaScript

### Senior Software Developer at BP
**June 2005 — November 2005**

Owned critical feature enhancements for an industrial invoicing system, leading performance optimization in high-volume billing workflows.

**Key Outcomes:**
- Engineered core invoicing features in VB.NET, streamlining high-volume industrial billing workflows.
- Redesigned stored procedures and optimized SQL Server query execution plans, significantly reducing latency in critical end-of-month billing cycles.

**Skills:** ASP.NET, C#, Microsoft SQL Server, Transact-SQL (T-SQL), Visual Basic .NET (VB.NET), Windows Server

### Senior Software Developer at Motorola
**August 2004 — May 2005**

Owned retail feature delivery, leading iterative execution in a complex enterprise sales portfolio application.

**Key Outcomes:**
- Introduced Scrum agile practices to cross-functional enterprise teams, increasing release predictability and milestone transparency.
- Developed core retail portfolio features in C#, ASP.NET, and SQL Server, supporting high-volume device sales operations.

**Skills:** C#, ASP.NET, Microsoft SQL Server, SOAP, Scrum, Transact-SQL (T-SQL), XML

### Software Developer at Riverpoint Group
**July 2004 — August 2004**

Owned reusable UI component architecture, leading frontend delivery for a personal health monitoring platform.

**Key Outcomes:**
- Developed a modular library of reusable ASP.NET Web Forms components, standardizing UI consistency across patient-facing health monitoring modules.
- Optimized SQL Server query performance and indexing, ensuring fast rendering for real-time patient health visualization metrics.

**Skills:** ASP.NET, C#, Microsoft SQL Server, JavaScript, HTML, CSS

### Programmer Analyst at Integrated Performance Solutions, Inc.
**November 2003 — July 2004**

Owned dynamic reporting architecture, leading the platform transition from classic ASP to .NET environments.

**Key Outcomes:**
- Developed a custom report rules engine and UI, allowing end users to generate dynamic reports without engineering intervention.
- Engineered a dynamic SQL rules wizard using early JSON data structures to support flexible reporting schemas.
- Migrated legacy reporting components to ASP.NET Web Forms, establishing modern .NET architectural standards.

**Skills:** ASP.NET, Active Server Pages (ASP), JavaScript, JSON, Microsoft SQL Server, Transact-SQL (T-SQL), Visual Studio .NET, CSS

### Programmer Analyst at New Labor Strategies, Inc.
**June 2002 — November 2003**

Owned kiosk-based HR modules, leading frontend modernization for high-friction factory floor environments.

**Key Outcomes:**
- Engineered touch-screen interfaces and automated job-bidding modules for factory floor kiosks, streamlining workforce shift operations.
- Refactored legacy VBScript workflows with client-side JavaScript, significantly improving UI responsiveness on embedded kiosk hardware.

**Skills:** Active Server Pages (ASP), VBScript, JavaScript, Microsoft SQL Server, CSS, HTML

### Software Developer at Trippe Manufacturing, Inc.
**October 2001 — December 2001**

Owned sales lead tracking systems, leading data automation and business continuity during a high-risk vendor transition.

**Key Outcomes:**
- Engineered an automated sales lead ingestion and validation pipeline, eliminating manual data entry errors.
- Stepped in as direct technical lead following an unexpected vendor departure, maintaining uninterrupted sales tracking continuity.

**Skills:** Microsoft Access, Visual Basic, Visual Basic for Applications (VBA), Visual SourceSafe

### Application Analyst at Sentinel Technologies, Inc.
**July 2000 — October 2001**

Owned custom web delivery and early OCR prototyping, leading cross-platform implementations for enterprise clients.

**Key Outcomes:**
- Designed an early-stage OCR pipeline using Unix shell scripting and pattern extraction, parsing and digitizing semi-structured paper receipts into relational databases.
- Delivered custom web applications and database integrations for enterprise clients, including Harley-Davidson.

**Skills:** Java, Active Server Pages (ASP), Microsoft SQL Server, JavaScript, HTML, CSS, VBScript

### System Administrator at C.H. Robinson
**December 1999 — July 2000**

Owned critical site infrastructure, leading early logistics workflow automation in a high-availability environment.

**Key Outcomes:**
- Managed site server infrastructure and hardware upgrades, ensuring 24/7 uptime for regional logistics operations.
- Prototyped an automated shipment booking workflow, reducing manual scheduling overhead for freight operations.

**Skills:** Windows NT, Windows 98

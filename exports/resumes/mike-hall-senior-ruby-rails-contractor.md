# Mike Hall

**Senior / Lead Software Engineer, Ruby on Rails**
Chicago, IL

- Email: [mike@just3ws.com](mailto:mike@just3ws.com)
- Phone: [(847) 877-3825](tel:+18478773825)
- Website: [just3ws.com](https://www.just3ws.com)
- LinkedIn: [linkedin.com/in/just3ws/](https://www.linkedin.com/in/just3ws/)
- GitHub: [github.com/just3ws](https://github.com/just3ws)

---

## Professional Summary

Senior software engineer focused on Ruby on Rails infrastructure, PostgreSQL, legacy
modernization, and production reliability. Delivers business value through complex state
machine refactoring, database optimization, asynchronous processing, third-party
integrations, and disciplined testing.

---

## Core Competencies & Skills

Ruby on Rails (Full-Lifecycle 2.x through 8.x), PostgreSQL & MySQL Query Optimization &
Indexing, Asynchronous Processing (Sidekiq, Resque, Redis), State Machine Refactoring &
Data Integrity, Third-Party API & Webhook Integrations, Test-Driven Development (RSpec,
Capybara, FactoryBot), Docker, Linux, Git & Zero-Downtime Deployment, Fast Ramp-Up &
Autonomous IC Execution

---

## Experience & Leadership

### Associate Director, Staff Engineer at OneMain Financial

**January 2021 - February 2026** | Remote

**Target Focus:** Architected and delivered an instant loan disbursement pipeline
(funding to debit cards in minutes) and refactored multi-step Rails workflow state
machines, eliminating lateral state corruptions across high-volume customer
prequalification pipelines.

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

**Target Focus:** Sequenced zero-downtime Ruby and Rails version upgrades, optimized
MySQL full-text search indices, and built batch Sidekiq/SendGrid delivery pipelines.

**Key Outcomes:**
- Search Infrastructure Modernization: Eliminated external cluster failure modes and
  reduced operating footprint by migrating legacy Sphinx to optimized MySQL full-text
  search and relational indices under live production traffic.
- Zero-Downtime Rails Upgrades: Led Ruby and Rails framework upgrades across core
  applications, sequencing database migrations to ensure zero downtime during platform
  modernization.

### Senior Software Developer at ActiveCampaign

**September 2018 - December 2018** | Chicago, IL

**Target Focus:** Introduced testable query patterns and caching into a tightly coupled
PHP/MySQL CRM backend and extended the Ember.js frontend test suite across contact
management workflows.

**Key Outcomes:**
- Legacy Query Modernization: Replaced ad-hoc global data access with structured,
  cacheable query patterns in the PHP backend, enabling unit testability and sub-second
  query execution.
- Frontend Verification Gates: Hardened Ember.js automated test suites across core CRM
  contact workflows, creating safety gates that enabled non-breaking legacy PHP
  refactoring.

### Senior Software Developer at Upcity

**October 2013 - February 2014** | Remote

**Target Focus:** Integrated Chargify recurring billing and standardized multi-VM local
development environments via Vagrant.

**Key Outcomes:**
- Integrated the Chargify subscription payment platform, launching self-service
  recurring billing and account management.
- Standardized local development environments using multi-VM Vagrant orchestration,
  eliminating developer environment drift against production.

### Senior Software Developer at Viewpoints

**May 2013 - October 2013** | Chicago, IL

**Target Focus:** Implemented custom tracking analytics and automated staging/production
deployment pipelines for high-traffic consumer web products.

**Key Outcomes:**
- Implemented custom tracking and analytics tools, enabling targeted monetization and
  direct platform revenue.
- Standardized automated testing and staging environments, establishing reliable
  continuous integration across the engineering team.
- Streamlined AWS deployment pipelines and server images, eliminating deployment
  downtime during peak consumer traffic spikes.

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

- **Senior Software Developer**, ReachLocal (March 2015 - November 2016): Owned API
  design and modernization strategy, leading incremental legacy migration for a
  high-volume digital marketing platform.
- **Senior Software Developer**, BenchPrep (March 2017 - February 2018): Owned
  enterprise assessment workflows, leading correctness and platform security in a
  high-concurrency environment.
- **Open-Source Transition Lead**, Coderwall (January 2014 - December 2014): Hired as a
  contractor by the founder to lead the open-source transition of the Coderwall
  developer reputation platform, a Y Combinator-backed professional network for software
  engineers (856 GitHub stars, 304 forks). Delivered security hardening, proprietary
  service extraction, infrastructure modernization, and community leadership as the top
  contributor to the open-source codebase.
- **Principal Consultant**, Tandem (August 2018 - August 2018): Conducted an on-site
  architectural and operational assessment for an at-risk federal software program (DoD
  MEPS), delivering viability analysis and risk mitigation recommendations directly to
  executive leadership.

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

# Automated Resume Quality & ATS Benchmarking Framework

## 1. System Overview & Purpose

This repository operates an automated, multi-tiered resume verification and ATS benchmarking suite. It ensures that Mike Hall's canonical career records (`_data/resume/`), tailored archetype variants (`resumes/`), plain text exports (`exports/resumes/*.txt`), machine-readable JSON files (`exports/resumes/*.json`), and print PDFs (`exports/resume.pdf`) maintain **100% data parity, zero formatting drift, high keyword resonance, and flawless ATS parseability**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CONTINUOUS RESUME VALIDATION PIPELINE                    │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
         ┌─────────────────────────────┼─────────────────────────────┐
         ▼                             ▼                             ▼
┌──────────────────┐          ┌──────────────────┐          ┌──────────────────┐
│  DATA PARITY &   │          │  ATS INGESTION   │          │  TARGET BENCHMARK│
│  SCHEMA GATES    │          │  EMULATION       │          │  SCORING         │
│                  │          │                  │          │                  │
│ • Canonical YAML │          │ • Contact info   │          │ • 5 Archetype    │
│   verification   │          │   extraction     │          │   Target Models  │
│ • Zero em dashes │          │ • Standard ATS   │          │ • Hard keywords  │
│ • Anti-metric    │          │   section headers│          │ • Architecture   │
│   hallucination  │          │ • Action verbs   │          │ • Leadership     │
│   attestation    │          │ • No AI jargon   │          │   density        │
└──────────────────┘          └──────────────────┘          └──────────────────┘
```

---

## 2. The 7 Automated Validation Layers (`bundle exec rake validate:resume_quality`)

Implemented in `bin/validate_resume_quality.rb` and executed as part of the master `validate:all` gate (see also `docs/resume-narrative-and-storytelling-guide.md` for narrative mechanics):

| Validation Layer | Implementation | Pass/Fail Criteria |
| :--- | :--- | :--- |
| **1. Macro Narrative Alignment** | Audits `_data/resume/summary.yml` and `_data/resume/profile.yml`. | Fails if summary text is missing/empty, lacks software-engineering scope, contains generic commodity phrases, or if profile title drifts. |
| **2. Canonical Positions & Causality** | Scans all YAML files in `_data/resume/positions/*.yml`. | Fails if summary is missing, if passive phrases (`responsible for`, `helped to`) are present, or if AI buzzwords (`tapestry`, `multifaceted`) are detected. Tracks structural outcome causality ratio. |
| **3. ATS Ingestion Emulation** | Simulates standard ATS ingestion engines across `exports/resumes/*.txt`. | Fails if contact info (name, email, phone, location) or required section headers (`PROFESSIONAL SUMMARY`, `CORE SKILLS`, `EXPERIENCE`) fail to parse. |
| **4. Structured JSON Schema** | Validates `exports/resumes/*.json` against JSON Resume schema. | Fails if `basics`/`profile` or `experience`/`positions` root keys are missing or malformed. |
| **5. Schema.org Linked Data** | Extracts `<script type="application/ld+json">` from rendered `_site/index.html`. | Fails if Googlebot-compatible `Person` or `Occupation` schema graph is invalid or missing. |
| **6. Strict Zero-Em-Dash Rule** | Scans all 38 YAML position records, Markdown resumes, and text exports. | Fails on any Unicode em dash or double-hyphen (`--`), enforcing `no-em-dashes`. |
| **7. Career Datalake Parity** | Compares canonical positions with `career_datalake.json` index. | Fails on any highlight drift, missing position ID, or stale delivery evidence. |

---

## 3. The 5 Target Benchmark Models (`bundle exec rake benchmark:ats`)

Implemented in `bin/benchmark_ats_keywords.rb`, this engine tests generated resume exports against real-world Staff+/Principal hiring requirements:

| Benchmark Model | Target Role Profile | Target Match Floor | Key Evaluation Signals |
| :--- | :--- | :--- | :--- |
| **Huntress Model** | Principal Software Engineer (Ruby/Rails & SOC Experience) | **>= 90%** | Rails platform architecture, OpenTelemetry, incident escalation, cybersecurity threat attribution, p99 reliability, PostgreSQL. |
| **Coder Model** | Staff Platform Engineer (Developer Enablement) | **>= 85%** | Platform enablement, Docker, Kubernetes, CI/CD, internal open source, working groups, automated verification gates. |
| **Enterprise Telemetry** | Observability & Resilience Specialist | **>= 95%** | Enterprise Trace, distributed tracing, MuleSoft/Mainframe boundaries, EMC/SRE alignment, 4% traffic loss recovery, root cause analysis. |
| **Fintech Modernizer** | Principal Systems Architect (Acquisition & Core Modernization) | **>= 85%** | Multi-channel acquisition funnels, Speedfunds instant disbursement, state machines, PII remediation, zero-downtime data migrations. |
| **Founding Staff AI** | Founding Staff Engineer (AI Systems & Developer Tooling) | **>= 75%** | Local LLM orchestration, workflow agents, JSON Schema inference, Bonsai Buckaroos, Rasa, MCP server tooling. |

---

## 4. Scoring Algorithm & Calculation

For each archetype profile, the composite match score is calculated as:

$$\text{Overall Score} = (\text{Hard Skills Match} \times 0.35) + (\text{Architecture Competencies} \times 0.35) + (\text{Leadership / Multiplier Match} \times 0.30)$$

### Quality Thresholds
* **Composite Average Score Target:** `>= 85.0%`
* **Minimum Archetype Floor:** `>= 75.0%`
* **ATS Section Extraction Rate:** `100.0%`

---

## 5. Operational Commands & Runbooks

### Run Standalone Resume Quality Audit:
```bash
bundle exec rake validate:resume_quality
```

### Run Standalone ATS Benchmark Suite:
```bash
bundle exec rake benchmark:ats
```

### Run Benchmark with Custom Thresholds:
```bash
ruby bin/benchmark_ats_keywords.rb --fail-under=88.0 --min-archetype=80.0
```

### Export Raw Benchmark JSON:
```bash
ruby bin/benchmark_ats_keywords.rb --json > tmp/ats_benchmark_report.json
```

### Run Master Site & Resume Validation Gate:
```bash
bundle exec rake validate:all
```

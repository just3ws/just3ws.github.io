# Engineering Tooling & Operational User Guide

This guide provides clear instructions on **why** and **how** to use the primary executable tools and AI skills in this repository to accomplish common platform tasks.

---

## 1. Executive Pitch Brief Generator (`bin/generate_executive_brief.rb`)

### Why Use It
When applying for Staff/Principal Engineer or Platform Architect roles, engineering leadership and recruiters respond far more effectively to a tailored 1-page executive pitch than a generic resume. This tool reads canonical YAML data (`_data/resume/`) and generates a custom executive brief mapping your 4D System Cartography case studies (OneMain Financial, EMR-Bear) directly to the target company's platform scaling challenges.

### How to Use It
```bash
# View CLI usage and options
ruby bin/generate_executive_brief.rb --help

# Generate a brief for a specific company and role
ruby bin/generate_executive_brief.rb "Stripe" "Principal Software Engineer"
ruby bin/generate_executive_brief.rb "Datadog" "Staff Platform Architect"
```

**Output Location:** `tmp/executive_briefs/brief_<company_name>.md`

---

## 2. Headless Chrome PDF Exporter (`bin/generate_pdf_resume.js`)

### Why Use It
Recruiters and hiring portals often require a traditional PDF attachment. Rather than manually exporting from a web browser, this automated Playwright script uses local Google Chrome to render a crisp, print-optimized 2-page PDF resume (`exports/resume.pdf`).

### How to Use It
```bash
# Generate the PDF export
node bin/generate_pdf_resume.js

# Validate PDF export integrity and file size budget in CI
ruby bin/validate_exports.rb
```

**Output Location:** `exports/resume.pdf`

---

## 3. Stdio MCP Protocol Verification Suite (`bin/verify_mcp_spec.js`)

### Why Use It
To maintain 100% self-verifying site integrity. This script connects directly to the repository's stdio MCP server (`bin/mcp_server.js`) to execute end-to-end schema validation (`validate_data.rb`), HTML link checking across 820+ pages (`html-proofer`), SEO metadata budget verification, and workspace skill manifest audits.

### How to Use It
```bash
# Execute full MCP verification suite
node bin/verify_mcp_spec.js
```

---

## 4. Unified Pipeline Runner (`bin/pipeline`)

### Why Use It
Provides a single, standardized entry point for all site build, test, and deployment workflows, preventing command drift between local development and GitHub Actions CI.

### How to Use It
```bash
# Build the production static site
./bin/pipeline build

# Run the complete test and validation suite
./bin/pipeline test

# Launch local development server on http://127.0.0.1:4000/
./bin/server

# Execute full CI parity check locally
./bin/pipeline ci
```

---

## 5. Registered Agent Skills (`.agents/skills/`)

### Why Use Them
Agents and subagents operating in this workspace rely on registered skills to perform specialized audits without manual instruction:

1. **`system-cartographer`** (`.agents/skills/system-cartographer/SKILL.md`): Audits legacy codebases and structures 4-dimensional cartography breakdowns (Interaction Surface, Lateral State Dependencies, Full-Stack Topology, Supply Chain Exposure).
2. **`executive-brief-generator`** (`.agents/skills/executive-brief-generator/SKILL.md`): Formats 1-page executive pitch briefs for specific Principal Engineer opportunities.
3. **`site-refresh-builder`** & **`site-refresh-reviewer`**: Governs liquid template and SCSS updates using a strict Director -> Builder -> Reviewer workflow.

---
type: C4 Component
title: PDF Resume & Brief Exporter
status: stable
groma:
  id: pdf-exporter
  parent: node-tooling
  code:
    - scanner: javascript
      file: bin/generate_pdf_resume.js
    - scanner: javascript
      file: bin/export_brief_pdfs.js
  technology: Node.js / Playwright
description: Generates vector PDF resumes and executive pitch briefs
---

Uses headless Chromium to render print CSS layouts for tailored resumes and Wayfinder executive pitch briefs.

## Relationships

| Source | Target | Description | Technology |
| --- | --- | --- | --- |
| [bin/generate_pdf_resume.js](../../../../../../bin/generate_pdf_resume.js) | [chromium-playwright](../../../../../externals/chromium-playwright.md) | Print pages to PDF | Playwright |

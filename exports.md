---
layout: minimal
title: Downloadable Exports
description: Download Mike Hall's resume and portfolio in multiple formats
permalink: /exports/
robots: index,follow
sitemap: true
---

{% include breadcrumbs.html %}

# Document Exports

Download resume, portfolio, and career history in multiple formats.

## Resume

- **PDF Resume (Named Recruiter Package)** - [mike-hall-principal-software-engineer-resume.pdf](/exports/mike-hall-principal-software-engineer-resume.pdf) (Print-optimized vector PDF package)
- **PDF Resume (Standard)** - [resume.pdf](/exports/resume.pdf)
- **Markdown** - [resume.md](/exports/resume.md) (Clean markdown, ideal for copy-pasting to LinkedIn or portals)
- **JSON Schema** - [resume.json](/resume.json) (Structured JSON for ATS and API ingestion)
- **Plain Text** - [resume.txt](/resume.txt) (UTF-8 plain text export)

## Portfolio

- **HTML** - [Project portfolio](/portfolio/) (interactive with timeline)

## Career History & Datalake

- **HTML** - [Complete timeline](/history/) (full experience breakdown)
- **Unified Datalake (JSON)** - [career_datalake.json](/career_datalake.json) (Career corpus, positions, writings, interviews, tech matrix)
- **Streaming Datalake (JSONL)** - [career_datalake.jsonl](/career_datalake.jsonl) (Line-delimited JSON for vector ingestion and AI pipelines)
- **LLM Context Markdown** - [exports/resume.md](/exports/resume.md) (Prompt-optimized markdown format)

---

**Note:** Text exports are generated from the source YAML data during each build. They're ideal for:
- Version control systems
- Documentation generators
- Accessibility tools
- Plain-text preservation
- Easy sharing via GitHub, email, or documentation platforms

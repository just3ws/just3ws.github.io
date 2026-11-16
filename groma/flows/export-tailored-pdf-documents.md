---
type: Groma Flow
title: Export tailored PDF documents
groma:
  id: export-tailored-pdf-documents
---

Operator invokes the Node PDF exporter, which drives headless Chromium via Playwright to render print-ready PDFs.

## Steps

| From | To | Action |
| --- | --- | --- |
| [Operator](../actors/operator.md) | [PDF Resume & Brief Exporter](../systems/just3ws-github-io/containers/node-tooling/components/pdf-exporter.md) | Export PDF documents |
| [PDF Resume & Brief Exporter](../systems/just3ws-github-io/containers/node-tooling/components/pdf-exporter.md) | [Chromium / Playwright](../externals/chromium-playwright.md) | Print pages to PDF |

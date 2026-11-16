---
type: C4 Component
title: Visual Regression Capture
status: stable
groma:
  id: visual-capture
  parent: node-tooling
  code:
    - scanner: javascript
      file: bin/capture_batch_2.js
      symbol: capture
    - scanner: javascript
      file: bin/capture_batch_3.js
      symbol: capture
    - scanner: javascript
      file: bin/capture_completionist.js
    - scanner: javascript
      file: bin/capture_portfolio_evolution.js
      symbol: capture
  technology: Node.js / Playwright
description: Batch screenshot capture for UI batches and portfolio evolution
---

Automates Chromium captures across key routes to inspect layout and styling regressions.

## Relationships

| Source | Target | Description | Technology |
| --- | --- | --- | --- |
| [bin/capture_batch_2.js](../../../../../../bin/capture_batch_2.js) | [chromium-playwright](../../../../../externals/chromium-playwright.md) | Capture page screenshots | Playwright |

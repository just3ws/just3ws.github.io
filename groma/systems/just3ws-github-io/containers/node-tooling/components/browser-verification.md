---
type: C4 Component
title: Browser & MCP Verification
status: stable
groma:
  id: browser-verification
  parent: node-tooling
  code:
    - scanner: javascript
      file: tests/layout.spec.js
    - scanner: javascript
      file: playwright.config.js
    - scanner: javascript
      file: bin/verify_mcp_spec.js
      symbol: runSelfVerification
  technology: Playwright Test / Node.js
description: Playwright layout specs, config, and MCP contract verification
---

Runs automated browser layout assertions and MCP verification checks before deployment.

## Relationships

| Source | Target | Description | Technology |
| --- | --- | --- | --- |
| [tests/layout.spec.js](../../../../../../tests/layout.spec.js) | [chromium-playwright](../../../../../externals/chromium-playwright.md) | Verify layout contracts | Playwright Test |

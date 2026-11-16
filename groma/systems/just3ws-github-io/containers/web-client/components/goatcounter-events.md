---
type: C4 Component
title: GoatCounter Event Tracker
status: stable
groma:
  id: goatcounter-events
  parent: web-client
  code:
    - scanner: javascript
      file: assets/js/goatcounter-events.js
  group: Site Discovery & Telemetry
  technology: Browser JavaScript
description: Lightweight privacy-friendly interaction telemetry
---

Dispatches custom navigation and CTA click events to GoatCounter without third-party cookies.

## Relationships

| Source | Target | Description | Technology |
| --- | --- | --- | --- |
| [assets/js/goatcounter-events.js](../../../../../../assets/js/goatcounter-events.js) | [goatcounter](../../../../../externals/goatcounter.md) | Send interaction telemetry | HTTPS |

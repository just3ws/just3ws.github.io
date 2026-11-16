---
type: C4 Component
title: Dehum Multimedia Suite
status: stable
groma:
  id: multimedia-suite
  parent: studio-browser
  code:
    - scanner: javascript
      file: dehum/js/multimedia-suite.js
  technology: Browser JavaScript / Web Audio
description: Interactive A/B audio restoration and waveform inspection UI
---

Coordinates synchronized original vs restored audio playback and visual diagnostics on the Dehum lab pages.

## Relationships

| Source | Target | Description | Technology |
| --- | --- | --- | --- |
| [dehum/js/multimedia-suite.js](../../../../../../dehum/js/multimedia-suite.js) | [dehum/js/analytics-events.js](../../../../../../dehum/js/analytics-events.js) | Emit audio inspection events | Browser events |

---
type: C4 Component
title: Mermaid Diagram Initializer
status: stable
groma:
  id: mermaid-init
  parent: web-client
  code:
    - scanner: javascript
      file: assets/js/mermaid-init.js
  group: Interactive Rendering
  technology: Browser JavaScript / Mermaid.js
description: Hydrates fenced Mermaid code blocks into inline SVGs
---

Initializes Mermaid.js at page load across documentation briefings, series hubs, and walkthroughs.

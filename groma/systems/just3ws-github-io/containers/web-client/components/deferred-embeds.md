---
type: C4 Component
title: Deferred Embeds Loader
status: stable
groma:
  id: deferred-embeds
  parent: web-client
  code:
    - scanner: javascript
      file: assets/js/deferred-embeds.js
  group: Interactive Rendering
  technology: Browser JavaScript
description: Lazy-loads YouTube and external iframes on user interaction
---

Replaces eager third-party iframe embeds with facade previews until clicked, preserving page performance.

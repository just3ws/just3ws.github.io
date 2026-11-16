---
type: C4 Component
title: OBS Overlay Controller
status: stable
groma:
  id: overlay-controller
  parent: studio-browser
  code:
    - scanner: javascript
      file: obs/overlays/js/overlay-controller.js
      symbol: OverlayController
  technology: Browser JavaScript
description: Polls overlay-state.json and drives lower-third broadcast graphics
---

Runs inside OBS Browser Sources to update lower-thirds and cue metadata during Studio Workbench and Sound Above sessions.

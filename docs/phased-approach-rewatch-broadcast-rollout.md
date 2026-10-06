# The Phased Approach: Broadcast Rollout and Knowledge Bridge Strategy

## Overview

This document defines the official phased execution strategy for **The Sound Above** oral history rewatch series and its integration with the `just3ws.com` public knowledge platform.

The goal is to transition from initial broadcast nervousness into a repeatable, sustainable, and stress-free production rhythm. Rather than attempting to launch all 21 episodes, companion retrospectives, and cross-platform channels simultaneously, this strategy breaks the initiative into five progressive phases.

```
┌────────────────────────────────────────────────────────────────────────┐
│                      FIVE-PHASE ROLLOUT ARCHITECTURE                   │
├─────────┬──────────────────────┬──────────────────┬────────────────────┤
│ Phase   │ Focus                │ Cadence          │ Deliverable        │
├─────────┼──────────────────────┼──────────────────┼────────────────────┤
│ Phase 1 │ The Maiden Voyage    │ Single Broadcast │ Episode 01 Live    │
│ Phase 2 │ Movement 1 Cadence   │ Bi-Weekly        │ Episodes 02 to 05  │
│ Phase 3 │ Dojo & Practice      │ Bi-Weekly        │ Episodes 06 to 10  │
│ Phase 4 │ Philosophy & Reckon  │ Monthly          │ Episodes 11 to 18  │
│ Phase 5 │ Capstone & Synthesis │ Special Events   │ Episodes 19 to 21  │
└─────────┴──────────────────────┴──────────────────┴────────────────────┘
```

---

## Phase 1: The Maiden Voyage (Episode 01)

### Primary Mandate
Break the seal. Overcome pre-flight hesitation by conducting a clean, unpretentious, low-friction maiden broadcast focused entirely on Sergio Pereira and Chicago Alt.NET.

### Core Objectives
1. **Host Psychological Safety:**
   - Establish comfort in front of the lens.
   - Speak in your natural voice: authentic, humble, and rooted in lived community memory.
   - Avoid performative influencer tropes, formal academic posturing, or corporate slickness.
2. **Technical Pipeline Verification:**
   - Verify native macOS Golden Gate desktop audio capture and host microphone levels.
   - Confirm hardware-accelerated Apple VideoToolbox H.264 streaming to YouTube Live.
   - Verify that the interactive HTML lower-third and now-watching overlays render cleanly.
3. **Artifact Handoff:**
   - Link the live stream replay to [series/the-sound-above/episode-01.html](/series/the-sound-above/episode-01/).
   - Ensure the high-fidelity 44-turn WebVTT caption track is active on YouTube video `qOHdZKz1WFw`.

---

## Phase 2: The Chicago Crucible Cadence (Episodes 02 to 05)

### Primary Mandate
Build a steady, comfortable operating rhythm around the roots of the Chicago craftsmanship renaissance.

### Sequence & Focus
- **Episode 02: Ray Hightower (ChicagoRuby):** The ambassador of grassroots hospitality and sustaining monthly gatherings for two decades.
- **Episode 03: Micah Martin and Mike Jansen (8th Light):** Pair Friday, early Libertyville origins, and the craft apprenticeship model.
- **Episode 04: Dave Hoover (Obtiva):** From clinical psychology to *Apprenticeship Patterns* and the Geekfest learning circle.
- **Episode 05: Ryan Gerry and Jim Suchy (SCMC):** The 17-year continuous user group in McHenry County and suburban self-reliance.

### Operational Adjustments
- Establish a consistent bi-weekly broadcast slot (such as Tuesday or Thursday evenings).
- Automate pre-broadcast overlay state updates using `obs/scripts/update-overlay-state.sh --episode <N>`.
- Generate 1080p and 720p thumbnails ahead of schedule via `bin/generate_rewatch_thumbnail.rb -e <N> -a`.

---

## Phase 3: The Practice and the Dojo (Episodes 06 to 10)

### Primary Mandate
Bridge deliberate human practice into the modern technical workbench.

### Sequence & Focus
- **Episode 06: Corey Haines:** Global Day of Coderetreat, Conway's Game of Life, and cranking design feedback loops to 11.
- **Episode 07: Charley Baker:** Toolmakers, early browser automation, and the roots of Watir and WatiN.
- **Episode 08: Tim Ottinger:** Clean code, Object Mentor roots in Lake Zurich, and deliberate daily practice.
- **Episode 09: Andrea Magnorsky:** Game jams, functional programming, and polyglot curiosity.
- **Episode 10: Gary Bernhardt:** Sub-millisecond feedback loops, Unix ergonomics, and *Boundaries*.

### Operational Evolution
- Introduce live workbench code demonstrations (Scene 05) connecting historical practices to modern TypeScript, Ruby, and Go test runners.
- Contrast human pair-programming disciplines with modern LLM copilot workflows.

---

## Phase 4: Philosophy, Sociology, and Reckoning (Episodes 11 to 18)

### Primary Mandate
Engage the major philosophical debates of the craft: BDD, team sociology, and the testing schism.

### Sequence & Focus
- **Episode 11: Dan North:** Software as human communication, deliberate discovery, and resisting certification mills.
- **Episode 12: Dave "pragdave" Thomas:** Unlearning dogma and returning to the Snowbird Agile principles.
- **Episode 13: Hadi Hariri:** Humility, perspective, and the truck driver's wisdom.
- **Episode 14: Sarah Mei:** Sociotechnical systems, team cognition, and code issues as social signals.
- **Episode 15: Sandi Metz:** Practical Object-Oriented Design, message passing, and small methods.
- **Episode 16: David Heinemeier Hansson (DHH):** The Chicago corridor interview immediately following the "TDD is Dead" keynote.
- **Episode 17: Matt Deiters:** Verifiable code provenance versus resume claims.
- **Episode 18: Jason Cranford Teague:** Preserving technical wisdom through the transition from paper to web.

### Operational Evolution
- Invite remote guest co-hosts or original interviewees for split-screen panel discussions (Scene 06).
- Cross-reference interactive transcripts on `just3ws.localhost` to highlight key historical quotes in real time.

---

## Phase 5: The Capstone & The AI Horizon (Episodes 19 to 21)

### Primary Mandate
Synthesize seventeen years of craftsmanship discipline into a coherent operating model for the agentic AI era.

### Sequence & Focus
- **Episode 19: The Platform Capstone (Without zdots, There Was Nothing):**
  - Why the local workbench had to be observable before language models arrived.
  - The Blink Test: Green, Red, Green again before any claim of success is accepted.
  - Demonstrating OpenTelemetry traces and deterministic system cartography.
- **Episode 20: Phalanx Duel (Legible Rules to Multiplayer Engine):**
  - How deterministic tabletop rules translate into a server-authoritative engine.
  - Why autonomous agents require explicit rule machines to prevent state drift.
- **Episode 21: The Sound Above Community Roundtable:**
  - Live community roundtable with Chicago Craftsmanship veterans and next-generation practitioners.
  - Framing the sound above for the coming decade: building bridges rather than gates.

---

## The Knowledge Preservation Mandate: Shortening the Interregnum

In Isaac Asimov's *Foundation*, Hari Seldon realized that the collapse of the imperial core could not be averted, but the dark age between civilizational eras could be compressed from thirty thousand years to a single millennium if core knowledge was deliberately gathered, protected, and stewarded by practitioners who understood how the machinery functioned.

Software engineering is navigating an analogous transition. As generative models synthesize code in milliseconds, the industry risks entering an interregnum of understanding:
1. **The Atrophy of Fundamentals:** If a generation of developers never has to isolate a subtle race condition, trace an HTTP pipeline down to TCP socket buffers, or structure an explicit state machine, the muscle memory of the craft atrophies.
2. **The Illusion of Synthesis:** Synthetic code without verified boundaries creates opaque technical debt that breaks catastrophically under load.
3. **The Seldon Vault of Software Craftsmanship:** The 184 interviews in the UGtastic archive, the 17 years of monthly gatherings at SCMC, and the 27,601 signatures in the Software Craftsmanship datalake represent our living vault. They document how practitioners clawed their way out of corporate monoliths through deliberate practice, test-driven feedback loops, and open-source collaboration.

By carrying this empirical knowledge forward across the AI transition, we ensure that when the hype cycle cools and systems require deep diagnosis, the principles to maintain and rebuild durable software remain intact.

---

## Summary Checklist for Host Confidence

```
┌────────────────────────────────────────────────────────────────────────┐
│                        HOST PEACE-OF-MIND CONTRACT                     │
├────────────────────────────────────────────────────────────────────────┤
│ 1. You are not giving a lecture. You are revisiting a conversation.    │
│ 2. The pipeline is tested and deterministic (40/40 OBS assertions).    │
│ 3. If audio or video glitches occur, press Cmd-4 for Technical Pause.  │
│ 4. You were in the room when this community formed; your memories are  │
│    the authentic context people cannot get from automated models.      │
│ 5. Keep it unpretentious, keep it grounded, and have fun with it.     │
└────────────────────────────────────────────────────────────────────────┘
```

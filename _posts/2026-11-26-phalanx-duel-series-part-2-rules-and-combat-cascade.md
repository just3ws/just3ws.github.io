---
layout: post
title: "Phalanx Duel Series, Part 2: Canonical Rules v3.0 & The Combat Cascade"
date: 2026-11-26 07:46:00 -0600
permalink: /2026/11/26/phalanx-duel-series-part-2-rules-and-combat-cascade.html
canonical_url: https://phalanxduel.com/articles/rules-and-combat-cascade/
originally_published_on: Phalanx Duel
original_url: https://phalanxduel.com/articles/rules-and-combat-cascade/
original_published_at: 2026-11-26
ai_generated: false
human_led: true
source_kind: organic-practitioner-essay
robots: index,follow
sitemap: true
categories: [architecture, craftsmanship, games]
tags: [phalanx-duel, rules-engine, state-machines, combat-cascade, typescript]
description: "Part 2 of the Phalanx Duel series: the executable 8-phase state machine, column overkill arithmetic, four suit boundaries, Classic vs Cumulative damage modes, and video walkthroughs."
---

The canonical rules breakdown lives at **[phalanxduel.com/articles/rules-and-combat-cascade/](https://phalanxduel.com/articles/rules-and-combat-cascade/)**. Here is the engineering lens on why encoding Rules `v3.0` as a finite state machine eliminates ambiguity.

## Executable Specifications Over Informal Prose

Every tabletop ruleset hides edge cases in English prose: *Can a player forfeit during cleanup? What happens if both players pass repeatedly? Does a suit effect fire before or after front-rank absorption?*

In Phalanx Duel, [`engine/src/state-machine.ts`](https://github.com/phalanxduel/phalanxduel/blob/main/engine/src/state-machine.ts) is the single source of truth for all valid transitions across 8 phases (`StartTurn`, `DeploymentPhase`, `AttackPhase`, `AttackResolution`, `CleanupPhase`, `ReinforcementPhase`, `DrawPhase`, `EndTurn`, plus terminal `gameOver`). Automated transition tests verify that the engine implements every declared edge and rejects every undeclared one - including `quickDeploy`, `deploy:auto`, and the canonical `system:draw` turn-boundary liveness rule.

## The Four Suit Boundaries

Damage travels strictly down a column: **Opposing Front Card → Opposing Back Card → Opponent Life Points**. Suits act only at the boundaries:

- **Diamonds (`♦`):** Shield carryover across the front-to-back boundary.
- **Clubs (`♣`):** Double eligible overflow spilling past a defeated defender.
- **Hearts (`♥`):** Cushion damage crossing into Life Points.
- **Spades (`♠`):** Double unblocked damage hitting opponent Life Points.

Players can test any scenario directly in the interactive [Combat Lab](https://phalanxduel.com/tools/battle-calculator/) or inspect the [State Machine Diagram](https://github.com/phalanxduel/phalanxduel/wiki/State-Machine-Diagram).

## Watch the Rules & Strategy Episodes (`@just3ws-mike`)

- [Formation-First Deployment & Quick Deploy](https://youtu.be/_7OLhDb4McQ) (Ep. 02)
- [Combat Cascade & Column Overkill Explained](https://youtu.be/YAnBdzdvQxQ) (Ep. 03)
- [The Four Suit Boundaries (Diamonds, Hearts, Clubs, Spades)](https://youtu.be/KS5A69rM3Tk) (Ep. 04)
- [Aces, Face Cards, Pass, Reinforce & Victory Conditions](https://youtu.be/c8y8SkhMlvk) (Ep. 05)
- [Classic vs. Cumulative Damage Modes](https://youtu.be/DmdoO1k01z0) (Ep. 09)
- [Advanced Strategy: Column Architecture & Suit Synergy](https://youtu.be/RCFCAqMH9Sk) (Ep. 20)
- [Pro Tip: Tempo, Pass Economy & Face-Card Traps](https://youtu.be/1-eyVc2Edwc) (Ep. 21)

## Series Navigation

- [← Part 1: The Game & Core Concepts](/2026/11/26/phalanx-duel-series-part-1-the-game-and-concepts.html)
- **Part 2 (Current):** Canonical Rules v3.0 & The Combat Cascade · [Canonical edition on phalanxduel.com](https://phalanxduel.com/articles/rules-and-combat-cascade/)
- [Next: Part 3 - Living Architecture & Diagrams →](/2026/11/26/phalanx-duel-series-part-3-living-architecture-and-diagrams.html)

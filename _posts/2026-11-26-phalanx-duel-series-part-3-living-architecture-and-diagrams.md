---
layout: post
title: "Phalanx Duel Series, Part 3: Living Architecture, Diagrams & Freshness Gates"
date: 2026-11-26 07:47:00 -0600
permalink: /2026/11/26/phalanx-duel-series-part-3-living-architecture-and-diagrams.html
originally_published_on: Phalanx Duel
original_url: https://phalanxduel.com/articles/living-architecture-and-diagrams/
original_published_at: 2026-11-26
ai_generated: false
human_led: true
source_kind: organic-practitioner-essay
robots: index,follow
sitemap: true
categories: [architecture, craftsmanship, observability]
tags: [phalanx-duel, panoramic-view, c4-model, diagrams, system-cartography, groma]
description: "Part 3 of the Phalanx Duel series: applying Panoramic View system cartography to keep 12 wiki diagrams, a Groma C4 explorer, and an automated freshness checker honest."
---

The canonical architecture reference lives at **[phalanxduel.com/articles/living-architecture-and-diagrams/](https://phalanxduel.com/articles/living-architecture-and-diagrams/)**. Here is how the **Panoramic View** system-cartography mindset turns diagrams from stale wall art into verifiable contracts.

## The Lie of Stale Diagrams

During our `v1.6.0` audit of the Phalanx Duel wiki, several diagrams still carried an outdated `v1.0` route map, referenced a retired error-tracking vendor, or pointed to a nonexistent `pnpm check:quick` command - even while their headers claimed they had been recently verified.

Fixing the prose once is not enough. Without a feedback loop, diagrams drift again on the next minor release.

## Two Tiers + One Executable Check

1. **Auto-Generated Live Views:** Every release rebuilds the **[Interactive Groma C4 Architecture Map](https://phalanxduel.com/library/architecture/)** and the **[Visual Documentation Library](https://phalanxduel.com/library/)** directly from source code (Database ERD, System Topology, Package DAG, and Fastify API Directory).
2. **12 Curated Wiki Diagrams + Meta-Diagram:** The [GitHub Wiki Diagram Index](https://github.com/phalanxduel/phalanxduel/wiki/Diagram-Index) renders a **Meta-Diagram of Diagrams** showing how System Context, Containers, API Surface, Bootstrap, Runtime Sequence, Match Lifecycle, State Machine, Database ERD, Telemetry Pipeline, Intake, and Contribution Workflow connect.
3. **Version Mapping & 90-Day Expiration (`bin/check-diagram-freshness`):** Every diagram carries `Applies to version: v1.6.0`, `Last verified: YYYY-MM-DD`, and `Reconfirm by: YYYY-MM-DD`. A zero-dependency Python checker compares every diagram against `../game/package.json` and today's date, exiting non-zero on version drift or expiration.

## Watch Verification & Observability Videos (`@just3ws-mike`)

- [Reading the HUD, Combat Math Inspector & Narration Settings](https://youtu.be/b5JYEdbTmlw) (Ep. 08)
- [Deterministic Replays & Cryptographic Hash-Chain Verification](https://youtu.be/U1u8AwF_OmI) (Ep. 15)
- [Spectator Mode: Watch Links, Delay & Fair-Play Redaction](https://youtu.be/yg8-nTqxdd8) (Ep. 16)

## Series Navigation

- [← Part 2: Canonical Rules v3.0 & The Combat Cascade](/2026/11/26/phalanx-duel-series-part-2-rules-and-combat-cascade.html)
- **Part 3 (Current):** Living Architecture & Diagrams · [Canonical edition on phalanxduel.com](https://phalanxduel.com/articles/living-architecture-and-diagrams/)
- [Next: Part 4 - The Engineering Process & Multi-Client Platform →](/2026/11/26/phalanx-duel-series-part-4-engineering-process-and-multi-client-platform.html)

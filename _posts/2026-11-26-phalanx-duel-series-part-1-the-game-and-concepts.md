---
layout: post
title: "Phalanx Duel Series, Part 1: The Game, Core Concepts & Making Rules Legible"
date: 2026-11-26 07:45:00 -0600
permalink: /2026/11/26/phalanx-duel-series-part-1-the-game-and-concepts.html
originally_published_on: Phalanx Duel
original_url: https://phalanxduel.com/articles/what-is-phalanx-duel/
original_published_at: 2026-11-26
ai_generated: false
human_led: true
source_kind: organic-practitioner-essay
robots: index,follow
sitemap: true
categories: [architecture, craftsmanship, games]
tags: [phalanx-duel, game-design, state-machines, scmc, deterministic-systems]
description: "Part 1 of the Phalanx Duel series: how a zero-RNG two-deck tactical card game designed at Camp Tesomas evolved into v1.6.0, with canonical links and published video walkthroughs."
---

This is **Part 1** of a five-part series documenting **Phalanx Duel (`v1.6.0` / Rules `v3.0`)** across [phalanxduel.com](https://phalanxduel.com) and [just3ws.com](https://www.just3ws.com), picking up the story from my earlier [SCMC presentation write-up](/2026/10/20/phalanx-duel-make-the-rules-legible-scmc-presentation-and-game-architecture.html).

The canonical player and concepts reference lives at **[phalanxduel.com/articles/what-is-phalanx-duel/](https://phalanxduel.com/articles/what-is-phalanx-duel/)**.

## Why Design a Zero-RNG Card Game?

Most digital card games lean on hidden randomness to create drama. When I sketched Phalanx Duel on a rainy afternoon at Boy Scout Camp Tesomas in July 2022, I wanted the opposite: **legible consequence**.

- **Two standard 52-card decks**, no dice, no mid-game reshuffles.
- **A 2×4 formation per player:** four front-rank vanguard slots and four back-rank flank slots.
- **Symmetric Fog of War:** once a card hits the battlefield it is public; hands and draw piles stay hidden and server-redacted.
- **Deterministic combat math:** every strike resolves front card → back card → player Life Points (`20 LP`), governed by four suit boundaries (Diamonds, Clubs, Hearts, Spades).

Because every outcome is a pure function of visible board state and legal player intent, the tabletop game and the production software engine speak the exact same language.

## Watch the Core Videos (`@just3ws-mike`)

- [What Is Phalanx Duel? (60-Second Overview)](https://youtu.be/Lktn0-bre5g)
- [Your First Attack in Phalanx Duel](https://youtu.be/ygf_GOylEQc)
- [Phalanx Duel: Make the Rules Legible (Automated Rules Engine & Combat Demo)](https://youtu.be/eH6VQa2Od3E)
- [Phalanx Duel: Early Version Walkthrough with Conrad Hall](https://youtu.be/CdYwA0SG34M)

Full 33-episode curriculum: [phalanxduel.com/learn/tutorials/](https://phalanxduel.com/learn/tutorials/) · [YouTube Playlist](https://www.youtube.com/playlist?list=PLHenvAZhJjHo).

## Series Navigation

- **Part 1 (Current):** The Game & Core Concepts · [Canonical edition on phalanxduel.com](https://phalanxduel.com/articles/what-is-phalanx-duel/)
- **Part 2:** [Canonical Rules v3.0 & The Combat Cascade](/2026/11/26/phalanx-duel-series-part-2-rules-and-combat-cascade.html)
- **Part 3:** [Living Architecture, Diagrams & Freshness Gates](/2026/11/26/phalanx-duel-series-part-3-living-architecture-and-diagrams.html)
- **Part 4:** [The Engineering Process & Multi-Client Platform](/2026/11/26/phalanx-duel-series-part-4-engineering-process-and-multi-client-platform.html)
- **Part 5:** [Automated Video Curriculum & Media Pipeline](/2026/11/26/phalanx-duel-series-part-5-automated-video-curriculum-and-media-pipeline.html)

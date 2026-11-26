---
layout: post
title: "Phalanx Duel Series, Part 5: Turning Live Gameplay into a 33-Episode Video Curriculum with Media Pipeline"
date: 2026-11-26 07:49:00 -0600
permalink: /2026/11/26/phalanx-duel-series-part-5-automated-video-curriculum-and-media-pipeline.html
canonical_url: https://www.just3ws.com/2026/11/26/phalanx-duel-series-part-5-automated-video-curriculum-and-media-pipeline.html
ai_generated: false
human_led: true
source_kind: organic-practitioner-essay
robots: index,follow
sitemap: true
categories: [craftsmanship, automation, media]
tags: [phalanx-duel, media-pipeline, playwright, video-automation, youtube, tutorials]
description: "Part 5 of the Phalanx Duel series (Canonical): how Playwright gameplay automation, engine rule-ID telemetry assertions, and media-pipeline produce and syndicate a 33-episode tutorial series."
---

*Canonical edition on `just3ws.com` · Companion index on [phalanxduel.com/articles/video-curriculum-and-media-pipeline/](https://phalanxduel.com/articles/video-curriculum-and-media-pipeline/) · Engine `v1.6.0`*

Manual tutorial videos age faster than architecture diagrams. One CSS layout shift, one renamed button, or one rules refinement and your entire video library contradicts the product.

For Phalanx Duel `v1.6.0`, I treated the **33-episode, 8-season video curriculum** the same way I treat automated integration tests: **executable, deterministic, and verified against live engine telemetry**.

## 1. Scripted Live Capture (`scripts/tutorials/record-episode.ts`)

Every episode - 16 vertical `9:16` Shorts and 17 widescreen `16:9` Deep Dives - boots against the real local server and React client via Playwright. Instead of faking screenshots, the harness creates real matches, executes real deployments and attacks, captures voiceover-paced beats, and verifies dark-mode luminance (`YAVG`) across every staged MP4.

## 2. Proving What Was Actually Recorded

A subtle trap in automated video generation is assuming a clip shows a rule just because the script *tried* to trigger it. To close that loop, we added `requiredRuleIds` telemetry assertions and phase-safe turn search to the recorder:

- Each episode inspects the live match transaction log after capture.
- If a Clubs overflow or Hearts life-point shield episode did not actually fire the expected engine rule ID on screen, the run flags it immediately instead of silently shipping misleading footage.

## 3. Syndication Through `media-pipeline`

Once captured, `scripts/tutorials/stage-episode.ts --sync-site` stages each episode's MP4, `.vtt` captions, thumbnail, `.card.md`, and `.metadata.json` directly into `media-pipeline` (`/just3ws-mike/phalanx-duel/`). From there:

1. Videos publish to **[`@just3ws-mike`](https://www.youtube.com/@just3ws-mike)** under the **[Phalanx Duel Playlist (`PLHenvAZhJjHo`)](https://www.youtube.com/playlist?list=PLHenvAZhJjHo)**.
2. Published YouTube IDs hydrate `_data/tutorials.yml` on **[phalanxduel.com/learn/tutorials/](https://phalanxduel.com/learn/tutorials/)** (enabling privacy-friendly `youtube-nocookie` click-to-load embeds alongside full transcripts).
3. Video receipts and transcripts sync into `just3ws.com`'s public archive (`_data/video_assets.yml`), connecting the game curriculum with the broader engineering archive.

## Featured Published Episodes (`@just3ws-mike`)

- [Sign Up, Gamertags & Account Management](https://youtu.be/Fax9WCreY8c) (Ep. 06)
- [Cardbacks & Cosmetics: Neon Relay, Dual Loop & Obsidian Heraldry](https://youtu.be/_Silz_TvaCA) (Ep. 07)
- [Profiles, Match History & Rarity Achievements](https://youtu.be/MucIU1Hq2G8) (Ep. 14)
- [How to Play in a Local / LAN Tournament](https://youtu.be/g_kIYFa4FP4) (Ep. 17)

Explore all 8 seasons and 33 episodes on **[phalanxduel.com/learn/tutorials/](https://phalanxduel.com/learn/tutorials/)** or watch the **[YouTube Playlist](https://www.youtube.com/playlist?list=PLHenvAZhJjHo)**.

## Canonical Sources & Attribution

- **Video Hub:** [phalanxduel.com/learn/tutorials/](https://phalanxduel.com/learn/tutorials/)
- **Companion Summary:** [phalanxduel.com/articles/video-curriculum-and-media-pipeline/](https://phalanxduel.com/articles/video-curriculum-and-media-pipeline/)
- **Recording Harness:** [`scripts/tutorials/`](https://github.com/phalanxduel/phalanxduel/tree/main/scripts/tutorials) in `phalanxduel/phalanxduel`

## Series Navigation

- [← Part 4: The Engineering Process & Multi-Client Platform](/2026/11/26/phalanx-duel-series-part-4-engineering-process-and-multi-client-platform.html)
- **Part 5 (Current):** Automated Video Curriculum & Media Pipeline
- [Series Index on phalanxduel.com →](https://phalanxduel.com/articles/)

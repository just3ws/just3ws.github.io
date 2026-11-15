---
layout: post
title: "Fluffle: Five Raspberry Pis and 1K+ Transcript Pairs"
date: 2026-10-16 14:00:00 -0500
permalink: /ai/2026/10/16/the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster/
redirect_from:
  - /2026/10/16/the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster.html
  - /ai/2026/10/16/the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster.html
  - /2026/10/16/the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster/
ai_generated: true
human_led: true
source_kind: ai-augmented-human-led
robots: noindex,follow
sitemap: false
categories: [ai, audio, craftsmanship]
tags: [whisper, raspberry-pi, distributed-systems, dead-rabbit-radio, audio-transcription]
description: "A full engineering retrospective on Fluffle (just3ws/fluffle): five Raspberry Pi 4s running DietPi and whisper.cpp across 79 commits to produce 1,017 Dead Rabbit Radio transcript pairs, and how those invariants shaped the 2026 media pipeline."
---

There is a circular Dead Rabbit Radio sticker on the lid of my MacBook Air, right next to the Apple logo. To most people it looks like ordinary podcast merch. To me it is a physical artifact of [just3ws/fluffle](https://github.com/just3ws/fluffle), the 2023 distributed `whisper.cpp` experiment that became the pivot plank of my 18-year infrastructure story in [Studio Workbench Episode 1: The Ship of Theseus](/series/studio-workbench/ship-of-theseus/).

> **Companion Surfaces:** Explore the [Studio Workbench Episode 2 Walkthrough](/series/studio-workbench/fluffle-cluster/) (with interactive HTML5 Canvas), the [7-Perspective Mermaid Briefing](/docs/studio-workbench-fluffle-theseus-briefing/), and the [JSON Canvas Architecture Map](/docs/fluffle-architecture-walkthrough.canvas).

---

## Why start with Dead Rabbit Radio instead of UGtastic?

Between 2009 and 2014, I recorded more than two hundred technical interviews for [UGtastic](/interviews/). Paying human transcription services at one to two dollars per minute was out of reach for a grassroots archive, and early cloud speech APIs mangled technical names like `NHibernate`, `StructureMap`, and `NUnit`. A 2014 crowdsourcing attempt (`just3ws/many-hands-make-light-work`) stalled as well.

When Georgi Gerganov released `whisper.cpp`, local speech recognition on hardware I already owned suddenly became possible. I refused to beta-test an unproven local AI pipeline on irreplaceable UGtastic community history. Dead Rabbit Radio, a daily paranormal podcast hosted by Jason Carpenter, gave me what an engineer actually needs before touching production cargo: a consistent solo speaker, more than a thousand episodes, and zero risk to the primary archive.

Seventeen months before writing a line of Fluffle code, on **November 8, 2021**, Jason welcomed me into Dead Rabbit Command as a Patreon supporter on **EP 769** (*Was Travis Scott's Astroworld A Satanic Sacrifice?*):

- **`00:00:49`**: *"Give it up for Mike Hall. Give a round of applause to Mike."*
- **`00:14:53`**: *"Mike Hall is flying us around the carbon helicopter."*

In show lore, Jason calls his supporter community **The Fluffle**, because a group of wild rabbits is called a fluffle. When I spun up five Raspberry Pis in April 2023, that was the only name for the repository.

---

## Hardware, OS, Ruby, and Engine Specs (Verified Ledger)

Every detail below comes directly from `~/github.com/just3ws/fluffle` and 2023-2024 session logs:

- **Cluster (`node01..node05`):** Five Raspberry Pi 4 boards on a desk (**two Raspberry Pi 4B, three plain Raspberry Pi 4**; `node01` confirmed 8GB RAM), stock passive heatsinks, official cases, **USB thumbdrives** for storage (not microSD cards), WiFi turned off, wired through a dedicated local hub router.
- **Node OS & Kernel:** **DietPi on Debian 11 (Bullseye) `aarch64`**, verified on `node01` via `uname -a`: `Linux node01 6.1.21-v8+ #1642 SMP PREEMPT Mon Apr 3 17:24:16 BST 2023 aarch64 GNU/Linux`.
- **Control Plane & Ruby:** Intel macOS 13 Ventura (`x86_64-darwin-22`), Bundler `2.4.13`, and Ruby `3.1+` hash-value shorthand syntax in `Rakefile`, `bin/distribution`, and `bin/episode_checker.rb` (no `.ruby-version` pin in the repo; March 25 Raft prototypes started on Ruby `2.7`).
- **Transcription Engine:** `~/whisper.cpp/main -m ~/whisper.cpp/models/ggml-small.bin -f "$file" -osrt -otxt` (Whisper `small` 244M GGML; exact 2023 build commit and model byte size are unlogged).

---

## Pre-Repo Effort and 67 Days of Git Archaeology (79 Commits)

The work began in vault logs two weeks before the repository's April 6 `Initial commit` (`6c0fa85`):

- **Mar 25 to Apr 5, 2023 (Pre-Repo Prep):** Asynchronous `Net::SSH` `apt update` loops across `node01..node05`, a Ruby 2.7 Raft prototype, Libsyn XML parsing (`feeds.libsyn.com/140084/rss`), a failed PyTorch/CUDA test on an Intel macOS Radeon GPU, `.srt` Word2Vec experiments, and `lm-sensors` thermal checks on the Pis.
- **Phase 1: Pure Discovery (Apr 6 to Apr 17, 51 commits in 12 days):** Commits cluster at 6 AM before work, noon at lunch, and 9 PM after dinner. On Day 1 (`2023-04-06`), I added CC BY-NC-ND 4.0 `LICENSE` and `CONTRIBUTING`. Commit `abc718c` dedicated episode 381 to fellow listener Rudie Jazz, and `2fac228` deleted 26 duplicate `.wav.srt` files (`-52,952` lines) after catching `whisper.cpp`'s `<file>.wav.srt` naming quirk.
- **Phase 2: The Manual Wall (Apr 25, 1 commit):** Commit `3122642` (*A whole mess of corrections*) hand-edited **509 files**, proving manual cleanup could not scale. A 22-day silence followed.
- **Phase 3: Systems Pivot & `Process 2.0` (May 17 to Jun 12, 27 commits):** On May 17 between `07:03` and `07:13 AM`, `bin/replacements` and `replacements.yaml` (*Order matters in replacements.yml*, `d8cd747`) fixed **981 files** in one automated pass (`4db66d1`). `Rakefile` formalized `podcasts:pull`, `podcasts:load`, `podcasts:convert`, and `podcasts:distribute` with `MIN_MB_AVAILABLE_ON_NODE = 5_000`, `MAX_PODCAST_GB_PER_NODE = 2`, and `sleep 120` thermal cooldowns. `bin/episode_checker.rb` rendered a Milligram HTML status grid (`episodes.html`, **1,175 rows**). Expanding `Process 2.0` (`bc4ec64`, 4,135 files changed) across `belief-hole` and `philosophize-this` hit feed drift and solo-maintenance weight, pausing the repo at commit 79.

---

## Blindsight in Practice: 30+ Ways to Misspell "Jason Carpenter"

Neural models extrude phonemes without semantic grounding. In `README.md` and `replacements.yaml`, I documented **30 phonetic variants** of "Jason Carpenter" (`Garpenter`, `Garbineiro`, `Krupper`, `Carmoner`, `Garbender`, and more) alongside `Jason Asa` (`a9ec62f`) and `deadrabberdurgible` (*Dead Rabbit Dirigible*). Deterministic domain dictionaries and atomic `Tempfile` swaps downstream turned raw inference into usable archives.

---

## Jason Carpenter Outreach and Licensing

No verifiable on-air Dead Rabbit Radio episode discussed `just3ws/fluffle`. After Jason mentioned transcripts on an episode, I drafted an outreach DM on **April 6, 2023** explaining GitHub (`LICENSE` CC BY-NC-ND 4.0, `CONTRIBUTING`, `README`), citing him as sole copyright owner, and offering write access. By April 7 he was aware and open to it; we chatted on Discord, and I paused follow-up when XML feed drift and day-job pressure stacked up at `Process 2.0`.

---

## What Ended Up in the Repo vs. Disk vs. Published

- **In `just3ws/fluffle` (GitHub, commit `bc4ec64`):** `transcripts/` holds **2,034 files** (`1,017` matching `.txt` and `.srt` pairs); `episodes/` holds **1,073 UUID directories** (`1,175` `episode.xml`, `1,170` `.downloaded`, `1,062` `.converted`, `171` `.distributed`, `139` `.transcribed`, `138` `episode.{srt,txt,vtt}`); `episodes.html` has **1,175 rows**; and `feed.xml` is **12.6 MB**.
- **On Local Disk Today:** `~/podcasts/` is no longer stored on this M4 Mac; those intermediate audio runs lived on the 2023 Intel Mac and the five Pi USB drives.
- **Survival Invariants in 2026:** Fluffle's dotfile markers (`.downloading`, `.downloaded`, `.converted`, `.distributed`, `.failed`) became the direct ancestor of `media-pipeline`'s 5-state Maildir queue (`staged/`, `pending/`, `processing/`, `processed/`, `failed/`), and its `16kHz` mono PCM WAV transcode carried straight forward into zero-disk-waste streaming on Apple Silicon M4 Metal.

Thanks to Jason Carpenter for creating Dead Rabbit Radio and for his generosity when I reached out. Continue the walkthrough in [Studio Workbench Episode 2](/series/studio-workbench/fluffle-cluster/) or inspect all seven Mermaid views in the [Fluffle Briefing](/docs/studio-workbench-fluffle-theseus-briefing/).

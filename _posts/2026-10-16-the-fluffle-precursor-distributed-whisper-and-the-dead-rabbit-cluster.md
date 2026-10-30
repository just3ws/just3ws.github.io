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
description: "A look back at Fluffle, a 2023 experiment using five Raspberry Pis and whisper.cpp to process Dead Rabbit Radio episodes before I returned to the UGtastic interview archive."
---

There is a Dead Rabbit Radio sticker on my MacBook Air. It reminds me of Fluffle, an experiment I built before returning to the UGtastic interview archive.

In 2023, I wanted to see whether `whisper.cpp` could transcribe a large set of spoken audio on hardware I already had. I used five Raspberry Pis to divide the work. The tracked Fluffle repository contains more than a thousand matching `.txt` and `.srt` transcript pairs. I use “1K+” here because the repository can keep growing.

## Why start with a podcast?

The UGtastic recordings mattered to me, and I did not want the first large run to be my only chance to learn how the software and workflow behaved. Dead Rabbit Radio gave me a substantial set of episodes to use as a test. Jason Carpenter created the show, and I was already listening to it.

The experiment was about the work around transcription as much as the speech recognition: getting audio to the machines, dividing jobs, tracking progress, and collecting the output. Five small computers made the processing visible. They also made it clear that distributing work brings its own setup and recovery problems.

## What the five Pis taught me

I wrote scripts to assign episodes to the Raspberry Pis and bring the results back together. When a job stalled or a file needed attention, I had to know which machine owned it and what had already completed. A queue and clear file names mattered as much as starting more workers.

This setup did not become a general-purpose podcast product. It was a practical experiment. It gave me experience with transcription jobs, audio files, and failure recovery before I applied related ideas to the UGtastic archive.

The results are useful, but they are not a claim that every transcript is perfect. Speech recognition still needs review, especially for names and technical terms. The archive has matching text and subtitle files that make the recordings easier to search and revisit.

## Thanks

Thanks to Jason Carpenter for creating Dead Rabbit Radio and for allowing the show to be used in this experiment. The source material remains his work. The Fluffle repository records the processing scripts and outputs.

This is a setup story for The Sound Above, whose Season One plan has a working target of 17 interviews. The [series page](/series/the-sound-above/) has the current outline. Episodes -1 and 0 are setup pieces; they do not add to that target.

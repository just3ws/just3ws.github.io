---
layout: post
title: "Testing the Audio Fix Under the Power Lines"
date: 2026-10-12
description: "I thought a phone recording had lost sync. Listening to the source showed that the extra time was a quiet walk after I finished speaking."
permalink: /ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/
ai_generated: true
human_led: true
source_kind: ai-augmented-human-led
robots: noindex,follow
sitemap: false
tags:
  - Field Recording
  - Audio Cleanup
  - Source Verification
  - The Sound Above
---

I took my phone for a walk under the power lines and recorded a few thoughts about software craftsmanship. At home, I heard a low hum and noticed that the video was longer than the audio. I thought the recording had lost sync.

An AI tool compared the track durations and suggested speeding up the audio. I tried it. My voice sounded wrong, so I went back to the original recording.

## The recording answered the question

I checked the end of the audio and video. I had finished speaking, said thank you, and kept walking while the camera continued to record. The extra time was mostly silence. The tracks were not out of sync.

The recording also had two audio channels. One carried more of the hum; the other had clearer speech. I compared them, selected the clearer channel, and tested cleanup on the remaining noise.

I took the same phone back to the trail and recorded again. That gave me another sample to check whether the cleanup was useful. It also kept the two questions separate: how to reduce the hum, and why the first recording had different track lengths.

## What I learned

The duration ratio looked like evidence, but it did not explain what happened. Listening to the source did. The time-stretch suggestion addressed the wrong problem and changed speech that was already in sync.

For this recording, the useful checks were simple: listen before changing the timing, inspect the point where speech ends, compare the channels, and listen to the result again. The second walk helped me test the cleanup without relying on the mistaken sync diagnosis.

This is one field note from The Sound Above. The episode plan and interview archive are on the [series page](/series/the-sound-above/). The recording and experiment notes are linked from the [audio workbench](/dehum/dashboard.html).

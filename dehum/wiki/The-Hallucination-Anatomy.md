---
title: "The Hallucination Anatomy"
description: "Forensic analysis and open knowledge documentation for just3ws/dehum"
license: "CC-BY-SA-4.0"
open_knowledge_foundation: "Open Definition 2.1 Conforming"
maintainer: "Mike Hall"
project: "just3ws/dehum"
date: "2026-10-12"
---

# The Hallucination Anatomy: The `atempo=0.837` Clock-Drift Trap

> *"The container reported a 212.5-second gap. The model reported a mathematical certainty. Both were completely wrong about physical reality."*

## 1. The Trap

When raw MP4 media recorded on mobile hardware is probed via container inspection tools (`ffprobe`), it reports stream durations:

- **Video Stream Duration**: `1303.608144` seconds (21m 43s)
- **Audio Stream Duration**: `1091.093333` seconds (18m 11s)
- **Apparent Discrepancy ($\Delta$)**: `212.514811` seconds

Faced with this container header discrepancy and a prompt asking to *"fix sync drift"*, the model computed the mathematical ratio:

$$\text{atempo} = \frac{1091.093333}{1303.608144} \approx 0.836979$$

It produced an executable command applying `-filter:a "atempo=0.836979"`.

---

## 2. The Failure Mode

In audio processing, `atempo=0.837` stretches the audio time domain by **16.3%**:
1. Speech is slowed down into a slurred, robotic, drunken cadence.
2. The speaker's syllables desynchronize completely from visual mouth articulation.
3. Because speech ended naturally at minute 18, stretching the speech caused the speaker's closing remarks to be dragged out across 21 minutes over visual footage of empty trails.

---

## 3. The Ground Truth Autopsy

Why did the container have a 212.5-second gap if there was no clock drift?

1. **Hardware Recording Protocol**: The user finished speaking, concluded with *"Thank you,"* and continued walking with the phone active while muting or cutting off the primary microphone track.
2. **Audio Stream Truncation**: The camera application ceased writing audio packets when the microphone stream went idle, but continued capturing video frames.
3. **Physical Speech Cadence**: Audio syllable rate was 1:1 with real-world time.

### Sovereign Lesson
**Never trust container headers to infer clock crystal drift.**  
Always verify physical ground truth:
- Speech onset alignment at $t_0$
- Speech conclusion timestamps
- Frame-by-frame lip sync articulation

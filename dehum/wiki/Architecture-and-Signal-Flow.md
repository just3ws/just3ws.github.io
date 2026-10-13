---
title: "Architecture and Signal Flow"
description: "Forensic analysis and open knowledge documentation for just3ws/dehum"
license: "CC-BY-SA-4.0"
open_knowledge_foundation: "Open Definition 2.1 Conforming"
maintainer: "Mike Hall"
project: "just3ws/dehum"
date: "2026-10-12"
---

# Mathematical DSP Architecture & Signal Flow

> *"Lossless video stream copy; surgical sequential audio filtering."*

```mermaid
flowchart TD
    subgraph Container["Source Media Container (VID_20261009_111445043.mp4)"]
        V0["Video Track: H.264 (1080p, 1303.61s)"]
        A0["Audio Track: AAC (Dual-mic EMI corrupted, 1091.09s)"]
    end

    subgraph VideoPipeline["Video Pipeline: Zero Loss"]
        V0 -->|"-c:v copy (Bit-for-bit passthrough)"| VMUX["Lossless Video Stream"]
    end

    subgraph AudioPipeline["5-Stage Sequential Audio DSP Pipeline"]
        A0 --> S1["Stage 1: Highpass Filter<br/>(f < 80 Hz, 12 dB/oct roll-off)"]
        S1 --> S2["Stage 2: Impulsive De-clicking<br/>(adeclick: corona micro-arcing)"]
        S2 --> S3["Stage 3: Spectral Denoising<br/>(afftdn: nr=12, nf=-40dB)"]
        S3 --> S4["Stage 4: Harmonic Bandreject Notches<br/>(60 Hz, 120 Hz, 180 Hz, 240 Hz, Q=30)"]
        S4 --> S5["Stage 5: Trailing Padding<br/>(apad=whole_dur=1303.61s)"]
    end

    subgraph Master["Output Container (VID_20261009_111445043_fixed.mp4)"]
        VMUX --> OUT["Master File: 1303.61s Duration<br/>Audio & Video Aligned to < 33ms Frame"]
        S5 --> OUT
    end

    style VideoPipeline fill:#1a3a2a,stroke:#2ecc71,stroke-width:2px,color:#fff
    style AudioPipeline fill:#2a1a3a,stroke:#9b59b6,stroke-width:2px,color:#fff
    style Master fill:#1a2a3a,stroke:#3498db,stroke-width:2px,color:#fff
```

## Filter Chain Mathematical Definition

```bash
-af "highpass=f=80,adeclick,afftdn=nr=12:nf=-40,bandreject=f=60:width_type=q:w=30,bandreject=f=120:width_type=q:w=30,bandreject=f=180:width_type=q:w=30,bandreject=f=240:width_type=q:w=30,apad=whole_dur=1303.608144"
```

1. **Sub-rumble Highpass (`highpass=f=80`)**: Eliminates wind turbulence and sub-audible electromagnetic oscillation below human speech fundamentals ($<80\text{ Hz}$).
2. **Impulsive De-clicking (`adeclick`)**: Restores sample continuity damaged by corona discharge atmospheric micro-arcing.
3. **Spectral Denoising (`afftdn=nr=12:nf=-40`)**: Attenuates continuous broadband induction hiss without degrading speech formant consonants.
4. **Harmonic Notch Rejection (`bandreject, Q=30`)**: Surgical harmonic rejection targeting the 60 Hz AC fundamental and its 120 Hz, 180 Hz, and 240 Hz induction multiples with ultra-narrow bandwidth ($Q=30$).
5. **Lossless Video Mux (`-c:v copy`)**: Copies all 39,069 camera frames bit-for-bit without recompression artifacts or generation loss.

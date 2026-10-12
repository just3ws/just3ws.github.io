---
layout: post
title: "Under the High-Tension Wires: Building Deterministic Tools from Nondeterministic Systems"
date: 2026-10-12
description: "A forensic journey into recovering a field recording ruined by high-voltage electromagnetic induction, dual-mic phone asymmetry, and clock drift illusions—and what it means to practice human craftspersonship by using AI like a 3D printer to forge deterministic assets you control."
permalink: /ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/
ai_generated: true
human_led: true
source_kind: ai-augmented-human-led
robots: noindex,follow
sitemap: false
tags:
  - Software Craftsmanship
  - Audio Forensics
  - DSP
  - UGtastic
  - Antigravity
  - Gemini
  - zdots
  - Engineering Ethics
---

_Editorial note: Mike Hall supplied the primary field recording (`VID_20261009_111445043.mp4`), physical telemetry, lived context beneath high-voltage transmission right-of-ways, and philosophical framing for this article. The acoustic diagnostics, DSP pipeline implementation, and forensic transcript verification were developed collaboratively with Google DeepMind's Gemini 3.8 Flash via the Antigravity agentic pairing CLI._

---

## The Field Recording Beneath the Conductors

In October 2026, I walked out beneath the high-voltage utility transmission lines in Northern Illinois to record a video. It was intended as an icebreaker—a candid walk through the utility right-of-way reflecting on personal and professional identity, the history of the Software Craftsmanship movement, and where we find ourselves now as software developers, engineers, and craftspersons facing an industry in turmoil and the upheaval of generative AI.

The physical setting was unvarnished: overhead transmission conductors carrying hundreds of kilovolts buzzing in the humid autumn air, the aftermath of industrial brush mowers on the path, and an unshielded Motorola Moto G smartphone held out at arm's length.

When I checked the footage back at my workstation, the recording appeared catastrophically ruined:

1. **Intense Low-Frequency Buzz and Drone**: A deafening 60 Hz fundamental accompanied by sharp overtones marching in lockstep up through 600 Hz.
2. **Impulsive Corona Discharge**: Random, microsecond-duration clicks and micro-arcing from atmospheric ionization around the conductors.
3. **Apparent Desync & Clock Drift**: The container reported **Video: 1303.61s (21m 43s)** while the audio track was only **1091.09s (18m 11s)**—an apparent 3.5-minute gap.

Conventional advice is simple: *trash the recording, rent a shotgun mic with RF shielding, and reshoot.* 

Instead, I sat down at my terminal with **Gemini 3.8 Flash (medium tier)** via Google DeepMind’s **Antigravity CLI**. 

In Hollywood police procedurals, the investigator sits in front of a fuzzy monitor and shouts: *"Enhance. Enhance. Enhance!"* and a magical super-resolution algorithm invents pixels out of thin air. In real life, that kind of wishful thinking produces hallucinated AI slop. But here, we did the real-world engineering equivalent: we used the model the way a machinist uses a 3D printer—as a high-speed synthesizer of hypotheses, filtergraphs, and physics checks, guided by human judgment to forge a **deterministic, permanent engineering asset** that remains entirely in my control.

<div class="video-embed">
  <iframe src="https://www.youtube.com/embed/8LYHo1dOkMo" title="Under the High-Tension Wires: Identity, Software Craftsmanship, and AI Forensics" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen loading="lazy"></iframe>
</div>


```mermaid

flowchart TD
    A["Raw Field Recording<br>(VID_20261009_111445043.mp4 • ~3.28 GB)"] --> B["EXIF & Container Diagnostics<br>(Motorola Moto G • Android 16 • 1303s vs 1091s)"]
    B --> C{"Hypothesis 1: Linear Clock Drift?"}
    C -- "atempo=0.837" --> D["Fails Listening Test<br>(Auditory Slurring & Severe Artificial Desync)"]
    D --> E["Whisper Alignment & High-FPS Frame Extraction"]
    E --> F["Ground Truth Discovery<br>(Presentation ended at 1091s with 'Thank you'<br>Speech was 1.0x natural speed • Trailing 3.5m was silent scenery)"]
    
    F --> G["Channel Forensics: Left vs Right Mic"]
    G --> H["Hardware Asymmetry Discovery<br>(Secondary top mic acted as an unshielded inductive loop antenna<br>Right channel had 65x more rumble • Left channel had clean speech)"]
    
    H --> I["7-Stage Precision DSP Pipeline<br>(fix_video.sh v1.3.0)"]
    I --> J["Lossless Stream Muxing (-c:v copy)"]
    J --> K["Verified Output: VID_20261009_111445043_fixed.mp4<br>(Noise cut 91.8% • SNR +20.9 dB • Bit-for-bit video parity)"]
    K --> L["Downstream ztranscribe / whisper.cpp Telemetry<br>(93.3% Lexical Recovery • Canonical UGtastic Brand Repair)"]
```

---

## 1. The Clock Drift Trap: Human Verification vs. Machine Assumption

The container metadata showed an audio-video discrepancy that immediately pointed toward a common digital recording failure:

$$\Delta t = 1303.608144\text{ s} - 1091.093333\text{ s} = 212.514811\text{ s}$$

Under strong electromagnetic radiation, it is well known that digital phase-locked loops (PLLs) and clock crystals can wander. The mathematical stretch factor seemed mathematically sound:

$$\text{tempo} = \frac{1091.093333}{1303.608144} \approx 0.836979$$

When we applied an `atempo=0.836979` filter, the speech sounded like a slurred caricature. More importantly, when verifying the video at $t=11.60\text{ s}$, word onsets lagged hundreds of milliseconds behind mouth articulation.

### The Ground Truth Discovery
Rather than accepting the mathematical illusion, we used automated speech transcription to locate the true end of the vocal track. At exactly $18\text{m }11.09\text{s}$, the speech concluded naturally with:

> _"I'll be publishing that in the next few days and I hope it's worthwhile. Thank you."_

For the remaining 3 minutes and 32 seconds, the camera had simply continued rolling silently as I walked back down the path. The speech had been recorded at **natural 1.0x speed** all along. Stretching the audio was creating artificial desync where none existed.

The solution was lossless padding: keep the audio at $1.0\times$ natural speed and pad the trailing silence using `apad=whole_dur=1303.608144`.

---

## 2. Asymmetric Hardware Forensics: The Hidden Antenna

Once the time axis was locked, we analyzed the acoustic spectrum. Standard multi-band noise gates were destroying speech formants, making the voice sound hollow.

We split the stereo file into independent mono channels and measured root-mean-square (RMS) energy, signal-to-noise ratio (SNR), and spectral distribution:

| Objective Metric | Left Channel (Bottom Primary Mic) | Right Channel (Top Secondary Mic) | Hardware Delta |
| :--- | :--- | :--- | :--- |
| **Silence Noise Floor** | $176.31\text{ RMS}$ | $611.15\text{ RMS}$ | Right mic is **$3.5\times$ louder** |
| **Speech Amplitude** | $659.78\text{ RMS}$ | $625.23\text{ RMS}$ | Right mic captures negligible voice gain |
| **Dynamic Range** | **$11.46\text{ dB}$** | **$0.20\text{ dB}$** | Right mic voice is completely drowned out |
| **Signal-to-Noise Ratio** | **$14.00$** | **$1.05$** | Right channel is mathematically unusable |
| **Sub-$100\text{ Hz}$ Rumble** | $7.86 \times 10^{15}$ | $5.12 \times 10^{17}$ | Right mic captures **$65.2\times$ more drone** |

The Motorola Moto G uses an asymmetric microphone array: a primary talk microphone at the base of the chassis and a secondary ambient microphone at the top for noise suppression. 

Held upright beneath utility transmission lines, the top microphone traces pointed straight up into the electric field, acting as an unshielded inductive antenna. Playing back the video in stereo was flooding the clean vocal signal on the left channel with pure electromagnetic hum from the right channel.

**The physical breakthrough**: Isolating the Left channel and panning it to dual-mono (`pan=stereo|c0=c0|c1=c0`) removed **over 95% of the drone before applying any digital filters**.

---

## 3. The 7-Stage Restoration Pipeline (`fix_video.sh`)

With clean voice isolated, we calibrated a deterministic 7-stage DSP pipeline encoded in a portable Bash script:

1. **Channel Isolation**: `pan=stereo|c0=c0|c1=c0` (discards corrupted top inductive loop).
2. **Sub-Sonic Rumble Roll-off**: `highpass=f=90` (cuts mechanical handling and wind rumble).
3. **Impulsive Corona De-clicking**: `adeclick=w=30:o=75:t=2:b=3` (removes atmospheric micro-arcing spikes without clipping vocal plosives).
4. **Spectral Subtraction**: `afftdn=nr=18:nf=-45:nt=c:gs=10` (smooth spectral noise reduction without phase flanging).
5. **Harmonic Notch Comb**: 10 cascaded Butterworth band-reject filters ($Q=15$) centered across 60 Hz to 600 Hz overtones.
6. **Voice High-Frequency Rolloff**: `lowpass=f=4000` (silences high-frequency sizzle while preserving fricative clarity).
7. **Downward Expander Gate**: `agate=threshold=0.012:ratio=2.5:range=0.08` (silences pause noise by $91.8\%$ between words).
8. **Lossless Stream Copy**: `-c:v copy` ensures zero generational re-encoding loss and identical frame-level video fidelity.

The script runs at **18.8x real-time speed**, restoring the entire 21.7-minute video in just 69 seconds.

---

## 4. Empirical Telemetry: Before and After

| Metric | Raw Corrupted Recording | Restored (`fix_video.sh`) | Objective Impact |
| :--- | :--- | :--- | :--- |
| **60 Hz Mains Hum** | $4.17 \times 10^{13}$ | **$2.95 \times 10^{12}$** | **92.9% Cut** |
| **120 Hz Harmonic Buzz** | $1.73 \times 10^{14}$ | **$2.28 \times 10^{13}$** | **86.8% Cut** |
| **180 Hz Harmonic Buzz** | $4.11 \times 10^{14}$ | **$5.20 \times 10^{13}$** | **87.3% Cut** |
| **Pause Noise Floor** | $68.26\text{ RMS}$ | **$5.63\text{ RMS}$** | **91.8% Reduction** |
| **Speech Clarity (SNR)**| $22.3\text{ dB}$ | **$43.2\text{ dB}$** | **+20.9 dB Gain** |
| **Impulsive Corona Clicks**| $76\text{ / 10s}$ | **$0\text{ / 10s}$** | **100% Eliminated** |
| **Video Compression Loss** | Native 1080p | **Bit-for-Bit Identical** | **`-c:v copy` Passthrough** |

### Downstream Impact on Speech Recognition (`whisper.cpp`)
Running both files through our automated `ztranscribe` pipeline revealed how acoustic noise corrupts neural language models:

- **Normalized Lexical Match**: **93.33%**
- **Acoustic Errors Unmasked**: **152 word substitutions** resolved. In the raw audio, the heavy 60 Hz buzz caused the acoustic decoder to mishear initial attacks (`"Going back"` instead of `"Coming back"`, `"being on camera"` instead of `"looking on camera"`).
- **Phonetic Hallucinations & Canonical Repair**: Phonetic ambiguities like `"eubatastic"` or `"eubot astic"` were unmasked and mapped to the canonical archive brand **UGtastic** through deterministic lexical repair rules in the `just3ws` pipeline.

---

## 5. Craftspersonship: Treating AI Like a 3D Printer

There is a loud, polarized debate across tech right now. One camp claims AI will render software engineers obsolete by generating entire codebases from prompts. The other camp dismisses LLMs entirely as sloppy hallucination engines that produce brittle technical debt.

Both camps miss the mark on what human craftspersonship looks like in practice.

The fundamental challenge with Large Language Models is **nondeterminism**. An LLM will give you a different answer tomorrow than it did today. If your engineering practice depends on repeatedly prompting a cloud model to do work, you own nothing: you have built no permanent capability, you have preserved no control, and you cannot guarantee reproducible behavior when systems fail.

**Human craftspersonship means treating AI like a 3D printer.**

When an engineer uses a 3D printer, they do not consider the printer to be the craftsman. The printer is a rapid synthesis mechanism. It extrudes plastic or sintered metal to test physical hypotheses quickly. But once the shape is proven, the engineer tests the tolerances, machines the surfaces, specifies the metallurgy, and integrates it into a reliable assembly.

In this project, Gemini 3.8 Flash was our 3D printer:
- It helped rapidly explore FFT filtergraphs, syntax variations for `ffmpeg`, and differential audio formulas.
- But every hypothesis was subjected to **human sensory and physical validation** (listening tests, video lip-sync frame extraction, RMS energy calculation).
- When the model proposed linear time-stretching (`atempo`), human domain knowledge and verification proved it wrong.

Most importantly, we did not leave the solution inside a chat transcript. We **curated the output forward into deterministic assets that remain entirely in our control**:

1. **A Standalone POSIX Utility**: [`fix_video.sh`](https://github.com/just3ws/dehum/blob/main/fix_video.sh) (v1.3.0) — zero dependencies beyond standard system binaries (`ffmpeg`, `ffprobe`, `bc`). It runs identically on any POSIX system, offline, forever, without touching an LLM again.
2. **Standard Documentation**: A UNIX troff manual page ([`fix_video.1`](https://github.com/just3ws/dehum/blob/main/fix_video.1)).
3. **Automated Verification Tooling**: [`compare_transcripts.py`](https://github.com/just3ws/dehum/blob/main/compare_transcripts.py) — an empirical Python script to benchmark transcript deltas objectively.
4. **Permanent Forensics**: Complete telemetry documented in [`FORENSICS.md`](https://github.com/just3ws/dehum/blob/main/FORENSICS.md).

```mermaid
flowchart LR
    A["Nondeterministic AI Exploration<br>(Gemini 3.8 Flash • Antigravity CLI)"] -->|Rapid Hypothesis Prototyping| B["Human Verification & Testing<br>(Listening tests • Frame alignment • SNR math)"]
    B -->|Machining & Curation| C["Deterministic Permanent Asset<br>(fix_video.sh • UNIX man page • compare_transcripts.py)"]
    C -->|Permanent Ownership| D["Repeatable Offline Pipeline<br>(100% In Human Control • Zero Cloud Dependency)"]
```

### 5.1 The Complete Loop: Documenting, Writing, and Publishing

Notice the full breadth of what just took place in this single afternoon:

- A corrupted field recording was forensically diagnosed and mathematically unmasked.
- A POSIX restoration script was authored, verified, and packaged with a UNIX man page.
- Parallel transcriptions were generated via local Whisper models to benchmark acoustic error rates.
- Canonical brand repair rules (`UGtastic`) were written into the site's publishing pipeline.
- This complete engineering case study was written, linted, and rendered across the Jekyll static architecture.
- The 3.1 GB restored video was uploaded directly to YouTube and inserted into the *Ramblin' & Amblin'* playlist with full telemetry and cross-links.

This is not a flex. It is an honest accounting of what is possible right now with commodity, accessible AI tooling (Gemini 3.8 Flash on a standard tier). 

Whether you love it or hate it, whether people dismiss it as "vibe slop" or hail it as the end of programming, this is simply the empirical capability of these tools when driven by a human who understands the underlying system. And the crucial point is: **we aren't even really pushing it.** We aren't running massive multi-million-dollar training runs or exotic prompt architectures. We are pairing at a terminal, using the machine to do the heavy mechanical synthesis, while the human sets the direction, verifies the physics, catches the false leads, and curates the output into permanent, deterministic software.

### 5.2 The True Danger: The Mirage of Competence and the High-Thrown Ball

There is, however, an immense and unsettling risk embedded in this entire exercise that must be confronted as a foundational warning:

**Reading this article might make you think I am an audio engineering expert. I am not.**

I am a software developer, systems architect, and oral historian. I understand container formats, POSIX pipes, and signal flow, but I do not possess a lifetime of professional acoustic mastering experience. The language model synthesized the complex DSP filter syntax, calculated the harmonic Butterworth band-reject coefficients, and formatted the telemetry with the effortless, authoritative vocabulary of a veteran audio engineer.

And that is the trap. 

Look how smart it makes **ME** look. Look how easily an external observer—or worse, a manager, a client, or the engineer themselves—might look at this forensics report, this man page, and these spectral charts, and mistakenly attribute deep, foundational domain competence to me.

This is the single most dangerous aspect of generative AI tools: **the perception of competence, the misattribution of trust, and the supercharging of the Dunning-Kruger effect.**

Pre-AI, Dunning-Kruger was already an endemic occupational hazard in software engineering. We all knew the developer who skimmed a blog post, learned three acronyms, and mistook superficial familiarity for architectural mastery. But LLMs act as a Dunning-Kruger catapult. An engineer can sit at a terminal, type three prompts, receive mathematically polished, impeccably phrased code, and deploy a system that extends vastly beyond their core professional skillset.

The terrifying question every craftsperson must ask themselves is:

> **How high can I throw the ball before I lose sight of it, drop it, or have it come crashing straight down on my head?**

```mermaid
flowchart TD
    A["Nondeterministic AI Output<br>(Authoritative Jargon • Fluent Polish)"] --> B{"The Critical Divergence"}
    B -->|Uncritical Acceptance<br>(The Mirage)| C["Synthetic Competence<br>(Supercharged Dunning-Kruger • 'Look How Smart I Look!')"]
    C --> D["Throwing the Ball Beyond Sight<br>(Operating far outside core professional competence)"]
    D --> E["Catastrophic Failure<br>(The ball comes straight down on your head in production)"]
    
    B -->|Rigorous Human Craftspersonship<br>(Self-Aware Skepticism)| F["Empirical Boundary Testing<br>(Listening tests • Frame alignment • Admitting what you don't know)"]
    F --> G["Machined Deterministic Asset<br>(Permanently verified • 100% in human control)"]
```

When you use an AI tool to leap outside your domain, you are throwing that ball higher and higher into the air. If you are operating within your own discipline, your peripheral vision and muscle memory know where the ball is going. But when the tool propels you deep into unfamiliar territory—acoustics, cryptography, high-voltage physics, distributed consensus—you quickly lose sight of the ball. You cannot evaluate the edge cases. You cannot feel the subtle failure modes. You are riding on borrowed competence.

Consider what almost happened at Step 1 of this project: the model looked at the duration metadata (1091s audio vs 1303s video) and confidently computed an `atempo=0.836979` stretch ratio. Mathematically, it looked immaculate. A developer seduced by the synthetic competence of the tool would have run the command, nodded at the terminal output, and shipped a video where speech was slurred into slow motion and desynced by hundreds of milliseconds.

It took human skepticism—listening with real human ears, questioning the premise, and extracting individual video frames to check mouth articulation—to discover that the model was completely wrong, because speech was running at 1.0x natural speed all along.

The danger of AI is not that it makes mistakes. The danger is that **it makes mistakes with absolute, unblinking fluency**, while stroking our ego and making us believe we are masters of domains we have never actually studied.

### 5.3 The Meta-Loop: How This Conversation Forged the Reality

There is a final, recursive layer to this entire story that deserves complete transparency: **the conversation you are reading about was itself forged live, in real time, between human and machine.**

This article did not spring fully formed from a single grand prompt. It emerged from an iterative, unvarnished dialogue:
- When the model initially defaulted to generic promotional language ("AI-assisted craftsmanship"), the human pushed back: *No, not "AI assisted craftsmanship." This is about human craftspersonship. Treat AI like a 3D printer.*
- When the transcription pipeline initially misheard the archive's brand name as `"eubot astic"`, the human immediately caught it: *That's UGtastic. Build rules into the pipeline so it never fails again.*
- When the forensic report started sounding too triumphant, the human forced the uncomfortable truth into the open: *The true danger is that this makes me look like an audio engineering expert. Document that gap. Document the high-thrown ball.*

Every piece of this architecture—the code, the forensics, the documentation, the YouTube video upload, the Jekyll rebuilds, and the philosophical warnings—was generated through the back-and-forth dynamic of human discipline checking non-deterministic generation.

The AI provided the raw speed, the command synthesis, and the exhaustive file handling. But the human provided the conscience, the reality checks, the memory of community history, and the moral line.

Without that active human vigilance, the machine would have happily hallucinated a slower video, mislabeled an oral history brand, and flattered the user into believing they had mastered a discipline they had never studied. 

With that vigilance, a corrupted recording was restored to pristine clarity, an automated tool was committed to source control, and a permanent lesson in software craftspersonship was forged.

### 5.4 The Anatomy of Borrowed Expertise: What We Missed, What Was Done Wrong, and the Hidden Blind Spots

To make this video even this quality without an AI assistant, what specific technologies and concepts would someone actually have had to possess expert, professional mastery over?

Let's do an honest accounting of the curriculum required to arrive at this result manually:

1. **Acoustic Physics & Electromagnetic Induction**: Understanding Maxwell's equations and Faraday induction loops in high-impedance unbalanced smartphone microphone traces under multi-phase transmission lines.
2. **Digital Signal Processing (DSP) & Filter Design**: 
   - Windowed Fast Fourier Transforms (FFTs) and spectral leakage.
   - Butterworth IIR band-reject notch filters, calculating Q-factors ($Q = f_0 / \text{BW}$), phase distortion, and group delay.
   - Spectral noise subtraction matrices (`afftdn`) and managing artifactual "musical noise" (flutter/chirping).
   - Time-domain transient derivatives ($|\Delta s| / \Delta t$) for impulsive de-clicking.
   - Downward dynamic range expansion: knee smoothing, attack ($t_a$), release ($t_r$), and ratio curves.
3. **Multimedia Container Forensics & Demuxing**:
   - ISO/IEC 14496-12 QuickTime/MP4 container architecture (moov/mdat atom layouts, timescale ticks, presentation vs. decoding timestamps).
   - Video track rotation matrices and container-level frame-rate variability (29.917 average fps).
   - Lossless stream passthrough (`-c:v copy`) vs. generational quantization loss in H.264 profiles.
4. **Speech Acoustics & Acoustic Phonetics**:
   - Human vocal formant preservation ($F_1, F_2, F_3$) across vowels vs. sibilant fricative consonants ($>4\text{ kHz}$).
   - Downstream attention decoding in transformer-based acoustic models (`whisper.cpp`).
5. **POSIX Systems Engineering**:
   - Shell scripting, standard streams, IEEE 754 floating-point precision via `bc`, and UNIX troff typesetting (`man ./fix_video.1`).

**No single software developer carries all of that in active working memory.**

#### What Was Done Wrong? What Did We Miss?

Because I am not an audio mastering engineer, there are subtle decisions made by the AI that I could not evaluate with expert intuition. An actual acoustic engineer listening to the output would instantly spot the compromises:

1. **Phase Smearing from Cascaded IIR Notches**: We chained 10 sequential Butterworth band-reject filters ($Q=15$) from 60 Hz to 600 Hz. In analogue or recursive IIR digital filters, each notch introduces sharp phase shifts around the cutoff boundaries. Cascading 10 of them can create audible group delay and phase smearing in the low-mid frequencies, slightly coloring the natural timbre of the speaker's chest resonance.
2. **Aggressive Downward Expander Noise Tail Gating**: The expander gate (`agate=threshold=0.012:ratio=2.5`) cuts pause noise by 91.8%. But in outdoor ambient field recordings, absolute silence sounds unnatural. A professional mastering engineer would not gate to near-zero; they would use gentle downward expansion with room tone convolution or dithered comfort noise so the listener doesn't feel a jarring drop in acoustic pressure between words.
3. **Fixed Lowpass Cutoff vs. Dynamic High-Frequency Sibilance**: We applied a hard `lowpass=f=4000` to eliminate atmospheric corona sizzle. While human speech fundamentals lie below 1 kHz, critical English consonants—fricatives like *s*, *th*, and *f*—carry vital acoustic energy between 4 kHz and 8 kHz. A master audio engineer would have used a dynamic de-esser or multi-band spectral suppression rather than a blunt lowpass brickwall.
4. **Trailing Hallucinations in Zero-Energy Silence**: When padding the silent 3.5 minutes with `apad`, the silence was so unnaturally pure that Whisper's autoregressive attention mechanism began hallucinating periodic phantom tokens (*"Thank you"*). A professional would have known that zero-energy digital silence breaks speech decoders and would have matched the background noise floor.

#### The Real Risk: Blind Trust in Plausible Decisions

This is the crux of the danger: **I could evaluate whether the speech sounded better than before, but I could not evaluate whether the DSP chain was mathematically optimal or introduce destructive side-effects.**

If the AI had introduced subtle inter-sample clipping, destructive phase cancellation, or warped a frequency band that renders the audio fatiguing to listen to on studio monitors, I would not have known. I would have looked at the SNR telemetry, seen a green number, and assumed the solution was perfect.

When you use an AI tool outside your core domain:
- You are competent enough to recognize *improvement*.
- You are rarely competent enough to recognize *subtle damage*.
- You risk building systems on foundation stones you cannot stress-test.

This is the ultimate lesson of the high-tension field recording: AI gives you immense leverage to solve problems you could never solve alone, but it also creates a blinding halo of false confidence. True craftsmanship means publishing the compromises, documenting what you don't know, and never mistaking machine assistance for human mastery.

---

- **Restoration Toolchain Repo**: [GitHub: `just3ws/dehum`](https://github.com/just3ws/dehum)
- **Technical Forensics Document**: [`FORENSICS.md`](https://github.com/just3ws/dehum/blob/main/FORENSICS.md)
- **Transcript Diff Telemetry**: [`TRANSCRIPT_DIFF.md`](https://github.com/just3ws/dehum/blob/main/TRANSCRIPT_DIFF.md)
- **YouTube Video**: Watch the restored video on YouTube: [Under the High-Tension Wires (https://youtu.be/8LYHo1dOkMo)](https://youtu.be/8LYHo1dOkMo), part of the [Ramblin' & Amblin' Playlist](https://www.youtube.com/playlist?list=PLNtb969T2-l0)
- **Key Restoration Timestamps**:
  - `00:00` — [Initial High-Tension Power Line Noise & Background](https://youtu.be/8LYHo1dOkMo?t=0)
  - `00:11` — [Clean Speech Baseline ("Here I am...")](https://youtu.be/8LYHo1dOkMo?t=11)
  - `01:21` — [UGtastic Oral History Archive Background](https://youtu.be/8LYHo1dOkMo?t=81)
  - `18:11` — [Speech Conclusion ("Thank you") & True Boundary](https://youtu.be/8LYHo1dOkMo?t=1091)
- **Raw vs. Restored Mirror**: Both the unedited corrupted master (`VID_20261009_111445043.mp4`, 3.1 GB) and the restored output (`VID_20261009_111445043_fixed.mp4`, 3.3 GB) are archived in the shared Google Drive directory (`Google Drive / ai / dehum/`) for direct waveform and listening comparison.
- **UGtastic Oral History Archive**: [UGtastic Interviews on just3ws](https://www.just3ws.com/ugtastic/)



# The Sound Above (Errata) Proposed Topics & Deep-Dive Prompts

> **Channel**: The Sound Above: Errata (@whoistechcmty)
> **Updated**: 2026-10-16 06:05 UTC
> **Source**: Derived from Mike Hall's 20-year archive, writings, and interviews

## Overview
Solo technical demonstrations, deep-dive forensic walkthroughs, audio restoration experiments, code reviews, and edge-case postmortems exploring the mechanics behind the systems.

---

## Curated Conversation Prompts

### Prompt 1: Errata: The 345kV Audio Recovery & Why Gemini Hallucinated 20% Clock Drift

- **ID**: `errata-mirage-of-competence-dsp`
- **Location / Setting**: Technical Demonstration & Forensic Audio Walkthrough
- **Core Inquiry**: Deconstructing the prompt-based DSP hallucination under high-tension power lines.

#### Talking Points & Narrative Arcs:
1. Walking through the raw frequency waterfall: the sharp 60 Hz fundamental and harmonic spikes.
1. Showing the exact browser query and Gemini Flash response asserting linear clock drift.
1. The audio slurring failure: playing the 0.837x output and demonstrating why math without listening is dangerous.
1. The 4 lines of deterministic scipy code that isolated the clean left channel and silenced the hum in 40ms.

- **Demonstration Artifacts**: fix_video.sh, dehum/dashboard.html, A/B Audio Player (/assets/audio/dehum_comparison_raw.mp4 vs fixed)

---

### Prompt 2: Errata: When a Smartphone Noise-Cancellation Mic Becomes an RF Loop Antenna

- **ID**: `errata-phone-mic-antenna-asymmetry`
- **Location / Setting**: Hardware Acoustics & Dual-Mic Physics
- **Core Inquiry**: Why smartphone noise-cancellation hardware failed catastrophically under electromagnetic induction.

#### Talking Points & Narrative Arcs:
1. How modern phones use dual microphones to perform phase-cancelling noise suppression.
1. The physical geometry: top microphone was unshielded and positioned directly facing the 345kV conductors.
1. Measuring 65x more low-frequency inductive rumble on the right channel versus the left channel.
1. Why splitting stereo channels and dropping the antenna track solved 90% of the problem with zero DSP.

- **Demonstration Artifacts**: Dual-channel FFT spectral graphs, Motorola Moto G hardware teardown diagram

---

### Prompt 3: Errata: Local whisper.cpp on Apple Silicon M4 with Zero Cloud Egress

- **ID**: `errata-local-whisper-m4-zero-egress`
- **Location / Setting**: Local-First Machine Learning & Transcription Pipelines
- **Core Inquiry**: Running multi-gigabyte speech-to-text inference on localhost with zero cloud costs and zero privacy leaks.

#### Talking Points & Narrative Arcs:
1. Setting up whisper.cpp with Metal acceleration on the Apple Silicon Neural Engine.
1. Benchmarking transcription speed: 1.6 GB video processed in 95 seconds using whisper-large-v3-turbo.
1. Deterministic post-processing: automated lexical brand repair for community names (e.g. 'eubatastic' to 'UGtastic').
1. Generating frame-accurate WebVTT subtitle tracks and syncing to YouTube Data API v3.

- **Demonstration Artifacts**: bin/intake_drive_video.rb, whisper.cpp command-line harness, _data/transcripts/ YAML schemas

---

### Prompt 4: Errata: Debugging Unbuffered Server-Sent Events (SSE) Through Nginx

- **ID**: `errata-nginx-unbuffered-sse-daemon`
- **Location / Setting**: Systems Networking & Realtime Web Telemetry
- **Core Inquiry**: Building zero-dependency near-realtime telemetry daemons without WebSockets or heavy framework overhead.

#### Talking Points & Narrative Arcs:
1. Why WebSockets are often overkill for one-way server-to-client telemetry.
1. The nginx buffering trap: proxy_buffering off and chunked_transfer_encoding off requirements.
1. Writing a pure Ruby SSE server using TCPServer and Thread.new in under 300 lines.
1. Handling client disconnects, broadcast keepalives, and instant queue state updates.

- **Demonstration Artifacts**: bin/live_dashboard_streamer.rb, nginx/just3ws.localhost.conf

---

### Prompt 5: Errata: BPMN 2.0 as an Executable State Machine for Cloud Media Intake

- **ID**: `errata-bpmn-media-intake-observability`
- **Location / Setting**: Enterprise Workflow Architecture & Observability
- **Core Inquiry**: Using formal BPMN 2.0 swimlanes, boundary error events, and SLO tripwires for single-operator pipelines.

#### Talking Points & Narrative Arcs:
1. The Maildir pattern: staged, pending, processing, processed, and failed directories.
1. Modeling 12 discrete service tasks from stability check to YouTube caption upload.
1. Defining strict Service Level Objectives (SLOs) and incident tripwires for audio DSP and cloud streaming.
1. Embedding interactive BPMN execution monitors in localhost dashboards.

- **Demonstration Artifacts**: docs/bpmn/media-intake-pipeline.bpmn, docs/bpmn/README.md, youtube/dashboard.html (#tab-bpmn)

---

---
layout: minimal
title: "The Self-Evolving Control Plane: Autonomous Storage Hygiene, Resource-Constrained Operating Disciplines, and Frontier-Local AI Symbiosis"
description: "A systems architecture monograph on managing finite 228GB SSD constraints, autonomous hygiene trios, multi-tier guardrails, and dual-model AI symbiosis in the zdots platform."
permalink: /docs/architecture/autonomous-storage-hygiene-and-self-evolving-os-architecture/
breadcrumb: Storage Hygiene & Control Plane
body_class: surface-editorial
---

# The Self-Evolving Control Plane: Autonomous Storage Hygiene, Resource-Constrained Operating Disciplines, and Frontier-Local AI Symbiosis

**Author:** Mike Hall &amp; Antigravity  
**Platform:** `zdots` / `adots` / `my` / `vdots`  
**Date:** October 20, 2026  
**Status:** Living Platform Architecture &amp; Reference Monograph  

---

## 1. Executive Summary &amp; Platform Heritage

Modern personal computing platforms often decay under their own weight. Unbounded package caches, orphaned container snapshots, sprawling log streams, and ephemeral execution artifacts gradually choke primary storage. For an operator managing local AI models, high-throughput audiovisual ingest pipelines, and production client applications on a finite **228 GB primary SSD**, unchecked storage rot is not an inconvenience: it is an existential risk to system availability, creative output, and professional employment.

This platform represents a **decade-plus continuum of intentional personal OS engineering** ("zdots"). Rather than treating system administration as an ad-hoc chore, zdots constructs an **Observable Control Plane** governed by:

1. **The Ratchet Effect**: Every tool, check, and contract is locked in by automated test suites (`bats`, `docs_contract.bats`). Once a bug is fixed or an interface contract is established, the platform never slips backward.
2. **Tools to Build Tools**: Meta-tooling (`zdots-man-gen`, `man-doc-curator`, `zdots-ctx`, `capabilities`) ensures that platform capabilities self-generate their own documentation, telemetry schemas, and contract proofs.
3. **The Virtuous Loop**: System residue is not discarded blindly. It is captured, curated, distilled into durable knowledge, and indexed back into the platform's memory before physical compaction.
4. **Symbiosis of Local &amp; Frontier AI**: Zero-cost, zero-latency, private local models (`llama.cpp`, `whisper.cpp`) handle continuous pipeline work, telemetry classification, and embeddings; frontier models (Gemini, Claude, Codex) provide high-altitude reasoning, architectural synthesis, and complex planning.

---

## 2. The Finite Workstation Challenge: Surviving &amp; Thriving on 228 GB

### 2.1 The Operational Paradox

Operating cutting-edge AI pipelines and heavy media workloads on a MacBook with a 228 GB drive presents a fundamental tension:

- **High-Velocity Pipeline Demands**: Ingesting hour-long YouTube podcasts, extracting uncompressed 16kHz WAV audio chunks, rendering video clips, and downloading npm/pip packages can consume 10 to 25 GB in a single afternoon.
- **Catastrophic Failure Modes**: When macOS root available storage drops below 5 GB, SQLite databases lock, Docker/Colima VM instances corrupt, launchd services crash-loop (`status=5`), and macOS memory swap thrashes.
- **The Trauma of Reckless Remediation**: Naive AI agents or panicked shell scripts reaching for `rm -rf` without validation risk catastrophic data loss (such as an early AI misparsing `~` and wiping `$HOME`).

### 2.2 The Semantic Storage Bucket Model

To govern physical storage safely, zdots rejects global, undifferentiated filesystem wipes. Instead, `bin/zdots-storage` partitions disk usage into **seven semantic buckets**, each with distinct governance, TTL policies, and health thresholds:

| Bucket | Monitored Paths | Operational Role | Governance / Eviction Policy |
|---|---|---|---|
| **Root** | `/` (Host macOS SSD) | Primary OS capacity | `>15GB [ok]`, `<15GB [warn]`, `<5GB [crit]`. Gates heavy pipeline work. |
| **Models** | `~/.local/share/llama-cpp`, `whisper-cpp` | GGUF weights &amp; Whisper models | Inactive model detection; profile-required weights locked against deletion. |
| **Docker** | `~/.colima`, containers, images, volumes | Container runtime &amp; k3s pause containers | Pruned via `docker-reclaim -f`; VM blocks shrunk via `fstrim`. |
| **Ingest** | `~/.local/state/zdots/ingest-sources` | Staged A/V downloads &amp; audio chunks | 7-day TTL grace period; raw chunks evicted post-distillation; lessons kept. |
| **Caches** | `~/.npm/_npx`, `pnpm/store`, `mise`, `uv`, `brew` | Ephemeral package &amp; runtime caches | Verified signature pruning; unreferenced packages evicted safely. |
| **Logs** | `~/.local/state/zsh`, `~/my/log`, `/opt/homebrew/var/log` | Telemetry dumps, service logs | In-place truncation via `log-rotate`; 30-day retention on `.gz` archives. |
| **Backups** | `~/.adots-backups`, `colima-xdg-backup` | System state snapshots | Retained for human curation; warns at &gt;1 GB to trigger compression. |

---

## 3. The Triad Architecture: Hygiene, Storage, and Log Management

The cleanup system is composed of three tightly coupled, single-responsibility components designed to operate predictably under automation:

1. **`bin/zdots-storage` (The Self-Describing Lens)**: Provides continuous operational observability. Dual-mode: formatted ASCII dashboard for interactive human inspection, and machine contract (`--json`) for automated gates and SwiftBar indicators (`🟢 🎙️`).
2. **`bin/zdots-hygiene` (The Bounded Sweeper)**: Coordinates all system sanitation passes. Dry-run by default; requires explicit `-f` or `--apply` flags to execute mutations. Enforces strict directory signature checks before deleting.
3. **`bin/log-rotate` (Zero-Downtime Log Management)**: Non-disruptive, in-place lifecycle. Gzips historical logs and truncates the active file (`true > "$LOG_PATH"`) without closing the file descriptor, keeping long-running services (Puma, Nginx, OTel Collector) writing continuously.

---

## 4. Multi-Tier Guardrails: Anti-Bitrot and Safety Protocols

1. **The Tilde Shield**: Absolute prohibition of naked `~` or unvalidated variable expansions in destructive commands. Bounded path validation via dirname checks.
2. **Anti-Bitrot Signature Validation**: Package managers change layouts across versions. `zdots-hygiene` verifies structural signatures (e.g. 16-hex hash directory name + `package.json` descriptor inside `~/.npm/_npx/`). If a path looks anomalous, it emits `[hygiene:warn]` and skips rather than deleting.
3. **Dynamic Store Discovery**: Never hardcode tool paths. `pnpm store path` dynamically resolves `/Users/mike/.local/share/pnpm/store/v11`; `colima-status socket` resolves active socket locations; `uv cache dir` queries uv.
4. **The Schrute Test**: Never proceed on assumption; verify execution preconditions. Blast radius must never exceed task scope.

---

## 5. The Dual-AI Topology: Symbiosis of Local Inference and Frontier Reasoning

The platform maximizes autonomy and financial sustainability by strictly dividing cognitive labor:

1. **Local AI (Continuous, Low-Latency, Zero Cost)**:
   - **Audio Transcription**: `ztranscribe` uses local `whisper.cpp` (Metal-accelerated on Apple Silicon). Zero audio leaves the machine; zero API tokens are burned transcribing 90-minute recordings.
   - **Vector Embeddings**: `nomic-embed-text-v2-moe` runs permanently on loopback (port 11500), generating embeddings for shell traces, lessons, and code chunks into PostgreSQL `pgvector`.
   - **PHI Scrubbing**: Regex patterns and local NER scrubbers intercept traces and prompts before any external transit, ensuring strict work-tenant privacy boundaries.
2. **Frontier AI (Episodic, High-Context, Strategic)**:
   - Reserved for deep reasoning, architectural auditing across the four repositories (`zdots`, `adots`, `my`, `vdots`), and long-range roadmap synthesis.
   - Operates with full local observability: every command executed is mirrored to local OpenObserve spans, maintaining total auditability.

---

## 6. The Virtuous Loop: Ingestion, Harvesting, and Compression Lifecycle

The platform's storage hygiene directly serves the media and knowledge pipeline:

1. **Top-of-Funnel Ingress & Cloud Decoupling**: Phone media drops over fast local transfer (LocalSend / USB into `~/Downloads`), and `--drop` immediately relocates it into Google Drive cold pending storage (`cloud_archive_path/<channel>/<target>/pending/`). This eliminates mobile cloud upload stalls while keeping resting multi-gigabyte assets off the primary SSD.
2. **Single-Item On-Demand NVMe Staging**: Pipeline workers pull strictly 1 video at a time (FIFO) into fast local NVMe SSD (`~/.local/var/media_intake/.../processing/`) under POSIX nice 15 and macOS Darwin Background QoS (`taskpolicy -b`).
3. **Local Transcription & DSP**: Metal-accelerated `whisper.cpp` and ffmpeg DSP filters run locally on the active working master.
4. **Intellectual Yield Harvesting**: Core lessons, timeline events, and entity relationships are extracted and indexed into `~/my` and CareerOS datalake before raw files are touched.
5. **Ephemeral Master Release & Cloud Quarantine**: Once bit-for-bit verified in Google Drive `processed/YYYY-MM/`, the multi-gigabyte working master on local NVMe SSD is released (`FileUtils.rm_f`), preserving only lightweight `.receipt.json` sidecars on local disk. If upstream YouTube API quotas enter daily cooldown, pending files quarantine to Google Drive `blocked/` rather than saturating local disk headroom.
6. **Action 7 Intermediate Scratch Purge**: `zdots-hygiene` Action 7 continuously audits and purges intermediate WAV audio scratch files older than 2 days (`~/.local/state/just3ws/scratch/*/*.wav`).
7. **Cold-Storage Compression**: Historical session logs and transcripts are compressed in-place using `zstd`. A 247 MB rollout shrinks to ~28 MB (`.jsonl.zst`), achieving 85%+ compression ratios.

---

## 7. The Architectural Synthesis

Resource constraints are not barriers to advanced AI workflows; they are the catalyst for architectural rigor.

By treating storage hygiene as a first-class control plane discipline:
- The system operates continuously with **20+ GB of healthy headroom** on a 228 GB drive.
- Media pipelines, local transcription engines, and dual AI agents collaborate without resource contention or anxiety of sudden disk exhaustion.
- High-altitude frontier intelligence and on-device private models work in harmony, bound together by structured contracts, automated verification, and the Virtuous Loop.

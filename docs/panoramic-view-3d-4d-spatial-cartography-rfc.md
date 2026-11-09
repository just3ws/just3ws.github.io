# Panoramic View: 3D & 4D Spatial-Temporal System Cartography RFC

**Author:** Mike Hall (just3ws)  
**Date:** 2026-11-09  
**Status:** Architectural Specification & Roadmap  
**Canonical Initiative:** Panoramic View Labs (PVL)  
**Specialist Agent:** Pavel  
**Platform Runtime:** zdots  

---

## 1. Executive Vision: Beyond the Flat Canvas

Two-dimensional process diagrams (BPMN swimlanes, flowchart blocks, and static dependency graphs) inevitably collapse under the cognitive weight of modern distributed systems. As soon as an architecture encompasses:
1. **Deep vertical abstraction stacks** (from Apple Silicon GPU registers up through CLI binaries, model weights, databases, and application middleware),
2. **Decoupled system boundaries** (parent publication pipelines calling sovereign transcription subprocesses and asynchronous message buses), and
3. **Dynamic temporal behavior** (bursty queue accumulation, latency jitter, and intermittent failure rates over rolling windows),

a flat 2D canvas forces unnatural compromises: crossing sequence lines, fragmented modal popups, and artificial visual clutter that obscures the underlying truth.

In the spirit of early cyberspace visualization (such as VRML in the 1990s) but powered by modern WebGL, WebXR, and hardware-accelerated GPUs, **4D System Cartography** elevates Panoramic View from static documentation into an interactive spatial-temporal simulation. Operators and engineering leaders can fly through, inspect, and temporally scrub distributed system execution as a living architectural landscape.

---

## 2. The 4-Dimensional Spatial Coordinate System

The 4D model organizes complex platforms into an intuitive, mathematically grounded coordinate space:

```
                  ▲ Y: Latitudinal Strata (The Vertical Stack)
                  │   L5: Telemetry & SLO Signals
                  │   L4: Auxiliary Services & Protocols
                  │   L3: Storage Engine & Vector Database
                  │   L2: Model Weights & Static Assets
                  │   L1: System CLI Binaries
                  │   L0: Compute Silicon (Metal GPU / CPU)
                  │
                  │              Z: Domain Depth (Sovereign Systems)
                  │             /
                  │            /  Z = -400: zdots Platform Bus & Context Engine
                  │           /  Z = -200: ztranscribe Subprocess
                  │          /  Z = 0: media-pipeline Parent Flow
                  │         /  Z = +200: YouTube Data API & External SaaS
                  │        /
                  └───────┼────────────────────────► X: Longitudinal Sequence
                         /                            (Transaction Journey: Ingress to Archive)
                        /
                       ▼
```

### X-Axis: Longitudinal Process Sequence (Left to Right)
Represents the transaction's progression through business stages. Nodes are placed along the X-axis following the logical lifecycle order:
- `media-pipeline`: Ingress & Hydration (X: 0 to 450) -> Local GPU Enrichment (X: 100 to 700) -> Fair-Share Round-Robin Dispatch (X: 100 to 850) -> Quota-Gated Publishing & Archival (X: 100 to 1100).
- `ztranscribe`: Ingress & Format Routing (X: 0 to 550) -> Metal GPU Whisper STT (X: 240 to 650) -> Lexical Cleansing & Boundaries (X: 150 to 450) -> Distillation, Diarization, pgvector Persistence (X: 40 to 1150).

### Y-Axis: Latitudinal Strata (Elevation / Vertical Abstraction)
Represents the physical-to-logical infrastructure elevation, mapping 1:1 to the six-layer health audit (`ZtranscribeSubsystemHealthService`):
- **Y = 0 (L0: Compute Silicon)**: Apple Silicon Unified Memory, Metal GPU execution pipelines, VideoToolbox hardware encoders.
- **Y = 100 (L1: System Binaries)**: Compiled CLI executables (`whisper-cli`, `ztranscribe`, `ffmpeg`, `ffprobe`).
- **Y = 200 (L2: Model Weights)**: GGUF/GGML weight tensors (`ggml-large-v3.bin`, 3.1 GB).
- **Y = 300 (L3: Data Storage)**: PostgreSQL 18, `pgvector`, Google Drive File Provider on-demand cache.
- **Y = 400 (L4: Service Middleware)**: Puma web workers, Solid Queue jobs, diarization runners.
- **Y = 500 (L5: Telemetry & App Interface)**: OpenTelemetry traces, Cockpit SSE streams, user decision interfaces.

### Z-Axis: Sovereign System Domain Boundaries (Depth)
Parallel systems do not collide on the same plane; they exist as stacked, translucent architectural planes along the Z-axis:
- **Z = 0 (Primary Plane)**: `media-pipeline` (Parent workflow).
- **Z = -200 (Subsystem Plane)**: `ztranscribe` (Sovereign transcription subprocess).
- **Z = -400 (Foundation Plane)**: `zdots` (Platform OS, local context engine, message bus).
- **Z = +200 (External Boundary)**: Upstream cloud APIs (Google Drive, YouTube Data API v3, Patreon v2).

**Inter-System Couplings (Call Activities):** When `media-publication.v3` invokes `local_transcription` (Call Activity), a volumetric 3D light conduit plunges through Z-space from Plane Z=0 down to Plane Z=-200, entering `ztranscribe.v1`'s `start_fast_wav` node. Upon completion at `exit_fast_stt`, the return conduit ascends back to Plane Z=0 into `enrichment`.

### T-Axis (The 4th Dimension): Temporal Scrubbing & Live Particle Physics
The fourth dimension animates time across the spatial landscape:
1. **Timeseries Scrubbing**: A temporal timeline slider allows operators to scrub through past executions, observing how transactions traversed the planes over hours, days, or months.
2. **Particle Flow Rate**: Transactions flow along sequence connectors as glowing light particles. Particle velocity reflects execution speed; clustering particles expose latency bottlenecks.
3. **Queue Fluid Accumulation**: Queues behave like physical liquid reservoirs. When YouTube daily quota cools down, assets waiting at `quota_gate` pool visibly on the canvas, draining in steady FIFO order once the quota reset event fires.
4. **Volumetric Health Heatmaps**: Nodes and whole planes pulse with color based on real-time SLIs: green for nominal, amber glow for degraded error-budget consumption (such as L5 intermittent error signals), and crimson flares for error offramps.

---

## 3. Technology Stack & WebGL Implementation Architecture

To ensure zero external dependencies and single-operator simplicity, the 3D/4D spatial cartography engine follows the Ponytail Principle:

```
+-------------------------------------------------------------------------+
|                  4D WebGL Spatial Cartography Pipeline                  |
+-------------------------------------------------------------------------+
|                                                                         |
|  1. Data Ingestion & Geometry Projection                                |
|     - PanoramicFlowRegistry (media-publication.v3, ztranscribe.v1)       |
|     - BPMNDI 2D Coordinates (PanoramicBpmnExporter) projected to (X,Y,Z) |
|     - ZtranscribeSubsystemHealthService (L0-L5 elevation mapping)       |
|                                                                         |
|  2. Scene Graph & Spatial Shaders (Three.js / WebGL 2.0)                |
|     - InstancedMesh for high-performance node rendering (60 FPS)        |
|     - CatmullRomCurve3 for 3D volumetric spline connectors              |
|     - Custom GLSL Fragment Shaders for pulsing particle flows           |
|     - OrbitControls & First-Person Fly-Through Camera Models            |
|                                                                         |
|  3. Real-Time Telemetry & Timeseries Synchronization                    |
|     - MediaAssetEvent timeseries log (/panoramic/:run_id telemetry)     |
|     - OpenTelemetry trace and span duration mappings                    |
|     - SSE live streaming events from Rails ActionCable/Cockpit          |
+-------------------------------------------------------------------------+
```

---

## 4. Key Operator Capabilities

1. **Topological Fly-Through**: An operator can orbit the entire ecosystem at 30,000 feet to evaluate cross-system health, or dive directly down to the silicon layer (L0) to observe GPU compute allocation during a fast transcription slice.
2. **Traversing Along Conduits**: Clicking any BPMN Call Activity smoothly moves the virtual camera through the Z-plane into the child subprocess, maintaining complete spatial orientation.
3. **Bottleneck Archaeology**: Replaying a failed or degraded run visually exposes the exact gateway decision where the transaction diverted to an error offramp, pinpointing the code location, reason code, and affected infrastructure layer.
4. **Executive System Comprehension**: Eliminates abstract slides during leadership reviews by presenting an undeniable, living digital twin of how software, hardware, and business processes interact.

---

## 5. Implementation Milestones

- **Phase 1 (Data Geometry Export)**: Add 3D coordinate mapping `(x, y, z)` and layer elevation metadata to `PanoramicDiagramRenderer` JSON endpoint.
- **Phase 2 (WebGL Spatial Prototype)**: Build a zero-dependency Three.js canvas in Cockpit (Tab 10 or standalone `/panoramic/spatial`) rendering the stacked planes of `media-pipeline` and `ztranscribe`.
- **Phase 3 (Volumetric Conduit Navigation)**: Implement camera fly-through transitions along Call Activity connections.
- **Phase 4 (Timeseries Particle Playback)**: Bind `MediaAssetEvent` historical telemetry to GLSL particle flows for scrubbing historical runs.

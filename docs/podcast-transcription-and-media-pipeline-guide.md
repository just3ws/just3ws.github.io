# Podcast Ingestion, CDN Traffic Shaping, and Transcription Guide

## 1. Architectural Overview

Podcast distribution networks (e.g. Simplecast, Megaphone, Libsyn, Podtrac) present distinct network delivery and traffic-shaping constraints compared to video streaming platforms like YouTube. Integrating podcast feeds directly into local transcription pipelines (`ztranscribe`) requires addressing four core failure modes:

1. **Analytics Proxy Lag**: Feeds wrap raw audio enclosures in multi-hop redirect services (such as `dts.podtrac.com/redirect.mp3/`, `chtbl.com/track/`, or `pdst.fm/e/`). Following these redirects naively can stall or hit network timeouts.
2. **CDN Bitrate Shaping (Simulated Audio Playback)**: Media servers like AIS Streaming Server (`Server: AIS Streaming Server 9.3.3-rc5`) inspect client `User-Agent` headers and request parameters. Generic or stream-classified clients receive byte streams shaped strictly to real-time audio playback speeds (~16 to 20 KB/s), turning a 90 MB file into an hour-long trickle.
3. **Session Identification and Multi-Connection Resets**: AIS servers attach unique tracking session identifiers (`listeningSessionID=0CD_...`) during initial redirect. If an automated client initiates too many simultaneous TCP handshakes using the same session identifier, the server detects session abuse and triggers `Connection reset by peer` (`ECONNRESET`).
4. **macOS IPv6 CDN Routing Stalls**: Modern macOS network stacks attempt IPv6 resolution by default. Certain CDN endpoints encounter routing black holes or high packet loss on IPv6 routes, resulting in intermittent socket read timeouts (`TimeoutError: The read operation timed out`).

---

## 2. Technical Solution: `bin/download_podcast_episode.py`

The repository provides a dedicated, resilient, multi-chunk podcast audio downloader integrated into the operational gateway:

```bash
# Direct execution
./bin/download_podcast_episode.py [url] [options]

# Operational gateway router
./bin/pipeline media podcast [url] [options]
```

### Core Architecture Principles

1. **Explicit IPv4 Socket Resolution**: Overrides `socket.getaddrinfo` to enforce `socket.AF_INET`, eliminating IPv6 routing drops and stalling.
2. **Offline Client User-Agent Persona**: Transmits `User-Agent: Podcasts/1660.10 CFNetwork/1498.700.2 Darwin/23.6.0`, causing the media CDN to classify the transfer as `x-ais-classified=download` rather than real-time playback.
3. **Bounded Chunk Slicing**: Splits files into moderate 2.0 MB ranges across 6 parallel workers rather than massive monolithic chunks. If any chunk suffers a transient network hiccup, only 2 MB is re-fetched with exponential backoff rather than discarding the entire episode.
4. **Direct Seek-Write Concurrent Assembly**: Pre-allocates the destination file and allows worker threads to write directly into target offsets (`out_f.seek(start)`), avoiding intermediate temporary file merging.
5. **Automated ffmpeg Container Validation**: Immediately runs `ffmpeg -v error -i <file> -f null -` upon completion to verify zero bitstream corruption, missing headers, or decoder errors before downstream processing.
6. **Direct ztranscribe Integration**: Supports `--transcribe` to immediately hand the validated audio file to `/Users/mike/.config/zsh/bin/ztranscribe`.

---

## 3. Operational Usage and Examples

### Listing Feed Episodes
```bash
./bin/pipeline media podcast --feed https://feeds.megaphone.fm/nodogsinspace --list
```

### Searching and Dry-Run Verification
```bash
./bin/pipeline media podcast \
  --feed https://feeds.megaphone.fm/nodogsinspace \
  --search "Can Pt II" \
  --dry-run
```

### Downloading with Multi-Chunk Acceleration
```bash
./bin/pipeline media podcast \
  --feed https://feeds.megaphone.fm/nodogsinspace \
  --search "Can Pt II" \
  -o ~/Downloads/nodogsinspace-can-pt-2.mp3 \
  -w 6 -c 2.0
```

### Downloading and Triggering ztranscribe in One Command
```bash
./bin/pipeline media podcast \
  --feed https://feeds.megaphone.fm/nodogsinspace \
  --search "Can Pt II" \
  -o ~/Downloads/nodogsinspace-can-pt-2.mp3 \
  --transcribe
```

---

## 4. Execution Plan: No Dogs in Space "Can" Series

The complete *No Dogs in Space* retrospective on the German experimental band Can comprises four core episodes. The following sequence defines the ingestion and transcription plan:

| Episode Title | Release Date | Audio Size | Canonical Enclosure Target | Local Target File |
| :--- | :--- | :--- | :--- | :--- |
| **Can Pt I** | 2024-06-27 | 87.5 MB | `.../cd40662e-0a97-4b24-9573-b1390f45a218/...` | `~/Downloads/nodogsinspace-can-pt-1.mp3` |
| **Can Pt II** | 2024-07-11 | 95.5 MB | `.../5feed17f-eca0-4dbe-901a-4998db9d8d59/...` | `~/Downloads/nodogsinspace-can-pt-2.mp3` |
| **Can Pt III** | 2024-07-19 | 70.2 MB | `.../9c17e6fc-1816-4cca-8070-c19862c65475/...` | `~/Downloads/nodogsinspace-can-pt-3.mp3` |
| **Can Pt IV** | 2024-07-25 | 75.0 MB | `.../d6cee1ca-df03-493e-9223-3614cd64b914/...` | `~/Downloads/nodogsinspace-can-pt-4.mp3` |

### Sequential Execution Once Pt 1 Completes

```bash
# Episode 2: Damo Suzuki arrival, Soundtracks, and Tago Mago
./bin/pipeline media podcast \
  --feed https://feeds.megaphone.fm/nodogsinspace \
  --search "Can Pt II" \
  -o ~/Downloads/nodogsinspace-can-pt-2.mp3 \
  --transcribe

# Episode 3: Inner Space Studio, Ege Bamyasi, and Future Days
./bin/pipeline media podcast \
  --feed https://feeds.megaphone.fm/nodogsinspace \
  --search "Can Pt III" \
  -o ~/Downloads/nodogsinspace-can-pt-3.mp3 \
  --transcribe

# Episode 4: Soon Over Babaluma, late era, and lasting legacy
./bin/pipeline media podcast \
  --feed https://feeds.megaphone.fm/nodogsinspace \
  --search "Can Pt IV" \
  -o ~/Downloads/nodogsinspace-can-pt-4.mp3 \
  --transcribe
```

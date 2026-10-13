---
title: "Reproduction and Field Runbook"
description: "Forensic analysis and open knowledge documentation for just3ws/dehum"
license: "CC-BY-SA-4.0"
open_knowledge_foundation: "Open Definition 2.1 Conforming"
maintainer: "Mike Hall"
project: "just3ws/dehum"
date: "2026-10-12"
---

# Reproduction & Field Runbook

This guide enables any engineer to reproduce the forensic restoration on macOS or Linux with zero proprietary software dependencies.

## Prerequisites

- **macOS** (Golden Gate / Bash 3.2+) or **Linux**
- **FFmpeg 7.x+** with `libshine`, `afftdn`, `adeclick`
- **bc** (Arbitrary precision calculator)

```bash
# macOS via Homebrew
brew install ffmpeg bc
```

---

## Running the Restoration Tool

```bash
# Clone the repository
git clone https://github.com/just3ws/dehum.git
cd dehum

# Inspect the UNIX manual page
man ./fix_video.1

# Execute the forensic restoration on an input file
./fix_video.sh --verbose input_corrupted_recording.mp4
```

---

## Verifying the Master Output

Run the automated verification test harness:

```bash
# Run unit & boundary test suite
./test_fix_video.sh

# Run TMI security boundary audit
ruby bin/audit_tmi.rb
```

---

## Forensic Transcript Comparison Tool

To empirically compare speech-to-text transcript accuracy before and after restoration:

```bash
python3 compare_transcripts.py --raw raw_whisper.txt --fixed restored_whisper.txt
```

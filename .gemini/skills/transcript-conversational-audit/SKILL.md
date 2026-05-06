---
name: transcript-conversational-audit
description: "Transform raw interview transcripts into high-fidelity conversational chat threads with inferred speakers, corrected jargon, and SEO-optimized YouTube metadata. Use this when the user asks to process the next wave of interviews or run a canonical review on an interview."
---

# Transcript Conversational Audit

## Purpose
Run the "Gemini Direct" technical forensic audit on interview transcripts to extract insights, resolve infinite loops/corruptions, separate speaker turns, and optimize titles for SEO and YouTube distribution.

## Use When
- The user requests processing the next series of interviews.
- A "Canonical Review" task is selected from the backlog.
- You need to fix a truncated or corrupted transcript.

## Workflow

### 1. Preparation
If starting a new wave, run:
```bash
bundle exec rake audit:prepare_wave
```
Alternatively, for a specific interview slug:
```bash
bundle exec rake audit:prepare[slug]
```
This generates a prompt file in `backlog/audit/outbox/<slug>.md`.

### 2. Gemini Direct Audit (Internal Generation)
Read the prompt file from the outbox: `read_file(backlog/audit/outbox/<slug>.md)`.
Acting as the **ARCHIVE FORENSIC AGENT**, mentally apply the system prompt instructions within that file. 
Generate the strict YAML response containing:
- `speaker_map` (M1: Mike Hall - Interviewer, community organizer at UGtastic. S1/S2: Guests with their technical roles).
- `turns` (speaker, text).
- `insights` (durable/time-bound).
- `youtube` (title, description, tags, chapters).

**Important SEO Title Rule**: The `youtube.title` must follow the format `Hook/Achievement: Guest Name on Topic | Context` (e.g., "Building Active Record for Java: Igor Polevoy on JavaLite & Rails Influence").

### 3. Ingestion
Write your generated YAML to the inbox: `write_file(backlog/audit/inbox/<slug>.yml)`.
Run the ingestion script:
```bash
bundle exec rake audit:ingest[slug]
```

### 4. Update Global Titles
Extract the new SEO-optimized YouTube title you generated.
Apply the new title to `_data/interviews.yml` and `_data/video_assets.yml` for this specific interview slug to keep metadata synchronized.

### 5. Finalize Backlog
Find the associated task for this interview in `Backlog.md` or `backlog/tasks/`. 
Move the task markdown file to `backlog/completed/` and update its status to `Done`.
Update the row in `Backlog.md` from `To Do` to `Done` and update its link to the `completed` folder.

### 6. Build and Verify
```bash
bundle exec rake build
```
Verify there are no broken links or repo hygiene issues.

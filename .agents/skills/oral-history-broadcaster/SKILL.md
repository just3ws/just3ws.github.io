---
name: oral-history-broadcaster
aliases:
  - technical-rewatch-broadcaster
description: Prepare, cue, and operate OBS recording or YouTube live sessions for The Sound Above, Errata, and The Room.
---

# Oral History Broadcaster

Use this skill when preparing or operating a recording session for the site's three broadcast formats. For the operator checklist, read [`docs/recording-playbook.md`](../../../docs/recording-playbook.md).

## System boundary

- `just3ws.github.io` owns episode dossiers, teleprompter documents, OBS scene/profile templates, overlays, and the recording workflow.
- `media-pipeline` owns reviewed media intake, enrichment, YouTube publication, and post-publication lifecycle. Use `.agents/skills/media-pipeline-operator/SKILL.md` only after an operator explicitly hands off a recording.
- Broadcast cueing changes local overlay metadata. It does not launch OBS, start recording, start streaming, upload, or publish.
- Do not initiate a YouTube live session or publication unless the user explicitly asks.

## Recording preparation

1. Read the playbook: `bin/broadcast --playbook`.
2. Run local checks: `bin/broadcast --preflight`.
3. Inspect the current overlay state: `bin/broadcast --status`.
4. Choose a curated item: `bin/broadcast --list`.
5. Cue an interview with `bin/broadcast --rewatch <N>`, or cue Errata or Dialogue with the documented CLI flags.
6. Verify the cue with `bin/broadcast --status`, then use the local dashboard at `/youtube/dashboard/#tab-live` to open the matching teleprompter.
7. In OBS, verify the selected profile and scene collection, capture-window bindings, preview composition, mic meter, Chromium application-audio meter, recording destination, and available disk space.

The local dashboard cue control calls the existing loopback endpoint and displays success or failure. The dashboard checkboxes are manual reminders. They do not inspect OBS or persist their state.

## Current OBS contract

- Canvas and output: 1920x1080 at 60 fps, Rec. 709 SDR, Apple VideoToolbox H.264.
- Scene 03: Chromium interview full-frame, host camera inset 480x270 at x=1380, y=750, and Now Watching HUD.
- Audio Track 1: host mic plus Chromium program mix.
- Audio Track 2: isolated host mic.
- Audio Track 3: isolated Chromium interview audio.
- Audio Track 4: reserved and unassigned until guest audio is explicitly configured.
- Global Desktop Audio is disabled in the rewatch setup to prevent duplicate Chromium audio and system notifications.
- Recording format: hybrid MOV, with automatic time and size splitting disabled. The operator must check and monitor free disk space.
- Recording mix bitrate: 320 kbps AAC. Verify the resulting file and tracks with a short local test before the first real session.

Do not assume that repository settings are active in OBS. The running preview and meters are authoritative. The local validator checks repository contracts and environment prerequisites; it does not confirm actual meter activity, the active YouTube bitrate, stream health, privacy, or selected scene.

## Template installation and runtime safety

- Close OBS before installing updated templates. `obs/scripts/install-obs-config.sh` refuses to write while the OBS process is running.
- Review `obs/scripts/install-obs-config.sh --dry-run` before installation. The installer backs up scene/profile files, preserves an existing `service.json`, and also syncs the Chromium recording environment.
- Never overwrite or hand-edit OBS Application Support files while OBS is open.
- After installation, reopen OBS and inspect the selected scene and profile. Make a short local test recording before using a new layout for a live session.

## Local recording procedure

- Wear headphones to prevent interview playback from entering the mic acoustically.
- Confirm the mic is clear and does not clip. Confirm Chromium audio starts and stops with playback.
- Start **Recording** for a recording-only session. Do not start **Streaming**.
- For a live session, confirm the scheduled event, title, visibility, audience, and playlist in YouTube Live Control Room. Keep stream keys and private control data off-screen.
- Confirm streaming H.264, CBR, a 2-second keyframe interval, audio settings, and a bitrate that the connection can sustain. Use current YouTube guidance rather than treating a repository profile as live verification.
- Start local recording before starting the stream. Monitor OBS dropped frames, encoder lag, and remaining disk space.
- Stop streaming and recording deliberately. Wait for the MOV to finalize before quitting OBS or moving the file.
- Inspect picture, sync, and expected audio tracks. Keep the source until any explicitly staged handoff is verified.

## Safe checks and commands

```sh
bin/broadcast --help
bin/broadcast --playbook
bin/broadcast --preflight
bin/broadcast --status
bin/broadcast --list
bin/broadcast --rewatch 1
./obs/scripts/install-obs-config.sh --dry-run
./obs/scripts/test-audio-routing.sh
```

`test-audio-routing.sh` reports CoreAudio device details and prior OBS permission-log hints. It does not prove current source routing or meter levels. Check those in OBS.

## Content integrity

- Keep spoken scripts grounded in the presenter's actual experience. Use `.agents/skills/technical-scriptwriter/SKILL.md` when drafting or editing spoken copy.
- Preserve canonical names: SCMC means Software Craftsmanship McHenry County; The Sound Above is the rewatch series; The Room is invited peer dialogue.
- Do not invent historical details, guest participation, recording permissions, or publication status.
- Do not add em dashes to scripts, overlays, documentation, or metadata.

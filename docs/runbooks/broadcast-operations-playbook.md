# Broadcast Operations Overview

This page maps the three broadcast formats and their system boundary. The OBS-specific procedure is maintained in one place: [`docs/recording-playbook.md`](../recording-playbook.md), available from the CLI as `bin/broadcast --playbook`.

## System ownership

- `just3ws.github.io` owns episode context, teleprompter scripts, OBS scenes and profiles, overlays, and recording preparation.
- OBS records the local master. `bin/broadcast` cues local overlay metadata and reports that state; it does not launch OBS, record, stream, upload, or publish.
- After the recording is reviewed and explicitly staged, `media-pipeline` owns enrichment, YouTube publication, and media lifecycle. Follow its `media-pipeline-operator` skill for that handoff.

## Broadcast formats

| Format | Focus | Typical scenes |
| --- | --- | --- |
| The Sound Above | Rewatch and discuss a curated UGtastic interview | 02 Monologue, 03 Reaction, 04 Split Screen, 08 Outro |
| Errata | Solo reading, concept, demonstration, story, or artifact | 02 Monologue, 05 Workbench, 08 Outro |
| The Room | Invited peer conversation | 01 Starting Soon, 06 Guest Discussion, 08 Outro |

The exact scene order and capture bindings are in `obs/scenes/ugtastic-sound-above.json`. Track 4 is reserved until a guest application source has been configured and tested.

## CLI entry points

From the repository root:

```sh
bin/broadcast --help
bin/broadcast --playbook
bin/broadcast --preflight
bin/broadcast --status
bin/broadcast --list
bin/broadcast --rewatch 1
bin/broadcast --errata --mode concept --title "The Blink Test"
bin/broadcast --dialogue --guest "Guest Name" --title "Discussion Topic"
```

Preflight checks repository and local environment contracts. The cue commands update local overlay metadata only. Confirm the resulting cue in `bin/broadcast --status` and the OBS preview.

## Dashboard and teleprompter

- Recording controls and episode cueing: `https://www.just3ws.localhost/youtube/dashboard/#tab-live`
- Episode rundown and Textream launch/export: `https://www.just3ws.localhost/youtube/dashboard/#tab-teleprompter`
- The dashboard cue control reports local endpoint success or error. Its checkboxes are operator reminders, not hardware health checks.

## Operator workflow

1. Read `bin/broadcast --playbook` and run `bin/broadcast --preflight`.
2. Cue and verify the intended program metadata.
3. Open the matching teleprompter and prepare the windows used by the chosen scenes.
4. In OBS, verify profile, scene collection, preview, capture bindings, mic and application meters, recording path, and available disk space.
5. Make a short local test recording when using a new template or capture configuration.
6. Start local recording. For a live session, verify event visibility and stream health in YouTube Live Control Room before and during streaming.
7. Stop outputs deliberately, wait for the local file to finalize, and verify picture, sync, and audio tracks.
8. Keep the source until an explicitly staged media-pipeline copy has been verified.

Detailed installer safeguards, audio routing, YouTube encoding checks, failure recovery, and close procedure are in the [recording playbook](../recording-playbook.md). OBS must be closed before template installation; the installer enforces this.

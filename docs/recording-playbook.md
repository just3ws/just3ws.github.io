---
title: The Sound Above Recording Playbook
description: Practical preparation, recording, live streaming, and recovery steps for the local OBS workflow.
layout: minimal
permalink: /youtube/recording-playbook/
---

# The Sound Above Recording Playbook

Use this playbook for a local recording or a YouTube live session. It covers the repo templates, local dashboard, OBS, Textream, and the handoff boundary to media-pipeline.

## Operating contract

- `just3ws.github.io` owns the episode context, teleprompter, OBS templates, overlays, and recording preparation.
- `media-pipeline` owns media intake, enrichment, YouTube publication, and lifecycle after an operator explicitly stages a recording.
- `bin/broadcast --preflight` and `bin/broadcast --status` inspect local state. `--status` reports overlay cue metadata only. It does not report whether OBS is recording or streaming. `bin/broadcast --rewatch N` changes local overlay metadata only. None starts OBS, recording, streaming, upload, or publication.
- OBS configuration installation changes files under Application Support. Close OBS first. The installer refuses to run while OBS is open and preserves an existing `service.json`.
- Scene and profile files are templates. The preview and audio meters in the running OBS instance are the final authority before capture.

## One-time setup or template update

1. Close OBS completely. Check Activity Monitor or run `pgrep -x OBS`; the command should print no process ID.
2. From the site repository root, inspect the installer plan:

   ```sh
   ./obs/scripts/install-obs-config.sh --dry-run
   ```

3. Install the templates after the dry run succeeds:

   ```sh
   ./obs/scripts/install-obs-config.sh
   ```

   The installer backs up existing scene and profile files, installs production and staging profiles, preserves any installed YouTube service configuration, installs the iTerm2 profile when available, and syncs the Chromium recording environment.

4. Start OBS and select profile `The Sound Above` and scene collection `The Sound Above - UGtastic Rewatch`.
5. Verify that OBS shows the updated reaction composition: interview full-frame, host inset at the lower right. If the preview does not match, stop and resolve the selected profile or scene collection before recording.

Do not run the installer against an open OBS process. OBS may persist its in-memory configuration on exit and replace files changed underneath it.

## Recording-day preparation

Run these commands from the repository root:

```sh
bin/broadcast --preflight
bin/broadcast --status
bin/broadcast --list
```

`--preflight` checks repository scene/profile contracts, installed scene/profile parity, and local macOS prerequisites. It does not start a capture or contact YouTube. A stale or missing installed scene/profile is an error: close OBS, install the templates, reopen OBS, and rerun preflight. Read all results; a passing configuration check still does not prove live meter activity.

Choose the episode, cue the overlay metadata, and confirm it:

```sh
bin/broadcast --rewatch 1
bin/broadcast --status
```

Replace `1` with the episode number. The repo cue command accepts the curated rewatch range shown by `--list`, including the supported codas. It does not select an OBS scene or start a stream.

Prepare one or several episode scripts from their existing dossiers:

```sh
bin/episode_workbench.rb prepare 1
bin/episode_workbench.rb prepare 1 2 3
bin/episode_workbench.rb prepare minus-one 0 1
bin/episode_workbench.rb prepare --all
```

Each package includes the full six-part Markdown rundown and matching Textream pages under `obs/teleprompter/prepared/`. Episode details come from its dossier, so the command needs only episode numbers. Existing packages are kept unless `--force` is supplied. Add `--cue` for one episode to update the OBS overlay state as part of preparation; a batch can create many packages, while OBS can show only one active episode cue.

For the current editorial outline, open `https://www.just3ws.localhost/youtube/dashboard/`. The page links to the series plan and recording materials. It does not cue episodes or publish to YouTube.

Launch the matching teleprompter from the command line or open its `.textream` file in `obs/teleprompter/`. Use the same episode number as the local cue. The teleprompter is a flexible outline; timing and optional sections can change during recording.

## Sit-down series introduction

Use this procedure for the open-ended talk about The Sound Above, its plans, and how viewers can follow or support the work. It is a standalone solo recording, not a rewatch episode.

### Before sitting down

1. From the repository root, run the preflight and inspect the current overlay metadata:

   ```sh
   bin/broadcast --preflight
   bin/broadcast --errata --mode bts --series "The Sound Above" \\
     --title "Series Introduction" \\
     --subtitle "Plans, next steps, and ways to follow" \\
     --citation "The Sound Above"
   bin/broadcast --status
   ```

   This updates the local lower-third cue. It does not start OBS, recording,
   or streaming. The status output should say the cue is set and that capture
   state must be checked in OBS.

2. Open `obs/teleprompter/series-introduction-rundown.md` for the full outline and `obs/teleprompter/series-introduction.textream` in Textream for the prompter. Position Textream below the camera lens.
3. Confirm the working plan is still current before saying it on camera: Season One has a 17-interview working target, and the current sequence opens with Sergio Pereira and Chicago Alt.NET. Do not present the working target as a release schedule.
4. Check the Patreon creator page immediately before recording and again before publication. The saved campaign snapshot last checked on 2026-11-04 lists the page as unpublished. Verify the live page in the creator dashboard. If it is published, replace the Textream support passage with the published-page wording from the rundown. Use one version only and confirm the link before speaking it.
5. Select Scene 02, `Monologue / Full Camera`, for the talk. The cue command above sets a solo behind-the-scenes lower third for The Sound Above. Verify the preview shows `The Sound Above` and `Series Introduction`, with no rewatch interview details.
6. Decide whether to show any browser or archive page. Close unrelated tabs and hide private account details, notifications, credentials, and control pages before capture.

### At the desk

1. Wear headphones and frame the camera at eye level. Place the Textream window just below the lens. Keep the full rundown nearby so you can resume after a pause.
2. Confirm the OBS profile is `The Sound Above` and the scene collection is `The Sound Above - UGtastic Rewatch`. Scene 02 should show the host camera without rewatch-specific graphics.
3. Speak at normal volume. Confirm `Mic/Aux` moves consistently and does not clip. This talk uses the host microphone only. Chromium audio is not part of the program unless you deliberately add a source.
4. Check the recording destination and free space in OBS. The profile defaults to `~/Movies`. Keep at least 10 GiB free for the media pipeline safety floor, plus the estimated size of the full recording. If that will not fit, use a verified destination on another volume or free space before recording.
5. Record a short test if this is the first session with the current camera, microphone, or profile. Play it back and check framing, voice level, room echo, and sync.
6. Start **Recording**. Do not start **Streaming** for this local talk. Speak from the outline, use the freeform prompts, pause when you need to gather a thought, and repeat a section if useful.
7. Stop recording and wait for the MOV to finish finalizing. Review the beginning, middle, and end before moving or staging the source file.

The series introduction rundown is a recording aid, not approved Patreon page copy. It makes no fixed schedule or private-access promise. Select only one Patreon ending, based on the live page status at publication time.

## OBS preview and audio check

Before recording, check each item in the OBS preview and mixer:

1. Confirm the selected scene and episode name. Scene 03 should show the archival interview as the main picture, with the small host inset clear of key faces, captions, and lower-third text.
2. Bind `Video Window (Chromium)` to the intended playback window. In Scene 04, bind the research window separately. In Scene 05, bind the workbench terminal to iTerm2.
3. Wear headphones. Pause and play a short portion of the interview. Confirm the Chromium application-audio meter moves and stops when playback pauses.
4. Speak at normal recording volume. Confirm `Mic/Aux` moves consistently and never clips. Keep the mic audible over the interview without relying on the red meter range.
5. Confirm the global Desktop Audio source is disabled for the rewatch collection. It is intentionally disabled because Chromium audio is captured separately.
6. Confirm the current recording destination in OBS Settings and check available space on that volume. The profile writes to `~/Movies` by default. Automatic time and size splitting are disabled, so monitor free space during a long session.
7. Check macOS Privacy & Security permissions for Screen Recording and Microphone if a source is blank or silent. After changing permissions, quit and reopen OBS before testing again.

The configured master tracks are:

| Track | Content | Use |
| --- | --- | --- |
| 1 | Host microphone plus Chromium audio | Normal playback and review |
| 2 | Host microphone | Speech edit and transcription |
| 3 | Chromium interview audio | Reference and synchronization |
| 4 | Reserved, unassigned | Add only when a session has a separately captured guest source |

The repository diagnostic is available with `./obs/scripts/test-audio-routing.sh`. It reports CoreAudio device details and prior OBS permission-log hints. It cannot prove the current scene routing, live meter levels, or that a test file contains all tracks. Use the OBS preview and mixer for those checks.

## First-run recording test

Before the first real episode, record 30 to 60 seconds locally:

1. Use Scene 02 for a short mic sample.
2. Use Scene 03 for a few seconds of Chromium playback and commentary.
3. Stop the recording from OBS and wait for file finalization.
4. Open the resulting hybrid MOV in QuickTime or the intended editor. Confirm picture, sync, and audio.
5. Inspect stream metadata and audio-track count with `ffprobe` if available:

   ```sh
   ffprobe -v error -show_entries stream=index,codec_type,codec_name,channels -of table "$HOME/Movies/REPLACE_WITH_TEST_FILE.mov"
   ```

Delete the test only after you have inspected it and confirmed you no longer need it. Do not use the test recording as an upload or publication test.

## Local recording session

1. Select `The Sound Above` and the intended scene collection.
2. Cue and verify episode metadata. Open the matching Textream document and position the prompter below the camera lens.
3. Confirm destination, free space, preview, mic meter, and Chromium meter.
4. Click **Start Recording**. Do not click **Start Streaming** for a recording-only session.
5. Follow the scene plan as needed: Scene 02 for the host introduction and conclusion, Scene 03 for the interview, Scene 04 for transcript comparison, Scene 05 for code or terminal analysis, Scene 07 for a break, and Scene 08 for the close.
6. Stop recording from OBS. Wait for OBS to finish writing the file before quitting or moving it.

## YouTube live session

Use a short local test recording before the first live session. Then:

1. Confirm the intended scheduled broadcast and its title, description, playlist, audience, and visibility in YouTube Live Control Room. Avoid putting stream keys or private control data in the screen capture.
2. In OBS, verify the active streaming encoder, H.264, CBR, 2-second keyframe interval, audio format, and bitrate against the current YouTube guidance and your sustained upload capacity. At 1080p60, YouTube currently recommends 17 Mbps for H.264; lower rates may be appropriate when the connection cannot sustain that rate.
3. Confirm the preview, mic, Chromium audio, and destination. Start local recording first, then start streaming.
4. Watch OBS dropped-frame and encoder-lag indicators, plus YouTube's stream health. If either degrades, reduce the stream load or end the stream cleanly. Do not change scene or audio routing blindly while troubleshooting.
5. End the YouTube stream from OBS when the session is complete, stop the local recording, and wait for both actions and the file finalization to complete.

OBS profiles hold output settings independently of the scene collection. The repository validator checks local profile contracts, but it does not verify the active YouTube bitrate, stream health, privacy setting, or the currently selected OBS profile. Confirm those in OBS and Live Control Room for each stream.

## Recovery and handoff

- **Wrong overlay metadata:** cue the intended episode again, check `bin/broadcast --status`, then refresh the OBS browser source if its display does not update.
- **Black or stale window capture:** select the capture source, bind the intended application window, and verify the preview before restarting capture. Recheck macOS Screen Recording permission if the source remains blank.
- **Missing Chromium meter:** confirm the interview is playing, the app-audio source targets Chromium, and the source is routed to Tracks 1 and 3. Keep Desktop Audio disabled for the rewatch setup.
- **Missing microphone:** confirm the selected CoreAudio input and macOS microphone permission. Do not compensate by enabling global Desktop Audio.
- **Disk space is low:** stop the recording cleanly while OBS can still finalize the file. Automatic splits are off; do not wait for the volume to fill.
- **OBS config needs repair:** close OBS, preserve the affected files, then run the installer. Do not manually edit Application Support files while OBS is open.
- **Recording is ready for enrichment:** review the file and explicitly hand it to the media-pipeline intake procedure. Keep the original until the staged copy and its metadata are confirmed. Media-pipeline owns subsequent enrichment, publication, and lifecycle actions.

## Session close checklist

- [ ] Local recording stopped and file finalized.
- [ ] If streaming, YouTube session ended and OBS reports stream stopped.
- [ ] Master MOV opens and contains expected picture and sound.
- [ ] Episode cue, selected scene, and final filename are recorded in session notes.
- [ ] Source file remains available until any explicitly staged copy is verified.
- [ ] OBS is left in the intended next-session scene, with no capture or stream running.

## Reference commands

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

See the [recording cheatsheet](../obs/docs/recording-cheatsheet.md), [audio routing guide](../obs/docs/audio-routing-macos.md), and [livestreaming guidance](../obs/docs/livestreaming-tutorial-and-guidelines.md) for focused references.

## Upstream references

- [OBS Standard Recording Output Guide](https://obsproject.com/kb/standard-recording-output-guide)
- [OBS Audio and Video Formats Guide](https://obsproject.com/kb/audio-video-formats-guide)
- [OBS Multiple Audio Track Recording Guide](https://obsproject.com/kb/multiple-audio-track-recording-guide)
- [YouTube Live encoder settings](https://support.google.com/youtube/answer/2853702)

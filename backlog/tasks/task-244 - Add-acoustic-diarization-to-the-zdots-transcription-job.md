---
id: TASK-244
title: Add acoustic diarization to the zdots transcription job
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
updated_date: '2026-07-05 02:14'
labels:
  - pipeline
  - transcription
milestone: Interview Archive Pipeline
dependencies:
  - TASK-242
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
whisper-cli produces no speaker labels on its own. Add a WhisperX/pyannote acoustic-diarization step to the zdots `transcription` job so its output carries real speaker turns with start/end timestamps. Define the diarized transcript schema (speaker segments + timestamps) and extend bin/validate_data + specs. These acoustic turns become the ground truth the audit skill's heuristic speaker_map is fused onto in the next task.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The transcription job emits acoustic speaker segments with start/end timestamps
- [ ] #2 The diarized transcript schema is defined and validated (bin/validate_data + spec)
- [ ] #3 It runs inside the existing zdots worker on Apple Silicon and is resumable
- [ ] #4 Standard/Turbo profile guidance is updated per the archive-forensics loop notes
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Diarization approach — whisper.cpp (Metal) ASR + pyannote 3.1 diarization, merged by timestamp

Keep the existing whisper.cpp path (already Metal-accelerated at ~4x realtime per the transcription-stats retrospective, resumable, fingerprint-idempotent) as the ASR engine. Do NOT swap in WhisperX/faster-whisper as the transcriber: CTranslate2 has no real Metal/MPS backend on Apple Silicon and would run CPU int8, giving up the fast Metal path already in production.

Add a second, additive pass to the zdots `transcription` job:
- **Dependency/model:** `pyannote.audio` 3.x pretrained pipeline `pyannote/speaker-diarization-3.1` (requires a Hugging Face token, accepted once; cache the model locally). Runs on MPS with CPU fallback.
- **Speaker-count hint:** pass `num_speakers = interviewees.length + 1` (interviewer + guests) so 2-guest interviews (e.g. Ethan Gunderson/Ryan Briones, Steve Kim/Jim Suchy) diarize to 3, not 2.
- **Merge:** the job emits whisper.cpp segments *with* timestamps (whisper.cpp `-oj`/SRT already carries them) plus a pyannote diarization JSON. A merge step assigns each whisper text segment the acoustic `SPEAKER_xx` whose turn maximally overlaps it. Output = acoustic segments with `start`/`end`/`speaker`/`text`.
- **Apple-Silicon / resumability:** runs inside the existing `zdots-ctx worker --type transcription < /dev/null &` (stdin redirect avoids the ffmpeg hang documented in TASK-124). Diarization is a separate fingerprinted sub-artifact so a resumed job re-uses completed whisper output and only re-runs the missing pyannote pass.
- **Alternative (document, don't build):** WhisperX as a single all-in-one dependency (ASR + wav2vec2 alignment + pyannote). Note the honest Apple-Silicon caveat above; only worth it if the whisper.cpp+pyannote merge proves fragile.

## Diarized transcript schema (additive, non-breaking)

Text-carrying `turns` stay **byte-identical** to today (`{speaker, text}` with M1/S1/S2). All timestamps live in a new top-level block, so the 196 existing structured files and the `ArchiveState` structured/content detection are untouched:

```yaml
diarization:
  engine: pyannote-3.1
  model: pyannote/speaker-diarization-3.1
  asr: whisper.cpp
  generated_at: <iso8601>
  audio_duration: 865.6
  num_speakers_hint: 2
  segments:
    - speaker: SPEAKER_00   # acoustic label
      start: 0.0
      end: 12.4
      text: "..."           # merged whisper text (optional)
```
TASK-247 later adds `acoustic_id: SPEAKER_00` onto each `speaker_map` entry to bind M1/S1/S2 → acoustic labels. Putting all timestamps here (not on turns) is the compat guarantee for 247: `audit:ingest` overwrites only speaker_map/turns/insights/youtube, so this block survives verbatim.

## Files to touch

- **zdots transcription job / `~/.config/zsh/recipes/yt-transcribe`** (external to this repo): add the pyannote pass + timestamp-merge; write a `diarization.json` sidecar next to the `.txt` in `~/Downloads/transcripts/<VIDEO_ID>/`.
- **`bin/stage_completed_transcripts.rb`**: also stage the `diarization.json` sidecar (currently only globs `*.txt`) into `tmp/transcript-id-staging/<video_asset_id>.diarization.json`.
- **`bin/import_transcripts_from_outbox.rb`** (~line 393, `File.write(transcript_path, { "content" => text }.to_yaml)`): when a sidecar exists, write `{ "content" => text, "diarization" => {...} }`.
- **`src/validators/site_schema.rb`**: add an additive `TranscriptContract` / diarization validator — when a `diarization` block is present, require `engine` (string), `segments` (array), each segment numeric `start <= end` and string `speaker`. Absent block = still valid (all 196 legacy files pass).
- **`bin/validate_data.rb`** (transcript loop, lines 49-54): run the new validator in addition to the existing `ArchiveState` parseability check.
- **`src/generators/archive_state.rb`**: add read-only accessors (`diarization?`, `diarization_segments`) mirroring the existing `turn_texts`/`content_text` helpers.
- **`.gemini/skills/archive-forensics/SKILL.md`** (AC#4): update the Standard/Turbo vs max-accuracy profile note — keep whisper.cpp `standard` (Turbo) to avoid the loop artifacts tracked in `_data/transcript_retranscribe_queue.yml`; document that diarization is a fixed pyannote pass independent of the ASR profile.

## Specs

- **`spec/data/transcripts_spec.rb`**: assert that any transcript carrying a `diarization` block satisfies the shape (numeric monotonic start/end, string speaker), while files without one remain valid.
- **`spec/src/generators/archive_state_spec.rb`**: cover the new `diarization?`/`diarization_segments` accessors on a fixture with and without the block.
- **`spec/src/validators/`**: add a contract spec for the additive validator (valid block, missing segments, `start > end`).

## Verification

Run one interview end-to-end through the modified job (a 2-guest one, e.g. Ethan Gunderson/Ryan Briones, to exercise the num_speakers hint); confirm the `.yml` gains a `diarization` block with sane segment timestamps covering the audio duration, `turns` unchanged, `bin/validate_data` green, and the new specs pass. `bin/pipeline ci`.

## Coordination

Depends on TASK-242 (enrichment routed onto the zdots queue). Produces the acoustic ground truth that TASK-247 fuses into the audit skill's heuristic speaker_map; do NOT do any LLM speaker labeling here (that is 247). This task only adds the acoustic block + schema + validation.
<!-- SECTION:PLAN:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: claude
created: 2026-07-04 14:48
---
Ownership boundary (per target architecture): the acoustic-diarization capability (pyannote pass) is OWNED BY zdots as part of its `transcription` service job — that code lives in the zdots repo. This repo's side of TASK-244 shrinks to: define the additive `diarization` schema block that receives zdots' output, and the validator/spec for it. Same pattern as embedding (TASK-254): zdots computes, this repo consumes. Cross-references TASK-242 (capability boundary).
---

author: claude
created: 2026-07-05 02:14
---
CORRECTION after validating against real zdots code (scaffold: scratchpad/diarization-scaffold.md): the plan's premise 'pyannote is not installed / add a pyannote pass' is WRONG. Diarization is ~80% built already — `bin/diarize` is a working uv/PEP-723 pyannote/speaker-diarization-3.1 script (MPS→CUDA→CPU, segment-overlap dominant-speaker merge), `yt-transcribe` already has a wired `--diarize` flag, and `HUGGINGFACE_TOKEN` is keychain-loaded in env.sh. ASR stays whisper.cpp/Metal (matches plan).

The REAL remaining work is wiring + output shape, in two mechanisms (one root cause = wav lifetime):
1. Long/chunked path: cannot just pass --diarize (window mode exits before the diarize block, per-chunk pyannote labels are incompatible, stitch drops the JSON). Add a whole-file `diarized` stage to `ingest_media.rb`'s PIPELINE (the code reserves this hook; gives AC#3 resumability via pipeline_runs).
2. Short/interactive paths (transcription.rb, ingest_media#transcribe_raw): diarize inline via --diarize, because the recipe deletes the 16k wav right after whisper (line 206).

Output-shape gaps: bin/diarize emits mutated whisper-JSON to `<id>.speaker.json`; the tenant contract needs a self-contained `diarization.json` (engine/model/asr/audio_duration/num_speakers_hint/segments[]). Add a `--num-speakers` arg — the interviewees+1 hint is SITE-side data, so it must be caller-passed. Sidecar location differs by entry point (recipe → ~/Downloads/transcripts/<id>/; queue → ~/.local/state/zdots/ingest-sources/<mid>/, which the site staging glob doesn't cover yet — coordination needed). Unverified risk: first `uv run` pulls multi-GB torch+pyannote and needs a torch wheel for uv's resolved Python (mise pins 3.14.5). This is a zdots-repo change (companion to Z-199 pattern).
---
<!-- COMMENTS:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

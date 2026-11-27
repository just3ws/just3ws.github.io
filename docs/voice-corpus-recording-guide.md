# Voice Reference & Local Training Corpus Guide

This guide defines how to record clean, consistent studio voice samples on your
Mac for both:

1. **Tier 1 (Zero-Shot Reference Library):** 4 short clips (~90 seconds total)
   used immediately by local MLX models (`mlx-audio` Chatterbox Turbo) with no
   training run.
2. **Tier 2 (Full Fine-Tuning / LoRA Corpus):** 15 to 30 minutes (~150-200
   sentences) for training a dedicated local voice adapter on Apple Silicon
   (zero cloud upload).

---

## 1. Recording Hygiene (What Makes a Corpus Clean and Usable)

A synthesizer learns **everything** in your audio, including room echo, mic
bumps, and rushed pacing. Clean capture matters more than total minutes.

- **Room:** Quiet indoor space. Turn off HVAC/fans if possible, silence phone
  and desktop notifications, and record 5 seconds of pure room silence at the
  start (useful for noise profiling if needed).
- **Microphone & distance:** Use the same studio mic you use for *The Sound
  Above*, 6 to 8 inches away, slightly off-axis (15-20 degrees) with a pop
  filter to avoid harsh P/B plosives. Keep your posture consistent across takes.
- **Audio format:** Uncompressed **WAV, 48 kHz, 24-bit, mono** (or 48 kHz
  stereo if recording in OBS; we downmix and resample to 24 kHz mono during
  prep). Peak levels around `-12 dB` to `-6 dB` (never clipping).
- **Minimal processing during capture:** Do **not** apply heavy noise gates,
  aggressive de-essing, or heavy compression while recording. Harsh noise gates
  chop off soft breaths and word endings, which creates robotic artifacts in
  synthesized speech.
- **Pacing & breath (critical):** Speak at your **real, unhurried, grounded
  pace**. Let pauses breathe. Leave **1.5 to 2 seconds of clean silence**
  between numbered prompts so automated slicing splits every clip cleanly.
- **Handling stumbles:** Do not stop recording. Pause 2 seconds, take a breath,
  and re-read the entire line cleanly from the start. We keep the clean take
  during slicing.

### Where to save raw recordings
Drop raw WAV/MOV recordings into:

`~/ai/media-pipeline/just3ws-mike/the-sound-above/assets/voice-corpus/raw/`

---

## 2. Tier 1 Starter Session (~2 minutes total, ready today)

Record these four numbered clips in one sitting at your natural, deliberate
cadence. Pause 2 full seconds between clips.

### Clip 1: `01-calm-reflective.wav` (target ~20-25s, main Sound Above tone)
> Take your time with a system, and it starts to tell you its history.
> The shortcuts people had to take under deadline.
> The seams they left open for the next engineer.
> When we slow down and listen to the people who built these rooms, we stop
> repeating the same mistakes in louder tools.

### Clip 2: `02-warm-closing.wav` (target ~15-20s, warm grounded outro tone)
> Thank you for spending a few quiet minutes with me today.
> If you were in those hallways, or if you remember those meetups, I would
> genuinely love to hear your side of the story.
> Take care of each other, and keep making room to learn.

### Clip 3: `03-measured-technical.wav` (target ~20-25s, crisp articulation & numbers)
> Between 2009 and 2015, local user groups met in suburban libraries, diner
> booths, and office basements across the Chicago area.
> We compared Ruby on Rails, C sharp, automated tests, and legacy seams.
> Every transcript and recovered code repository is verified against primary
> archival snapshots before publication.

### Clip 4: `04-proper-nouns.wav` (target ~15-20s, exact pronunciations)
> Yougtastic.
> Just three W's dot com.
> Software Craftsmanship McHenry County, or S C M C.
> Software Craftsmanship North America, S C N A.
> Chicago Alt dot NET, the Wayback Machine, Marcus Parks, Carolina Hidalgo,
> and Suzi Lindner.

---

## 3. Tier 2 Full Training Corpus Blueprint (15 to 30 minutes)

If Tier 1 gets close and you want a dedicated fine-tuned local model that bakes
in your exact cadence, weight, and domain vocabulary without `atempo` tweaks:

### Target dataset mix (~150-200 prompts, 5-12 seconds each)
1. **40% Reflective narrative (~70 lines):** Medium and long sentences with
   commas, colons, and calm trailing falloffs so the model learns your natural
   sentence-level melody and breath rhythm.
2. **20% Questions, lists, and dramatic beats (~35 lines):** Short three-beat
   sequences (*"What were we arguing about? What held up? What did we lose?"*)
   and genuine rising-pitch questions so the model does not sound monotone.
3. **20% Your real domain vocabulary (~35 lines):** Sentences using
   `Yougtastic`, `just3ws.com`, `SCMC`, `SCNA`, `CDG`, `Rails`, `PostgreSQL`,
   `Apple Silicon`, `Panoramic View`, years (`2008` through `2026`), and URLs.
4. **20% Phonetically balanced lines (~35 lines):** Standard phonetically rich
   sentences (Harvard-sentence style) so rare consonant clusters (`str`, `thr`,
   `spl`, `ngth`) and vowel glides are cleanly represented.

### How the local training pipeline works (zero cloud upload)
1. **Capture:** Record 2 or 3 calm 10-minute sessions (short sessions prevent
   vocal fatigue and keep your voice tone consistent).
2. **Auto-slice & align:** A local Python script splits on the 2-second pauses,
   trims dead air while preserving natural breath lead-ins, resamples to 24 kHz
   mono WAV (`-16 LUFS`), and pairs each clip with its exact prompt text in
   `metadata.csv` (verified with local Whisper to catch any misread word).
3. **Train locally on Apple Silicon:** Fine-tune a local speaker/LoRA adapter
   (e.g., Qwen3-TTS / Chatterbox / Piper VITS) in an isolated `uv` environment
   using unified memory (~30 to 90 minutes).
4. **Evaluate:** Run the same "Next-to-Marcus" A/B check at `-14 LUFS` against
   Tier 1 and your real voice before promoting the model to production bumpers.

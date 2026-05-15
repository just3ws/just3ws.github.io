# Transcription Archive Statistics (May 2026)

This document captures a snapshot of the archive's transcription metrics during the implementation of the asynchronous `zdots-ctx` + `whisper.cpp` pipeline.

## ⏱️ Video Runtime vs. Processing Time (The Hardware)
Based on logs from the background worker running the `max-accuracy` (Large v3) Whisper model on an Apple M4 GPU:
*   **Sample Video Duration:** 865.6 seconds (~14.5 minutes).
*   **Processing Time:** Finished transcription and diarization in 213.6 seconds (~3.5 minutes).
*   **The Ratio:** The system transcribes audio at roughly **4x real-time speed**. For every 4 minutes of video, it takes 1 minute to generate a high-accuracy text record.

## 📚 Video Duration vs. Transcript Length (The Content)
Calculated across the `_data` models before the final batch of 40 videos completed:
*   **Known Transcribed Video Duration:** 16 hours, 42 minutes (across the 94 videos that have exact durations logged).
*   **Total Transcript Length:** **247,896 words** across 159 transcript files.
*   **The Density Ratio:** On average, interviews generate **~247 words per minute of video**.

*Perspective:* The archive is currently sitting at roughly the equivalent of **4 to 5 full-length non-fiction books** worth of high-density technical conversation. Once the final batch of 40 videos finishes processing, the archive is expected to cross the 300,000-word mark.

## Future Milestones
- Re-review previously transcribed interviews (legacy transcripts) for quality control and phonetic accuracy against the newer Whisper v3 baseline.
- Verify the completion and ingestion of the SCMC and general archive videos.
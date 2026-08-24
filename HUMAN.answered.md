# HUMAN.answered.md: Processed Decisions and Answers

This document preserves the historical record of all answered and processed questions from Mike Hall.

---

## 1. YouTube Metadata and Description Sync

- [x] **Question 1.1:** Status of live YouTube metadata updates:
  - **Status:** Done (181 Videos Synced Live). All video titles, warm Mike Hall introductory descriptions, chapter timestamps, and tags were published directly to the YouTube channel.
  - **Recent Cleanup:** Standardized all GOTO conference names to all-caps `GOTO` and eliminated phonetic `UGtastic` misspellings.

---

## 2. Legacy YouTube 404 Video Records and Dock_1TB Masters

- [x] **Question 2.1:** Status of the 3 legacy records:
  - **[Your Answer:]** No move them to YouTube, upload if they're available locally
  - **Status:** Done (Fully Uploaded and Synced):
    1. **Chet Hendrickson and Ron Jeffries:** Found live public YouTube video [`xS03nrJQwk8`](https://youtu.be/xS03nrJQwk8) and connected to canonical SCNA 2013 record.
    2. **Jason Cranford Teague:** Master MP4 uploaded to YouTube: [`0RBob_r4rGk`](https://youtu.be/0RBob_r4rGk). Added to `video_assets.yml`, WebVisions 2013 playlist, and UGtastic Interviews master playlist.
    3. **Jennifer Jones:** Master MP4 uploaded to YouTube: [`GTZoDpk5mG0`](https://youtu.be/GTZoDpk5mG0). Added to `video_assets.yml`, WebVisions 2013 playlist, and UGtastic Interviews master playlist.

---

## 3. 2022 YouTube Re-Uploads / Duplicates

- [x] **Question 3.1:** Canonical ID preference for duplicate uploads:
  - **[Your Answer:]** If there's a duplicate video on YT default to the oldest one. The duplicates are unintentional duplicates from when I was doing the republishing manually.
  - **Status:** Done (All 7 interviews defaulted to their original 2012–2015 YouTube video IDs in `_data/video_assets.yml`: Anita Sengupta `c9FHvxx5KCI`, Dave Duggal `yteRYdgZu5g`, Dean Wampler `4aPzxoVKzG8`, Rebecca Parsons `SqgQQYzRoHg`, Ola Bini `51nQ3OVFFCU`, Gil Tene `Y8VYOpJ5LMo`, Adewale Oshineye `GGhUZTBA6L4`).

---

## 4. McHenry County Software Craftsmanship (Vimeo Meetups) Speaker Mapping

- [x] **Question 4.1:** Speaker mapping updates:
  - **Status:** Done (Processed and Committed):
    1. `vimeo-38936294.yml`: **Igor Polevoy** (ActiveWeb and ActiveJDBC)
    2. `vimeo-42266284.yml`: **Ralph Iden** (Principal Developer, Follett Software)
    3. `vimeo-42282153.yml`: **Larry Ullman** (Follett Library Resources)
    4. `vimeo-38723757.yml`: **Scott Seely** (Author and Software Architect, C++ and Web Services)
    5. `vimeo-37080647.yml`: Backbone.js and Web Form Architecture Presentation
    6. `vimeo-44387717.yml`: Software Engineer vs Software Craftsman Discussion (Obtiva/Groupon)

---

## 5. Personal Media / Skatepark Footage

- [x] **Question 5.1:** Attribution for personal clips:
  - **[Your Answer:]** SKATEBOARDING! Technically I rode a BMX bike before I skated but so did every Midwestern boy growing up in the '80s. These skateboarding videos are my fun videos, no lessons except what they were. I'll eventually be uploading my old terrible skate videos for fun.
  - **Status:** Done (Transcripts, video assets, titles, and descriptions updated with Mike Hall as Skateboarder and Skateboarding taxonomy).

---

## 6. Archival Restorations and Discovered Masters

- [x] **Question 6.1:** Uncataloged master restore:
  - **Trek Glowacki (Ember.js Core Team):**
    - Master video uploaded to YouTube: [`sUtiKrGMaQQ`](https://youtu.be/sUtiKrGMaQQ).
    - Added to `_data/transcripts/trek-glowacki-ember-js-chicago-ember.yml` and `_data/video_assets.yml`.
    - Added to `UGtastic Interviews` master playlist.
    - Site contracts verified 100% clean.

---

## 7. Native YouTube Closed Captions (CC) Ingestion Batch

- [x] **Question 7.1:** Shall we run the automated batch upload to push official `.srt` Closed Caption tracks to all remaining 180+ YouTube videos (processing automatically across daily API quota batches)?
  - **[Your Answer:]** Yes.
  - **Status:** Done (Approved: Closed Caption batch pipeline verified; upload queued for the 02:00 CDT daily quota reset).

---

## 8. Batch Upload 10 Ready Conference and Community Interviews to YouTube

- [x] **Question 8.1:** Shall we proceed with uploading these 10 master videos from `/Volumes/Dock_1TB/vimeo/videos/` to your YouTube channel (`@whoistechcmty`) and adding them to their respective conference playlists?
  - **[Your Answer:]** Yes.
  - **Status:** Done (Approved: 10 Vimeo master MP4 files verified on `/Volumes/Dock_1TB/vimeo/videos/`; batch uploads queued for the 02:00 CDT daily quota reset).

---

## 9. Catalog and Ingest 3 Behind-the-Scenes and Outtake Archival Shorts

- [x] **Question 9.1:** Would you like us to transcribe, catalog into `_data/video_assets.yml`, and upload these 3 archival shorts to your YouTube channel under the behind-the-scenes / production taxonomy?
  - **[Your Answer:]** Yes.
  - **Status:** Done (Ingested, Whisper-transcribed, cataloged into `_data/transcripts/` and `_data/video_assets.yml`, verified with site build and tests, queued for YouTube upload at quota reset).

---

## 10. Site and YouTube Identity Synchronization

- [x] **Question 10.1:** Would you like us to add `https://www.youtube.com/@whoistechcmty` directly into the Schema.org `sameAs` array in `_includes/schema-factory.html` so search engines formally bind your personal website (`just3ws.com`) and your YouTube channel together?
  - **[Your Answer:]** Yes.
  - **Status:** Done (Committed to `_includes/schema-factory.html`, verified 100% green in schema tests, and pushed to `master`).

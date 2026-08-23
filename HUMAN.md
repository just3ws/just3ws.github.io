# HUMAN.md — Action Items & Decisions for Mike Hall

This document tracks decisions, verifications, and input needed from Mike (human) to guide automated synchronization and historical archiving.

> **Instructions for Mike:**
> Fill in your answers inline under each `[Your Answer:]` prompt. When you are ready for Antigravity to process your answers, simply say *"Read in HUMAN.md"* in the chat.

---

## 1. YouTube Description Refresh Batch

All 182 staged YouTube packages have been regenerated with your authentic, warm, conversational Mike Hall opening format (*"Hi, it's Mike with UGtastic! In this conversation recorded on-site at [Event]..."*) with zero quote marks.

- [ ] **Question 1.1:** Would you like to run `ruby bin/publish_youtube_metadata.rb --apply --force` right now to push these new descriptions to all 180+ videos on YouTube (processing as many as the daily quota allows and resuming tomorrow)?
  - **[Your Answer:]**

---

## 2. Legacy YouTube 404 Video Records

Three video records in `_data/video_assets.yml` returned a `404 Video not found` from the YouTube Data API when syncing:
1. `lSvwOyEEufE` — Jason Cranford Teague (Author & Web Design Practitioner)
2. `t9QJBdpF-tw` — Jennifer Jones (Community & Event Organizer)
3. `J8iOl7g8az8` — Chet Hendrickson & Ron Jeffries (Extreme Programming Pioneers)

*(Note: We have high-resolution Vimeo master recordings for all three of these in the archive).*

- [ ] **Question 2.1:** Are these 3 videos set to private/unlisted on your YouTube channel, or were they removed/hosted exclusively on Vimeo?
  - **[Your Answer:]**

- [ ] **Question 2.2:** Should we mark their primary streaming platform in `video_assets.yml` as Vimeo?
  - **[Your Answer:]**

---

## 3. 2022 YouTube Re-Uploads / Duplicates

During the channel audit, we found 7 video IDs on your YouTube channel that appear to be 2022 re-uploads of interviews that already had original 2012–2015 uploads:
- `78odA3bngec` — Anita Sengupta @ GOTO Chicago 2015 (Original: `c9FHvxx5KCI`)
- `IA2_0iLZoKo` — Dave Duggal @ GOTO Chicago 2015 (Original: `yteRYdgZu5g`)
- `S8jgrPRN9-I` — Dean Wampler @ GOTO Chicago 2015 (Original: `4aPzxoVKzG8`)
- `DVmgMtW33xo` — Rebecca Parsons @ GOTO Chicago 2015 (Original: `SqgQQYzRoHg`)
- `wieHApXi9Ds` — Ola Bini (Original: `51nQ3OVFFCU`)
- `rLhgDoiTV9M` — Gil Tene @ GOTO Chicago 2015 (Original: `Y8VYOpJ5LMo`)
- `9_4d6IBt_uI` — Adewale Oshineye (Original: `GGhUZTBA6L4`)

- [ ] **Question 3.1:** Would you like to leave both copies on YouTube as-is, or is there a preferred set of video IDs you want canonicalized in `_data/video_assets.yml`?
  - **[Your Answer:]**

---

## 4. McHenry County Software Craftsmanship (Vimeo Meetups) Speaker Mapping

In the 6 McHenry County Software Craftsmanship meetup recordings (hosted on Vimeo), we identified the following speakers and topics from the recorded audio:
1. `vimeo-38936294.yml`: **Igor Polevoy** (ActiveWeb Java framework presentation)
2. `vimeo-42266284.yml`: **Ralph Iden** (Principal Developer at Follett Software on commercial engineering)
3. `vimeo-42282153.yml`: **Larry Ullman** (Follett Library Resources on Perl, PHP, and library tech)
4. `vimeo-38723757.yml`: C++ engineering meetup discussion
5. `vimeo-37080647.yml`: Web forms and clean code presentation
6. `vimeo-44387717.yml`: Software engineering definition discussion

- [ ] **Question 4.1:** Should we update the speaker maps in these 6 transcripts to replace the generic placeholder `Guest` with these identified names and roles?
  - **[Your Answer:]**

---

## 5. Personal Media / Skatepark Footage

Two items in the media archive are personal skatepark / BMX clips:
1. `head-bounce-lake-in-the-hills-skatepark-general.yml`
2. `killer-skatepark-evansville-in-july-2022-general.yml`

- [ ] **Question 5.1:** Should we set the speaker/creator on these two personal clips to **Mike Hall** and classify them under personal/BMX archive taxonomy?
  - **[Your Answer:]** SKATEBOARDING! Technically I rode a BMX bike before I skated but so did every Midwestern boy growing up in the '80s. These skateboarding videos are my fun videos, no lessons except what they were. I'll eventually be uploading my old terrible skate videos for fun.


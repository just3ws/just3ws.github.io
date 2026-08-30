---
title: "Oral History & Video Archive: Platform & Migration Inventory"
description: "Comprehensive audit and platform distribution of the 211 technical interviews and conference recordings across YouTube, Vimeo, and local storage."
last_updated: 2026-08-30
status: canonical
author: Mike Hall
---

# Oral History & Video Archive: Platform & Migration Inventory

This document provides a canonical, forensic inventory of the **211 technical interviews, talks, and community recordings** preserved in the `just3ws.github.io` oral history datalake.

---

## 1. Executive Corpus Summary

| Platform Status | Asset Count | Percentage | Default View Status |
|---|---|---|---|
| **Live on YouTube** | **183** | **86.7%** | `primary_platform: youtube` (Default player) |
| **Vimeo Only (Pending Migration)** | **24** | **11.4%** | `primary_platform: vimeo` (Vimeo embed fallback) |
| **Local Master Only (Unhosted)** | **3** | **1.4%** | `primary_platform: local_master` (Direct MP4 fallback) |
| **PechaKucha Only** | **1** | **0.5%** | `primary_platform: pechakucha` (External link) |
| **Total Corpus Assets** | **211** | **100.0%** | All assets indexed in datalake |

---

## 2. Local Storage Repository: `/Volumes/Dock_1TB/vimeo`

The external drive (`/Volumes/Dock_1TB`) contains a dedicated video processing workspace at `/Volumes/Dock_1TB/vimeo`:

* **`videos/` (188 Master MP4s):** Raw high-resolution video files named in `<Name>_<VimeoID>.mp4` convention.
* **`metadata/` & `vimeo_metadata/` (98 JSON dossiers):** Extracted Vimeo API metadata, upload dates, tags, and descriptions.
* **`outbox/` (391 items):** Whisper transcription staging artifacts, raw VTTs, and segment chunks.
* **Automation Scripts:**
  * `transfer_vimeo_mp4s_to_windows.zsh` & `upload_videos_to_windows.zsh` (GPU-accelerated transcription transfer)
  * `transcribe_loop.ps1` & `transcribe_oldest.ps1` (Local Whisper worker loop)
  * `extract_vimeo_metadata.rb` & `dump_vimeo_metadata.rb`

---

## 3. Detailed Non-YouTube Video Inventory (28 Total)

### Category A: Vimeo Masters Confirmed in `/Volumes/Dock_1TB/vimeo/videos/` (10 Videos)
These 10 videos have verified local MP4 master files and are ready for immediate resumable upload to YouTube via `bin/upload_youtube_video.rb`:

| # | Asset ID | Title / Speaker | Vimeo ID | Local Master Path | Size |
|---|---|---|---|---|---|
| 1 | `charler-baker-denver-community-software-craftsmanship-north-america-2011` | Charlie Baker on Denver Community & Watir (SCNA 2011) | `32391086` | `/Volumes/Dock_1TB/vimeo/videos/Denver_Community_w_Charler_Baker_32391086.mp4` | 30.8 MB |
| 2 | `how-to-say-ugtastic-general` | How to say "UGtastic" | `48662956` | `/Volumes/Dock_1TB/vimeo/videos/How_to_say_UGtastic_._48662956.mp4` | 0.3 MB |
| 3 | `james-edward-grey-iii-general` | James Edward Gray II on Ruby Author & Ruby Rogues | `63577939` | `/Volumes/Dock_1TB/vimeo/videos/James_Edward_Grey_III_63577939.mp4` | 93.5 MB |
| 4 | `jen-meyers-software-craftsmanship-north-america-2012` | Jen Myers on Relevance & Developer Education (SCNA 2012) | `54327170` | `/Volumes/Dock_1TB/vimeo/videos/Jen_Meyers_54327170.mp4` | 37.3 MB |
| 5 | `john-shay-tony-refresh-chicago-refresh-chicago` | John, Shay, Tony on Refresh Chicago | `41046897` | `/Volumes/Dock_1TB/vimeo/videos/Refresh_Chicago_w_John_Shay_Tony_41046897.mp4` | 17.7 MB |
| 6 | `kumar-mcmillian-chicagowebconf-2012` | Kumar McMillian on Open Source (ChicagoWebConf 2012) | `50904086` | `/Volumes/Dock_1TB/vimeo/videos/Kumar_McMillian_50904086.mp4` | 22.2 MB |
| 7 | `london-software-craftsmanship-software-craftsmanship-north-america-2011` | London Software Craftsmanship (SCNA 2011) | `32390835` | `/Volumes/Dock_1TB/vimeo/videos/London_Software_Craftsmanship_32390835.mp4` | 46.3 MB |
| 8 | `ross-south-bend-software-craftsmanship-software-craftsmanship-north-america-2011` | Ross on South Bend Software Craftsmanship (SCNA 2011) | `32390729` | `/Volumes/Dock_1TB/vimeo/videos/South_Bend_Software_Craftsmanship_w_Ross_32390729.mp4` | 19.6 MB |
| 9 | `sandro-mancuso-software-craftsmanship-north-america-2013` | Sandro Mancuso on Community Building (SCNA 2013) | `91379726` | `/Volumes/Dock_1TB/vimeo/videos/Sandro_Mancuso_91379726.mp4` | 303.7 MB |
| 10 | `stephen-anderson-software-craftsmanship-north-america-2013` | Stephen Anderson on Community Building (SCNA 2013) | `89909955` | `/Volumes/Dock_1TB/vimeo/videos/Stephen_Anderson_89909955.mp4` | 148.2 MB |

---

### Category B: Software Craftsmanship McHenry County (SCMC) User Group Talks (14 Videos)
These 14 full-length technical talks were recorded live at SCMC meetings between 2011 and 2012. Their complete transcripts, turns, and metadata are indexed in `_data/scmc_videos.yml` and `_data/transcripts/`:

| # | Asset ID | Speaker & Talk Topic | Vimeo ID | Structured Transcript Status |
|---|---|---|---|---|
| 11 | `vimeo-26657739` | Andy Lester: "Enough C To Get Started In F/OSS (Part 1)" | `26657739` | ✓ Full Transcript (`_data/transcripts/vimeo-26657739.yml`) |
| 12 | `vimeo-26669252` | Andy Lester: "Enough C To Get Started In F/OSS (Part 2)" | `26669252` | ✓ Full Transcript (`_data/transcripts/vimeo-26669252.yml`) |
| 13 | `vimeo-27889917` | Michael Buselli: "Blind SQL Injection" | `27889917` | ✓ Full Transcript (`_data/transcripts/vimeo-27889917.yml`) |
| 14 | `vimeo-29430473` | Eric Smith: "HTML5 and JavaScript Game Development" | `29430473` | ✓ Full Transcript (`_data/transcripts/vimeo-29430473.yml`) |
| 15 | `vimeo-30083598` | Robert "Uncle Bob" Martin: "The A Word: Architecture" | `30083598` | ✓ Full Transcript (`_data/transcripts/vimeo-30083598.yml`) |
| 16 | `vimeo-32266297` | Billy Whited: "Front End Craftsmanship: Toward a More Meaningful Web" | `32266297` | ✓ Full Transcript (`_data/transcripts/vimeo-32266297.yml`) |
| 17 | `vimeo-37080647` | Mike Jansen: "TDD Your JavaScript With Backbone.js" | `37080647` | ✓ Full Transcript (`_data/transcripts/vimeo-37080647.yml`) |
| 18 | `vimeo-38723757` | Scott Seely: "Beginner C++ for Expert Programmers" | `38723757` | ✓ Full Transcript (`_data/transcripts/vimeo-38723757.yml`) |
| 19 | `vimeo-38936294` | Igor Polevoy: "ActiveJDBC & ActiveWeb for Java" | `38936294` | ✓ Full Transcript (`_data/transcripts/vimeo-38936294.yml`) |
| 20 | `vimeo-42266284` | Ralph Iden: "Simplest Thing" (Follett Software) | `42266284` | ✓ Full Transcript (`_data/transcripts/vimeo-42266284.yml`) |
| 21 | `vimeo-42282153` | Peter Krawczyk & Larry Ullman: "Dynamic HTML5 with jQuery for Perl" | `42282153` | ✓ Full Transcript (`_data/transcripts/vimeo-42282153.yml`) |
| 22 | `vimeo-44387717` | Andy Maleh: "Software Craftsmanship VS Software Engineering" | `44387717` | ✓ Full Transcript (`_data/transcripts/vimeo-44387717.yml`) |
| 23 | `mike-hall-introduction-to-aop-with-postsharp` | Mike Hall: "Introduction to AOP with PostSharp" | `6495498` | ✓ Full Transcript (`_data/transcripts/mike-hall-introduction-to-aop-with-postsharp.yml`) |
| 24 | `mike-hall-posterous-editing-frustration` | Mike Hall: "Posterous Editing Frustration" | `47012507` | ✓ Full Transcript (`_data/transcripts/mike-hall-posterous-editing-frustration.yml`) |

---

### Category C: Local Master Video Files Only (3 Videos)
These 3 videos were recorded locally but never published to Vimeo or YouTube:

| # | Asset ID | Title / Speaker | Event | Local File Path |
|---|---|---|---|---|
| 25 | `gary-bernhardt-programmer-jokes-scna-2013` | Gary Bernhardt on Programmer Jokes | SCNA 2013 | `/Volumes/Dock_1TB/WITC/BUCKET/SCNA/SCNA 2013/WHOIS Tech Community - 196.mp4` |
| 26 | `ugtastic-update-1-returning-to-production-and-scna-2013-sponsorship` | Mike Hall: Returning to Production (Update #1) | Production | `/Volumes/Dock_1TB/WITC/TBD/WHOIS Tech Community - 198.mp4` |
| 27 | `ugtastic-update-2-community-stickers-and-eve-of-scna-2013` | Mike Hall: Community Stickers (Update #2) | Production | `/Volumes/Dock_1TB/WITC/TBD/WHOIS Tech Community - 197.mp4` |

---

### Category D: External Platform Only (1 Video)
| # | Asset ID | Title | Platform | External Link |
|---|---|---|---|---|
| 28 | `pechakucha-teach-yourself-beginning-community-in-24-months-2` | Teach Yourself Beginning Community in 24 Months | PechaKucha | [pechakucha.com/presentations/...](https://www.pechakucha.com/presentations/teach-yourself-beginning-community-in-24-months-2) |

---

## 4. YouTube Resumable Upload Workflow (`TASK-264`)

To upload remaining masters to YouTube:

1. **Verify OAuth Channel:** `ruby -e 'require_relative "bin/lib/youtube_client"; puts YouTubeClient.new.get_channel_info["snippet"]["title"]'`
2. **Execute Resumable Batch Upload:**
   ```bash
   ruby bin/upload_youtube_video.rb --file "/Volumes/Dock_1TB/vimeo/videos/Denver_Community_w_Charler_Baker_32391086.mp4" --asset-id charler-baker-denver-community-software-craftsmanship-north-america-2011
   ```
3. **Attach Subtitle Tracks:** Post the existing `.vtt` file from `assets/subtitles/<transcript_id>.vtt` to YouTube Data API captions endpoint.
4. **Update Platform Record:** Append `platform: youtube` and set `primary_platform: youtube` in `_data/video_assets.yml`.

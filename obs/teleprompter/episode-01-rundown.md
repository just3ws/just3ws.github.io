# The Sound Above: Episode 01 Rundown & Rewatch Cue Sheet

**Episode:** 01 - Sergio Pereira and Chicago Alt.NET  
**Movement:** Movement 1: The Chicago Workshop  
**Channel:** Mike Hall (`@just3ws-mike`)  
**Series Playlist:** [The Sound Above (`PLVcmLmfz2uyA`)](https://www.youtube.com/playlist?list=PLVcmLmfz2uyA)  
**Target Length:** ~25 to 30 minutes (5-7m intro, ~14m unscripted rewatch with pauses, 4-5m synthesis & outro)

---

## 1. Quick Links & Broadcast Assets

- **Textream Teleprompter Script:** [`obs/teleprompter/episode-01.textream`](episode-01.textream)
- **Episode 01 Companion Page:** `https://www.just3ws.localhost/series/the-sound-above/episode-01/` ([public](https://www.just3ws.com/series/the-sound-above/episode-01/))
- **Interactive Transcript (44 turns, 13 chapters):** `https://www.just3ws.localhost/interviews/sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011/`
- **Source Recording (YouTube, 14m):** [Sergio Pereira at SCNA 2011 (`qOHdZKz1WFw`)](https://www.youtube.com/watch?v=qOHdZKz1WFw)
- **Signatory Network Map (#106 Mike / #592 Sergio):** `https://www.just3ws.localhost/reports/software-craftsmanship-forensics/signatory-network/`
- **Chicago Code Camp Retrospective (`just3ws/ccs`, 24 commits):** `https://www.just3ws.localhost/ai/2026/11/18/chicago-code-camp-2012-code-camp-server-retrospective/`
- **Contemporary 2008-2009 Blog Posts:**
  - [Aug 5, 2008: Sergio Pereira on Devlicio.us (Wayback, Nov 14, 2011)](https://web.archive.org/web/20111114202141/http://devlicio.us/blogs/sergio_pereira/archive/2008/08/05/august-s-chicago-alt-net-meeting-on-the-13th.aspx)
  - [Aug 11, 2008: Upcoming Chicago Alt.NET Meeting](https://www.just3ws.localhost/2008/08/11/upcoming-chicago-alt-net-meeting-on-august-13th.html)
  - [Aug 14, 2008: August 13th Meeting Review (Cruise CI)](https://www.just3ws.localhost/2008/08/14/chicago-alt-net-meeting-august-13th-meeting-review.html)
  - [Aug 21, 2008: Video Recorded by Sergio Pereira](https://www.just3ws.localhost/2008/08/21/video-from-chicago-alt-net-meeting.html)
  - [Mar 12, 2009: Fishbowl Recap (DDD & db4o)](https://www.just3ws.localhost/2009/03/12/chicagoalt-net-march-meeting-recap.html)
  - [Apr 25, 2009: twatio.com /Home/About (Wayback - ASP.NET MVC & SubSonic)](https://web.archive.org/web/20090425135438/http://twatio.com:80/Home/About)
  - [Nov 2008 Chicago Alt.NET Wayback Capture (NHaml & Spark)](https://web.archive.org/web/20081101091417/http://www.chicagoalt.net/Home)

---

## 2. Pre-Flight Checklist

1. **OBS Profile:** Select `The Sound Above - Staging` for test run (or `The Sound Above` for production). Both record to `/Users/mike/ai/media-pipeline/just3ws-mike/the-sound-above/staged/`.
2. **OBS Scene Collection:** `The Sound Above - UGtastic Rewatch` (Split Screen locked to `910x1080` left/right at `y=0`).
3. **macOS Camera Effect:** Green camera menu bar icon -> **OBS** -> **Background** ON (Portrait OFF), Craftsman backdrop active on Logitech C920.
4. **Audio Check:** Track 1 (Mix), Track 2 (Mic isolated), Track 3 (Chromium `sck_audio_capture` isolated). Do a 10-second test recording and verify both mic and Chromium audio play back cleanly without echo.
5. **Overlay State:** `obs/overlays/overlay-state.json` is cued to Episode 1 (`Sergio Pereira`, `SCNA 2011`, `Mike Hall (@just3ws-mike)`).
6. **Textream:** Load `obs/teleprompter/episode-01.textream`.
7. **Chromium Tabs (Left Window: Canonical Interview | Right Window: Research):**
   - Left Window (Scene 03 / 04): `https://www.just3ws.localhost/interviews/sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011/` (canonical hosted interview with YouTube-backed player, 13 chapters, and 44-turn diarized transcript - driven directly by the 3-Pane Broadcast Workbench).
   - Right Window (Scene 04): Tab 1 = Nov 2008 Wayback (`chicagoalt.net`), Tab 2 = Signatory Network Map, Tab 3 = Chicago Code Camp Retrospective (`just3ws/ccs`), Tab 4 = `twatio.com/Home/About` (Apr 25, 2009 Wayback).

---

## 3. Episode Structure & Act-by-Act Flow

### Part A: Scripted Intro & Context (Acts 1-3 in Textream, ~5-7 min)
- **Scene 01 (`Starting Soon`) -> Scene 02 (`Monologue / Full Camera`):**
  - **Act 1 (Cold Open - Scripted):** SCNA 2011 at Swissotel Chicago (Nov 19, 2011), Photo Booth on a 15-inch unibody MacBook Pro. Personal arc: Chicago Alt.NET was the first user group where you ever gave a talk; Aug 13, 2008 was your first Chicago Alt.NET meeting off the Metra UP-NW from Crystal Lake where Sergio recorded *you* in the audience; 3 years later you traded places.
  - **Act 2 (Setting the Scene - Scripted):** What Chicago Alt.NET was (working devs improving craft, not ideology), April 2007 Alt.NET Manifesto, late 2007 launch (Derik Whittaker, John Nuechterlein (jdn); later Eduardo Scoz), 2nd Wednesday 6:30 PM at Redpoint in Sears Tower, 25-person room, your first talk on NHaml (Nov 12, 2008) beside Adam Tybor on Spark.
  - **Act 3 (Three Archival Clicks - Scripted + brief Scene 04 Split Screen):**
    1. Fishbowl debates (Mar 12, 2009 blog recap: Adam Tybor DDD + Sergio `db4o`).
    2. `twatio.com` empirical Twitter overlap test (later redirected to `ugtastic.com`).
    3. Chicago Code Camp (`just3ws/ccs`): Sergio is Manifesto Signatory `#592` (Grayslake, IL) and #2 contributor with **24 Ruby/Haml/Sass commits** alongside your 764 commits.

---

### Part B: Unscripted Rewatch Guide (Act 4, ~14 min + pauses - NO SCRIPT NEEDED)

Switch to **Scene 03 (`Reaction - Video Focus`)** and press `Spacebar` on `qOHdZKz1WFw` at `00:00`. Switch to **Scene 04 (`Split Screen`)** whenever you want to pull up a transcript quote or archive artifact.

#### Timestamped Watch-For Table & Pause Triggers

| Timestamp | What Sergio Says | Context & Pause Triggers (Keep an Eye Out For) | Visual / Tab to Pull Up (Optional) |
| :--- | :--- | :--- | :--- |
| **`00:00`** | Resists defining Alt.NET as a label; focuses on continuous improvement | Notice his tone: pragmatic, zero gatekeeping. Good spot to let it roll and settle into the 2011 Photo Booth energy. | Scene 03 (Full Video) |
| **`02:19`** | 2nd Wednesday at 6:30 PM at Redpoint Technologies (Sears Tower) | **Pause trigger:** Logistics as community design. 6:30 PM bridged Loop workers and Metra commuters catching the 8:30 PM train back to Crystal Lake. | Aug 2008 Blog Post |
| **`03:06`** | ~25-person room; cultivating first-time speakers from work talks | **Pause trigger:** Why 25 people is the magic number (big enough for energy, small enough not to terrify a first-time speaker). Tie back to your Nov 12, 2008 NHaml talk. | Nov 2008 `chicagoalt.net` Wayback |
| **`05:17`** | Your thank-you to Sergio; late 2007 origin with Derik Whittaker & John Nuechterlein (jdn); Microsoft adopting MVC & jQuery | **Context tip:** Watch how warmly he receives the thank-you and immediately credits co-founders. Notice the historical shift from WebForms to ASP.NET MVC. | Transcript turn |
| **`07:09`** | Seeing TDD, BDD, NHibernate, IronRuby, and judging for yourself | **Key quote (Transcript line 145):** *"That's the place that they can come, see those things, and judge for themselves if it's going to work for them or not."* Anchor for Act 5's AI-era echo. | Scene 04: Interactive Transcript |
| **`10:29`** | Non-.NET regulars, Kanban, and Chicago Code Camp | **Best Split Screen moment:** Pull up the `just3ws/ccs` retrospective and Signatory Network Map (`#592` Grayslake, 24 Ruby on Rails commits). He lived what he said. | Scene 04: `just3ws/ccs` & Signatory Map |
| **`11:42`** | Redpoint pizza sponsorship, open projector nights, Fishbowl debates, curating with Eduardo Scoz vs. ChicagoRuby | **Pause trigger:** Mention the Mar 12, 2009 4-chair Fishbowl (DDD + `db4o`). His shout-out to ChicagoRuby naturally bridges into **Episode 2 (Ray Hightower)**! | Mar 12, 2009 Blog Post |

#### Rewatch Preparation & Pacing Tips
- **Let Sergio finish his sentence before pausing:** Leave a half-second beat after his thought lands, hit `Spacebar`, react naturally, then resume. That makes future clip/Short extraction in `media-pipeline` super clean.
- **No need to pause at every timestamp:** Pick the 3 to 4 moments that genuinely spark a memory or reaction in the moment. If a section is flowing well, let it play.
- **Keep keyboard focus on the Chromium video window** during Scene 03 so `Spacebar` always pauses/plays reliably (and `J`/`L` jumps 10s if you want to replay a great line).
- **Audio hygiene:** Stay quiet while Sergio is speaking unless you pause, so Track 2 (your mic) and Track 3 (interview audio) stay clean and separable.

---

### Part C: Scripted Synthesis & Outro (Acts 5-6 in Textream, ~4-5 min)
- **Scene 02 (`Monologue`) or Scene 05 (`Workbench`):**
  - **Act 5 (Synthesis - Scripted):** The 15-year transcription arc (`many-hands-make-light-work` 2014 -> 5 Raspberry Pis `fluffle` 2023 -> Apple Silicon local `media-pipeline` 2026). Echo of line 145: WebForms wizards (2008) vs. plausible AI code (2026) - no vendor default replaces peer rooms and empirical verification.
- **Scene 08 (`Outro & Next Stream`):**
  - **Act 6 (Outro - Scripted):** Thank Sergio Pereira, point viewers to Episode 1 page on `just3ws.com`, invite comments/corrections from anyone who was at ThoughtWorks, Redpoint, Chicago Code Camp, or SCNA, mention `just3ws.com/support`, tease **Episode 2 (Ray Hightower & ChicagoRuby)**, sign off.

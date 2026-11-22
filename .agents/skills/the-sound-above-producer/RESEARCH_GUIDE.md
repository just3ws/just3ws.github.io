# The Sound Above: Deep Research & Archival Forensics Guide

This guide details the research methodology required before drafting any episode of **The Sound Above** (`@just3ws-mike`, playlist `PLVcmLmfz2uyA`) or its companion **Errata** series (playlist `PLKPAHha6I990`).

The goal of deep research is not nostalgia. It is to recover grounded historical evidence so every broadcast is anchored in verified dialogue turns, exact-date Wayback captures, git commit receipts, and community logistics.

---

## 1. The 4 Stages of Episode Research

```
  Stage 1: Transcript Forensics & Ear-Checking
  ├── Audit _data/transcripts/<slug>.yml
  ├── Flag Whisper mishearings & phonetic catches
  └── Extract dialogue turns for pause triggers
         │
         ▼
  Stage 2: Primary-Source Archival Recovery (Wayback CDX)
  ├── Search exact HTTP 200 captures (2007-2015)
  ├── Verify snapshot integrity (no wildcard captures)
  └── Pin 3 archival receipts for Act 3 / Split Screen
         │
         ▼
  Stage 3: Physical & Code Forensics
  ├── Inspect legacy git repos (commit logs, author stats)
  ├── Map Software Craftsmanship Manifesto signatories
  └── Retrieve historical blog posts and meeting recaps
         │
         ▼
  Stage 4: Narrative Spine & 2026 AI-Era Echo
  ├── Define the core inquiry (logistics over dogma)
  └── Connect historical craftsmanship to current AI practice
```

---

## 2. Stage 1: Transcript Forensics & Ear-Checking

Every episode centers on a historical interview from the archive. Before writing the script:

1. **Locate the Transcript Dossier**:
   - Transcripts live in `just3ws.github.io/_data/transcripts/<slug>.yml`.
   - Verify that the transcript contains dialogue turns with speaker attributions (`Mike Hall` and the interviewee) and start/end timestamps.
2. **Conduct the Phonetic Ear-Check**:
   - Machine transcription (Whisper) frequently mishears proper nouns, developer handles, and era-specific terminology.
   - *Example from Episode 1*: Whisper transcribed John Nuechterlein as `jdn` or a phonetic scramble. Cross-referencing `chicagoalt.net/Home/About` from November 2008 confirmed John Nuechterlein was a founding co-organizer alongside Derik Whittaker.
   - *Example from Episode 2*: Whisper transcribed a ChicagoRuby organizer's name with an audio loop after `06:25`. Ear-checking before recording prevents quoting looped machine hallucinations.
3. **Select 3-5 Anchor Rewatch Cues**:
   - Identify moments where the interviewee says something surprising, counter-intuitive, or operationally revealing.
   - Note the exact time (`MM:SS`) and calculate seconds for the rewatch cue board:
     ```yaml
     rewatch_cues:
       - time: "02:19"
         seconds: 139
         label: "The Second Wednesday at 6:30 PM"
         guest_says: "Meeting monthly at Redpoint Technologies in the Sears Tower..."
         watch_for: "Pause trigger: Logistics as community design (Loop workers + 8:30 PM Metra to Crystal Lake)."
     ```

---

## 3. Stage 2: Primary-Source Archival Recovery (Wayback CDX)

Every external historical link displayed on screen or linked on the episode page must be pinned to an immutable, exact-capture HTTP 200 Wayback Machine URL.

### Non-Negotiable Rule: No Wildcard Captures
Never use wildcard URLs (such as `web.archive.org/web/*/http://...`) or unverified search URLs. Wildcard captures can redirect to HTTP 404, robots.txt exclusions, or modern domain-squatter pages.

### CDX Lookup Query Pattern
To find clean HTTP 200 captures from the era (2007-2015), run:

```bash
curl -s "https://web.archive.org/cdx/search/cdx?url=<TARGET_URL>&output=json&fl=timestamp,original,statuscode,length&filter=statuscode:200&from=2007&to=2015&limit=10"
```

### Verification Criteria
When inspecting a capture candidate:
1. **Status Code**: Must be HTTP `200`.
2. **Page Content**: Open the URL in a browser. Ensure the content was rendered by the crawler (not an empty JavaScript shell).
3. **Era Alignment**: Prefer captures dated within 30 days of the recorded event or meeting being discussed.
4. **Pinning Format**:
   `https://web.archive.org/web/<14-DIGIT-TIMESTAMP>/<ORIGINAL_URL>`
   *(Example: `https://web.archive.org/web/20111101093510/http://chicagoruby.org:80/`)*

---

## 4. Stage 3: Physical & Code Forensics

Oral history becomes compelling when backed by contemporary physical and digital records:

1. **Software Craftsmanship Manifesto Signatory Ledger**:
   - Check the Manifesto signatory database (`/reports/software-craftsmanship-forensics/signatory-network/`).
   - Identify the exact signatory number, signing date, and location.
   - *Example*: Mike Hall is Signatory #106 (Crystal Lake, IL); Sergio Pereira is Signatory #592 (Grayslake, IL).
2. **Historical Git Forensics**:
   - Resurrect relevant historical repositories (e.g., `just3ws/ccs` for Chicago Code Camp).
   - Run `git shortlog -sn` and `git log --author="<name>"` to discover actual commit counts and code contributions.
   - *Example*: Finding that Sergio Pereira was the #2 contributor to the Ruby on Rails `just3ws/ccs` repository with 24 commits demonstrated that his commitment to multi-platform craft was lived code, not talk.
3. **First-Hand Blog Archives**:
   - Search Mike's 2007-2015 blog posts (`_posts/`) for meeting announcements, trip notes (e.g., Metra train commutes), and recap articles.
   - Contemporary recaps provide exact attendee counts, debate topics, and pizza sponsor details that make the narrative vivid.

---

## 5. Stage 4: Narrative Spine & 2026 AI-Era Echo

Every episode must connect past craftsmanship lessons to the present day:

1. **Theme**: The overarching human or technical principle (e.g., *Community Hospitality & Radical Practitioner Inclusion*).
2. **Core Inquiry**: A focused question driving the rewatch:
   - *Wrong*: "What did Sergio talk about in 2011?"
   - *Right*: "What made people come back to Chicago Alt.NET, and how did a monthly room of twenty-five developers cultivate first-time speakers across platform boundaries?"
3. **Chicago Context**: Ground the community in its physical geography (e.g., Redpoint in the Sears Tower, Midway Restaurant diner meetings, Franklin Park Library, ThoughtWorks downtown).
4. **AI-Era Parallel**:
   - How does the historical transition mirror today?
   - *Example*: In 2008, vendor defaults were drag-and-drop WebForms wizards that hid HTTP and hindered testing; in 2026, defaults are often generative AI code synthesis tools that output plausible code while obscuring domain boundaries. In both eras, engineers require trusted peer rooms and empirical verification.

---

## 6. Research Hand-Off Checklist

Before passing research to the scriptwriter:
- [ ] Diarized transcript audited and phonetic mishearings caught.
- [ ] 3-5 high-conviction rewatch cues chosen with exact seconds calculated.
- [ ] 3 era-specific HTTP 200 Wayback receipts verified without wildcards.
- [ ] Primary code or signatory receipts checked and cross-referenced.
- [ ] Core inquiry and 2026 AI-era parallel framed.
- [ ] Companion Errata deep-dive topics identified.

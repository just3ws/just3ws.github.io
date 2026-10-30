# Data Structures and Schema Definitions

## The Sound Above: Livestream Toolchain Contracts

This document specifies the data models, state persistence patterns, and schema definitions governing the livestreaming toolchain.

---

## 1. Schema Inventory

All declarative data in this project is bounded by JSON Schema draft 2020-12 definitions located in `obs/schemas/`:

| Schema File | Target Data File | Primary Purpose |
| :--- | :--- | :--- |
| `obs/schemas/overlay-state.schema.json` | `obs/overlays/overlay-state.json` | Real-time browser source HUD state |
| `obs/schemas/sequence-manifest.schema.json` | `obs/curation/sequence-manifest.json` | Archive map; first 17 interviews form the Season One working plan |
| `obs/schemas/obs-scene-collection.schema.json` | `obs/scenes/ugtastic-sound-above.json` | OBS Studio 33 production scene contract |

---

## 2. Overlay State Data Structure

The file `obs/overlays/overlay-state.json` serves as the single source of truth for active broadcast overlays. Browser sources (`lower-third.html`, `now-watching.html`, `stream-starting.html`) poll this file every 2.5 seconds.

### Data Model

```json
{
  "broadcast_type": "rewatch",
  "episode": {
    "number": 1,
    "title": "Sergio Pereira and Chicago Alt.NET",
    "interviewee": "Sergio Pereira",
    "role": "Chicago Alt.NET Organizer",
    "conference": "SCNA 2011",
    "location": "Chicago, IL",
    "year": "2011",
    "era": "The Chicago Workshop",
    "sound_above_prompt": "What made people come back to Chicago Alt.NET?",
    "companion_links": [
      "https://just3ws.localhost/timeline/community/",
      "https://just3ws.localhost/scmc/"
    ]
  },
  "stream": {
    "series_title": "The Sound Above",
    "series_subtitle": "UGtastic Rewatch: Learning About People in Tech (2009–2026)",
    "host": "Mike Hall (Software Craftsmanship #106)",
    "status": "live",
    "topic": "Rewatching Sergio Pereira at SCNA 2011: Chicago Alt.NET"
  },
  "errata": {
    "mode": "reading",
    "title": "The Cat Ate My Source Code",
    "subtitle": "Marginalia & Systems Study",
    "citation": "The Pragmatic Programmer (1999)",
    "excerpt_or_thesis": "Provide options, don't make lame excuses.",
    "artifact_year": "1999"
  },
  "dialogue": {
    "guests": [
      {
        "name": "Ryan Gerry",
        "role": "Co-Founder, SCMC",
        "affiliation": "Follett / Suburban Craftsmanship"
      }
    ],
    "topic": "17 Years of Sub-Second Feedback Loops",
    "prompt": "How did suburban craftsmanship sustain continuous monthly meetings for 17 years?"
  }
}
```

### Broadcast Archetypes

1. **`rewatch` (The Sound Above)**: Oral history rewatch and forensic reaction. Drives `episode` fields, archival timeline cross-referencing, and historical questions.
2. **`errata` (Errata Solo / Marginalia)**: Personal insights, book readings, architectural concept breakdowns, code demonstrations, and physical artifact shows. Drives `errata` fields (`mode`, `citation`, `excerpt_or_thesis`).
3. **`dialogue` (The Room / Invitational Conversations)**: Collegial discussions, pair workbench investigations, and community roundtables. Drives `dialogue` fields (`guests`, `topic`, `prompt`).

### Field Definitions

- `broadcast_type` (Enum): `rewatch`, `errata`, `dialogue`.
- `errata.mode` (Enum): `reading`, `concept`, `demo`, `story`, `artifact`.
- `episode.number` (Integer, >= 1): Sequence number matching the manifest.
- `episode.title` (String): Episode title displayed on title cards and lower thirds.
- `episode.interviewee` (String): Full name of the featured practitioner.
- `episode.role` (String): Professional or historical role description.
- `episode.conference` (String): Event where the interview was originally captured.
- `episode.year` (String, 4 digits): Recording year.
- `episode.era` (String): Historical movement identifier.
- `episode.sound_above_prompt` (String): Core inquiry into early influences and inspirations.
- `stream.status` (Enum): `starting`, `live`, `brb`, `ended`.

---

## 3. Sequence Manifest Data Structure

The file `obs/curation/sequence-manifest.json` maps 35 candidate interviews across six chronological and thematic movements. The current Season One working plan covers Episodes 1 through 17. The rest remain candidates, not a release commitment.

1. `the-chicago-workshop`: The Chicago Workshop
2. `practice-and-dojo`: The Practice and the Dojo
3. `human-communication-layer`: The Human Communication Layer & Inclusion
4. `philosophy-and-empathy`: Philosophy, Empathy & Craftsmanship
5. `architecture-testing-discipline`: The Architecture & Testing Discipline
6. `observable-control-plane`: The AI Horizon & The Observable Control Plane

### Episode Record Schema

```json
{
  "number": 1,
  "era_id": "the-chicago-workshop",
  "era_name": "The Chicago Workshop",
  "interviewee": "Sergio Pereira",
  "slug": "sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011",
  "conference": "SCNA 2011",
  "year": 2011,
  "location": "Chicago, IL",
  "title": "Sergio Pereira and Chicago Alt.NET",
  "sound_above_inquiry": "What made people come back to Chicago Alt.NET?",
  "chicago_context": "A monthly group where members shared talks and discussed software beyond .NET.",
  "ai_era_parallel": "Engineers still benefit from places to share work, ask questions, and judge new tools together.",
  "companion_video": "None (Primary Oral History Focus)",
  "status": "cued"
}
```

---

## 4. State Synchronization Flow

```
[sequence-manifest.json]
         |
         v
[obs/scripts/update-overlay-state.sh --episode N]
         |
         v
[overlay-state.json] <------- Polled every 2.5s by JavaScript controller
         |
         +----> [lower-third.html]     (OBS Scene 02, 03, 04, 05, 06)
         +----> [now-watching.html]    (OBS Scene 03)
         +----> [stream-starting.html] (OBS Scene 01)
         +----> [stream-brb.html]      (OBS Scene 07)
         +----> [stream-outro.html]    (OBS Scene 08)
```

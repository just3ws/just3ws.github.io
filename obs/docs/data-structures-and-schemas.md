# Data Structures and Schema Definitions

## The Sound Above: Livestream Toolchain Contracts

This document specifies the data models, state persistence patterns, and schema definitions governing the livestreaming toolchain.

---

## 1. Schema Inventory

All declarative data in this project is bounded by JSON Schema draft 2020-12 definitions located in `obs/schemas/`:

| Schema File | Target Data File | Primary Purpose |
| :--- | :--- | :--- |
| `obs/schemas/overlay-state.schema.json` | `obs/overlays/overlay-state.json` | Real-time browser source HUD state |
| `obs/schemas/sequence-manifest.schema.json` | `obs/curation/sequence-manifest.json` | Curated 21-episode historical roadmap |
| `obs/schemas/obs-scene-collection.schema.json` | `obs/scenes/ugtastic-sound-above.json` | OBS Studio 32 production scene contract |

---

## 2. Overlay State Data Structure

The file `obs/overlays/overlay-state.json` serves as the single source of truth for active broadcast overlays. Browser sources (`lower-third.html`, `now-watching.html`, `stream-starting.html`) poll this file every 2.5 seconds.

### Data Model

```json
{
  "episode": {
    "number": 1,
    "title": "The First Room: Chicago Alt.NET & Escaping Corporate Monoliths",
    "interviewee": "Sergio Pereira",
    "role": "Founder, Chicago Alt.NET",
    "conference": "SCNA 2011",
    "location": "Chicago, IL",
    "year": "2011",
    "era": "The Chicago Crucible (2008–2010)",
    "sound_above_prompt": "Who inspired the engineers breaking free from enterprise Microsoft silos? How did grassroots peer groups form before commercial developer platforms existed?",
    "companion_links": [
      "https://just3ws.localhost/timeline/community/",
      "https://just3ws.localhost/scmc/"
    ]
  },
  "stream": {
    "series_title": "The Sound Above",
    "series_subtitle": "UGtastic Oral History Rewatch & Craftsmanship in the Age of AI",
    "host": "Mike Hall (Signatory #106)",
    "status": "live",
    "topic": "Rewatching Sergio Pereira (SCNA 2011): Community Before Platforms"
  }
}
```

### Field Definitions

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

The file `obs/curation/sequence-manifest.json` defines the entire 21-episode curriculum across five chronological and thematic movements:

1. `chicago-crucible`: The Chicago Crucible (2005–2010)
2. `practice-and-dojo`: The Practice and the Dojo (2010–2012)
3. `philosophy-and-discovery`: The Philosophy and Deliberate Discovery (2012–2014)
4. `reckoning`: The Architecture and Testing Reckoning (2014–2016)
5. `ai-horizon`: The AI Horizon and The Observable Control Plane (2026)

### Episode Record Schema

```json
{
  "number": 1,
  "era_id": "chicago-crucible",
  "era_name": "The Chicago Crucible (2005–2010)",
  "interviewee": "Sergio Pereira",
  "slug": "sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011",
  "conference": "SCNA 2011",
  "year": 2011,
  "location": "Chicago, IL",
  "title": "The First Room: Chicago Alt.NET & Escaping Corporate Monoliths",
  "sound_above_inquiry": "Who inspired the engineers breaking free from enterprise Microsoft silos? How did grassroots peer groups form before commercial developer platforms existed?",
  "chicago_context": "Chicago Alt.NET was the precursor room for dozens of Chicago developers who later founded startups, consultancy practices, and user groups.",
  "ai_era_parallel": "Just as Alt.NET questioned monolithic enterprise frameworks, modern engineers must question monolithic cloud AI abstractions and reclaim local control.",
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

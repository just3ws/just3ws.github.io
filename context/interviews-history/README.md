# UGtastic Archive Extraction

**Extracted:** 2026-02-03
**Source:** `/Volumes/Dock_1TB/WITC/`
**Destination:** Homepage catalog rebuild

---

## Contents

### `/transcripts/` (196 files)
Clean text transcripts converted from YouTube auto-captions (TTML).
- One `.txt` file per interview
- Filenames are slugified (lowercase, underscores)
- Ready for full-text search indexing

**Notable transcripts:**
- `interview_with_rich_hickey_creator_of_clojure_at_goto_chicago_2013.txt`
- `interview_with_david_heinemeier_hansson_dhh_at_railsconf_2014.txt`
- `interview_with_chad_fowler_founder_rubyconf_railsconf.txt`
- `gary_bernhardt.txt` (SCNA 2012)
- `robert_martin.txt` (Uncle Bob)
- `avdi_grimm.txt`

### `/articles/` (4 files)
Original written content:
- `gary_bernhardt_interview.md` - Full transcript with speaker labels
- `360_learning_at_user_groups.md` - Blog post about UG learning
- `tribune_tech_interview.md` - Jen Lindner & Milan Dobrota
- `dean_wampler_bio.md` - Speaker bio

### `/metadata/` (258 files)
JSON metadata from Vimeo (94) and YouTube (164):
- Video URLs, IDs, thumbnails
- Upload dates, durations
- Descriptions

### `/catalog.json`
Master index with 249 entries:
```json
{
  "title": "Interview with Rich Hickey...",
  "subject": "Rich Hickey",
  "event": "GOTO Chicago 2013",
  "source": "youtube",
  "youtube_id": "...",
  "has_transcript": true
}
```

### `/catalog.csv`
Spreadsheet-friendly format:
```
subject,event,source,has_transcript
"Rich Hickey","GOTO Chicago 2013",youtube,yes
```

### `/video-asset-canonical-map.tsv`
Canonical YouTube ID mapping used for cautious dedupe application:
- `winner` rows are canonical IDs for merged duplicates
- `alias_to_winner` rows preserve secondary IDs as alternates
- `keep_both` rows explicitly preserve separate interviews

### `/goto-official-playlists.md`
Reference list of official GOTO Conference YouTube playlists for interview years.

---

## For Homepage Import

### Option 1: Direct file import
Copy `/transcripts/` and `/articles/` to your site's content directory.

### Option 2: Database import
Parse `catalog.json` to populate interview records, then link transcripts by slug.

### Option 3: Static site generator
Use `catalog.json` as data source, templates render each interview page with transcript content.

---

## Processing Scripts

- `convert_ttml.py` - TTML to text converter (already run)
- `build_catalog.py` - Catalog builder (already run)

---

## Source Files (not in _output)

Original TTML files: `/consolidated/Uploads from WHOIS Tech Community/`
Original video files: `/BUCKET/`, `/Vimeo/`, `/YouTube/`

---

## Stats

| Type | Count |
|------|-------|
| Total interviews | 249 |
| With transcripts | 196 |
| With video | ~200+ |
| Events covered | 10+ |
| Years spanned | 2012-2015 |

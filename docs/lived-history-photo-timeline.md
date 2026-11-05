# Lived History Photo Timeline

The public route `/timeline/lived-history/` combines first-person recollections
with photographs and links into the existing community and career archive. Its
event content lives in `_data/lived_history_timeline.yml`; the additional
event-gallery index lives in `_data/lived_history_galleries.yml`.

## Curation and provenance

- The Google Photos ZIP exports stay in the operator's local archive. Never add
  ZIPs to this repository. Mike's direct account establishes his authorship,
  provenance, and intended use of these event photographs.
- Every displayed photograph is an optimized derivative under
  `assets/images/lived-history/`. The derivative is rotated according to the
  source orientation, resized, and saved without embedded EXIF or GPS.
- Keep optimized event photographs in ordinary Git so GitHub Pages can serve them.
  GitHub Pages does not support Git LFS for site assets. Keep each derivative
  small (roughly 500 KB or less where image quality allows); source albums and
  unreviewed exports stay in the local archive, outside the site repository.
- Use `date_evidence`, `location_evidence`, and `source` to say whether a detail
  comes from original EXIF, a filename or album title, a public site record, or
  Mike's recollection. A filename date is not an event date unless the evidence
  supports that interpretation.
- Keep event dates distinct from photo capture dates. For example, the TicketsNow
  notes were photographed later than the teaching period they describe.
- Credit photos to Mike Hall. Use the `alt` field to describe what the selected
  photo actually shows; do not infer the identity of people from appearance.
- Keep personal identifiers, service cards, and unreviewed workplace material
  out of the public archive. For workplace communities, use already-public
  summaries until the photos and notes have been cleared for publication.
- Treat family photos and newspaper clippings as separate editorial choices:
  use only selected, privacy-reviewed derivatives, and summarize archival
  context instead of reproducing copyrighted articles.
- For future video assets, retain the source's exact YouTube publication
  timestamp and timezone in `published_at` when available. The structured-data
  fallback uses midnight UTC only when the archive has a calendar date but no
  time; that is a date-precision marker, not a claim about the actual upload
  minute. For photos, retain the original capture time and timezone in local
  provenance notes when known, but publish only the evidence-supported date
  and a rounded location.
- Consolidate duplicate exports as one historical event. Do not turn repeated
  Google Photos copies into multiple timeline entries.
- Do not publish meeting notes whose project, audience, or publication status
  is unclear. Record their existence locally and revisit after the context is
  established.

## Adding an album

1. Review the album title, member count, media types, and dates without changing
   the source archive.
2. Group photographs under their event and consolidate repeated exports and
   visually duplicate frames. Preserve the breadth of albums Mike supplied for
   this history; galleries are collapsed by default so the timeline remains
   easy to scan.
3. Confirm each caption against the photo, album, existing public records, or
   Mike's recollection. Keep uncertain venue, event, and speaker details open.
4. Create a small local web derivative with orientation corrected and EXIF/GPS
   removed. Keep the source ZIP outside Git.
5. Add an event to `_data/lived_history_timeline.yml` with a stable `id`, ISO
   `date_sort`, reader-facing `date_display`, evidence fields, first-person
   narrative, photo alt text, and source album name. Add additional images to
   the matching `event_id` in `_data/lived_history_galleries.yml`.
6. Build and install the site, then inspect the timeline and source links.

`bin/import-photo-album` handles shared Google Photos URLs, not local ZIP files.
It is not the import path for this local album collection.

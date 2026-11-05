# Timeline context research and implementation

Reviewed November 5, 2026. This is an editorial and engineering decision record,
not a claim that the whole archive has been independently verified.

## Surface and job

Help readers follow Mike's projects through photographs, recollections,
interviews, and work records. Preserve the complete chronology while giving
new visitors shorter paths through it.

## Design read

Reading this as a personal historical exhibit for practitioners and curious
visitors, using the existing paper, ink, teal, and editorial typography.
Keep professional inquiries and voluntary project support distinct.

## Mode and dial movement

Preserve the existing composition and photo archive. Add a bounded orientation
layer, with no new timeline engine or dependency.

| Dial | Before | Target | Reason |
| --- | --- | --- | --- |
| Variance | 3 | 3 | Keep the established reading order and layout. |
| Motion | 1 | 1 | Native disclosures and links need no animation. |
| Density | 7 | 6 | Short guided paths precede the complete archive. |

## Research and applications

These applications are design judgments informed by the linked sources. They
are not claims that the site implements the standards in full.

| Principle | Primary reference | Applied here |
| --- | --- | --- |
| Give the reader a manageable story through a large chronology. | [Knight Lab TimelineJS best practices](https://github.com/NUKnightLab/TimelineJS#best-practices) | Four short editorial threads point into the existing records. All events remain available. |
| Offer different depths of information. | [Smithsonian accessible exhibition guidelines](https://www.sifacilities.si.edu/sites/default/files/Files/Accessibility/accessible-exhibition-design1.pdf) | Titles and narratives remain visible; sources, indexes, and galleries use disclosures. |
| Distinguish date precision and uncertainty. | [Library of Congress EDTF specification](https://www.loc.gov/standards/datetime/edtf.html) | Explain the difference between an event, a photograph, and publication. Preserve existing approximate labels. No EDTF parser or conformance claim is added. |
| Preserve source and transformation separately. | [W3C PROV Primer](https://www.w3.org/TR/prov-primer/) | Keep source notes beside the narrative and explain derivative photographs. Recorded sources do not imply independent confirmation. |
| Make disclosures usable from the keyboard. | [W3C disclosure pattern](https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/) | Use native details/summary, visible focus, and no JavaScript dependency for browsing. |
| Describe images according to their actual information and purpose. | [W3C images tutorial](https://www.w3.org/WAI/tutorials/images/) | Retain reviewed selected-photo descriptions; explicitly disclose incomplete gallery descriptions. Do not fabricate 670 individual captions. |
| Give annotations stable targets. | [W3C Web Annotation model](https://www.w3.org/TR/annotation-model/) | Keep event IDs, expose links to events, and provide correction routes. Image and timed-media annotations are a later stage. |
| Keep media and interpretation separate. | [IIIF Presentation API](https://iiif.io/api/presentation/3.0/) | Keep photos, event narratives, and source notes distinct. IIIF export is an option, not a launch dependency. |

## Timeline forms and their useful jobs

| Form | Useful question | Fit and sequencing |
| --- | --- | --- |
| Chronological record | What happened, and what can we date? | Existing foundation. Keep uncertain dates readable. |
| Short guided story | Where should a new reader begin? | Applied now with four threads. |
| Project lifecycle | How did an idea become a working project? | Collect dated milestones for Phalanx Duel and other projects first. One notebook photograph does not establish a complete lifecycle. |
| Parallel lanes | What was happening across projects at once? | Extend the existing main timeline after reconciling shared records. Overlap does not establish influence. |
| Relationship view | Which people, communities, and artifacts connect? | Use typed, sourced relationships. Separate participation, authorship, recollection, and editorial association. |
| Geographic view | Where did the public gatherings happen? | Use established venues or city-level locations. Keep private addresses and precise photo GPS private. |
| Oral-history view | What was said about this moment? | Link exact transcript passages and timecodes after verification. |
| Image exhibit | What does this particular photograph show? | Inspect images, write specific descriptions, and link observations to stable image IDs. |
| Evidence ledger | What supports each claim? | Event-level notes exist. Expand to claim-level citations where readers need them. |
| Revision history | What changed in our understanding? | Add dated corrections with their sources when substantive corrections accumulate. |

## Preserve

Implementation evidence and naming follow the local stack: existing
`lived-history-provenance`, `lived-history-jumps`, and `timeline-orientation`
patterns in `_sass/_p_timeline.scss`; the `support-story` section in
`support.md`; and the existing canonical engagement models in
`_data/engagements.yml`. The larger scope is a cross-surface content change,
so claim review, campaign-state checks, and public-boundary checks are required.

- Existing routes, event IDs, era anchors, canonical narratives, and source albums.
- The 34-event chronology, selected photographs, and 31 expandable galleries.
- Metadata, analytics, project identity, and publication boundaries.
- First-person recollection as legitimate evidence, with its limits stated.

## Retire

- The unsupported Redpoint floor number in the community spotlight and naming guide.
- A paraphrase formatted as a verbatim quotation.
- The claim that Chicago Alt.NET caused all the later named communities.
- The incorrect one-week interval between October 18 and October 19, 2010.

The unverified floor assertion was also removed from the historical chronology
document. Its wider founding chronology needs a separate reconciliation before
it is promoted.

## Introduce

- Four short threads: learning rooms, recorded conversations, shared systems
  practice, and the Phalanx Duel workbench.
- A complete linked event index and a plain explanation of evidence limits.
- Links from events back to their threads, plus a correction/contact path.
- Larger web-image access without a lightbox or third-party viewer.
- A modest support invitation and a separate engineering inquiry route.

The thread descriptions are editorial associations. They do not add evidence
that one project caused another or that photographed people endorse the work.

## Responsive and motion behavior

Use a two-column thread list on wide screens and one column below 780px.
Keep controls at least 44px high and show keyboard focus. Preserve native
disclosure behavior. Do not add auto-play, scroll animation, or a horizontal
timeline as the only reading path.

## Authorized files and exclusions

Canonical content remains in the lived-history, campaign, and engagement YAML.
Markup stays in their existing pages, including a link from the main timeline
to the photo reading paths. Timeline styles stay in the timeline SCSS module.
Planning and unsent promotion drafts stay under excluded runbooks.

Do not ingest new source albums, identify people from appearance, rewrite
transcripts, invent dates, or add a database for these changes.

## Verification

- Validate thread event references, uniqueness, related routes, and fragments.
- Check campaign calls to action in both draft and published states.
- Build production output and run the public-surface audit before release.
- Build/install development output and verify the affected HTTPS routes.
- Obtain independent council review of claims, public boundaries, and the diff.
- Desktop at 1440px and mobile at 375px require browser inspection, including
  disclosure keyboard behavior, focus, and overflow. Record unavailable evidence
  as a release limitation, not as a pass.

## Staged enrichment

1. Inspect the photos used in the first promotion stories. Add image-specific
   descriptions and dimension metadata. Review names and captions against
   sources rather than recognition alone.
2. Collect project milestones from public releases, commits, talks, notebooks,
   and recordings. Store event, capture, publication, and curation dates
   separately. Keep unknown dates unknown.
3. Add explicit relationships such as presented-at, recorded-by, contributed-to,
   and recollected-by, each with its supporting record. Keep editorial threads
   distinct from causal historical claims.
4. Generate project and person views from shared records once multiple views
   need the same evidence. Preserve stable routes instead of copying narratives.
5. Add timecoded excerpts, image-region annotations, correction history, and
   optional IIIF/Web Annotation exports when there is a real reader or reuse need.

Ramblin' & Amblin' and Panoramic View can have current project destinations
before their full histories are assembled. Do not manufacture dated events to
make the project coverage look complete.

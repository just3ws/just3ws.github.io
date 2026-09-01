# Project Context

This repository is the public-facing brand site, job history knowledge base, and
public archive for just3ws.com. It must remain safe to publish through GitHub
Pages.

`$HOME/my` is local, private, and internal context. It may inform this site only
through approved, sanitized public artifacts. Raw private notes, vault content,
local context-engine output, unpublished source material, and private history do
not belong in this repository.

## Domain Glossary

- **Public Archive**: The public just3ws.com archive surface, including resume
  pages, history pages, interviews, writing, one-off videos, SCMC material,
  exports, metadata snapshots, and archive status pages.
- **Public Canon**: The versioned public record in this repository. Canonical
  data generally lives in `_data/`; generated pages and exports are derived from
  that public data.
- **Private Context**: The private `$HOME/my` system, including personal vaults,
  internal knowledge, source registries, local services, indexes, and unpublished
  material.
- **Approved Public Artifact**: A sanitized artifact that has been intentionally
  cleared for public use, such as curated metadata, a public-safe transcript,
  a public note export, or a generated page payload.
- **Publication Gate**: The approval and validation boundary between Private
  Context and Public Canon. Material must pass this gate before it is committed
  here or published on just3ws.com.
- **Archive Item**: A stable public object in the archive, such as an interview,
  video, post, history entry, resume export, community page, or recovered
  Wayback record.
- **Transcript State**: The processing state recorded for a transcript, including
  normalization, restructuring, validation, and any validation error or
  retranscription queue status.
- **Provenance**: The source lineage for an Archive Item: original URLs, recovered
  metadata, source files, transformation steps, approval notes, and confidence
  limits.
- **3-Tier Content Classification**: The strict categorization separating human
  and machine authorship:
  - *Tier 1 (Organic Writing)*: 100% human-authored essays and practice notes in
    `/writing/`.
  - *Tier 2 (Forensic Transcripts)*: Word-for-word primary source dialogues in
    `/interviews/` (AI used strictly for verbatim transcription and timecode alignment).
  - *Tier 3 (Quarantined AI Syntheses)*: Machine-assisted exploratory retrospectives
    quarantined under `/ai/` with `noindex,follow` headers and clear provenance banners.
- **Public Safety**: The requirement that public artifacts exclude private,
  sensitive, raw, misleading, or unapproved material and preserve the stated
  publication contract.
- **Installed Local Site**: The HTTPS site at `https://just3ws.localhost/`,
  published from the generated Jekyll output by `bin/install-localhost`. It is
  integrated with Mike's local system and is a required verification surface,
  not an optional or interchangeable alias for the development server.

## Local Runtime and Publication Contract

This repository is deeply integrated with Mike's local system. Do not treat it
as an isolated Jekyll checkout or assume that a successful `_site/` build alone
proves the installed site is correct.

For a user-facing Jekyll change, the default completion path is:

1. Edit canonical data, templates, styles, plugins, or generators. Resume
   content must remain data-driven from `_data/resume/`.
2. Regenerate and build through `./bin/pipeline build`; use
   `./bin/pipeline ci` for the complete validation path when appropriate.
3. Publish the generated site through `bin/install-localhost`.
4. Verify the rendered result at `https://just3ws.localhost/`, including the
   specific routes and metadata affected by the change.

`./bin/server` and `http://127.0.0.1:4000/` remain useful for quick iteration,
but they do not replace final verification of the installed HTTPS site. Never
hand-edit `_site/` or other generated artifacts to make that verification pass.

## Operating Rules

1. Treat `_data/` as Public Canon when changing archive metadata.
2. Treat `$HOME/my` as Private Context, not as an import tree for this repo.
3. Publish only Approved Public Artifacts, with clear Provenance where the source
   is recovered, transformed, AI-assisted, or confidence-limited.
4. Keep Transcript State visible and honest. Do not hide validation failures by
   presenting low-confidence transcript output as fully canonical.
5. Enforce the 3-Tier Content Classification: never pass off AI-generated articles
   as human essays. Quarantine synthetic compositions under `/ai/` with explicit
   provenance banners, hallucination caveats, and `noindex,follow` headers.
6. Run the appropriate Jekyll, link, data, and smoke checks before shipping
   public archive changes.
7. When safety is uncertain, keep the material private or mark it as pending
   review instead of publishing it.
8. For user-facing changes, complete the installed-local-site workflow and
   verify `https://just3ws.localhost/` before reporting completion.

## Key References

- `README.md` describes the public site surfaces, canonical data files, and
  validation commands.
- `docs/pipeline-continuity.md` describes the archive transcript pipeline and
  validation gate.
- `docs/adr/0001-public-archive-publication-contract.md` records the public
  archive publication contract.
- `docs/style-guide-and-canonical-naming.md` defines permanent canonical naming,
  casing, and compound word standards across all site content, transcripts,
  data files, and search indexes.
- `AGENTS.md`'s System Identity section records this repo's standing peer
  relationship: `wwworkremote.localhost` consumes Public Canon
  (`resume.json`, `/exports/resume.md`, `/exports/portfolio.md`) via
  `CareerOS::PeerMutex` to drive job-search decisions for Mike. That
  relationship does not change what belongs in Public Canon, but it is a
  live downstream consumer of it, not just this site's own display copy.

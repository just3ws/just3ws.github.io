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
5. Run the appropriate Jekyll, link, data, and smoke checks before shipping
   public archive changes.
6. When safety is uncertain, keep the material private or mark it as pending
   review instead of publishing it.
7. For user-facing changes, complete the installed-local-site workflow and
   verify `https://just3ws.localhost/` before reporting completion.

## Key References

- `README.md` describes the public site surfaces, canonical data files, and
  validation commands.
- `docs/pipeline-continuity.md` describes the archive transcript pipeline and
  validation gate.
- `docs/adr/0001-public-archive-publication-contract.md` records the public
  archive publication contract.

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

## Key References

- `README.md` describes the public site surfaces, canonical data files, and
  validation commands.
- `docs/pipeline-continuity.md` describes the archive transcript pipeline and
  validation gate.
- `docs/adr/0001-public-archive-publication-contract.md` records the public
  archive publication contract.

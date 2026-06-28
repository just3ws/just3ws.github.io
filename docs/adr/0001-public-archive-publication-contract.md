# 0001: Public Archive Publication Contract

## Status

Accepted

## Date

2026-06-28

## Context

This repository is the public GitHub Pages source for just3ws.com. It contains
the public brand site, resume and job history surfaces, and a growing technical
archive of interviews, videos, writing, metadata, transcripts, and generated
exports.

The local `$HOME/my` system is a separate private/internal context system. It
owns private vaults, local source registries, internal knowledge, local services,
indexes, and publish-readiness workflows. It may manage or inform this public
repository, but it must not absorb it or push raw private context into it.

Archive work also has processing state. Transcripts may be normalized,
restructured, validated, failed, or queued for retranscription. Public pages need
to preserve provenance and avoid presenting low-confidence or unapproved material
as canonical.

## Decision

We will treat this repository as the **Public Archive** and **Public Canon** for
just3ws.com.

We will treat `$HOME/my` as **Private Context**. Private Context may influence
this repository only through an **Approved Public Artifact** that has crossed a
**Publication Gate**.

The Publication Gate requires:

- public approval or a public-safe source policy for the artifact;
- removal of private notes, raw vault content, sensitive material, and unrelated
  local system details;
- provenance sufficient for future agents to understand source lineage and
  confidence;
- accurate transcript state when transcript content is involved;
- successful relevant validation before merge or publication.

`CONTEXT.md` is the compact domain glossary for future agents. ADRs under
`docs/adr/` record durable publication and architecture decisions.

## Consequences

- Future agents must not crawl or bulk-import `$HOME/my` into this repository.
- Public content sourced from local/private systems must be represented as
  approved, sanitized artifacts before entering Public Canon.
- `_data/` remains the preferred home for canonical public metadata; generated
  pages and exports should derive from it.
- Transcript quality, validation errors, retranscription queues, and confidence
  limits are part of the public archive contract, not cleanup details to hide.
- If provenance or public safety is unclear, the artifact stays private or
  pending review.

## Non-Goals

- This ADR does not define a new schema, pipeline, or approval UI.
- This ADR does not make `$HOME/my` public.
- This ADR does not change the GitHub Pages serving contract for just3ws.com.

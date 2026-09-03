---
title: WITC Corpus and Temporal Archive
description: Build and query the local WHOIS Tech Community and UGtastic archive.
type: guide
---

# WITC corpus

The WITC corpus is a local, searchable representation of the archive configured through `WITC_CORPUS_DIR`. It uses the same portable shape as the ChatGPT archive: SQLite documents, an FTS5 index, optional threads, and deterministic command-line retrieval.

The corpus is intentionally separate from `career_datalake.json`. WITC contains interviews, captions, metadata, source repositories, production notes, generated exports, and historical backups. Keeping it as a named corpus preserves provenance and prevents duplicate physical artifacts from overwriting canonical career entities.

## Build safely

The default operation is a read-only dry run:

```sh
bin/build_witc_corpus.rb --dry-run
```

Build the local database only after reviewing the inventory:

```sh
bin/build_witc_corpus.rb --apply
bin/query_witc_corpus.rb --stats --json
```

The output defaults to `lake/witc/corpus.db`, which is ignored by git. Set `WITC_CORPUS_DIR` or pass `--source` when the archive is mounted elsewhere. Set `WITC_CORPUS_DB` or pass `--db` to query a cached database.

## Provenance contract

Every document records:

- a stable ID derived from the corpus name, relative source path, and SHA-256
- the relative source path, never an absolute path in the database record
- source kind: transcript, metadata, documentation, or source
- project/archive identity
- byte size and SHA-256 of the original file
- the searchable UTF-8 representation
- file modification time and the kind of primary timestamp used

Invalid UTF-8 is replaced only in the searchable representation. The original file’s hash is calculated before normalization. This makes historical files searchable without presenting normalized text as the original evidence.

## Exclusions

The importer does not read or index files below VCS internals, dependency trees, caches, logs, build outputs, public/assets directories, private or backup trees, or known credential and history filenames. It excludes credential-like extensions including key, pem, p12, pfx, crt, cer, asc, secret, and credential. It also rejects text files containing credential-shaped configuration keys and excludes text files larger than 2 MiB by default to avoid treating dumps or generated artifacts as context.

This is a safety boundary, not a claim that every remaining file is public. The WITC corpus is a local research artifact. Review source paths before sharing excerpts or publishing conclusions.

## Temporal interpretation

The importer distinguishes the timestamp of a record from the historical event it may describe. A date in a path is recorded as a `path_date_candidate`. Otherwise the initial primary time is the file modification time. Metadata can contain upload or event dates, but those are not inferred from a caption file unless explicitly encoded by the source.

Use `docs/witc-temporal-timeline.md` for the generated epoch map. The timeline describes recording, production, consolidation, and later curation as different phases. A 2018 conversion does not turn a 2014 interview into a 2018 interview.

## Queries

```sh
bin/query_witc_corpus.rb --search "organizer perspective" --kind transcript --limit 10 --json
bin/query_witc_corpus.rb --search "UGtastic" --source consolidated --limit 10 --json
bin/query_witc_corpus.rb --since 2012-01-01 --until 2015-12-31 --limit 20 --json
```

Results are bounded to 100 records and search excerpts are capped. The source hash and path are included so a human can return to the underlying evidence.

The existing ChatGPT archive’s local LLM `ask` workflow can consume this SQLite contract through a small `CorpusSpec` adapter in `~/my`. The repo-local builder deliberately does not invoke an LLM. Retrieval remains deterministic, local, and auditable; synthesis is a separate human-directed step.

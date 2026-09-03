---
layout: minimal
title: Corpus Metrics Tool
description: A reusable, source-grounded metrics tool for one corpus or a combination of corpuses.
robots: index,follow
sitemap: true
---

# Corpus Metrics Tool

`bin/corpus_metrics.rb` measures a corpus without assuming that the corpus is
UGtastic. It accepts one or many named corpuses. Each corpus can combine
manifests and transcript files or directories.

## Configuration

Create a YAML file:

```yaml
corpora:
  - name: UGtastic
    manifests:
      - path: _data/video_assets.yml
        kind: video_assets
      - path: _data/interviews.yml
        kind: interviews
    transcripts:
      - _data/transcripts/*.yml
  - name: Another archive
    manifests:
      - path: /path/to/archive/episodes.json
        kind: episodes
    transcripts:
      - /path/to/archive/transcripts/*.yml
```

The loader accepts Markdown, YAML, JSON, and JSON Lines files. Markdown files
become one text record each, with frontmatter and the first H1 used when
available. A manifest can be an array or a hash containing `items`, `records`,
`documents`, `entries`, or `episodes`. A single hash is treated as one record.

## Run it

```bash
ruby bin/corpus_metrics.rb --config corpus-metrics.yml
ruby bin/corpus_metrics.rb --config corpus-metrics.yml --format markdown --output report.md
```

The report includes:

- record counts by source kind;
- total records and measurable duration;
- records carrying duration data;
- transcript files with content;
- structured turn counts;
- speaker-map counts and distinct speaker labels;
- top tags and year distribution; and
- Markdown word, heading, and link counts; and
- per-corpus and combined totals.

## Evidence boundary

The tool reports only fields it can locate in the supplied sources. It does not
guess missing durations, merge people from similar names, or claim that a
transcript timestamp is frame-accurate. When combining manifests with the same
records, inspect the per-source report before treating duration as a unique
corpus total. The combined report is an additive view, not automatic entity
deduplication.

This makes the tool useful for archive reports, article source notes, migration
inventories, and graph preparation while keeping the human responsible for
interpreting what the numbers mean.

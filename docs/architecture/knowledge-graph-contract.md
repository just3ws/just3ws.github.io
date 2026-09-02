# Knowledge Graph Contract

The public archive uses a relationship graph to connect evidence, ideas, people,
systems, and the routes where a reader can inspect them. The graph is an index of
the archive, not a replacement for its source files.

## Graph layers

| Layer | Source of truth | Purpose |
| --- | --- | --- |
| Archive data | `_data/*.yml`, `_data/*.json` | Interviews, speakers, topics, positions, engagements, case studies, and navigation metadata |
| Published content | `_posts/`, `case-studies/`, pages, transcripts | Human-readable evidence and primary source material |
| Rendered contract | `_site/**/*.html` | Routes, JSON-LD, breadcrumbs, and links actually published by Jekyll |
| Derived graph | `_data/knowledge_graph.json`, `assets/data/knowledge_graph.json` | Queryable nodes and relationships for site features and agents |
| Audit output | `_data/knowledge_graph_audit.json` | Coverage, integrity, orphan, duplicate, and unresolved-reference findings |

## Stable node identifiers

Node IDs are namespaced by kind and derived from canonical source identifiers.

| Kind | ID pattern | Example |
| --- | --- | --- |
| Interview | `interview:<id>` | `interview:ray-hightower-chicagoruby` |
| Person | `person:<canonical-name>` | `person:ray-hightower` |
| Post | `post:<site-route>` | `post:/2025/02/01/the-boy-who-told-the-truth/` |
| Transcript | `transcript:<interview-id>` | `transcript:ray-hightower-chicagoruby` |
| Topic | `topic:<canonical-slug>` | `topic:open-telemetry` |
| Position | `position:<source-id>` | `position:onemain` |
| Engagement | `engagement:<source-id>` | `engagement:internal-community-mentorship-design` |
| Case study | `case-study:<source-id>` | `case-study:onemain-acquisition` |
| Tool | `tool:<repo-relative-path>` | `tool:bin/pipeline` |

Existing legacy graph IDs remain readable during migration. New generators should
emit the namespaced form and a `legacy_id` field when an older ID is retained.

## Relationships

Relationships use a verb phrase and include `source`, `target`, `kind`,
`confidence`, and `provenance` fields.

| Relationship | Meaning |
| --- | --- |
| `features` | A person appears in an interview or recording |
| `has_transcript` | An interview has a transcript |
| `covers_topic` | Content explicitly names or declares a topic |
| `belongs_to_position` | Evidence is associated with a career position |
| `describes_case_study` | A position or article describes a case study |
| `supports_engagement` | Evidence supports an engagement offering |
| `links_to` | A published page links to another public route |
| `invokes_tool` | Documentation names a repository tool |
| `related_to` | A semantic or editorial relationship exists without a stronger kind |

## Confidence and provenance

- `EXTRACTED` means the relationship was read directly from structured data,
  frontmatter, a transcript, or rendered markup.
- `INFERRED` means a deterministic rule or semantic process proposed the edge.
- `AMBIGUOUS` means a possible relationship was retained for review but must not
  be presented as established fact.

Every derived node and edge records at least one `provenance` path. Unresolved
targets remain in the audit output and are never silently discarded.

## Integrity rules

1. Node IDs are unique within the graph.
2. Every edge has a source, target, relationship kind, confidence, and provenance.
3. Every internal target resolves to a node. External URLs are explicitly marked
   as external references.
4. Orphan nodes are reported. They are not automatically deleted.
5. Generated output is reproducible from source data and the generator version.
6. Sensitive files, environment files, keys, and PHI-adjacent material are never
   scanned or copied into graph output.

The canonical entry point is `./bin/pipeline knowledge-graph`. The audit can be
run independently with `ruby ./bin/audit_knowledge_graph.rb`.

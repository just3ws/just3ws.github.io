# Mike Hall, Staff Software Engineer

[![CI Pipeline](https://github.com/just3ws/just3ws.github.io/actions/workflows/build-and-validate.yml/badge.svg)](https://github.com/just3ws/just3ws.github.io/actions)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

I am a Staff Software Engineer rooted in hands-on software engineering. I work
at multiple levels of the system, from code and runtime behavior through
business and organizational boundaries. I work with and across teams of
individual contributors to make difficult systems clearer, safer to change,
and more useful to the business.

My work combines legacy modernization, production reliability, distributed
observability, system cartography, and carefully bounded AI-assisted tooling.

## Start here

- [Website and portfolio](https://www.just3ws.com/)
- [Targeted Principal Software Engineer resume](https://www.just3ws.com/resumes/mike-hall-principal-software-engineer/)
- [Career timeline](https://www.just3ws.com/timeline/)
- [Architecture case studies](https://www.just3ws.com/case-studies/)
- [Advisory and consulting engagements](https://www.just3ws.com/engagements/)
- [Writing and field notes](https://www.just3ws.com/writing/)

## What I do

- Modernize legacy systems with explicit seams, observability, and reversible
  migration steps.
- Map static code, runtime behavior, historical evidence, and organizational
  ownership into one working system model.
- Build internal technical communities with durable communication channels,
  delegated ownership, mentoring relays, and clear handoffs.
- Apply OpenTelemetry and service-level objectives to understand normal system
  behavior before changing it.
- Build local-first and bounded AI workflows with human review, provenance,
  deterministic checks, and no assumption that model output is authority.

## Featured project: Phalanx Duel

[Phalanx Duel](https://play.phalanxduel.com/) is a real-time tactical game and
architecture laboratory. It explores deterministic simulation, server-authoritative
state, replayable action logs, WebSockets, and human-led AI-assisted engineering.

- [Play the game](https://play.phalanxduel.com/)
- [Source repository](https://github.com/phalanxduel/phalanxduel)
- [Architecture and craftsmanship brief](https://github.com/phalanxduel/phalanxduel/blob/main/docs/talks/phalanx-duel-commercial-and-user-group.md)

## The public archive

The site preserves a growing oral history of software communities, technical
conferences, and engineering practice across the Midwest and beyond.

- [UGtastic and WHOIS Tech Community archive](https://www.just3ws.com/archive-atlas/)
- [Video and transcript archive](https://www.just3ws.com/interviews/)
- [Interactive career and technology timeline](https://www.just3ws.com/timeline/)
- [SCMC archive](https://www.just3ws.com/scmc/)
- [Archive methodology](https://www.just3ws.com/docs/public-artifact-curation-policy/)

Canonical identity maintenance is coordinated by Zarathustra and the
`canonical-surface-steward` skill. The Hierophant, Fool, Commissar, and
Watercourse personas handle canon, contradiction checks, process, and minimal
change.

The archive distinguishes organic writing, source-backed transcripts, and
AI-assisted syntheses. AI may help preserve, search, or organize the record.
The public interpretation remains human-led and carries the relevant
provenance and uncertainty.

## Repository tools

This Jekyll repository contains the public site, canonical resume data, archive
metadata, deterministic query tools, and validation workflows.

```bash
./bin/pipeline build
./bin/pipeline ci
ruby bin/audit_public_surface.rb --strict
ruby bin/query_career_datalake.rb --help
```

Local archive roots and corpus databases belong in ignored local configuration.
They are never required for the public site build.

## Documentation

- [Contributing](CONTRIBUTING.md)
- [Public artifact curation policy](docs/public-artifact-curation-policy.md)
- [AI content disclosure and provenance](docs/ai-content-disclosure-and-provenance.md)
- [Public surface audit](docs/public-surface-audit.md)
- [Changelog](CHANGELOG.md)

## Security and privacy

Please report security issues privately through [SECURITY.md](SECURITY.md).
Do not open a public issue containing credentials, private personal information,
local filesystem paths, or unpublished archive material.

The repository is a public archive. Contributions should use public-safe,
source-supported material and should not add secrets, environment files,
private corpus exports, or machine-specific paths.

## Contact

- [Website](https://www.just3ws.com/)
- [LinkedIn](https://www.linkedin.com/in/just3ws/)
- [GitHub](https://github.com/just3ws)

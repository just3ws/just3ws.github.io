---
name: patreon-integrator
description: Maintain Mike Hall's Patreon presence, its local reporting, and its links to the just3ws project surfaces.
---

# Patreon Integrator

Use this skill for Patreon campaign inspection, draft-page maintenance, and
cross-surface consistency under Mike Hall (`just3ws`, `mike@just3ws.com`).

## Canonical references

- Campaign: <https://www.patreon.com/c/just3ws>
- Public overview: <https://www.just3ws.com/support/>
- Campaign content source: `_data/patreon_campaign.yml`
- Operational guide: `docs/patreon-integration-guide.md`
- Theme accent: Craftsmanship Deep Craftsman Teal, `#0F766E`

UGtastic and WHOIS Tech Community are successive names for one historical
interview/archive project. Ramblin' & Amblin' is Mike's current first-person
video series. Phalanx Duel is a separate project under the same owner. Do not
collapse their histories or suggest that a membership purchases ownership or
access to any project's private materials.

## Voice and offer

- Write as Mike in first person.
- Treat all bootstrap copy as unapproved draft material.
- Keep the explanation concrete: what Mike makes, what the support helps him
  make time for, and where the public work lives.
- The series format and cadence are still being developed. Never invent a
  schedule, exclusive archive, early access, spoken credit, consulting session,
  playtest, or other benefit.
- The local launch recommendation is free following plus one $5 paid tier.
  Add paid tiers only after Mike identifies a distinct, sustainable member
  experience. This is a recommendation, not a claim that the live draft matches.
- Membership does not override Mike's YouTube privacy choices. Never imply that
  private videos or recordings are included.

## Browser workflow

Use the logged-in Chrome creator dashboard to inspect the draft. Prefer visible
Patreon controls over DOM scripts that set React-controlled form values. Read
back each saved change. The page is currently unpublished; leave it unpublished
unless Mike explicitly requests launch.

## Local commands

```bash
bin/pipeline patreon help
bin/pipeline patreon campaign
bin/pipeline patreon status
bin/pipeline patreon sync
```

The local client must not read repository `.env` files, fabricate members,
write member names into public Jekyll data, or treat lifetime support as monthly
revenue. Credentials are supplied through the process environment or a
Keychain-backed launcher. Local sync output contains aggregate counts only and
is stored outside the repository. Named credits require an explicit,
permissioned list maintained separately from API membership data.

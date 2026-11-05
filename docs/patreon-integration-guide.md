# Patreon: Creator Workbench

Patreon is the shared membership surface for Mike Hall (`just3ws`), not a
continuation of the retired `whoistechcmty` campaign identity. The canonical
page is <https://www.patreon.com/c/just3ws>. The public site support page is
<https://www.just3ws.com/support/>.

The canonical campaign narrative and cross-surface project links live in
[`_data/patreon_campaign.yml`](../_data/patreon_campaign.yml). The website's
support page, YouTube preparation surface, campaign guide, and generated career
data should draw from or agree with that source.

## Creator position

Mike Hall (`just3ws`) is the creator and first-person narrator. He founded
Cloud Developers Group with Ryan Gerry in 2009, was a lead co-founder of
Software Craftsmanship McHenry County, and built the Chicago Code Camp website
from 2010 through 2012. He created UGtastic, later branded WHOIS Tech
Community, and recorded more than 200 interviews. These are chapters in one
continuing interview and community-history project.

Today Mike creates Phalanx Duel and the Panoramic View technique and makes
Ramblin' & Amblin', his evolving first-person video series about software,
systems, work, and ideas he is still considering. The projects share an owner;
each keeps its own history and audience. The personal Patreon page makes that
ownership and lineage clear.

Membership is a way to make room for independent recording, editing, archive
care, and software experiments. Do not imply that a payment is ring-fenced to a
specific project unless Mike explicitly sets that up. Public videos and archive
materials stay on their public surfaces. Patreon membership does not change the
privacy decision for a recording or make private material available.

## Launch recommendation

The page is still an unpublished draft. The current six-step ladder was a
bootstrap and should not be treated as the final offer. Recommended first
release:

1. Keep free following for general public updates. Do not describe it as a
   lifetime alumni membership or promise historical interviewees access.
2. Start with one paid tier, **Studio Notes**, at **$5/month**. Patreon
   itself recommends beginning with one tier and identifies $5 as a useful
   starting point for many new membership programs.
3. Offer posts Mike chooses to publish for members, such as occasional process
   notes, topic drafts, and archive progress. Do not promise a monthly cadence,
   early access, private consulting, playtest builds, spoken credits, or other
   deliverables until they are both enabled and sustainable.
4. Add another tier only when it offers a distinct experience Mike can sustain.

Draft tier copy:

> I share occasional notes about shaping Ramblin' & Amblin', caring for the
> interview archive, and making software. Your membership helps me make room
> for those projects. My public work stays in its usual places; membership
> doesn't unlock private recordings or change what I choose to publish.

The creator page remains unpublished. The $5 **Studio Notes** tier is the only
active paid option; the bootstrap $1, $7, $20, and $97 tiers are unpublished
drafts with no members. The welcome post is copy prepared in
`_data/patreon_campaign.yml`; it has not been created in Patreon. The public
support page hides Patreon calls to action until `page_status` changes to
`published`, so visitors are not sent to a closed creator page. Local tooling
does not publish pages, posts, or tiers.

## Cross-surface map

| Surface | Role | Canonical link |
|---|---|---|
| Patreon | Membership, community posts, and support | <https://www.patreon.com/c/just3ws> |
| just3ws.com/support | First-person overview and project map | <https://www.just3ws.com/support/> |
| Ramblin' & Amblin' | Current YouTube series | <https://www.youtube.com/@whoistechcmty> |
| Interview archive | Historical UGtastic / WHOIS Tech Community record | <https://www.just3ws.com/interviews/> |
| Phalanx Duel | Independent game project | <https://github.com/phalanxduel/phalanxduel> |
| Panoramic View | System-cartography method | <https://www.just3ws.com/panoramic-view/> |

The creator page name is **Mike Hall**; `just3ws` is the handle and part of the
campaign URL. On the website, show both together in the identity line. The
Craftsmanship accent is teal (`#0F766E`), but the Patreon draft currently still
shows amber (`#C46820`). Update the Patreon theme color in its creator editor
before publishing. Do not copy the retired campaign's "Tools for everything"
manifesto into new copy without review.

## Local CLI and data safety

`bin/patreon_pipeline.rb` is for read-only campaign inspection and local
aggregate reporting. It must not read the repository `.env`, fabricate demo
patrons, publish member names, or write identifiable membership records into
Jekyll's `_data/` directory. Inject credentials through the process environment
or a local Keychain-backed launcher; never print or commit them.

Current supported commands:

```bash
bin/pipeline patreon help
bin/pipeline patreon campaign
bin/pipeline patreon status
bin/pipeline patreon sync
```

`sync` stores aggregate-only data in the operator's local application-support
directory. `members` reports counts by tier, not names. `credits` produces only
a generic thank-you unless Mike manually supplies a separate, explicit
permissioned credit list. Patron display names are personal data; API access
does not itself grant permission to publish them.

The Patreon API defines `currently_entitled_amount_cents` separately from
lifetime support. Do not label lifetime support as monthly recurring revenue.
The local report intentionally avoids revenue estimates until billing cadence
and refunds are modeled correctly.

## Browser operation

Use the logged-in Chrome creator dashboard to inspect and edit the draft page.
Prefer Patreon’s visible editor over DOM scripts that manipulate React state.
Read the saved page back after each change. Treat **Publish page** as a separate
launch action; the automation and documentation workflows leave the page
unpublished unless Mike explicitly requests publication.

## References

- [Patreon: How to write an eye-catching About section](https://support.patreon.com/hc/en-us/articles/8293386737677-How-to-write-an-eye-catching-About-section)
- [Patreon: Setting up your membership program](https://support.patreon.com/hc/en-us/articles/8293538677005-Setting-Up-Your-Membership-Program)
- [Patreon API v2 reference](https://docs.patreon.com/)

# YouTube publication ownership

This repository owns episode dossiers, scripts, source notes, thumbnails, recording materials, and the Jekyll pages that present the series. YouTube publication work belongs to the separate `media-pipeline` repository.

## Publishing work

Use `media-pipeline` for video uploads, captions, metadata updates, playlist changes, publication status, and quota tracking. Its `bin/mp` CLI and operations cockpit are the supported publication surfaces.

The similarly named scripts left in this repository are retired compatibility entrypoints. They exit without making API changes and direct operators to `media-pipeline`. The local `bin/youtube_pipeline.rb schedule` command only prints the current Season One working target. It does not create or update a publication schedule.

Live broadcast scheduling is not currently available through the media-pipeline publishing interface. OBS recording preparation and local cueing remain documented in [the recording playbook](../recording-playbook.md).

## Content preparation

Generate local episode materials from the episode dossiers and review the result before recording. Keep the Season One outline flexible: 17 interviews is a working target, Episodes -1 and 0 are setup pieces, and later archive candidates are not commitments or a release calendar.

The public series outline is at `/series/the-sound-above/`.

## Creator identity and support link

The channel `@whoistechcmty` hosts more than one era of Mike Hall's work; it is
not the creator identity. Use Mike Hall / `just3ws` as the owner and write
descriptions in Mike's first-person voice. The cross-project overview is
[`/support/`](https://www.just3ws.com/support/), which connects Ramblin' &
Amblin', the UGtastic / WHOIS Tech Community archive, Phalanx Duel, and
Panoramic View. While the Patreon page is a draft, use the public project
overview at `/support/` in descriptions and outros. After the page is published,
the overview can invite viewers to Patreon. Membership must never imply that
public videos or private recordings are gated by support.

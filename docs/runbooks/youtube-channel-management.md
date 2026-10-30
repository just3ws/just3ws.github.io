# YouTube publication ownership

This repository owns episode dossiers, scripts, source notes, thumbnails, recording materials, and the Jekyll pages that present the series. YouTube publication work belongs to the separate `media-pipeline` repository.

## Publishing work

Use `media-pipeline` for video uploads, captions, metadata updates, playlist changes, publication status, and quota tracking. Its `bin/mp` CLI and operations cockpit are the supported publication surfaces.

The similarly named scripts left in this repository are retired compatibility entrypoints. They exit without making API changes and direct operators to `media-pipeline`. The local `bin/youtube_pipeline.rb schedule` command only prints the current Season One working target. It does not create or update a publication schedule.

Live broadcast scheduling is not currently available through the media-pipeline publishing interface. OBS recording preparation and local cueing remain documented in [the recording playbook](../recording-playbook.md).

## Content preparation

Generate local episode materials from the episode dossiers and review the result before recording. Keep the Season One outline flexible: 17 interviews is a working target, Episodes -1 and 0 are setup pieces, and later archive candidates are not commitments or a release calendar.

The public series outline is at `/series/the-sound-above/`.

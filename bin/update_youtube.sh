#!/usr/bin/env bash
set -euo pipefail

if [[ -f "$HOME/.youtuberc" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.youtuberc"
fi

if [[ -z "${YOUTUBE_API_KEY:-}" ]]; then
  echo "YOUTUBE_API_KEY is not set. Add it to ~/.youtuberc (YOUTUBE_API_KEY=...)" >&2
  exit 1
fi

YOUTUBE_API_KEY="$YOUTUBE_API_KEY" bin/fetch_youtube_playlists.rb

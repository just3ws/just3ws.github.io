#!/usr/bin/env bash
# ==============================================================================
# The Sound Above: Dedicated Studio Chromium Launcher
# Launches Chromium with an isolated profile and real-time audio/rendering flags
# to eliminate audio drops, tab throttling, and window capture drift in OBS Studio.
# ==============================================================================
set -euo pipefail

PROFILE_DIR="${HOME}/Library/Application Support/Chromium-TheSoundAbove"
CHROMIUM_APP="/Applications/Chromium.app/Contents/MacOS/Chromium"

if [[ ! -x "${CHROMIUM_APP}" ]]; then
  echo "Error: Chromium not found at ${CHROMIUM_APP}" >&2
  exit 1
fi

mkdir -p "${PROFILE_DIR}"

# Terminate any stale studio instances if --restart is passed
if [[ "${1:-}" == "--restart" ]]; then
  shift
  echo "Terminating existing studio Chromium instances..."
  pkill -f "Chromium-TheSoundAbove" || true
  sleep 1
fi

echo "Launching The Sound Above Studio Browser..."
exec "${CHROMIUM_APP}" \
  --user-data-dir="${PROFILE_DIR}" \
  --autoplay-policy=no-user-gesture-required \
  --disable-background-timer-throttling \
  --disable-renderer-backgrounding \
  --disable-backgrounding-occluded-windows \
  --window-name="The Sound Above - Browser" \
  "$@"

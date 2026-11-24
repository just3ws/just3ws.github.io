#!/usr/bin/env bash
# ==============================================================================
# The Sound Above: Ghostty Studio Terminal Launcher
# Launches a dedicated, isolated Ghostty broadcast terminal anchored to the
# episode recording profile for deterministic OBS window capture.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_SRC="${ROOT_DIR}/obs/ghostty/the-sound-above.config"
USER_CONFIG_DIR="${HOME}/.config/ghostty"
USER_CONFIG_TARGET="${USER_CONFIG_DIR}/the-sound-above.config"

mkdir -p "${USER_CONFIG_DIR}"
if [[ ! -f "${USER_CONFIG_TARGET}" ]] || [[ "${CONFIG_SRC}" -nt "${USER_CONFIG_TARGET}" ]]; then
  cp "${CONFIG_SRC}" "${USER_CONFIG_TARGET}"
fi

echo "Launching The Sound Above Ghostty Terminal..."
open -na /Applications/Ghostty.app --args \
  --config-file="${USER_CONFIG_TARGET}" \
  --title="The Sound Above - Terminal" \
  "$@"

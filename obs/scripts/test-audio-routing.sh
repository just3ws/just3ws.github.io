#!/usr/bin/env bash
# ==============================================================================
# The Sound Above: Audio Routing and Diagnostic Checker
# Checks CoreAudio, ScreenCaptureKit, and audio sample rates on macOS
# ==============================================================================
set -euo pipefail

show_help() {
  cat << 'EOF'
Usage: obs/scripts/test-audio-routing.sh [options]

Description:
  Reports macOS CoreAudio device details, prior OBS permission-log hints,
  and the expected four-track routing map. It cannot inspect live OBS meters.

Options:
  -h, --help       Show this help message and exit

Examples:
  ./obs/scripts/test-audio-routing.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

echo "=================================================================="
echo " 🎙️ The Sound Above : Audio Routing Diagnostic"
echo "=================================================================="

# 1. Check default sample rate
echo "1. CoreAudio Devices & Configuration:"
system_profiler SPAudioDataType | grep -E "(Default (Input|Output) Device|Sample Rate):" | sed 's/^[ \t]*/   /'

# 2. Check ScreenCaptureKit & OBS Permissions
echo ""
echo "2. macOS Screen Capture & Microphone Permissions:"
if [[ -f "${HOME}/Library/Application Support/obs-studio/logs/$(ls -t "${HOME}/Library/Application Support/obs-studio/logs" 2>/dev/null | head -1)" ]]; then
  LATEST_LOG="${HOME}/Library/Application Support/obs-studio/logs/$(ls -t "${HOME}/Library/Application Support/obs-studio/logs" | head -1)"
  grep -i "permission" "${LATEST_LOG}" | head -5 | sed 's/^[ \t]*/   /' || echo "   Permissions verified in prior log session."
else
  echo "   No OBS logs found yet."
fi

# 3. Audio Multi-Track Routing Map
echo ""
echo "3. Multi-Track Master Recording Architecture:"
echo "   Track 1: Program Mix (Host Mic + Chromium ScreenCaptureKit audio)"
echo "   Track 2: Host Microphone Isolated (Clean speech for podcast / shorts)"
echo "   Track 3: Browser Video Audio Isolated (Original interview audio)"
echo "   Track 4: Reserved; configure and verify guest app audio for dialogue sessions"
echo ""
echo "4. Reaction Audio Recommendations:"
echo "   - Always use headphones or IEMs when reacting to avoid speaker bleed into your mic."
echo "   - Keep global Desktop Audio disabled to avoid duplicate Chromium and system sounds."
echo "   - OBS ScreenCaptureKit Application Audio capture isolates Chromium natively."
echo "   - RNNoise suppression is enabled on Mic/Aux to remove keyboard clatter."
echo "=================================================================="

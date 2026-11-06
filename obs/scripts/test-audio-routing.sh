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
audio_metadata_failed=0
if audio_profile_report="$(system_profiler SPAudioDataType 2>&1)"; then
  audio_device_fields="$(printf '%s\n' "$audio_profile_report" | grep -E "(Default (Input|Output) Device|Sample Rate):" || true)"
  if [[ -n "$audio_device_fields" ]]; then
    printf '%s\n' "$audio_device_fields" | sed 's/^[ \t]*/   /'
  else
    echo "   No default input/output device or sample-rate fields were reported."
    audio_metadata_failed=1
  fi
else
  echo "   macOS did not return audio device metadata."
  audio_metadata_failed=1
fi

# 2. Check ScreenCaptureKit & OBS Permissions
echo ""
echo "2. macOS Screen Capture & Microphone Permissions:"
obs_log_dir="${HOME}/Library/Application Support/obs-studio/logs"
latest_log_name="$(ls -t "$obs_log_dir" 2>/dev/null | head -1 || true)"
if [[ -n "$latest_log_name" && -f "$obs_log_dir/$latest_log_name" ]]; then
  if grep -iq "permission" "$obs_log_dir/$latest_log_name"; then
    echo "   Prior OBS permission diagnostics exist. Confirm current macOS permissions and capture in OBS."
  else
    echo "   No prior OBS permission hints found. Confirm current permissions and capture in OBS."
  fi
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

if [[ "$audio_metadata_failed" -ne 0 ]]; then
  echo "Audio device metadata is unverified. Confirm the selected input and live OBS meters before recording."
  exit 1
fi

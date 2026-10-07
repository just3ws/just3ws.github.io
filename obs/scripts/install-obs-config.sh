#!/usr/bin/env bash
# ==============================================================================
# The Sound Above: OBS Studio Configuration Installer
# Installs Scene Collection and Hardware-Accelerated Profile to OBS Studio
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OBS_PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OBS_SUPPORT_DIR="${HOME}/Library/Application Support/obs-studio"
BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

show_help() {
  cat << 'EOF'
Usage: obs/scripts/install-obs-config.sh [options]

Description:
  Installs or synchronizes the 'The Sound Above' Scene Collection and Profile
  from this repository into ~/Library/Application Support/obs-studio/.
  Automatically creates timestamped backups of any existing configurations.

Options:
  -d, --dry-run    Inspect changes without writing files to disk
  -h, --help       Show this help message and exit

Examples:
  ./obs/scripts/install-obs-config.sh
  ./obs/scripts/install-obs-config.sh --dry-run
EOF
}

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

echo "=================================================================="
echo " 🎬 The Sound Above : OBS Studio Configuration Installer"
if [[ "${DRY_RUN}" == "true" ]]; then
  echo "    MODE: DRY-RUN (No files will be modified)"
fi
echo "=================================================================="

# 1. Verify OBS Installation
if [[ ! -d "/Applications/OBS.app" ]]; then
  echo "❌ Error: /Applications/OBS.app not found."
  echo "   Install OBS via Homebrew: brew install --cask obs"
  exit 1
fi
echo "✓ Found /Applications/OBS.app"

# 2. Verify and prepare OBS Application Support directory
if [[ "${DRY_RUN}" == "false" ]]; then
  mkdir -p "${OBS_SUPPORT_DIR}/basic/scenes"
  mkdir -p "${OBS_SUPPORT_DIR}/basic/profiles"
else
  echo "ℹ [dry-run] Would ensure directories exist in ${OBS_SUPPORT_DIR}"
fi

# 3. Install Scene Collection
SCENE_SRC="${OBS_PROJECT_DIR}/scenes/ugtastic-sound-above.json"
SCENE_DEST="${OBS_SUPPORT_DIR}/basic/scenes/The Sound Above - UGtastic Rewatch.json"

if [[ -f "${SCENE_SRC}" ]]; then
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "ℹ [dry-run] Would install Scene Collection to: ${SCENE_DEST}"
  else
    if [[ -f "${SCENE_DEST}" ]]; then
      echo "ℹ Backing up existing scene collection..."
      cp "${SCENE_DEST}" "${SCENE_DEST}.bak_${BACKUP_TIMESTAMP}"
    fi

    # Dynamically ensure local file paths point to current workspace root
    CURRENT_WORKSPACE="$(cd "${OBS_PROJECT_DIR}/.." && pwd)"
    sed "s|/Users/[^/][^/]*/github.com/just3ws/just3ws.github.io|${CURRENT_WORKSPACE}|g; s|/Users/mike/|${HOME}/|g" \
      "${SCENE_SRC}" > "${SCENE_DEST}"
    
    echo "✓ Installed Scene Collection: 'The Sound Above - UGtastic Rewatch'"
  fi
else
  echo "❌ Error: Scene source not found at ${SCENE_SRC}"
  exit 1
fi

# 4. Install Profiles (Production & Staging)
for PROFILE_NAME in "The Sound Above" "The Sound Above - Staging"; do
  PROFILE_SRC_DIR="${OBS_PROJECT_DIR}/profiles/${PROFILE_NAME}"
  PROFILE_DEST_DIR="${OBS_SUPPORT_DIR}/basic/profiles/${PROFILE_NAME}"

  if [[ -d "${PROFILE_SRC_DIR}" ]]; then
    if [[ "${DRY_RUN}" == "true" ]]; then
      echo "ℹ [dry-run] Would install Profile to: ${PROFILE_DEST_DIR}"
    else
      if [[ -d "${PROFILE_DEST_DIR}" ]]; then
        echo "ℹ Backing up existing profile '${PROFILE_NAME}'..."
        cp -r "${PROFILE_DEST_DIR}" "${PROFILE_DEST_DIR}_bak_${BACKUP_TIMESTAMP}"
      else
        mkdir -p "${PROFILE_DEST_DIR}"
      fi

      # Dynamically adjust recording target paths to current user's $HOME/Movies
      sed "s|/Users/[^/][^/]*/Movies|${HOME}/Movies|g; s|/Users/mike/|${HOME}/|g" \
        "${PROFILE_SRC_DIR}/basic.ini" > "${PROFILE_DEST_DIR}/basic.ini"
      
      # Only copy service.json if one doesn't already exist (preserve user stream key)
      if [[ ! -f "${PROFILE_DEST_DIR}/service.json" ]]; then
        cp "${PROFILE_SRC_DIR}/service.json" "${PROFILE_DEST_DIR}/service.json"
      else
        echo "ℹ Preserving existing service.json in profile '${PROFILE_NAME}'"
      fi

      echo "✓ Installed Profile: '${PROFILE_NAME}'"
    fi
  else
    echo "❌ Error: Profile source directory not found at ${PROFILE_SRC_DIR}"
    exit 1
  fi
done

echo "------------------------------------------------------------------"
if [[ "${DRY_RUN}" == "true" ]]; then
  echo "✅ Dry-run check completed successfully! No files were modified."
else
  echo "✅ Installation Complete!"
  echo "------------------------------------------------------------------"
  echo "To activate in OBS Studio:"
  echo " 1. If OBS is running, restart OBS Studio or switch from the menus:"
  echo "    - Profile Menu -> Select 'The Sound Above - Staging' (for testing/sandbox)"
  echo "    - Profile Menu -> Select 'The Sound Above' (for production broadcast)"
  echo "    - Scene Collection Menu -> Select 'The Sound Above - UGtastic Rewatch'"
  echo " 2. In Scene 03/04, click 'Video Window (Orion)' to confirm your browser window."
  echo " 3. Verify 'Video Application Audio (Orion)' captures browser playback."
fi
echo "=================================================================="

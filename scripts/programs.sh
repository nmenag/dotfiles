#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Updating system package index..."
if ! sudo apt-get update -y; then
  echo "WARNING: apt-get update finished with warnings or errors."
fi

FAILED_PROGRAMS=()

install_if_missing() {
  local cmd="$1"
  local pkg="$2"
  local name="$3"

  if command -v "$cmd" &>/dev/null; then
    echo "  $name is already installed ($cmd)."
  else
    echo "  Installing $name ($pkg)..."
    if ! sudo apt-get install -y "$pkg"; then
      echo "  [ERROR] Failed to install $name ($pkg)"
      FAILED_PROGRAMS+=("$name ($pkg)")
    else
      echo "  $name installed successfully!"
    fi
  fi
}

install_if_missing flameshot flameshot "Flameshot"
install_if_missing vlc vlc "VLC Media Player"
install_if_missing bleachbit bleachbit "BleachBit"

echo "Checking Google Chrome..."
if command -v google-chrome &>/dev/null || command -v google-chrome-stable &>/dev/null; then
  echo "  Google Chrome is already installed."
else
  echo "  Downloading and installing Google Chrome..."
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  
  if curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o "$TMP_DIR/google-chrome-stable_current_amd64.deb"; then
    if ! sudo apt-get install -y "$TMP_DIR/google-chrome-stable_current_amd64.deb"; then
      echo "  [ERROR] Failed to install Google Chrome deb package"
      FAILED_PROGRAMS+=("Google Chrome")
    else
      echo "  Google Chrome installed successfully!"
    fi
  else
    echo "  [ERROR] Failed to download Google Chrome deb package"
    FAILED_PROGRAMS+=("Google Chrome")
  fi
fi

if [[ ${#FAILED_PROGRAMS[@]} -gt 0 ]]; then
  echo ""
  echo "=================================================="
  echo "         Desktop Programs Summary                 "
  echo "=================================================="
  echo "The following program(s) could not be installed:"
  for prog in "${FAILED_PROGRAMS[@]}"; do
    echo "  ✗ $prog"
  done
  exit 1
fi

echo "Desktop programs check completed successfully!"

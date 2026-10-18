#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Updating system package index..."
sudo apt-get update -y

install_if_missing() {
  local cmd="$1"
  local pkg="$2"
  local name="$3"

  if command -v "$cmd" &>/dev/null; then
    echo "  $name is already installed ($cmd)."
  else
    echo "  Installing $name ($pkg)..."
    sudo apt-get install -y "$pkg"
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
  
  curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o "$TMP_DIR/google-chrome-stable_current_amd64.deb"
  sudo apt-get install -y "$TMP_DIR/google-chrome-stable_current_amd64.deb"
  echo "  Google Chrome installed successfully!"
fi

echo "Desktop programs check completed successfully!"

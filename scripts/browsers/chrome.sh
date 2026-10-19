#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing Google Chrome ==="

# 1. Check if already installed
if command -v google-chrome &>/dev/null || command -v google-chrome-stable &>/dev/null; then
  echo "Google Chrome is already installed: $(command -v google-chrome 2>/dev/null || command -v google-chrome-stable)"
  exit 0
fi

# 2. Ensure prerequisites
if ! command -v curl &>/dev/null; then
  echo "Installing curl..."
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

# 3. Download and install official deb package
echo "Downloading Google Chrome..."
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DEB_PATH="$TMP_DIR/google-chrome-stable_current_amd64.deb"
if ! curl -fsSL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -o "$DEB_PATH"; then
  echo "[ERROR] Failed to download Google Chrome deb package." >&2
  exit 1
fi

echo "Installing Google Chrome deb package..."
sudo apt-get install -y "$DEB_PATH"

echo "Google Chrome installed successfully!"

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing Obsidian ==="

# 1. Check if already installed
if dpkg-query -W -f='${Status}' obsidian 2>/dev/null | grep -q "install ok installed" || command -v obsidian &>/dev/null; then
  echo "Obsidian is already installed."
  exit 0
fi

ARCH="$(dpkg --print-architecture)"
if [[ "$ARCH" != "amd64" ]]; then
  echo "Obsidian .deb is only published for amd64 (detected: $ARCH)." >&2
  exit 1
fi

# 2. Resolve latest official .deb from GitHub releases
sudo apt-get update -y
sudo apt-get install -y curl ca-certificates

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DEB_URL="$(curl -fsSL https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
  | grep -o 'https://[^"]*obsidian_[^"]*_amd64\.deb' | head -n 1)"
if [[ -z "$DEB_URL" ]]; then
  echo "Could not resolve latest Obsidian .deb URL." >&2
  exit 1
fi

echo "Downloading $DEB_URL..."
DEB_PATH="$TMP_DIR/obsidian.deb"
curl -fsSL "$DEB_URL" -o "$DEB_PATH"

# 3. Install (apt resolves dependencies)
sudo apt-get install -y "$DEB_PATH"

echo "Obsidian installed successfully!"

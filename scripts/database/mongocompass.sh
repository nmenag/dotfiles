#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing MongoDB Compass ==="

# 1. Check if already installed
if (dpkg-query -W -f='${Status}' mongodb-compass 2>/dev/null | grep -q "install ok installed") || command -v mongodb-compass &>/dev/null; then
  echo "MongoDB Compass is already installed: $(command -v mongodb-compass 2>/dev/null || echo 'dpkg: mongodb-compass')"
  exit 0
fi

# 2. Ensure prerequisites
if ! command -v curl &>/dev/null; then
  echo "Installing curl..."
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

# 3. Determine latest version or fallback
COMPASS_VERSION="1.53.0"
if command -v curl &>/dev/null; then
  LATEST_TAG="$(curl -fsSL -m 5 https://api.github.com/repos/mongodb-js/compass/releases/latest 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/' || true)"
  if [[ -n "$LATEST_TAG" ]]; then
    COMPASS_VERSION="$LATEST_TAG"
  fi
fi

# 4. Download and install deb package in temporary workspace
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DEB_FILE="$TMP_DIR/mongodb-compass_${COMPASS_VERSION}_amd64.deb"
DEB_URL="https://downloads.mongodb.com/compass/mongodb-compass_${COMPASS_VERSION}_amd64.deb"

echo "Downloading MongoDB Compass v${COMPASS_VERSION}..."
curl -fsSL "$DEB_URL" -o "$DEB_FILE"

echo "Installing MongoDB Compass deb package..."
sudo apt-get update -y
sudo apt-get install -y "$DEB_FILE"

echo "MongoDB Compass installation completed successfully!"

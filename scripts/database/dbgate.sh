#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing DbGate ==="

# 1. Check if already installed
if dpkg -s dbgate &>/dev/null || command -v dbgate &>/dev/null; then
  echo "DbGate is already installed: $(command -v dbgate 2>/dev/null || echo 'dpkg: dbgate')"
  exit 0
fi

# 2. Ensure prerequisites
if ! command -v curl &>/dev/null; then
  echo "Installing curl..."
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

# 3. Determine latest version or fallback
DBGATE_VERSION="7.3.2"
if command -v curl &>/dev/null; then
  LATEST_TAG="$(curl -fsSL -m 5 https://api.github.com/repos/dbgate/dbgate/releases/latest 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/' || true)"
  if [[ -n "$LATEST_TAG" ]]; then
    DBGATE_VERSION="$LATEST_TAG"
  fi
fi

# 4. Download and install deb package in temporary workspace
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DEB_FILE="$TMP_DIR/dbgate-${DBGATE_VERSION}-linux_amd64.deb"
DEB_URL="https://github.com/dbgate/dbgate/releases/download/v${DBGATE_VERSION}/dbgate-${DBGATE_VERSION}-linux_amd64.deb"

echo "Downloading DbGate v${DBGATE_VERSION}..."
curl -fsSL -L "$DEB_URL" -o "$DEB_FILE"

echo "Installing DbGate deb package..."
sudo apt-get update -y
sudo apt-get install -y "$DEB_FILE"

echo "DbGate installation completed successfully!"

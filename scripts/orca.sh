#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Installing Orca IDE (Agentic Development Environment) ==="

# 1. Check if already installed
if command -v orca-ide &>/dev/null || dpkg -s orca-ide &>/dev/null; then
  echo "Orca IDE is already installed: $(command -v orca-ide 2>/dev/null || echo 'dpkg: orca-ide')"
  exit 0
fi

# 2. Ensure prerequisites
if ! command -v curl &>/dev/null; then
  echo "Installing curl..."
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

# 3. Determine latest version via GitHub API or fallback
ORCA_VERSION="1.4.229"
if command -v curl &>/dev/null; then
  LATEST_TAG="$(curl -fsSL -m 5 https://api.github.com/repos/stablyai/orca/releases/latest 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/' || true)"
  if [[ -n "$LATEST_TAG" ]]; then
    ORCA_VERSION="$LATEST_TAG"
  fi
fi

# 4. Download deb package in temporary workspace
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DEB_FILE="$TMP_DIR/orca-ide_${ORCA_VERSION}_amd64.deb"
DEB_URL="https://github.com/stablyai/orca/releases/download/v${ORCA_VERSION}/orca-ide_${ORCA_VERSION}_amd64.deb"

echo "Downloading Orca IDE v${ORCA_VERSION} from ${DEB_URL}..."
curl -fsSL -L "$DEB_URL" -o "$DEB_FILE"

# 5. Install package via apt-get (resolves dependencies automatically)
echo "Installing Orca IDE deb package..."
sudo apt-get update -y
sudo apt-get install -y "$DEB_FILE"

echo "Orca IDE installation completed successfully!"
echo "NOTE: Launch via 'orca-ide' or from your desktop applications menu."

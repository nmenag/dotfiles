#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Installing Cursor AI Editor..."

# Check if already installed
if command -v cursor &>/dev/null || [[ -x "/opt/cursor.appimage" ]] || [[ -x "$HOME/.local/bin/cursor" ]]; then
  EXISTING_PATH="$(command -v cursor 2>/dev/null || echo "/opt/cursor.appimage")"
  echo "Cursor is already installed at: $EXISTING_PATH"
  exit 0
fi

# Ensure prerequisite utilities exist
sudo apt-get update -y
sudo apt-get install -y gpg wget curl ca-certificates

# Install official APT keyring and repository
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://downloads.cursor.com/keys/anysphere.asc | gpg --dearmor --yes | sudo tee /etc/apt/keyrings/cursor.gpg > /dev/null
sudo chmod 0644 /etc/apt/keyrings/cursor.gpg

ARCH="$(dpkg --print-architecture 2>/dev/null || echo "amd64")"
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/cursor.gpg] https://downloads.cursor.com/aptrepo stable main" | sudo tee /etc/apt/sources.list.d/cursor.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y cursor

echo "Cursor AI Editor installation completed successfully!"

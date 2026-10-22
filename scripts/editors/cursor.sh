#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Installing Cursor AI Editor..."

# 1. Check if already installed via official APT package
if dpkg-query -W -f='${Status}' cursor 2>/dev/null | grep -q "install ok installed"; then
  echo "Cursor AI Editor is already installed via APT."
  exit 0
fi

# Clean up legacy /usr/local/bin/cursor symlink if it points to /opt/cursor.appimage so it doesn't shadow /usr/bin/cursor
if [[ -L "/usr/local/bin/cursor" ]] && [[ "$(readlink "/usr/local/bin/cursor" 2>/dev/null)" == "/opt/cursor.appimage" ]]; then
  echo "Removing legacy /usr/local/bin/cursor symlink pointing to /opt/cursor.appimage..."
  sudo rm -f "/usr/local/bin/cursor"
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

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing VLC Media Player ==="

# 1. Check if already installed
if command -v vlc &>/dev/null; then
  echo "VLC Media Player is already installed: $(command -v vlc)"
  exit 0
fi

# 2. Install VLC via APT
echo "Updating APT package index..."
sudo apt-get update -y

echo "Installing VLC Media Player..."
sudo apt-get install -y vlc

echo "VLC Media Player installed successfully!"

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing Flameshot ==="

# 1. Check if already installed
if command -v flameshot &>/dev/null; then
  echo "Flameshot is already installed: $(command -v flameshot)"
  exit 0
fi

# 2. Install Flameshot via APT
echo "Updating APT package index..."
sudo apt-get update -y

echo "Installing Flameshot..."
sudo apt-get install -y flameshot

echo "Flameshot installed successfully!"

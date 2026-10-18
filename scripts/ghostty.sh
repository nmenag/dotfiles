#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Setting up Ghostty terminal..."

# 1. Check if already installed
if command -v ghostty &>/dev/null; then
  echo "Ghostty is already installed: $(command -v ghostty)"
  echo "Version: $(ghostty --version 2>&1 | head -n 1 || echo 'unknown')"
  exit 0
fi

# 2. Ensure snapd is installed
if ! command -v snap &>/dev/null; then
  echo "Installing snapd..."
  sudo apt-get update -y
  sudo apt-get install -y snapd
fi

# 3. Install Ghostty via official classic snap
echo "Installing Ghostty via Snap (--classic)..."
sudo snap install ghostty --classic

echo "Ghostty installation completed successfully!"

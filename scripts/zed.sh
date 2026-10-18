#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Setting up Zed editor..."

# 1. Check if already installed
if command -v zed &>/dev/null; then
  echo "Zed is already installed: $(command -v zed)"
  echo "Version: $(zed --version 2>&1 | head -n 1 || echo 'unknown')"
  exit 0
fi

# 2. Ensure prerequisites
if ! command -v curl &>/dev/null; then
  echo "Installing curl..."
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

# 3. Download and execute official vendor install script
echo "Downloading and installing Zed (official installer)..."
curl -fsSL https://zed.dev/install.sh | sh

echo "Zed installation completed successfully!"
echo "NOTE: Ensure ~/.local/bin is in your PATH to run 'zed'."

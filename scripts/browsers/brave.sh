#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing Brave Browser ==="

# 1. Check if already installed
if command -v brave-browser &>/dev/null; then
  echo "Brave Browser is already installed: $(command -v brave-browser)"
  exit 0
fi

# 2. Ensure prerequisites
if ! command -v curl &>/dev/null; then
  echo "Installing curl..."
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

# 3. Install Brave Browser via official installer
echo "Installing Brave Browser via official installer (https://dl.brave.com/install.sh)..."
curl -fsS https://dl.brave.com/install.sh | sh

echo "Brave Browser installation completed successfully!"

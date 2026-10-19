#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing BleachBit ==="

# 1. Check if already installed
if command -v bleachbit &>/dev/null; then
  echo "BleachBit is already installed: $(command -v bleachbit)"
  exit 0
fi

# 2. Install BleachBit via APT
echo "Updating APT package index..."
sudo apt-get update -y

echo "Installing BleachBit..."
sudo apt-get install -y bleachbit

echo "BleachBit installed successfully!"

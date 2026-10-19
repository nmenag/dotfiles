#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing Stacer ==="

# 1. Check if already installed
if command -v stacer &>/dev/null; then
  echo "Stacer is already installed: $(command -v stacer)"
  exit 0
fi

# 2. Install Stacer via APT
echo "Updating APT package index..."
sudo apt-get update -y

echo "Installing Stacer..."
sudo apt-get install -y stacer

echo "Stacer installed successfully!"

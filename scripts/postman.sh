#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if command -v postman &>/dev/null; then
  echo "Postman is already installed: $(command -v postman)"
  exit 0
fi

echo "Installing Postman via Snap..."
sudo snap install postman
echo "Postman installed successfully!"

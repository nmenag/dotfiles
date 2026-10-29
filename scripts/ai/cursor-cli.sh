#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Installing Cursor CLI (cursor-agent)..."

if command -v cursor-agent &>/dev/null || command -v agent &>/dev/null; then
  echo "Cursor CLI is already installed: $(command -v cursor-agent || command -v agent)"
  exit 0
fi

if ! command -v curl &>/dev/null; then
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

curl -fsSL https://cursor.com/install | bash

echo "Cursor CLI installed to ~/.local/bin (ensure it is on your PATH)."

#!/bin/bash
set -euo pipefail

if command -v postman &>/dev/null; then
  echo "Postman is already installed: $(command -v postman)"
  exit 0
fi

echo "Installing Postman via Snap..."
sudo snap install postman
echo "Postman installed successfully!"

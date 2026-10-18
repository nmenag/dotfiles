#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Installing Mise Version Manager..."

# Check if already installed in system or user paths
if command -v mise &>/dev/null || [[ -x "$HOME/.local/bin/mise" ]]; then
  EXISTING_PATH="$(command -v mise 2>/dev/null || echo "$HOME/.local/bin/mise")"
  echo "Mise is already installed at: $EXISTING_PATH"
  exit 0
fi

# Ensure prerequisite utilities exist
sudo apt-get update -y
sudo apt-get install -y gpg wget curl ca-certificates

# Install official APT keyring and repository
sudo install -m 0755 -d /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor --yes | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
sudo chmod 0644 /etc/apt/keyrings/mise-archive-keyring.gpg

ARCH="$(dpkg --print-architecture 2>/dev/null || echo "amd64")"
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=${ARCH}] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y mise

echo "Mise Version Manager installation completed successfully!"

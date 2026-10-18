#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if command -v bruno &>/dev/null; then
  echo "Bruno is already installed: $(command -v bruno)"
  exit 0
fi

echo "Installing Bruno dependencies..."
sudo apt-get update -y
sudo apt-get install -y gpg curl ca-certificates

echo "Configuring Bruno official APT repository..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9FA6017ECABE0266" | gpg --dearmor | sudo tee /etc/apt/keyrings/bruno.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/bruno.gpg

ARCH="$(dpkg --print-architecture)"
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/bruno.gpg] http://debian.usebruno.com/ bruno stable" | sudo tee /etc/apt/sources.list.d/bruno.list > /dev/null

echo "Updating APT package lists..."
sudo apt-get update -y

echo "Installing Bruno..."
sudo apt-get install -y bruno
echo "Bruno installed successfully!"

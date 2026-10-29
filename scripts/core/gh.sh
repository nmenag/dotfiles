#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Installing GitHub CLI (gh)..."

if command -v gh &>/dev/null; then
  echo "GitHub CLI is already installed: $(command -v gh)"
  exit 0
fi

if ! command -v curl &>/dev/null; then
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

# Official GitHub CLI APT repository (modern keyring)
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
ARCH="$(dpkg --print-architecture)"
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y gh

echo "GitHub CLI installed. Run 'gh auth login' to authenticate."

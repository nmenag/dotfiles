#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing Claude Desktop (official Anthropic apt repository) ==="

# 1. Check if already installed
if command -v claude-desktop &>/dev/null || dpkg -s claude-desktop &>/dev/null; then
  echo "Claude Desktop is already installed: $(command -v claude-desktop 2>/dev/null || echo 'dpkg: claude-desktop')"
  exit 0
fi

# 2. Ensure prerequisites
sudo apt-get update -y
sudo apt-get install -y curl gnupg

# 3. Register Anthropic's signing key and repository
KEYRING="/usr/share/keyrings/claude-desktop-archive-keyring.asc"
sudo curl -fsSLo "$KEYRING" https://downloads.claude.ai/claude-desktop/key.asc

EXPECTED_FPR="31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE"
if ! gpg --show-keys --with-colons "$KEYRING" | grep -q "^fpr:::::::::${EXPECTED_FPR}:"; then
  echo "ERROR: Anthropic signing key fingerprint mismatch" >&2
  exit 1
fi

echo "deb [arch=amd64,arm64 signed-by=$KEYRING] https://downloads.claude.ai/claude-desktop/apt/stable stable main" \
  | sudo tee /etc/apt/sources.list.d/claude-desktop.list > /dev/null

# 4. Install
sudo apt-get update -y
sudo apt-get install -y claude-desktop

echo "Claude Desktop installation completed successfully!"
echo "NOTE: Launch via 'claude-desktop' or the application menu. For Cowork, run 'sudo usermod -aG kvm \$USER' and re-login."

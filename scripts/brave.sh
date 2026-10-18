#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Installing Brave Browser ==="

# 1. Check if already installed
if command -v brave-browser &>/dev/null || dpkg -s brave-browser &>/dev/null; then
  echo "Brave Browser is already installed: $(command -v brave-browser 2>/dev/null || echo 'dpkg: brave-browser')"
  exit 0
fi

# 2. Ensure prerequisites
if ! command -v curl &>/dev/null; then
  echo "Installing curl..."
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

# 3. Setup official GPG keyring
sudo install -m 0755 -d /etc/apt/keyrings
KEYRING_PATH="/etc/apt/keyrings/brave-browser-archive-keyring.gpg"
if [[ ! -f "$KEYRING_PATH" ]]; then
  echo "Downloading Brave Browser official GPG keyring..."
  sudo curl -fsSLo "$KEYRING_PATH" https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  sudo chmod 0644 "$KEYRING_PATH"
fi

# 4. Configure APT repository
echo "Configuring Brave Browser APT repository..."
REPO_FILE="/etc/apt/sources.list.d/brave-browser-release.list"
echo "deb [signed-by=$KEYRING_PATH] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee "$REPO_FILE" > /dev/null

# 5. Update and install brave-browser
sudo apt-get update -y
sudo apt-get install -y brave-browser

echo "Brave Browser installation completed successfully!"

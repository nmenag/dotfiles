#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing DBeaver Community Edition ==="

# 1. Check if already installed
if (dpkg-query -W -f='${Status}' dbeaver-ce 2>/dev/null | grep -q "install ok installed") || command -v dbeaver &>/dev/null || command -v dbeaver-ce &>/dev/null; then
  echo "DBeaver CE is already installed."
  exit 0
fi

# 2. Ensure prerequisites
if ! command -v curl &>/dev/null || ! command -v gpg &>/dev/null; then
  echo "Installing prerequisites (curl, gpg)..."
  sudo apt-get update -y
  sudo apt-get install -y curl gpg ca-certificates
fi

# 3. Setup official GPG keyring
sudo install -m 0755 -d /etc/apt/keyrings
KEYRING_PATH="/etc/apt/keyrings/dbeaver.gpg"
if [[ ! -f "$KEYRING_PATH" ]]; then
  echo "Adding DBeaver official GPG key..."
  curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor --yes -o "$KEYRING_PATH"
  sudo chmod 0644 "$KEYRING_PATH"
fi

# 4. Configure DBeaver official APT repository
echo "Configuring DBeaver APT repository..."
REPO_FILE="/etc/apt/sources.list.d/dbeaver.list"
echo "deb [signed-by=$KEYRING_PATH] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee "$REPO_FILE" > /dev/null

# 5. Update and install dbeaver-ce
sudo apt-get update -y
sudo apt-get install -y dbeaver-ce

echo "DBeaver Community Edition installation completed successfully!"

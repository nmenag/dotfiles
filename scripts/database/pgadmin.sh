#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing pgAdmin 4 Desktop ==="

# 1. Check if already installed
if (dpkg-query -W -f='${Status}' pgadmin4-desktop 2>/dev/null | grep -q "install ok installed") || command -v pgadmin4 &>/dev/null; then
  echo "pgAdmin 4 Desktop is already installed."
  exit 0
fi

# 2. Ensure prerequisites
if ! command -v curl &>/dev/null || ! command -v gpg &>/dev/null; then
  echo "Installing prerequisites (curl, gpg)..."
  sudo apt-get update -y
  sudo apt-get install -y curl gpg
fi

# 3. Setup official GPG keyring
sudo install -m 0755 -d /etc/apt/keyrings
KEYRING_PATH="/etc/apt/keyrings/packages-pgadmin-org.gpg"
if [[ ! -f "$KEYRING_PATH" ]]; then
  echo "Adding pgAdmin official GPG key..."
  curl -fsSL https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor --yes -o "$KEYRING_PATH"
  sudo chmod 0644 "$KEYRING_PATH"
fi

# 4. Determine Ubuntu codename dynamically (supporting Pop!_OS, Mint, Ubuntu)
CODENAME="${UBUNTU_CODENAME:-$(lsb_release -cs)}"
echo "Configuring pgAdmin APT repository for codename: $CODENAME..."
REPO_FILE="/etc/apt/sources.list.d/pgadmin4.list"
echo "deb [signed-by=$KEYRING_PATH] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/${CODENAME} pgadmin4 main" | sudo tee "$REPO_FILE" > /dev/null

# 5. Update and install pgadmin4-desktop
sudo apt-get update -y
sudo apt-get install -y pgadmin4-desktop

echo "pgAdmin 4 Desktop installation completed successfully!"

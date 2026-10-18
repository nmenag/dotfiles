#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Setting up Docker..."

# Check if Docker is already installed and operational
if command -v docker &>/dev/null && docker compose version &>/dev/null; then
  echo "Docker is already installed: $(docker --version)"
  if ! id -nG "$USER" 2>/dev/null | grep -qw "docker"; then
    if ! getent group docker > /dev/null; then
      sudo groupadd docker
    fi
    sudo usermod -aG docker "$USER"
  fi
  exit 0
fi

# Remove conflicting older packages
echo "Removing legacy docker packages if present..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

echo "Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Ensure keyrings directory exists
sudo install -m 0755 -d /etc/apt/keyrings

# Add Docker's official GPG key
echo "Adding Docker official GPG key..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Determine Ubuntu codename (handles Pop!_OS and Ubuntu derivatives)
CODENAME="${UBUNTU_CODENAME:-$(lsb_release -cs)}"
ARCH="$(dpkg --print-architecture)"

echo "Adding Docker repository for ${CODENAME} (${ARCH})..."
echo \
  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  ${CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker Engine, CLI, Containerd, Buildx, and Compose plugin..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Setup docker group
echo "Configuring docker group and permissions..."
if ! getent group docker > /dev/null; then
  sudo groupadd docker
fi

sudo usermod -aG docker "$USER"

# Provide legacy docker-compose CLI compatibility wrapper if desired
if ! command -v docker-compose &>/dev/null; then
  echo "Creating docker-compose compatibility shim for 'docker compose'..."
  sudo tee /usr/local/bin/docker-compose > /dev/null << 'EOF'
#!/bin/sh
exec docker compose "$@"
EOF
  sudo chmod +x /usr/local/bin/docker-compose
fi

echo "Docker installation and configuration completed!"
echo "NOTE: To run docker commands without sudo in the current terminal, run: newgrp docker"
echo "Or log out and log back in for group membership to take full effect."

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/plugins.sh"

echo "Checking Mise installation..."

# 1. Install Mise if not present in system or user paths
if ! command -v mise &>/dev/null && [[ ! -x "$HOME/.local/bin/mise" ]]; then
  echo "Installing Mise Version Manager..."

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
else
  EXISTING_PATH="$(command -v mise 2>/dev/null || echo "$HOME/.local/bin/mise")"
  echo "Mise is already installed at: $EXISTING_PATH"
fi

# 2. Load mise into PATH for current session
if [[ -x "$HOME/.local/bin/mise" ]] && ! command -v mise &>/dev/null; then
  export PATH="$HOME/.local/bin:$PATH"
fi
if [[ -d "$HOME/.local/share/mise/shims" ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

echo "Current Mise version: $(mise --version)"

# 3. Configure shared toolchains natively in Mise (completely independent of ASDF)
for item in "${VERSION_MANAGER_PLUGINS[@]}"; do
  IFS="|" read -r name _asdf_url mise_name <<< "$item"
  echo "Configuring $name in Mise..."
  mise install "$mise_name" || mise use --global "${mise_name}@latest" || echo "$name install skipped or already up-to-date"
done

# 4. If a ~/.tool-versions or config.toml exists, ensure all declared tools are installed
if [[ -f "$HOME/.tool-versions" || -f "$HOME/.config/mise/config.toml" ]]; then
  echo "Installing any remaining tools declared in config..."
  mise install || true
fi

# Reshim Mise to guarantee shims are updated
mise reshim || true

echo "Mise installation and toolchain setup completed successfully!"

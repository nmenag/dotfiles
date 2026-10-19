#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Setting up Visual Studio Code..."

# Ensure prerequisites and keyrings directory exist
sudo apt-get update -y
sudo apt-get install -y wget curl gpg apt-transport-https ca-certificates
sudo install -m 0755 -d /etc/apt/keyrings

# Add Microsoft official GPG key
echo "Adding Microsoft GPG key..."
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
sudo chmod a+r /etc/apt/keyrings/packages.microsoft.gpg

# Add Microsoft VS Code repository
echo "Adding VS Code apt repository..."
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

echo "Installing VS Code..."
sudo apt-get update -y
sudo apt-get install -y code

if command -v code &>/dev/null; then
  echo "Installing VS Code extensions..."

  pkglist=(
    alefragnani.project-manager
    azemoh.one-monokai
    bradlc.vscode-tailwindcss
    bung87.vscode-gemfile
    castwide.solargraph
    craigmaslowski.erb
    dbaeumer.vscode-eslint
    donjayamanne.githistory
    eamodio.gitlens
    esbenp.prettier-vscode
    florinpatrascu.vscode-elixir-snippets
    googlecloudtools.cloudcode
    iampeterbanjo.elixirlinter
    jakebecker.elixir-ls
    maxmellen.elixir-language-support
    mermade.openapi-lint
    misogi.ruby-rubocop
    mrorz.language-gettext
    ms-vscode-remote.remote-containers
    ms-vscode.vscode-typescript-next
    ms-vsliveshare.vsliveshare
    oderwat.indent-rainbow
    redhat.vscode-yaml
    streetsidesoftware.code-spell-checker
    streetsidesoftware.code-spell-checker-spanish
    techer.open-in-browser
    wakatime.vscode-wakatime
    yoavbls.pretty-ts-errors
  )

  installed_extensions="$(code --list-extensions 2>/dev/null || true)"

  for ext in "${pkglist[@]}"; do
    if echo "$installed_extensions" | grep -qi "^${ext}$"; then
      echo "Extension already installed: $ext"
    else
      echo "Installing extension: $ext"
      code --install-extension "$ext" --force || echo "Failed to install $ext, continuing..."
    fi
  done
else
  echo "Warning: 'code' binary was not found in PATH. Skipping extension installations."
fi

echo "Visual Studio Code setup completed!"

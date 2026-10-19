#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Setting up Herdr (terminal workspace manager for AI coding agents)..."

# 1. Install or verify binary
if command -v herdr &>/dev/null; then
  echo "Herdr is already installed: $(command -v herdr)"
  echo "Version: $(herdr --version 2>&1 | head -n 1 || echo 'unknown')"
else
  # Ensure curl is installed
  if ! command -v curl &>/dev/null; then
    echo "Installing curl..."
    sudo apt-get update -y
    sudo apt-get install -y curl
  fi

  echo "Downloading and installing Herdr via official installer (https://herdr.dev)..."
  curl -fsSL https://herdr.dev/install.sh | sh
  echo "Herdr installed successfully to ~/.local/bin/herdr!"
fi

# 2. Configure Zsh completions if Oh My Zsh is present
if [[ -d "$HOME/.oh-my-zsh" ]] && command -v herdr &>/dev/null; then
  echo "Configuring Herdr completions for Zsh..."
  ZSH_HERDR_DIR="$HOME/.oh-my-zsh/custom/plugins/herdr"
  mkdir -p "$ZSH_HERDR_DIR"
  herdr completion zsh > "$ZSH_HERDR_DIR/_herdr" 2>/dev/null || true
  echo "  Generated Zsh completion in $ZSH_HERDR_DIR/_herdr"
fi

echo "Herdr setup completed successfully!"

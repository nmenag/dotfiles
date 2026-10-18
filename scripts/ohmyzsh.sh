#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Installing Zsh and Oh My Zsh..."

sudo apt-get update -y
sudo apt-get install -y zsh curl git

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "Oh My Zsh is already installed at $HOME/.oh-my-zsh."
else
  echo "Downloading and installing Oh My Zsh (unattended)..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo "Oh My Zsh installed successfully!"
fi

CURRENT_SHELL="$(basename "$SHELL")"
if [[ "$CURRENT_SHELL" != "zsh" ]]; then
  echo "Current shell is $CURRENT_SHELL."
  echo "To make Zsh your default shell, run: chsh -s $(which zsh)"
fi
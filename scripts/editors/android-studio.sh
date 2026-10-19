#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Setting up Java and Android Studio..."

# Setup Java via ASDF if ASDF is available
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  # shellcheck disable=SC1091
  . "$HOME/.asdf/asdf.sh"

  if asdf plugin list 2>/dev/null | grep -q "^java$"; then
    echo "ASDF java plugin already installed."
  else
    echo "Adding ASDF java plugin..."
    asdf plugin add java
  fi

  echo "Installing Java via ASDF..."
  asdf install java openjdk-22 || asdf install java latest
  asdf global java openjdk-22 2>/dev/null || asdf global java latest

  if [[ -f "$HOME/.asdf/plugins/java/set-java-home.zsh" ]] && [[ -f "$HOME/.zshrc" ]]; then
    if ! grep -q "set-java-home.zsh" "$HOME/.zshrc"; then
      echo '. ~/.asdf/plugins/java/set-java-home.zsh' >> "$HOME/.zshrc"
    fi
  fi
else
  echo "ASDF not found at $HOME/.asdf. Installing openjdk via apt..."
  sudo apt-get update -y
  sudo apt-get install -y default-jdk
fi

# Install Android Studio via snap
if command -v snap &>/dev/null; then
  if snap list | grep -q "^android-studio "; then
    echo "Android Studio snap is already installed."
  else
    echo "Installing Android Studio via snap..."
    sudo snap install android-studio --classic
  fi
else
  echo "Warning: snap command not found. Please install snapd to install Android Studio."
fi

echo "Android Studio setup completed successfully!"

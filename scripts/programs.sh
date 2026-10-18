#!/bin/bash
set -euo pipefail

echo "Updating system package index..."
sudo apt-get update -y

echo "Installing Flameshot (screenshot tool)..."
sudo apt-get install -y flameshot

echo "Installing VLC (media player)..."
sudo apt-get install -y vlc

echo "Installing BleachBit (system cleaner)..."
sudo apt-get install -y bleachbit

echo "Checking Google Chrome..."
if command -v google-chrome &>/dev/null || command -v google-chrome-stable &>/dev/null; then
  echo "Google Chrome is already installed."
else
  echo "Downloading and installing Google Chrome..."
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  
  curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o "$TMP_DIR/google-chrome-stable_current_amd64.deb"
  sudo apt-get install -y "$TMP_DIR/google-chrome-stable_current_amd64.deb"
  echo "Google Chrome installed successfully!"
fi

echo "All desktop programs installed successfully!"

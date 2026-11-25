#!/bin/bash
set -euo pipefail

echo "Setting up Kotlin CLI and ADB (Android device config)..."

# --- Kotlin CLI (kotlinc) ---
if command -v kotlinc &>/dev/null; then
  echo "Kotlin CLI already installed."
elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  # shellcheck disable=SC1091
  . "$HOME/.asdf/asdf.sh"
  if ! asdf plugin list 2>/dev/null | grep -q "^kotlin$"; then
    echo "Adding ASDF kotlin plugin..."
    asdf plugin add kotlin
  fi
  echo "Installing Kotlin via ASDF..."
  asdf install kotlin latest
  asdf global kotlin latest
elif command -v snap &>/dev/null; then
  echo "Installing Kotlin via snap..."
  sudo snap install kotlin --classic
else
  echo "Warning: neither ASDF nor snap found; skipping Kotlin CLI."
fi

# --- ADB + udev rules ---
if command -v adb &>/dev/null && dpkg -s android-sdk-platform-tools-common &>/dev/null; then
  echo "ADB and udev rules already installed."
else
  echo "Installing ADB, fastboot and udev rules..."
  sudo apt-get update -y
  sudo apt-get install -y adb fastboot android-sdk-platform-tools-common
fi

# Device access: user must be in plugdev group for non-root adb
TARGET_USER="${SUDO_USER:-$USER}"
if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx "plugdev"; then
  echo "User '$TARGET_USER' already in plugdev group."
else
  echo "Adding '$TARGET_USER' to plugdev group (re-login required)..."
  sudo usermod -aG plugdev "$TARGET_USER"
fi

sudo udevadm control --reload-rules
sudo udevadm trigger

# Restart adb server so it picks up the new permissions
adb kill-server 2>/dev/null || true
adb start-server 2>/dev/null || true

echo "Connected devices:"
adb devices || true

echo "Kotlin CLI and ADB setup completed! Log out/in for plugdev group changes to apply."

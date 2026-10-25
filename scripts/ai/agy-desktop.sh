#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing Agy Desktop (Google Antigravity 2.0 app) ==="

# Google ships Antigravity 2.0 for Linux only as a raw .tar.gz (no apt package);
# the download page is JS-rendered, so pass the tarball URL or local path.
#   ANTIGRAVITY_TARBALL=<url-or-path> ./scripts/ai/agy-desktop.sh
APP_DIR="$HOME/Applications/antigravity"
BIN_LINK="$HOME/.local/bin/antigravity"

# 1. Check if already installed
if [[ -x "$APP_DIR/antigravity" ]]; then
  echo "Agy Desktop is already installed: $APP_DIR"
  exit 0
fi

if [[ -z "${ANTIGRAVITY_TARBALL:-}" ]]; then
  echo "SKIPPED: set ANTIGRAVITY_TARBALL to the Linux x64 tarball URL/path from https://antigravity.google/download"
  exit 0
fi

# 2. Fetch and extract in a temporary workspace
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if [[ "$ANTIGRAVITY_TARBALL" =~ ^https:// ]]; then
  curl -fsSL "$ANTIGRAVITY_TARBALL" -o "$TMP_DIR/antigravity.tar.gz"
else
  cp "$ANTIGRAVITY_TARBALL" "$TMP_DIR/antigravity.tar.gz"
fi
mkdir -p "$TMP_DIR/extract"
tar -xzf "$TMP_DIR/antigravity.tar.gz" -C "$TMP_DIR/extract"

SRC="$(find "$TMP_DIR/extract" -maxdepth 2 -type f -name antigravity -perm -u+x -print -quit)"
if [[ -z "$SRC" ]]; then
  echo "ERROR: 'antigravity' executable not found in tarball" >&2
  exit 1
fi

# 3. Install user-local
mkdir -p "$HOME/Applications" "$HOME/.local/bin" "$HOME/.local/share/applications"
mv "$(dirname "$SRC")" "$APP_DIR"
ln -sf "$APP_DIR/antigravity" "$BIN_LINK"

cat > "$HOME/.local/share/applications/antigravity-desktop.desktop" <<DESKTOP
[Desktop Entry]
Name=Antigravity
Exec=$APP_DIR/antigravity %U
Terminal=false
Type=Application
Categories=Development;
DESKTOP

# 4. Ubuntu 24.04+ blocks Chromium's userns sandbox for unprofiled binaries
if [[ "$(sysctl -n kernel.apparmor_restrict_unprivileged_userns 2>/dev/null || echo 0)" == "1" ]] \
  && [[ ! -f /etc/apparmor.d/antigravity-desktop ]]; then
  sudo tee /etc/apparmor.d/antigravity-desktop > /dev/null <<PROFILE
abi <abi/4.0>,
include <tunables/global>
profile antigravity-desktop $APP_DIR/antigravity flags=(unconfined) {
  userns,
}
PROFILE
  sudo apparmor_parser -r /etc/apparmor.d/antigravity-desktop
fi

echo "Agy Desktop installation completed successfully!"
echo "NOTE: Launch via 'antigravity' or the application menu. Re-run with a new tarball after removing $APP_DIR to update."

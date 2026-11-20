#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Installing Agy Desktop (Google Antigravity 2.0 app) ==="

# Google ships Antigravity 2.0 for Linux as a .tar.gz archive; resolve the latest
# download URL from https://antigravity.google/download unless ANTIGRAVITY_TARBALL is set.
#   ./scripts/ai/agy-desktop.sh
#   ANTIGRAVITY_TARBALL=<url-or-path> ./scripts/ai/agy-desktop.sh
APP_DIR="$HOME/Applications/antigravity"
BIN_LINK="$HOME/.local/bin/antigravity"

# 1. Check if already installed
if [[ -x "$APP_DIR/antigravity" ]] || command -v antigravity &>/dev/null; then
  echo "Agy Desktop is already installed: $(command -v antigravity 2>/dev/null || echo "$APP_DIR/antigravity")"
  exit 0
fi

# 2. Detect Linux architecture
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) TARBALL_ARCH="linux-x64" ;;
  aarch64|arm64) TARBALL_ARCH="linux-arm" ;;
  *)
    echo "ERROR: Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

# 3. Ensure curl is available when downloading
if [[ -z "${ANTIGRAVITY_TARBALL:-}" ]] || [[ "${ANTIGRAVITY_TARBALL:-}" =~ ^https?:// ]]; then
  if ! command -v curl &>/dev/null; then
    echo "Installing curl..."
    sudo apt-get update -y
    sudo apt-get install -y curl
  fi
fi

# 4. Resolve tarball URL automatically if ANTIGRAVITY_TARBALL is not provided
TARBALL_SOURCE="${ANTIGRAVITY_TARBALL:-}"
if [[ -z "$TARBALL_SOURCE" ]]; then
  echo "Resolving latest Antigravity Linux (${TARBALL_ARCH}) tarball URL from https://antigravity.google/download..."
  TARBALL_SOURCE="$(
    curl -fsSL "https://antigravity.google/download" \
      | grep -oE "https://storage\.googleapis\.com/antigravity-public/antigravity-hub/[^\"' ]+/${TARBALL_ARCH}/Antigravity\.tar\.gz" \
      | head -n 1 || true
  )"
  if [[ -z "$TARBALL_SOURCE" ]]; then
    echo "ERROR: Could not resolve Antigravity download URL for ${TARBALL_ARCH} from https://antigravity.google/download" >&2
    echo "You can pass a URL or local tarball path manually: ANTIGRAVITY_TARBALL=<url-or-path> $0" >&2
    exit 1
  fi
fi

# 5. Fetch and extract in a temporary workspace
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if [[ "$TARBALL_SOURCE" =~ ^https?:// ]]; then
  echo "Downloading ${TARBALL_SOURCE}..."
  curl -fsSL "$TARBALL_SOURCE" -o "$TMP_DIR/antigravity.tar.gz"
else
  cp "$TARBALL_SOURCE" "$TMP_DIR/antigravity.tar.gz"
fi
mkdir -p "$TMP_DIR/extract"
tar -xzf "$TMP_DIR/antigravity.tar.gz" -C "$TMP_DIR/extract"

SRC="$(find "$TMP_DIR/extract" -maxdepth 2 -type f -name antigravity -perm -u+x -print -quit)"
if [[ -z "$SRC" ]]; then
  echo "ERROR: 'antigravity' executable not found in tarball" >&2
  exit 1
fi

# 6. Install user-local
mkdir -p "$HOME/Applications" "$HOME/.local/bin" "$HOME/.local/share/applications"
rm -rf "$APP_DIR"
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

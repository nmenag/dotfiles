#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if command -v postman &>/dev/null; then
  echo "Postman is already installed: $(command -v postman)"
  exit 0
fi

# Check if installed via Flatpak
if command -v flatpak &>/dev/null && flatpak info com.getpostman.Postman &>/dev/null; then
  echo "Postman is already installed via Flatpak (com.getpostman.Postman)."
  mkdir -p "$HOME/.local/bin"
  if [[ ! -f "$HOME/.local/bin/postman" ]]; then
    cat <<'EOF' > "$HOME/.local/bin/postman"
#!/bin/sh
exec flatpak run com.getpostman.Postman "$@"
EOF
    chmod +x "$HOME/.local/bin/postman"
    echo "Created ~/.local/bin/postman CLI shim for Flatpak."
  fi
  exit 0
fi

echo "Installing Postman via Snap..."
sudo snap install postman
echo "Postman installed successfully!"

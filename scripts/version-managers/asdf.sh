#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/plugins.sh"

ASDF_DIR="$HOME/.asdf"
ASDF_VERSION="v0.15.0"

echo "Checking ASDF installation..."

if [[ ! -d "$ASDF_DIR" ]]; then
  echo "Installing ASDF ($ASDF_VERSION)..."
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch "$ASDF_VERSION"
else
  echo "ASDF is already cloned at $ASDF_DIR."
fi

# Load asdf into current shell session
if [[ -f "$ASDF_DIR/asdf.sh" ]]; then
  # shellcheck disable=SC1091
  . "$ASDF_DIR/asdf.sh"
else
  echo "Error: $ASDF_DIR/asdf.sh not found!"
  exit 1
fi

# Helper function to add asdf plugins safely
add_plugin() {
  local name="$1"
  local url="${2:-}"
  if asdf plugin list 2>/dev/null | grep -q "^${name}$"; then
    echo "ASDF plugin '$name' already added."
  else
    echo "Adding ASDF plugin '$name'..."
    if [[ -n "$url" ]]; then
      asdf plugin add "$name" "$url"
    else
      asdf plugin add "$name"
    fi
  fi
}

echo "Current ASDF version: $(asdf --version)"

# Iterate through shared plugins list (DRY)
for item in "${VERSION_MANAGER_PLUGINS[@]}"; do
  IFS="|" read -r name asdf_url _mise_name <<< "$item"
  echo "Configuring $name in ASDF..."
  add_plugin "$name" "$asdf_url"
  asdf install "$name" latest || echo "$name install skipped or already up-to-date"
  asdf global "$name" latest || true
done

echo "ASDF installation and plugin setup completed successfully!"

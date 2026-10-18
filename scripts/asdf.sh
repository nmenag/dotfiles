#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Ruby
echo "Configuring Ruby..."
add_plugin "ruby" "https://github.com/asdf-vm/asdf-ruby.git"
asdf install ruby latest || echo "Ruby install skipped or already up-to-date"
asdf global ruby latest || true

# Erlang
echo "Configuring Erlang..."
add_plugin "erlang" "https://github.com/asdf-vm/asdf-erlang.git"
asdf install erlang latest || echo "Erlang install skipped or already up-to-date"
asdf global erlang latest || true

# Elixir
echo "Configuring Elixir..."
add_plugin "elixir" "https://github.com/asdf-vm/asdf-elixir.git"
asdf install elixir latest || echo "Elixir install skipped or already up-to-date"
asdf global elixir latest || true

# Node.js
echo "Configuring Node.js..."
add_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
asdf install nodejs latest || echo "Node.js install skipped or already up-to-date"
asdf global nodejs latest || true

# Python
echo "Configuring Python..."
add_plugin "python"
asdf install python latest || echo "Python install skipped or already up-to-date"
asdf global python latest || true

echo "ASDF installation and plugin setup completed successfully!"

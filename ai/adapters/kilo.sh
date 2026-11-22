#!/bin/bash
set -euo pipefail

# ai/adapters/kilo.sh - Kilo CLI integration adapter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

echo "=== Installing & Syncing Kilo CLI Adapter ==="

export PATH="$HOME/.kilo/bin:$HOME/.local/bin:$PATH"

# 0. Install Kilo CLI binary if not present
if [[ -x "$HOME/.kilo/bin/kilo" ]] || command -v kilo &>/dev/null; then
  echo "Kilo CLI is already installed: $(command -v kilo 2>/dev/null || echo "$HOME/.kilo/bin/kilo")"
else
  if ! command -v curl &>/dev/null; then
    echo "Installing curl..."
    sudo apt-get update -y
    sudo apt-get install -y curl
  fi
  echo "Downloading and installing Kilo CLI via official installer (https://kilo.ai/cli/install)..."
  curl -fsSL https://kilo.ai/cli/install | bash
fi

if [[ -x "$HOME/.kilo/bin/kilo" ]]; then
  ensure_dir "$HOME/.local/bin"
  ln -sfn "$HOME/.kilo/bin/kilo" "$HOME/.local/bin/kilo"
fi

if ! command -v kilo &>/dev/null; then
  echo "ERROR: Kilo CLI installation failed (kilo binary not found in PATH)" >&2
  exit 1
fi

KILO_DIR="$HOME/.config/kilo"
ensure_dir "$KILO_DIR"
ensure_dir "$KILO_DIR/skills"

# 1. Global instructions
echo "Configuring Kilo global AGENTS.md..."
safe_symlink "$AI_DIR/common-instructions.md" "$KILO_DIR/AGENTS.md"

# 2. Skills
echo "Configuring Kilo global skills..."
for skill_dir in "$AI_DIR"/skills/*; do
  if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    safe_symlink "$skill_dir" "$KILO_DIR/skills/$skill_name"
  fi
done

echo "Kilo adapter synchronized successfully!"

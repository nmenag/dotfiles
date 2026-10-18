#!/bin/bash
set -euo pipefail

# ai/adapters/kilo.sh - Kilo CLI integration adapter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

echo "=== Syncing Kilo CLI Adapter ==="

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

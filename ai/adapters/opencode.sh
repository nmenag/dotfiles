#!/bin/bash
set -euo pipefail

# ai/adapters/opencode.sh - OpenCode CLI integration adapter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

echo "=== Syncing OpenCode Adapter ==="

OPENCODE_DIR="$HOME/.config/opencode"
ensure_dir "$OPENCODE_DIR"
ensure_dir "$OPENCODE_DIR/skills"

# 1. Global instructions
echo "Configuring OpenCode global AGENTS.md..."
safe_symlink "$AI_DIR/common-instructions.md" "$OPENCODE_DIR/AGENTS.md"

# 2. Skills
echo "Configuring OpenCode global skills..."
for skill_dir in "$AI_DIR"/skills/*; do
  if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    safe_symlink "$skill_dir" "$OPENCODE_DIR/skills/$skill_name"
  fi
done

echo "OpenCode adapter synchronized successfully!"

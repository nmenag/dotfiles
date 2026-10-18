#!/bin/bash
set -euo pipefail

# ai/adapters/pi.sh - Pi Coding Agent integration adapter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

echo "=== Syncing Pi Coding Agent Adapter ==="

PI_DIR="$HOME/.pi/agent"
ensure_dir "$PI_DIR"
ensure_dir "$PI_DIR/skills"

# 1. Global instructions (Pi reads AGENTS.md in ~/.pi/agent/)
echo "Configuring Pi global AGENTS.md..."
safe_symlink "$AI_DIR/common-instructions.md" "$PI_DIR/AGENTS.md"

# 2. Global skills
echo "Configuring Pi global skills..."
for skill_dir in "$AI_DIR"/skills/*; do
  if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    safe_symlink "$skill_dir" "$PI_DIR/skills/$skill_name"
  fi
done

echo "Pi Coding Agent adapter synchronized successfully!"

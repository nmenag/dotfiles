#!/bin/bash
set -euo pipefail

# ai/adapters/agy.sh - Antigravity / Gemini CLI integration adapter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

echo "=== Syncing Agy (Antigravity CLI) Adapter ==="

GEMINI_DIR="$HOME/.gemini"
ensure_dir "$GEMINI_DIR"
ensure_dir "$GEMINI_DIR/skills"

# 1. Global instructions
echo "Configuring Agy global GEMINI.md..."
safe_symlink "$AI_DIR/common-instructions.md" "$GEMINI_DIR/GEMINI.md"

# 2. Workspace root GEMINI.md link
safe_symlink "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/GEMINI.md"

# 3. Global Skills
echo "Configuring Agy global skills..."
for skill_dir in "$AI_DIR"/skills/*; do
  if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    safe_symlink "$skill_dir" "$GEMINI_DIR/skills/$skill_name"
  fi
done

# 4. Workspace skills sync to .agents/skills for local project discovery
ensure_dir "$ROOT_DIR/.agents/skills"
for skill_dir in "$AI_DIR"/skills/*; do
  if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    if [[ ! -d "$ROOT_DIR/.agents/skills/$skill_name" ]]; then
      cp -r "$skill_dir" "$ROOT_DIR/.agents/skills/$skill_name"
    fi
  fi
done

echo "Agy adapter synchronized successfully!"

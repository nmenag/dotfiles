#!/bin/bash
set -euo pipefail

# ai/adapters/codex.sh - OpenAI Codex CLI integration adapter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

echo "=== Syncing Codex CLI Adapter ==="

CODEX_DIR="$HOME/.codex"
ensure_dir "$CODEX_DIR"
ensure_dir "$CODEX_DIR/skills"

# 1. Global instructions
echo "Configuring Codex global AGENTS.md..."
safe_symlink "$AI_DIR/common-instructions.md" "$CODEX_DIR/AGENTS.md"

# 2. Skills
echo "Configuring Codex global skills..."
for skill_dir in "$AI_DIR"/skills/*; do
  if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    safe_symlink "$skill_dir" "$CODEX_DIR/skills/$skill_name"
  fi
done

echo "Codex adapter synchronized successfully!"

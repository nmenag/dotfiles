#!/bin/bash
set -euo pipefail

# ai/adapters/claude.sh - Claude Code integration adapter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

echo "=== Syncing Claude Code Adapter ==="

CLAUDE_DIR="$HOME/.claude"
ensure_dir "$CLAUDE_DIR"
ensure_dir "$CLAUDE_DIR/rules"
ensure_dir "$CLAUDE_DIR/skills"

# 1. Global instructions / memory
echo "Configuring Claude Code global instructions..."
safe_symlink "$AI_DIR/common-instructions.md" "$CLAUDE_DIR/CLAUDE.md"

# 2. Workspace root CLAUDE.md relative link (DRY)
echo "Configuring workspace root CLAUDE.md..."
ln -sfn "AGENTS.md" "$ROOT_DIR/CLAUDE.md"

# 3. Rules
echo "Configuring Claude Code global rules..."
for rule_file in "$AI_DIR"/rules/*.md; do
  if [[ -f "$rule_file" ]]; then
    rule_name="$(basename "$rule_file")"
    safe_symlink "$rule_file" "$CLAUDE_DIR/rules/$rule_name"
  fi
done

# 4. Skills
echo "Configuring Claude Code global skills..."
for skill_dir in "$AI_DIR"/skills/*; do
  if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    safe_symlink "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
  fi
done

echo "Claude Code adapter synchronized successfully!"

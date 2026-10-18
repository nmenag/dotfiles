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

# 2. Workspace root GEMINI.md relative link (DRY)
echo "Configuring workspace root GEMINI.md..."
ln -sfn "AGENTS.md" "$ROOT_DIR/GEMINI.md"

# 3. Global Skills
echo "Configuring Agy global skills..."
for skill_dir in "$AI_DIR"/skills/*; do
  if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    safe_symlink "$skill_dir" "$GEMINI_DIR/skills/$skill_name"
  fi
done

# 4. Workspace rules sync to .agents/rules using DRY relative symlinks
ensure_dir "$ROOT_DIR/.agents/rules"
echo "Linking workspace rules to .agents/rules (DRY)..."
for rule_file in "$AI_DIR"/rules/*.md; do
  if [[ -f "$rule_file" ]]; then
    rule_name="$(basename "$rule_file")"
    ln -sfn "../../ai/rules/$rule_name" "$ROOT_DIR/.agents/rules/$rule_name"
  fi
done

# 5. Workspace skills sync to .agents/skills using DRY relative symlinks
ensure_dir "$ROOT_DIR/.agents/skills"
echo "Linking workspace skills to .agents/skills (DRY)..."
for skill_dir in "$AI_DIR"/skills/*; do
  if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    # Replace non-symlink directories with symlinks if present
    if [[ -d "$ROOT_DIR/.agents/skills/$skill_name" && ! -L "$ROOT_DIR/.agents/skills/$skill_name" ]]; then
      rm -rf "$ROOT_DIR/.agents/skills/$skill_name"
    fi
    ln -sfn "../../ai/skills/$skill_name" "$ROOT_DIR/.agents/skills/$skill_name"
  fi
done

echo "Agy adapter synchronized successfully!"

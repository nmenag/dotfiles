#!/bin/bash
set -euo pipefail

# ai/adapters/common.sh - Shared utility functions for AI CLI adapters

ADAPTERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(cd "$ADAPTERS_DIR/.." && pwd)"
ROOT_DIR="$(cd "$AI_DIR/.." && pwd)"

BACKUP_DIR="$HOME/.dotfiles_backup/ai_$(date +%Y%m%d_%H%M%S)"

ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi
}

safe_symlink() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    echo "  [WARN] Source does not exist: $src"
    return 1
  fi

  ensure_dir "$(dirname "$dst")"

  # If destination is already a symlink pointing to the exact same source
  if [[ -L "$dst" ]]; then
    local current_target
    current_target="$(readlink "$dst" || true)"
    local abs_src
    abs_src="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"
    if [[ "$current_target" == "$src" || "$current_target" == "$abs_src" ]]; then
      echo "  [OK] Link up-to-date: $dst -> $src"
      return 0
    fi
  fi

  # Non-destructive backup of existing file or directory
  if [[ -e "$dst" || -L "$dst" ]]; then
    ensure_dir "$BACKUP_DIR"
    local base_name
    base_name="$(basename "$dst")"
    mv "$dst" "$BACKUP_DIR/${base_name}_$(date +%s)"
    echo "  [BACKUP] Existing $dst moved to $BACKUP_DIR"
  fi

  ln -sfn "$src" "$dst"
  echo "  [LINKED] $dst -> $src"
}

safe_copy() {
  local src="$1"
  local dst="$2"

  if [[ ! -f "$src" ]]; then
    echo "  [WARN] Source file does not exist: $src"
    return 1
  fi

  ensure_dir "$(dirname "$dst")"

  if [[ -f "$dst" ]]; then
    if cmp -s "$src" "$dst"; then
      echo "  [OK] File identical: $dst"
      return 0
    fi
    ensure_dir "$BACKUP_DIR"
    cp -p "$dst" "$BACKUP_DIR/$(basename "$dst")_$(date +%s)"
    echo "  [BACKUP] Existing $dst backed up to $BACKUP_DIR"
  fi

  cp -p "$src" "$dst"
  echo "  [COPIED] $src -> $dst"
}

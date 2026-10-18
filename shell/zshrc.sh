#!/usr/bin/env zsh
# shell/zshrc.sh - Dotfiles entrypoint for Zsh

# Derive directory safely in Zsh or fallback
if [[ -n "${ZSH_VERSION:-}" ]]; then
  DOTFILES_SHELL_DIR="${0:A:h}"
else
  DOTFILES_SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [[ -z "$DOTFILES_SHELL_DIR" || ! -d "$DOTFILES_SHELL_DIR" ]]; then
  DOTFILES_SHELL_DIR="${DOTFILES_DIR:-$HOME/personal-projects/dotfiles}/shell"
fi

# 1. Environment variables & PATH
if [[ -f "$DOTFILES_SHELL_DIR/env.sh" ]]; then
  source "$DOTFILES_SHELL_DIR/env.sh"
fi

# 2. Shared aliases
if [[ -f "$DOTFILES_SHELL_DIR/aliases.sh" ]]; then
  source "$DOTFILES_SHELL_DIR/aliases.sh"
fi

# 3. Shared functions
if [[ -f "$DOTFILES_SHELL_DIR/functions.sh" ]]; then
  source "$DOTFILES_SHELL_DIR/functions.sh"
fi

#!/bin/bash
# shell/bashrc.sh - Dotfiles entrypoint for Bash

DOTFILES_SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Environment variables & PATH
if [[ -f "$DOTFILES_SHELL_DIR/env.sh" ]]; then
  # shellcheck disable=SC1091
  source "$DOTFILES_SHELL_DIR/env.sh"
fi

# 2. Shared aliases
if [[ -f "$DOTFILES_SHELL_DIR/aliases.sh" ]]; then
  # shellcheck disable=SC1091
  source "$DOTFILES_SHELL_DIR/aliases.sh"
fi

# 3. Shared functions
if [[ -f "$DOTFILES_SHELL_DIR/functions.sh" ]]; then
  # shellcheck disable=SC1091
  source "$DOTFILES_SHELL_DIR/functions.sh"
fi

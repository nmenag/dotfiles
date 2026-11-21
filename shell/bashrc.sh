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

# 4. Version managers & runtime hooks
if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
fi

# 5. COSMIC Terminal split-pane working directory inheritance
# Works around cosmic-term PaneSplit focusing the new empty pane before querying cwd.
if [[ -r "/proc/$PPID/comm" ]] && [[ "$(<"/proc/$PPID/comm")" == "cosmic-term" ]]; then
  _COSMIC_TERM_CWD_FILE="${XDG_RUNTIME_DIR:-/tmp}/cosmic_term_cwd_${PPID}"
  if [[ "$PWD" == "$HOME" && -f "$_COSMIC_TERM_CWD_FILE" ]]; then
    _COSMIC_SAVED_CWD="$(<"$_COSMIC_TERM_CWD_FILE")"
    if [[ -n "$_COSMIC_SAVED_CWD" && -d "$_COSMIC_SAVED_CWD" && "$_COSMIC_SAVED_CWD" != "$HOME" ]]; then
      builtin cd -- "$_COSMIC_SAVED_CWD" || true
    fi
    unset _COSMIC_SAVED_CWD
  fi
  _cosmic_term_track_cwd() {
    printf '%s' "$PWD" > "${XDG_RUNTIME_DIR:-/tmp}/cosmic_term_cwd_${PPID}" 2>/dev/null || true
  }
  _cosmic_term_track_cwd
  if [[ "${PROMPT_COMMAND:-}" != *"_cosmic_term_track_cwd"* ]]; then
    PROMPT_COMMAND="_cosmic_term_track_cwd${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  fi
fi



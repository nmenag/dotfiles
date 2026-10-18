#!/bin/bash
# shell/env.sh - Idempotent environment variable and PATH configuration
# Compatible with both Bash and Zsh

# Helper to prepend directory to PATH if it exists and is not already present
path_prepend() {
  local dir="$1"
  if [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$dir:$PATH"
  fi
}

# Helper to append directory to PATH if it exists and is not already present
path_append() {
  local dir="$1"
  if [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$PATH:$dir"
  fi
}

# Base developer directories
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"

# ASDF Version Manager
if [[ -d "$HOME/.asdf" ]]; then
  export ASDF_DATA_DIR="$HOME/.asdf"
  path_prepend "$ASDF_DATA_DIR/shims"
  if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    # shellcheck disable=SC1091
    . "$HOME/.asdf/asdf.sh"
  fi
fi

# Erlang & Elixir history
export ERL_AFLAGS="-kernel shell_history enabled"

# Android SDK
if [[ -d "$HOME/Android/Sdk" ]]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
  path_append "$ANDROID_HOME/emulator"
  path_append "$ANDROID_HOME/platform-tools"
fi

# AI CLI tooling paths
path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/.kilo/bin"
path_append "$HOME/.maestro/bin"

# Railway CLI environment if present
if [[ -f "$HOME/.railway/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.railway/env"
fi

# Preferred default editor
export EDITOR="${EDITOR:-nano}"

# Location of dotfiles repository
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/personal-projects/dotfiles}"

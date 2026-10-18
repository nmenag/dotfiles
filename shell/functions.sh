#!/bin/bash
# shell/functions.sh - Reusable helper functions across Bash and Zsh

# Create a new directory and enter it
mkcd() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: mkcd <directory_name>"
    return 1
  fi
  mkdir -p "$1" && cd "$1"
}

# Universal archive extractor
extract() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: extract <archive_file>"
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "Error: '$1' is not a valid file"
    return 1
  fi

  case "$1" in
    *.tar.bz2)   tar xjf "$1"     ;;
    *.tar.gz)    tar xzf "$1"     ;;
    *.bz2)       bunzip2 "$1"     ;;
    *.rar)       unrar x "$1"     ;;
    *.gz)        gunzip "$1"      ;;
    *.tar)       tar xf "$1"      ;;
    *.tbz2)      tar xjf "$1"     ;;
    *.tgz)       tar xzf "$1"     ;;
    *.zip)       unzip "$1"       ;;
    *.Z)         uncompress "$1"  ;;
    *.7z)        7z x "$1"        ;;
    *)           echo "Cannot extract '$1': unknown file format" ;;
  esac
}

# Inspect each entry of PATH on an isolated line
path_inspect() {
  echo "Current PATH entries:"
  local idx=1
  # Split PATH on ':' portably
  local old_ifs="$IFS"
  IFS=':'
  for p in $PATH; do
    if [[ -d "$p" ]]; then
      printf "  [%2d] %s\n" "$idx" "$p"
    else
      printf "  [%2d] %s (NOT FOUND)\n" "$idx" "$p"
    fi
    idx=$((idx + 1))
  done
  IFS="$old_ifs"
}

# Audit presence and health of AI CLI tools
ai_status() {
  local tools=("claude" "opencode" "codex" "kilo" "agy")
  local tool=""
  local tool_path=""
  local tool_version=""

  echo "=== AI Coding Assistant CLI Status ==="
  for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      tool_path="$(which "$tool")"
      tool_version="$("$tool" --version 2>&1 | head -n 1 || echo "unknown")"
      printf "  [✓] %-10s : %s\n      Path: %s\n" "$tool" "$tool_version" "$tool_path"
    else
      printf "  [✗] %-10s : NOT INSTALLED or NOT in PATH\n" "$tool"
    fi
  done
}
ai-status() {
  ai_status "$@"
}

# Reload the active shell configuration
reload_shell() {
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    echo "Reloading ~/.zshrc..."
    # shellcheck disable=SC1090
    source "$HOME/.zshrc"
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    echo "Reloading ~/.bashrc..."
    # shellcheck disable=SC1090
    source "$HOME/.bashrc"
  else
    echo "Unknown shell; please restart your terminal."
  fi
}

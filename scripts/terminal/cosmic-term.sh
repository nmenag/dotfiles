#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Setting up COSMIC Terminal (cosmic-term)..."

# 1. Install cosmic-term via native APT if not already installed
if command -v cosmic-term &>/dev/null; then
  echo "COSMIC Terminal is already installed: $(command -v cosmic-term)"
  echo "Version: $(cosmic-term --version 2>&1 | head -n 1 || echo 'unknown')"
else
  echo "Installing cosmic-term via APT..."
  sudo apt-get update -y
  sudo apt-get install -y cosmic-term
fi

# 2. Configure COSMIC Terminal to match Ghostty (Tilix Default theme, keybindings, UI)
COSMIC_TERM_DIR="$HOME/.config/cosmic/com.system76.CosmicTerm/v1"
BACKUP_BASE="$HOME/.dotfiles_backup/cosmic-term"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

mkdir -p "$COSMIC_TERM_DIR"

write_cosmic_config() {
  local filename="$1"
  local content="$2"
  local target="$COSMIC_TERM_DIR/$filename"

  if [[ -f "$target" ]]; then
    local current
    current="$(cat "$target")"
    if [[ "$current" == "$content" ]]; then
      return 0
    fi
    mkdir -p "$BACKUP_BASE/$TIMESTAMP"
    cp -a "$target" "$BACKUP_BASE/$TIMESTAMP/$filename"
  fi

  printf '%s' "$content" > "$target"
}

TILIX_SCHEME_MAP='{
    0: (
        name: "Tilix Default",
        foreground: "#efefef",
        background: "#303030",
        cursor: "#efefef",
        bright_foreground: "#ededeb",
        dim_foreground: "#d3d6cf",
        normal: (
            black: "#000000",
            red: "#cc0000",
            green: "#4d9a05",
            yellow: "#c3a000",
            blue: "#3464a3",
            magenta: "#754f7b",
            cyan: "#05979a",
            white: "#d3d6cf",
        ),
        bright: (
            black: "#545652",
            red: "#ef2828",
            green: "#89e234",
            yellow: "#fbe84f",
            blue: "#729ecf",
            magenta: "#ac7ea8",
            cyan: "#34e2e2",
            white: "#ededeb",
        ),
    ),
}'

SHORTCUTS_RON='{
    (
        modifiers: [
            Ctrl,
        ],
        key: "c",
    ): CopyOrSigint,
    (
        modifiers: [
            Ctrl,
        ],
        key: "v",
    ): Paste,
}'

echo "Applying Ghostty-equivalent theme (Tilix Default), shortcuts (Ctrl+C/Ctrl+V), and UI config..."
write_cosmic_config "color_schemes_dark" "$TILIX_SCHEME_MAP"
write_cosmic_config "color_schemes_light" "$TILIX_SCHEME_MAP"
write_cosmic_config "syntax_theme_dark" '"Tilix Default"'
write_cosmic_config "syntax_theme_light" '"Tilix Default"'
write_cosmic_config "app_theme" 'Dark'
write_cosmic_config "shortcuts_custom" "$SHORTCUTS_RON"
write_cosmic_config "tab_new_inherit_working_directory" 'true'
write_cosmic_config "show_pane_borders" 'true'
write_cosmic_config "opacity" '100'
write_cosmic_config "show_headerbar" 'true'

# 3. Pin COSMIC Terminal in COSMIC Dock favorites alongside existing apps (if favorites file exists)
FAVORITES_FILE="$HOME/.config/cosmic/com.system76.CosmicAppList/v1/favorites"
if [[ -f "$FAVORITES_FILE" ]] && ! grep -q '"com.system76.CosmicTerm"' "$FAVORITES_FILE"; then
  mkdir -p "$BACKUP_BASE/$TIMESTAMP"
  cp -a "$FAVORITES_FILE" "$BACKUP_BASE/$TIMESTAMP/favorites"
  sed -i 's/^]/    "com.system76.CosmicTerm",\n]/' "$FAVORITES_FILE"
  echo "Pinned COSMIC Terminal (com.system76.CosmicTerm) to COSMIC dock favorites."
fi

echo "COSMIC Terminal setup and configuration completed successfully!"

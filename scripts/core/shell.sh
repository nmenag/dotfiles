#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Configuring Shell Dotfiles (Bash & Oh My Zsh) ==="

BACKUP_DIR="$HOME/.dotfiles_backup/shell_$(date +%Y%m%d_%H%M%S)"

backup_file() {
  local target="$1"
  if [[ -f "$target" && ! -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp -p "$target" "$BACKUP_DIR/$(basename "$target")"
    echo "  Backed up $target -> $BACKUP_DIR/$(basename "$target")"
  fi
}

# 1. Ensure Zsh and Oh My Zsh are installed
if ! command -v zsh &>/dev/null; then
  echo "Zsh not found. Installing Zsh and prerequisites..."
  sudo apt-get update -y
  sudo apt-get install -y zsh curl git
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Downloading and installing Oh My Zsh (unattended)..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo "Oh My Zsh installed successfully!"
else
  echo "Oh My Zsh is already installed at $HOME/.oh-my-zsh."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

# 2. Install Oh My Zsh custom plugins idempotently
install_omz_plugin() {
  local name="$1"
  local repo="$2"
  local target_dir="$ZSH_CUSTOM/plugins/$name"

  if [[ -d "$target_dir" ]]; then
    echo "  OMZ plugin '$name' already installed."
  else
    echo "  Cloning OMZ plugin '$name'..."
    git clone --depth=1 "$repo" "$target_dir"
  fi
}

echo "Installing productivity plugins for Oh My Zsh..."
install_omz_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

# 3. Install custom DevEx theme
echo "Installing custom devex theme..."
if [[ -f "$ROOT_DIR/shell/zsh/custom/themes/devex.zsh-theme" ]]; then
  cp -f "$ROOT_DIR/shell/zsh/custom/themes/devex.zsh-theme" "$ZSH_CUSTOM/themes/devex.zsh-theme"
  echo "  Copied devex.zsh-theme to $ZSH_CUSTOM/themes/"
fi

# 4. Configure ~/.zshrc integration idempotently
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
  # Ensure Oh My Zsh core loader is present even if ~/.zshrc was pre-created by another tool
  if ! grep -q "oh-my-zsh.sh" "$ZSHRC"; then
    backup_file "$ZSHRC"
    echo "  Prepending Oh My Zsh initialization to existing ~/.zshrc..."
    OMZ_HEADER=$'export ZSH="$HOME/.oh-my-zsh"\nZSH_THEME="robbyrussell"\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting)\nif [[ -f "$ZSH/oh-my-zsh.sh" ]]; then\n  source "$ZSH/oh-my-zsh.sh"\nfi\n'
    printf '%s\n%s\n' "$OMZ_HEADER" "$(cat "$ZSHRC")" > "${ZSHRC}.tmp" && mv "${ZSHRC}.tmp" "$ZSHRC"
  fi

  # Ensure plugins line contains git, zsh-autosuggestions, and zsh-syntax-highlighting if only git is set
  if grep -q "^plugins=(git)" "$ZSHRC"; then
    backup_file "$ZSHRC"
    echo "  Updating plugins list in ~/.zshrc to include autosuggestions and syntax highlighting..."
    sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
  fi

  # Ingest loader block idempotently
  if ! grep -q "DOTFILES SHELL INTEGRATION" "$ZSHRC"; then
    backup_file "$ZSHRC"
    echo "  Adding dotfiles loader to ~/.zshrc..."
    cat << EOF >> "$ZSHRC"

# >>> DOTFILES SHELL INTEGRATION >>>
if [[ -f "$ROOT_DIR/shell/zshrc.sh" ]]; then
  source "$ROOT_DIR/shell/zshrc.sh"
fi
# <<< DOTFILES SHELL INTEGRATION <<<
EOF
  else
    echo "  Dotfiles integration already present in ~/.zshrc"
  fi
else
  echo "  Warning: ~/.zshrc does not exist. Creating a minimal one with dotfiles loader..."
  cat << EOF > "$ZSHRC"
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
if [[ -f "\$ZSH/oh-my-zsh.sh" ]]; then
  source "\$ZSH/oh-my-zsh.sh"
fi

# >>> DOTFILES SHELL INTEGRATION >>>
if [[ -f "$ROOT_DIR/shell/zshrc.sh" ]]; then
  source "$ROOT_DIR/shell/zshrc.sh"
fi
# <<< DOTFILES SHELL INTEGRATION <<<
EOF
fi

# 5. Configure ~/.bashrc integration and auto-launch Zsh in interactive terminals idempotently
BASHRC="$HOME/.bashrc"
if [[ ! -f "$BASHRC" ]]; then
  touch "$BASHRC"
fi

if ! grep -q "DOTFILES SHELL INTEGRATION" "$BASHRC"; then
  backup_file "$BASHRC"
  echo "  Adding dotfiles loader to ~/.bashrc..."
  LOADER_BLOCK="
# >>> DOTFILES SHELL INTEGRATION >>>
if [[ -f \"$ROOT_DIR/shell/bashrc.sh\" ]]; then
  source \"$ROOT_DIR/shell/bashrc.sh\"
fi
# <<< DOTFILES SHELL INTEGRATION <<<
"
  if grep -q "exec zsh" "$BASHRC"; then
    # Insert before exec zsh
    awk -v block="$LOADER_BLOCK" '/exec zsh/ {print block; print; next} 1' "$BASHRC" > "${BASHRC}.tmp" && mv "${BASHRC}.tmp" "$BASHRC"
  else
    echo "$LOADER_BLOCK" >> "$BASHRC"
  fi
else
  echo "  Dotfiles integration already present in ~/.bashrc"
fi

# Ensure interactive Bash terminals automatically switch to Zsh + Oh My Zsh
# (handles active desktop sessions before re-login or terminals spawning /bin/bash)
if ! grep -q "exec zsh" "$BASHRC"; then
  backup_file "$BASHRC"
  echo "  Adding automatic Zsh handoff for interactive terminals to ~/.bashrc..."
  cat << 'EOF' >> "$BASHRC"

# Start Zsh automatically in interactive terminals
if [[ $- == *i* ]] && [[ -z "${ZSH_VERSION:-}" ]] && [[ -z "${BASH_EXEC_ZSH_SKIP:-}" ]] && command -v zsh >/dev/null 2>&1; then
  exec zsh -l
fi
EOF
fi

# 6. Ensure executable permissions
chmod +x "$ROOT_DIR"/shell/*.sh 2>/dev/null || true

# 7. Set Zsh as the default login shell in /etc/passwd non-interactively
ZSH_BIN="$(command -v zsh || true)"
TARGET_USER="${SUDO_USER:-${USER:-$(id -un)}}"
USER_LOGIN_SHELL="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f7 || echo "${SHELL:-}")"

if [[ -n "$ZSH_BIN" ]]; then
  if [[ "$USER_LOGIN_SHELL" != "$ZSH_BIN" ]]; then
    echo "Setting Zsh ($ZSH_BIN) as default login shell for $TARGET_USER..."
    if sudo usermod -s "$ZSH_BIN" "$TARGET_USER" 2>/dev/null || sudo chsh -s "$ZSH_BIN" "$TARGET_USER" 2>/dev/null; then
      echo "  Default login shell updated to $ZSH_BIN for $TARGET_USER."
    else
      echo "  Could not update /etc/passwd automatically; ~/.bashrc will still auto-launch Zsh in interactive terminals."
    fi
  else
    echo "Default login shell for $TARGET_USER is already $ZSH_BIN."
  fi
fi

echo "Shell dotfiles installation and configuration completed successfully!"

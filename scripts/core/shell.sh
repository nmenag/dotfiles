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
    cat << 'EOF' >> "$ZSHRC"

# >>> DOTFILES SHELL INTEGRATION >>>
if [[ -f "$HOME/personal-projects/dotfiles/shell/zshrc.sh" ]]; then
  source "$HOME/personal-projects/dotfiles/shell/zshrc.sh"
fi
# <<< DOTFILES SHELL INTEGRATION <<<
EOF
  else
    echo "  Dotfiles integration already present in ~/.zshrc"
  fi
else
  echo "  Warning: ~/.zshrc does not exist. Creating a minimal one with dotfiles loader..."
  cat << 'EOF' > "$ZSHRC"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# >>> DOTFILES SHELL INTEGRATION >>>
if [[ -f "$HOME/personal-projects/dotfiles/shell/zshrc.sh" ]]; then
  source "$HOME/personal-projects/dotfiles/shell/zshrc.sh"
fi
# <<< DOTFILES SHELL INTEGRATION <<<
EOF
fi

# 5. Configure ~/.bashrc integration idempotently
BASHRC="$HOME/.bashrc"
if [[ -f "$BASHRC" ]]; then
  if ! grep -q "DOTFILES SHELL INTEGRATION" "$BASHRC"; then
    backup_file "$BASHRC"
    echo "  Adding dotfiles loader to ~/.bashrc..."
    LOADER_BLOCK=$'\n# >>> DOTFILES SHELL INTEGRATION >>>\nif [[ -f "$HOME/personal-projects/dotfiles/shell/bashrc.sh" ]]; then\n  source "$HOME/personal-projects/dotfiles/shell/bashrc.sh"\nfi\n# <<< DOTFILES SHELL INTEGRATION <<<\n'
    if grep -q "exec zsh" "$BASHRC"; then
      # Insert before exec zsh
      awk -v block="$LOADER_BLOCK" '/exec zsh/ {print block; print; next} 1' "$BASHRC" > "${BASHRC}.tmp" && mv "${BASHRC}.tmp" "$BASHRC"
    else
      echo "$LOADER_BLOCK" >> "$BASHRC"
    fi
  else
    echo "  Dotfiles integration already present in ~/.bashrc"
  fi
fi

# 6. Ensure executable permissions
chmod +x "$ROOT_DIR"/shell/*.sh 2>/dev/null || true

# 7. Check default shell
CURRENT_SHELL="$(basename "$SHELL")"
if [[ "$CURRENT_SHELL" != "zsh" ]]; then
  echo "Current shell is $CURRENT_SHELL."
  if command -v zsh &>/dev/null; then
    echo "To make Zsh your default shell, run: chsh -s $(command -v zsh)"
  fi
fi

echo "Shell dotfiles installation and configuration completed successfully!"

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source .env if variables are missing
if [[ -z "${EMAIL:-}" || -z "${USERNAME:-}" ]]; then
  if [[ -f "$ROOT_DIR/.env" ]]; then
    echo "Loading environment variables from $ROOT_DIR/.env..."
    # shellcheck disable=SC1091
    source "$ROOT_DIR/.env"
  fi
fi

if [[ -z "${EMAIL:-}" || -z "${USERNAME:-}" ]]; then
  echo "WARNING: EMAIL and USERNAME should be set in .env or exported in your shell."
  echo "Current EMAIL='${EMAIL:-}', USERNAME='${USERNAME:-}'"
fi

echo "Configuring Git..."

# Set user identity if provided
if [[ -n "${USERNAME:-}" ]]; then
  git config --global user.name "$USERNAME"
  echo "Set git user.name to: $USERNAME"
fi

if [[ -n "${EMAIL:-}" ]]; then
  git config --global user.email "$EMAIL"
  echo "Set git user.email to: $EMAIL"
fi

# Core Git Settings
git config --global init.defaultBranch main
git config --global core.editor "nano -w"

# Color Configuration
git config --global color.ui auto
git config --global color.status auto
git config --global color.branch auto
git config --global color.diff auto
git config --global color.interactive auto

git config --global color.branch.current "yellow reverse"
git config --global color.branch.local "yellow"
git config --global color.branch.remote "green"

git config --global color.diff.meta "yellow bold"
git config --global color.diff.frag "magenta bold"
git config --global color.diff.old "red bold"
git config --global color.diff.new "green bold"

git config --global color.status.added "yellow"
git config --global color.status.changed "green"
git config --global color.status.untracked "cyan"

# Aliases
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# SSH Key Configuration (Idempotent)
SSH_KEY="$HOME/.ssh/id_ed25519"
if [[ -f "$SSH_KEY" ]]; then
  echo "SSH key already exists at $SSH_KEY. Skipping generation."
else
  echo "Generating new ED25519 SSH key..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "${EMAIL:-git-user}" -f "$SSH_KEY" -N ""
  echo "Generated SSH key at $SSH_KEY"
fi

# Add key to ssh-agent
eval "$(ssh-agent -s)" > /dev/null
ssh-add "$SSH_KEY" 2>/dev/null || true

# Copy public key to clipboard if clipboard tool is available
if command -v wl-copy &>/dev/null; then
  wl-copy < "${SSH_KEY}.pub"
  echo "Public key copied to clipboard using wl-copy."
elif command -v xclip &>/dev/null; then
  xclip -selection clipboard < "${SSH_KEY}.pub"
  echo "Public key copied to clipboard using xclip."
else
  echo "Public key (${SSH_KEY}.pub):"
  cat "${SSH_KEY}.pub"
fi

echo "Git configuration completed successfully!"

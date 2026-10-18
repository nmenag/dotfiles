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

set_git_config() {
  local key="$1"
  local val="$2"
  git config --global --replace-all "$key" "$val"
}

# Set user identity if provided
if [[ -n "${USERNAME:-}" ]]; then
  set_git_config user.name "$USERNAME"
  echo "Set git user.name to: $USERNAME"
fi

if [[ -n "${EMAIL:-}" ]]; then
  set_git_config user.email "$EMAIL"
  echo "Set git user.email to: $EMAIL"
fi

# Core Git Settings
set_git_config init.defaultBranch main
set_git_config core.editor "nano -w"

# Color Configuration
set_git_config color.ui auto
set_git_config color.status auto
set_git_config color.branch auto
set_git_config color.diff auto
set_git_config color.interactive auto

set_git_config color.branch.current "yellow reverse"
set_git_config color.branch.local "yellow"
set_git_config color.branch.remote "green"

set_git_config color.diff.meta "yellow bold"
set_git_config color.diff.frag "magenta bold"
set_git_config color.diff.old "red bold"
set_git_config color.diff.new "green bold"

set_git_config color.status.added "yellow"
set_git_config color.status.changed "green"
set_git_config color.status.untracked "cyan"

# Aliases
set_git_config alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

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

# Setup Commitlint commit-msg hook if inside dotfiles git repo
HOOKS_DIR="$ROOT_DIR/.git/hooks"
if [[ -d "$HOOKS_DIR" ]]; then
  echo "Installing Commitlint commit-msg hook..."
  cat <<'EOF' > "$HOOKS_DIR/commit-msg"
#!/bin/bash
set -euo pipefail

COMMIT_MSG_FILE="$1"
FIRST_LINE="$(head -n 1 "$COMMIT_MSG_FILE")"

if [[ "$FIRST_LINE" =~ ^Merge.* || "$FIRST_LINE" =~ ^fixup\!.* || "$FIRST_LINE" =~ ^squash\!.* ]]; then
  exit 0
fi

if npx --version >/dev/null 2>&1; then
  npx --yes @commitlint/cli --edit "$COMMIT_MSG_FILE"
elif commitlint --version >/dev/null 2>&1; then
  commitlint --edit "$COMMIT_MSG_FILE"
else
  PATTERN="^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([a-zA-Z0-9_.-]+\))?: .+"
  if ! echo "$FIRST_LINE" | grep -qE "$PATTERN"; then
    echo -e "\033[0;31m[commitlint error]\033[0m Invalid commit message format:"
    echo "  \"$FIRST_LINE\""
    echo ""
    echo "Commit messages must follow Conventional Commits specification:"
    echo "  <type>(<optional scope>): <subject>"
    echo ""
    echo "Allowed types:"
    echo "  feat, fix, chore, docs, style, refactor, perf, test, build, ci, revert"
    echo ""
    echo "Examples:"
    echo "  feat: add commitlint support"
    echo "  chore(cli): rename dotctl to mena"
    echo "  docs: update CI documentation"
    exit 1
  fi
fi
EOF
  chmod +x "$HOOKS_DIR/commit-msg"
  echo "Commitlint commit-msg hook active at $HOOKS_DIR/commit-msg"
fi

echo "Git configuration completed successfully!"

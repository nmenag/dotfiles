#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Load environment variables if available
if [[ -z "${EMAIL:-}" || -z "${USERNAME:-}" ]]; then
  if [[ -f "$ROOT_DIR/.env" ]]; then
    log_info "Loading environment variables from $ROOT_DIR/.env..."
    # shellcheck disable=SC1091
    source "$ROOT_DIR/.env"
  fi
fi

# Fallback values from git config or system
if [[ -z "${EMAIL:-}" ]]; then
  EMAIL="$(git config --global user.email 2>/dev/null || echo "$USER@$(hostname 2>/dev/null || echo "localhost")")"
fi
if [[ -z "${USERNAME:-}" ]]; then
  USERNAME="$(git config --global user.name 2>/dev/null || echo "$USER")"
fi

SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519}"
SSH_DIR="$(dirname "$SSH_KEY")"
SSH_CONFIG="$SSH_DIR/config"
FORCE=false

show_help() {
  cat << EOF
Usage: ./scripts/core/github-ssh.sh [COMMAND] [OPTIONS]

Generates, configures, and deploys ED25519 SSH keys for GitHub authentication.

Commands:
  all         Generate SSH key, configure ~/.ssh/config, add to ssh-agent, deploy, and verify (default)
  generate    Generate ED25519 SSH key (if missing), configure ~/.ssh/config, and register with agent
  deploy      Deploy public key to GitHub (via gh CLI / clipboard) and verify SSH connection
  test        Test GitHub SSH authentication (ssh -T git@github.com)
  help, -h    Show this help message

Options:
  --force     Force regeneration of existing SSH key (creates a timestamped backup first)

Environment Variables:
  EMAIL       Email comment for SSH key (current: '${EMAIL:-}')
  USERNAME    GitHub username (current: '${USERNAME:-}')
  SSH_KEY     Target SSH private key path (current: '$SSH_KEY')
EOF
}

# Ensure ~/.ssh directory exists with secure permissions
ensure_ssh_dir() {
  if [[ ! -d "$SSH_DIR" ]]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    log_info "Created SSH directory at $SSH_DIR with 0700 permissions."
  else
    chmod 700 "$SSH_DIR"
  fi
}

# Generate ED25519 SSH key idempotently
generate_ssh_key() {
  ensure_ssh_dir

  if [[ -f "$SSH_KEY" && "$FORCE" != "true" ]]; then
    log_info "SSH key already exists at $SSH_KEY. Skipping generation (use --force to regenerate)."
    chmod 600 "$SSH_KEY"
    [[ -f "${SSH_KEY}.pub" ]] && chmod 644 "${SSH_KEY}.pub"
    return 0
  fi

  if [[ -f "$SSH_KEY" && "$FORCE" == "true" ]]; then
    local backup_key="${SSH_KEY}.bak.$(date +%Y%m%d%H%M%S)"
    log_warn "Backing up existing SSH key to $backup_key before regeneration..."
    cp "$SSH_KEY" "$backup_key"
    [[ -f "${SSH_KEY}.pub" ]] && cp "${SSH_KEY}.pub" "${backup_key}.pub"
  fi

  log_info "Generating new ED25519 SSH key for '${EMAIL:-git-user}'..."
  ssh-keygen -t ed25519 -C "${EMAIL:-git-user}" -f "$SSH_KEY" -N ""
  chmod 600 "$SSH_KEY"
  chmod 644 "${SSH_KEY}.pub"
  log_success "Generated ED25519 SSH key at $SSH_KEY"
}

# Configure ~/.ssh/config for GitHub
configure_ssh_config() {
  ensure_ssh_dir

  if [[ ! -f "$SSH_CONFIG" ]]; then
    touch "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
  else
    chmod 600 "$SSH_CONFIG"
  fi

  if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    log_info "Adding GitHub configuration block to $SSH_CONFIG..."
    cat << EOF >> "$SSH_CONFIG"

# GitHub SSH Configuration
Host github.com
  HostName github.com
  User git
  IdentityFile $SSH_KEY
  IdentitiesOnly yes
  AddKeysToAgent yes
EOF
    log_success "GitHub SSH configuration appended to $SSH_CONFIG"
  else
    log_info "GitHub configuration already present in $SSH_CONFIG"
  fi
}

# Start ssh-agent if needed and register key
setup_ssh_agent() {
  if [[ -z "${SSH_AUTH_SOCK:-}" ]] || ! ssh-add -l &>/dev/null && [[ $? -eq 2 ]]; then
    log_info "Starting ssh-agent..."
    eval "$(ssh-agent -s)" > /dev/null
  fi

  if [[ -f "$SSH_KEY" ]]; then
    if ssh-add "$SSH_KEY" 2>/dev/null; then
      log_success "Added $SSH_KEY to active ssh-agent."
    else
      log_warn "Could not add key to ssh-agent automatically."
    fi
  fi
}

# Deploy public key to GitHub (via gh CLI, or clipboard + browser URL)
deploy_ssh_key() {
  if [[ ! -f "${SSH_KEY}.pub" ]]; then
    log_error "Public key not found at ${SSH_KEY}.pub. Run 'generate' first."
    return 1
  fi

  local key_title="${HOSTNAME:-workstation}-$(date +%Y%m%d)"
  local key_content
  key_content="$(cat "${SSH_KEY}.pub")"
  local deployed_via_gh=false

  log_info "Deploying SSH public key to GitHub..."

  # Attempt automated upload via GitHub CLI if available and authenticated
  if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null; then
      local gh_output=""
      local gh_exit=0
      gh_output="$(gh ssh-key add "${SSH_KEY}.pub" --title "$key_title" --type authentication 2>&1)" || gh_exit=$?

      if [[ $gh_exit -eq 0 ]]; then
        log_success "SSH key deployed to GitHub via GitHub CLI ($key_title)!"
        deployed_via_gh=true
      elif echo "$gh_output" | grep -qi "already.*in use\|already.*exists\|already been added"; then
        log_info "SSH key is already registered on your GitHub account."
        deployed_via_gh=true
      elif echo "$gh_output" | grep -qi "admin:public_key"; then
        log_warn "GitHub CLI lacks the 'admin:public_key' scope required to upload keys."
        echo "  To grant permission to gh: gh auth refresh -h github.com -s admin:public_key"
      else
        log_warn "GitHub CLI key upload returned: $gh_output"
      fi
    else
      log_warn "GitHub CLI is installed but not authenticated. Run 'gh auth login' to enable automated deployment."
    fi
  fi

  # Copy to clipboard as universal fallback / verification helper
  if command -v wl-copy &>/dev/null; then
    wl-copy < "${SSH_KEY}.pub"
    log_success "Public key copied to clipboard (Wayland: wl-copy)."
  elif command -v xclip &>/dev/null; then
    xclip -selection clipboard < "${SSH_KEY}.pub"
    log_success "Public key copied to clipboard (X11: xclip)."
  elif command -v xsel &>/dev/null; then
    xsel --clipboard --input < "${SSH_KEY}.pub"
    log_success "Public key copied to clipboard (X11: xsel)."
  else
    echo ""
    log_info "Public key content (${SSH_KEY}.pub):"
    echo -e "${YELLOW}$key_content${NC}"
    echo ""
  fi

  if [[ "$deployed_via_gh" != "true" ]]; then
    echo ""
    log_info "To complete manual deployment, paste the key into your GitHub account:"
    echo "  URL: https://github.com/settings/ssh/new"
    echo "  Title suggestion: $key_title"
    echo ""
  fi
}

# Verify SSH authentication with GitHub
verify_ssh_connection() {
  log_info "Testing SSH connection to GitHub (ssh -T git@github.com)..."
  local test_out=""
  test_out="$(ssh -o StrictHostKeyChecking=accept-new -o BatchMode=yes -o ConnectTimeout=8 -T git@github.com 2>&1 || true)"

  if echo "$test_out" | grep -qi "successfully authenticated"; then
    log_success "GitHub SSH authentication verified successfully!"
    echo "  $test_out"
    return 0
  else
    log_warn "GitHub SSH authentication check did not confirm login:"
    echo "  $test_out"
    echo "  Ensure your public key is added to https://github.com/settings/ssh/new"
    return 0
  fi
}

# Parse options and commands
COMMAND="all"
for arg in "$@"; do
  case "$arg" in
    --force)
      FORCE=true
      ;;
    generate|deploy|test|verify|all)
      COMMAND="$arg"
      ;;
    help|--help|-h)
      show_help
      exit 0
      ;;
    *)
      log_error "Unknown argument: $arg"
      show_help
      exit 1
      ;;
  esac
done

case "$COMMAND" in
  generate)
    generate_ssh_key
    configure_ssh_config
    setup_ssh_agent
    ;;
  deploy)
    configure_ssh_config
    setup_ssh_agent
    deploy_ssh_key
    verify_ssh_connection
    ;;
  test|verify)
    setup_ssh_agent
    verify_ssh_connection
    ;;
  all)
    generate_ssh_key
    configure_ssh_config
    setup_ssh_agent
    deploy_ssh_key
    verify_ssh_connection
    ;;
esac

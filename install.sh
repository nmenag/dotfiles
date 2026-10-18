#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR" && pwd)"

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

show_help() {
  cat << EOF
Usage: ./install.sh [OPTIONS] [CATEGORY]

Bootstraps core workstation requirements (Git & Docker) and launches mena.
All development tools, runtimes, browsers, editors, and shell dotfiles are managed via mena.

Arguments:
  [CATEGORY]     Optional category to install (e.g. core, browser, cli, runtimes, dev, ai, shell)

Options:
  -d, --dry-run  Preview actions without modifying the system
  -y, --yes      Approve installation non-interactively
  --help, -h     Show this help message
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

if [[ "${1:-}" == "--core" ]]; then
  log_info "Executing core workstation foundations setup directly..."
  bash "$ROOT_DIR/scripts/core.sh" "${@:2}"
  exit 0
fi

log_info "Bootstrapping workstation environment from: $ROOT_DIR"

# 1. Load environment variables
if [[ -f "$ROOT_DIR/.env" ]]; then
  log_info "Loading environment variables from .env..."
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
else
  log_warn "No .env found. Copy .env.sample to .env to configure EMAIL and USERNAME."
fi

# 2. Update package lists & install core system build tools
log_info "Updating package lists..."
sudo apt-get update -y

install_pkg() {
  local pkg="$1"
  if dpkg -s "$pkg" &>/dev/null; then
    echo "  Package already installed: $pkg"
  else
    echo "  Installing package: $pkg..."
    sudo apt-get install -y "$pkg"
  fi
}

log_info "Installing core build tools and dependencies..."
CORE_PACKAGES=(
  make
  build-essential
  libssl-dev
  zlib1g-dev
  libbz2-dev
  libreadline-dev
  libsqlite3-dev
  libyaml-dev
  wget
  curl
  git
  llvm
  snapd
  ca-certificates
  gnupg
  lsb-release
)

for pkg in "${CORE_PACKAGES[@]}"; do
  install_pkg "$pkg"
done

# Handle ncurses development package
if apt-cache show libncurses-dev &>/dev/null; then
  install_pkg libncurses-dev
elif apt-cache show libncurses5-dev &>/dev/null; then
  install_pkg libncurses5-dev
fi

# 3. Core Foundation: Git & Docker are core (yes or yes are installed)
log_info "Configuring core essentials: Git and Docker..."
bash "$ROOT_DIR/scripts/gitconfig.sh"
bash "$ROOT_DIR/scripts/docker.sh"

# 4. Build and link mena Rust CLI
if [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

if ! command -v cargo &>/dev/null; then
  if [[ -x "$HOME/.cargo/bin/cargo" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
  fi
fi

if command -v cargo &>/dev/null; then
  log_info "Compiling mena CLI (Rust + Clap + Dialoguer)..."
  cargo build --release --manifest-path "$ROOT_DIR/mena/Cargo.toml" --quiet
  mkdir -p "$HOME/.local/bin"
  ln -sfn "$ROOT_DIR/mena/target/release/mena" "$HOME/.local/bin/mena"
  ln -sfn "$ROOT_DIR/mena/target/release/mena" "$HOME/.local/bin/dotctl"
  log_success "mena CLI installed and linked to ~/.local/bin/mena (aliased to dotctl)"
else
  log_warn "Cargo not found in PATH. Install Rust toolchain to build mena."
fi

# 5. Hand off workstation installation to mena
export PATH="$HOME/.local/bin:$PATH"
if command -v mena &>/dev/null; then
  log_success "Core environment ready. Launching mena workstation manager..."
  exec mena install "$@"
elif [[ -x "$ROOT_DIR/mena/target/release/mena" ]]; then
  log_success "Core environment ready. Launching mena workstation manager..."
  exec "$ROOT_DIR/mena/target/release/mena" install "$@"
else
  log_warn "mena binary not available. Run 'cargo build --release --manifest-path mena/Cargo.toml' to build it."
fi

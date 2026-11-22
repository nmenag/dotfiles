#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR" && pwd)"

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

RETRY_SCRIPT="$ROOT_DIR/scripts/retry.sh"

run_with_retry() {
  if [[ -f "$RETRY_SCRIPT" ]]; then
    bash "$RETRY_SCRIPT" -- "$@"
  else
    "$@"
  fi
}

show_help() {
  cat << EOF
Usage: ./install.sh [OPTIONS] [CATEGORY]

Bootstraps core workstation requirements (Git & Docker) and launches mena.
All development tools, runtimes, browsers, editors, and shell dotfiles are managed via mena.

Arguments:
  [CATEGORY]     Optional category to install (e.g. core, browser, cli, version-managers, dev, database, api, ai, shell)

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
  bash "$ROOT_DIR/scripts/core/core.sh" "${@:2}"
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
if ! run_with_retry sudo apt-get update -y; then
  log_warn "Package list update finished with warnings or errors; continuing."
fi

FAILED_BOOTSTRAP_ITEMS=()

install_pkg() {
  local pkg="$1"
  if dpkg -s "$pkg" &>/dev/null; then
    echo "  Package already installed: $pkg"
  else
    echo "  Installing package: $pkg..."
    if ! run_with_retry sudo apt-get install -y "$pkg"; then
      log_error "Failed to install package: $pkg"
      FAILED_BOOTSTRAP_ITEMS+=("Package: $pkg")
    fi
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
else
  log_error "libncurses development package not found in APT cache"
  FAILED_BOOTSTRAP_ITEMS+=("Package: libncurses-dev")
fi

# 3. Core Foundation: Git, Docker, and Shell are core (yes or yes are installed)
log_info "Configuring core essentials: Git, Docker, and Shell Dotfiles..."
if ! run_with_retry bash "$ROOT_DIR/scripts/core/gitconfig.sh"; then
  log_error "Core Git configuration failed"
  FAILED_BOOTSTRAP_ITEMS+=("Git Configuration (scripts/core/gitconfig.sh)")
fi

if ! run_with_retry bash "$ROOT_DIR/scripts/core/docker.sh"; then
  log_error "Core Docker configuration failed"
  FAILED_BOOTSTRAP_ITEMS+=("Docker Configuration (scripts/core/docker.sh)")
fi

if ! run_with_retry bash "$ROOT_DIR/scripts/core/shell.sh"; then
  log_error "Core Shell Dotfiles configuration failed"
  FAILED_BOOTSTRAP_ITEMS+=("Shell Dotfiles Configuration (scripts/core/shell.sh)")
fi

if [[ ${#FAILED_BOOTSTRAP_ITEMS[@]} -gt 0 ]]; then
  echo ""
  log_warn "Bootstrap completed with errors in ${#FAILED_BOOTSTRAP_ITEMS[@]} component(s):"
  for failed in "${FAILED_BOOTSTRAP_ITEMS[@]}"; do
    echo -e "  ${YELLOW}!${NC} $failed"
  done
  echo ""
fi

# 4. Build and link mena Rust CLI
load_rust_env() {
  for dir in "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.local/share/mise/shims" "$HOME/.asdf/shims"; do
    if [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]]; then
      export PATH="$dir:$PATH"
    fi
  done

  if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    # shellcheck disable=SC1091
    . "$HOME/.asdf/asdf.sh"
  fi
}

load_rust_env

if ! command -v cargo &>/dev/null; then
  AUTO_YES=false
  DRY_RUN=false
  for arg in "$@"; do
    case "$arg" in
      -y|--yes) AUTO_YES=true ;;
      -d|--dry-run) DRY_RUN=true ;;
    esac
  done

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY-RUN] Cargo not found; would bootstrap version manager (Mise or ASDF) and Rust toolchain."
  else
    VM_CHOICE=""
    if command -v mise &>/dev/null || [[ -x "$HOME/.local/bin/mise" ]]; then
      VM_CHOICE="mise"
      log_info "Mise detected. Installing Rust toolchain via Mise to build mena..."
    elif command -v asdf &>/dev/null || [[ -d "$HOME/.asdf" ]]; then
      VM_CHOICE="asdf"
      log_info "ASDF detected. Installing Rust toolchain via ASDF to build mena..."
    elif [[ "$AUTO_YES" == "true" || ! -t 0 ]]; then
      VM_CHOICE="mise"
      log_info "Cargo not found. Non-interactive mode: bootstrapping Mise and Rust toolchain..."
    else
      echo ""
      log_warn "Rust (cargo) is required to build the mena workstation CLI."
      echo "Select a version manager to install Rust:"
      echo "  1) Mise Version Manager (recommended)"
      echo "  2) ASDF Version Manager"
      read -r -p "Enter choice [1-2, default: 1]: " vm_input || true
      case "${vm_input:-1}" in
        2|asdf|ASDF) VM_CHOICE="asdf" ;;
        *) VM_CHOICE="mise" ;;
      esac
    fi

    if [[ "$VM_CHOICE" == "asdf" ]]; then
      if ! run_with_retry bash "$ROOT_DIR/scripts/version-managers/asdf.sh" rust; then
        log_error "Failed to bootstrap ASDF and Rust toolchain."
        FAILED_BOOTSTRAP_ITEMS+=("Rust via ASDF (scripts/version-managers/asdf.sh rust)")
      fi
    else
      if ! run_with_retry bash "$ROOT_DIR/scripts/version-managers/mise.sh" rust; then
        log_error "Failed to bootstrap Mise and Rust toolchain."
        FAILED_BOOTSTRAP_ITEMS+=("Rust via Mise (scripts/version-managers/mise.sh rust)")
      fi
    fi

    load_rust_env
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

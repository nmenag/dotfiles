#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DRY_RUN=false
for arg in "$@"; do
  if [[ "$arg" == "--dry-run" || "$arg" == "-d" ]]; then
    DRY_RUN=true
  fi
done

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

log_info "Starting Core & System Foundations installation..."
if [[ "$DRY_RUN" == "true" ]]; then
  log_warn "DRY-RUN mode enabled: No system modifications will be performed."
fi

# 1. Load environment variables if available
if [[ -f "$ROOT_DIR/.env" ]]; then
  log_info "Loading environment variables from .env..."
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
elif [[ -f "$ROOT_DIR/.env.sample" ]]; then
  log_warn "No .env file found; using default system settings."
fi

# 2. Update APT package lists
if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[DRY-RUN] Would run: sudo apt-get update -y"
else
  log_info "Updating APT package lists..."
  sudo apt-get update -y
fi

install_pkg() {
  local pkg="$1"
  if dpkg -s "$pkg" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Package already installed: $pkg"
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "  [DRY-RUN] Would install package: $pkg"
    else
      echo "  Installing package: $pkg..."
      sudo apt-get install -y "$pkg"
    fi
  fi
}

# 3. Core build tools, compilation headers, and system utilities
log_info "Installing core build tools and runtime dependencies..."
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

# Handle distribution-dependent ncurses development package
if apt-cache show libncurses-dev &>/dev/null; then
  install_pkg libncurses-dev
elif apt-cache show libncurses5-dev &>/dev/null; then
  install_pkg libncurses5-dev
fi

# 4. Core Git Configuration (SSH key, aliases, conventional commits)
log_info "Configuring Core Git..."
if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[DRY-RUN] Would execute: bash scripts/gitconfig.sh"
else
  bash "$ROOT_DIR/scripts/gitconfig.sh"
fi

# 5. Core Docker CE & Compose Engine
log_info "Configuring Core Docker CE..."
if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[DRY-RUN] Would execute: bash scripts/docker.sh"
else
  bash "$ROOT_DIR/scripts/docker.sh"
fi

log_success "Core & System Foundations installation complete!"

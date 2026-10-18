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
  if ! sudo apt-get update -y; then
    log_warn "APT package list update finished with warnings or errors; continuing with installation."
  fi
fi

FAILED_PACKAGES=()
FAILED_COMPONENTS=()
SUCCESS_COUNT=0

install_pkg() {
  local pkg="$1"
  if dpkg -s "$pkg" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Package already installed: $pkg"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "  [DRY-RUN] Would install package: $pkg"
      SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
      echo "  Installing package: $pkg..."
      if sudo apt-get install -y "$pkg"; then
        echo -e "  ${GREEN}✓${NC} Package installed successfully: $pkg"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
      else
        echo -e "  ${RED}✗${NC} Failed to install package: $pkg"
        FAILED_PACKAGES+=("$pkg")
      fi
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
else
  echo -e "  ${RED}✗${NC} libncurses development package not found in APT cache"
  FAILED_PACKAGES+=("libncurses-dev")
fi

# 4. Core Git Configuration (SSH key, aliases, conventional commits)
log_info "Configuring Core Git..."
if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[DRY-RUN] Would execute: bash scripts/gitconfig.sh"
  SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
  if bash "$ROOT_DIR/scripts/gitconfig.sh"; then
    log_success "Core Git configured successfully!"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    log_error "Core Git configuration encountered errors!"
    FAILED_COMPONENTS+=("Git Configuration (scripts/gitconfig.sh)")
  fi
fi

# 5. Core Docker CE & Compose Engine
log_info "Configuring Core Docker CE..."
if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[DRY-RUN] Would execute: bash scripts/docker.sh"
  SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
else
  if bash "$ROOT_DIR/scripts/docker.sh"; then
    log_success "Core Docker CE configured successfully!"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    log_error "Core Docker CE configuration encountered errors!"
    FAILED_COMPONENTS+=("Docker CE & Compose Engine (scripts/docker.sh)")
  fi
fi

echo ""
echo "=================================================="
echo "         Core Installation Summary                "
echo "=================================================="
if [[ ${#FAILED_PACKAGES[@]} -eq 0 && ${#FAILED_COMPONENTS[@]} -eq 0 ]]; then
  log_success "All core workstation foundations installed and configured successfully!"
  exit 0
else
  log_error "Core installation completed with errors."
  if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
    echo -e "\n${RED}The following ${#FAILED_PACKAGES[@]} package(s) could not be installed:${NC}"
    for pkg in "${FAILED_PACKAGES[@]}"; do
      echo -e "  ${RED}✗${NC} $pkg"
    done
  fi
  if [[ ${#FAILED_COMPONENTS[@]} -gt 0 ]]; then
    echo -e "\n${RED}The following ${#FAILED_COMPONENTS[@]} component(s) failed configuration:${NC}"
    for comp in "${FAILED_COMPONENTS[@]}"; do
      echo -e "  ${RED}✗${NC} $comp"
    done
  fi
  echo ""
  log_warn "Summary: $SUCCESS_COUNT succeeded, $((${#FAILED_PACKAGES[@]} + ${#FAILED_COMPONENTS[@]})) failed."
  exit 1
fi

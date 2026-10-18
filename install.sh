#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
Usage: ./install.sh [OPTION]

Provision development workstation packages and configurations.

Options:
  --all           Run full installation (Core packages, Shell, Desktop apps, ASDF, VS Code, Zed, Ghostty, Herdr, pgAdmin, MongoDB Compass, Brave, Orca, Git, AI tools, Docker, Android Studio)
  --core          Install only core build tools and essential system libraries
  --shell         Configure only Bash and Oh My Zsh dotfiles and plugins
  --ai            Configure only AI CLI adapters (Claude, OpenCode, Codex, Kilo, Agy, Pi)
  --zed           Install only Zed editor
  --ghostty       Install only Ghostty terminal
  --herdr         Install only Herdr workspace manager
  --pgadmin       Install only pgAdmin 4 Desktop
  --mongocompass  Install only MongoDB Compass
  --brave         Install only Brave Browser
  --orca          Install only Orca IDE
  --cursor        Install only Cursor AI Editor
  --mise          Install only Mise Version Manager
  --dotctl        Build and link the interactive dotctl Rust CLI
  --help, -h      Show this help message

Without options, defaults to running the standard installation suite.
EOF
}

MODE="standard"
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  show_help
  exit 0
elif [[ "${1:-}" == "--core" ]]; then
  MODE="core"
elif [[ "${1:-}" == "--shell" ]]; then
  MODE="shell"
elif [[ "${1:-}" == "--ai" ]]; then
  MODE="ai"
elif [[ "${1:-}" == "--zed" ]]; then
  MODE="zed"
elif [[ "${1:-}" == "--ghostty" ]]; then
  MODE="ghostty"
elif [[ "${1:-}" == "--herdr" ]]; then
  MODE="herdr"
elif [[ "${1:-}" == "--pgadmin" ]]; then
  MODE="pgadmin"
elif [[ "${1:-}" == "--mongocompass" ]]; then
  MODE="mongocompass"
elif [[ "${1:-}" == "--brave" ]]; then
  MODE="brave"
elif [[ "${1:-}" == "--orca" ]]; then
  MODE="orca"
elif [[ "${1:-}" == "--cursor" ]]; then
  MODE="cursor"
elif [[ "${1:-}" == "--mise" ]]; then
  MODE="mise"
elif [[ "${1:-}" == "--dotctl" ]]; then
  MODE="dotctl"
elif [[ "${1:-}" == "--all" ]]; then
  MODE="all"
fi

log_info "Starting dotfiles setup from: $ROOT_DIR"

# Check and source environment variables
if [[ -f "$ROOT_DIR/.env" ]]; then
  log_info "Found .env file, loading environment variables..."
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
else
  log_warn "No .env file found. You can copy .env.sample to .env to configure EMAIL and USERNAME."
fi

build_dotctl() {
  if [[ -f "$ROOT_DIR/dotctl/Cargo.toml" ]]; then
    if [[ -d "$HOME/.cargo/bin" ]]; then
      export PATH="$HOME/.cargo/bin:$PATH"
    fi
    if command -v cargo &>/dev/null; then
      log_info "Compiling dotctl interactive CLI (Rust + Clap + Dialoguer)..."
      cargo build --release --manifest-path "$ROOT_DIR/dotctl/Cargo.toml" --quiet
      mkdir -p "$HOME/.local/bin"
      ln -sfn "$ROOT_DIR/dotctl/target/release/dotctl" "$HOME/.local/bin/dotctl"
      log_success "dotctl binary linked to ~/.local/bin/dotctl"
    else
      log_warn "Cargo not found in PATH. Install Rust toolchain to build dotctl."
    fi
  fi
}

# Modular component execution
run_script() {
  local script_name="$1"
  local script_path="$ROOT_DIR/scripts/$script_name"

  if [[ -f "$script_path" ]]; then
    log_info "Running $script_name..."
    bash "$script_path"
    log_success "Finished $script_name"
  else
    log_warn "Script not found: $script_path"
  fi
}

# Selective execution for user-space configs
if [[ "$MODE" == "dotctl" ]]; then
  build_dotctl
  log_success "dotctl build completed!"
  exit 0
elif [[ "$MODE" == "shell" ]]; then
  run_script "shell.sh"
  log_success "Shell dotfiles installation completed!"
  exit 0
elif [[ "$MODE" == "ai" ]]; then
  run_script "ai-tools.sh"
  log_success "AI tools synchronization completed!"
  exit 0
elif [[ "$MODE" == "zed" ]]; then
  run_script "zed.sh"
  log_success "Zed installation completed!"
  exit 0
elif [[ "$MODE" == "ghostty" ]]; then
  run_script "ghostty.sh"
  log_success "Ghostty installation completed!"
  exit 0
elif [[ "$MODE" == "herdr" ]]; then
  run_script "herdr.sh"
  log_success "Herdr installation completed!"
  exit 0
elif [[ "$MODE" == "pgadmin" ]]; then
  run_script "pgadmin.sh"
  log_success "pgAdmin 4 Desktop installation completed!"
  exit 0
elif [[ "$MODE" == "mongocompass" ]]; then
  run_script "mongocompass.sh"
  log_success "MongoDB Compass installation completed!"
  exit 0
elif [[ "$MODE" == "brave" ]]; then
  run_script "brave.sh"
  log_success "Brave Browser installation completed!"
  exit 0
elif [[ "$MODE" == "orca" ]]; then
  run_script "orca.sh"
  log_success "Orca IDE installation completed!"
  exit 0
elif [[ "$MODE" == "cursor" ]]; then
  run_script "cursor.sh"
  log_success "Cursor AI Editor installation completed!"
  exit 0
elif [[ "$MODE" == "mise" ]]; then
  run_script "mise.sh"
  log_success "Mise installation completed!"
  exit 0
fi

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
  cheese
)

for pkg in "${CORE_PACKAGES[@]}"; do
  install_pkg "$pkg"
done

# Handle ncurses development package (libncurses-dev on modern Ubuntu/Pop!_OS, libncurses5-dev on legacy)
if apt-cache show libncurses-dev &>/dev/null; then
  install_pkg libncurses-dev
elif apt-cache show libncurses5-dev &>/dev/null; then
  install_pkg libncurses5-dev
fi

log_info "Cleaning up unused packages..."
sudo apt-get autoremove -y

if [[ "$MODE" == "core" ]]; then
  log_success "Core system packages installed successfully!"
  exit 0
fi

log_info "Running workstation setup modules..."
run_script "shell.sh"
run_script "programs.sh"
run_script "asdf.sh"
run_script "mise.sh"
run_script "vscode.sh"
run_script "cursor.sh"
run_script "zed.sh"
run_script "ghostty.sh"
run_script "herdr.sh"
run_script "pgadmin.sh"
run_script "mongocompass.sh"
run_script "brave.sh"
run_script "orca.sh"
run_script "gitconfig.sh"
run_script "ai-tools.sh"

if [[ "$MODE" == "all" ]]; then
  log_info "Running extended modules..."
  run_script "docker.sh"
  run_script "android-studio.sh"
fi

# Build and link dotctl Rust CLI if toolchain is present
build_dotctl

log_success "Dotfiles workstation installation completed!"
log_info "Tip: Run 'dotctl doctor' to audit your environment or 'dotctl install' to customize."
log_info "Tip: Run './scripts/verify.sh' to validate all scripts and tools."

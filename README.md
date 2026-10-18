# Developer Dotfiles & Workstation Automation

Automated workstation provisioning, development environment setup, unified shell configurations (Bash & Oh My Zsh), and multi-agent AI assistant integrations for Debian/Ubuntu-based distributions.

---

## Features

- **Idempotent & Safe**: Every script checks existing dependencies, avoids duplicate shell exports, handles errors safely (`set -euo pipefail`), and creates automatic timestamped backups before updating user configurations (`~/.dotfiles_backup/`).
- **Unified Shell Layer (Bash & Oh My Zsh)**:
  - Centralized shell configuration under `shell/` for aliases, environment variables, PATH deduplication, and helper functions.
  - Oh My Zsh custom plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) and a lightweight custom prompt theme (`devex.zsh-theme`).
  - Useful DevEx functions: `mkcd`, `extract`, `path_inspect`, `ai-status`, and `reload_shell`.
- **6-in-1 AI Coding Assistant Integration**:
  - Unified source of instructions (`ai/common-instructions.md`), rules (`ai/rules/`), and reusable skills (`ai/skills/`).
  - Specialized adapters with non-destructive symlinks for:
    1. **Claude Code** (`~/.claude`)
    2. **OpenCode** (`~/.config/opencode`)
    3. **Codex CLI** (`~/.codex`)
    4. **Kilo CLI** (`~/.config/kilo`)
    5. **Agy / Antigravity CLI** (`~/.gemini` and root `.agents/`)
    6. **Pi Coding Agent** (`~/.pi/agent`)
- **Modern APT Keyrings & Security**: Uses `/etc/apt/keyrings/` instead of deprecated `apt-key`. Strictly enforces `.gitignore` rules against tokens, keys, and credentials.
- **Distribution Agnostic**: Automatically resolves Ubuntu release codenames across standard Ubuntu and derivatives like Pop!_OS and Linux Mint.
- **Developer Tools & Desktop Suites**: Automated setup for ASDF (Node.js, Ruby, Python, Elixir, Erlang), Docker Engine, VS Code (+ curated extensions), Git (+ SSH ED25519), and Android Studio.

---

## Directory Layout

```text
.
├── AGENTS.md                  # Canonical workspace guidelines for AI coding agents
├── CLAUDE.md                  # Claude Code workspace entrypoint (links to AGENTS.md)
├── GEMINI.md                  # Antigravity / Gemini entrypoint (links to AGENTS.md)
├── install.sh                 # Master workstation setup and provisioning entrypoint
├── LICENSE                    # MIT license
├── README.md                  # DevEx documentation & usage manual
├── .env.sample                # Sample environment configuration (Git identity)
├── .gitignore                 # Hardened ignore list (secrets, keys, backups, IDE)
├── ai/                        # Unified AI agent architecture
│   ├── common-instructions.md # Universal principles, coding styles & Context7 docs rule
│   ├── rules/                 # Shared modular rules (Context7, Bash standards, Safety)
│   ├── skills/                # Reusable Agent Skills (open SKILL.md format)
│   └── adapters/              # CLI-specific adapters (Claude, OpenCode, Codex, Kilo, Agy, Pi)
├── shell/                     # Centralized shell dotfiles
│   ├── env.sh                 # Idempotent PATH & environment variables loader
│   ├── aliases.sh             # Shared Git, Docker, and navigation shortcuts
│   ├── functions.sh           # Productivity functions (ai-status, mkcd, extract, etc.)
│   ├── bashrc.sh              # Bash integration entrypoint
│   ├── zshrc.sh               # Zsh integration entrypoint
│   └── zsh/custom/themes/     # Custom prompt themes (devex.zsh-theme)
├── .agents/                   # Native workspace bridge for Antigravity / Agy discovery
│   ├── rules/
│   └── skills/
└── scripts/                   # Modular installer scripts
    ├── ai-tools.sh            # Synchronizes all 6 AI CLI adapters
    ├── android-studio.sh      # Java OpenJDK & Android Studio
    ├── asdf.sh                # ASDF runtime manager & plugins
    ├── brave.sh               # Official Brave Browser signed APT repository & installer
    ├── docker.sh              # Docker Engine, CLI, Buildx, and Compose v2
    ├── ghostty.sh             # Fast native terminal emulator via Snap
    ├── gitconfig.sh           # Git identity, aliases, and SSH ED25519 generation
    ├── herdr.sh               # Terminal workspace manager for AI coding agents
    ├── mongocompass.sh        # Official MongoDB Compass GUI installer
    ├── ohmyzsh.sh             # Installs Zsh and Oh My Zsh (unattended)
    ├── orca.sh                # Next-gen Orca IDE agentic development environment
    ├── pgadmin.sh             # Official pgAdmin 4 Desktop APT repository & installer
    ├── programs.sh            # Desktop essentials (Chrome, Flameshot, VLC, BleachBit)
    ├── shell.sh               # Configures Bash & Oh My Zsh dotfiles, plugins, and themes
    ├── verify.sh              # Automated repository linting & integrity verification
    ├── vscode.sh              # VS Code installation & 25+ curated extensions
    └── zed.sh                 # Fast modern code editor (Zed)
```

---

## Quickstart

### 1. Prerequisites
Ensure Git is installed on your workstation:
```bash
sudo apt-get update && sudo apt-get install -y git
```

### 2. Clone Repository
```bash
git clone https://github.com/nmenag/dotfiles.git ~/personal-projects/dotfiles
cd ~/personal-projects/dotfiles
```

### 3. Configure Environment Variables
Copy `.env.sample` to `.env` and fill in your details:
```bash
cp .env.sample .env
nano .env   # Set EMAIL and USERNAME
```

### 4. Run Installation

#### Standard Setup (Recommended)
Installs core system dependencies, shell configurations (Bash & Oh My Zsh), desktop tools, ASDF runtimes, VS Code extensions, Git configuration, and synchronizes all 6 AI CLI adapters:
```bash
./install.sh
```

#### Selective Setup Options
```bash
./install.sh --shell    # Configures only Bash, Oh My Zsh, plugins and themes
./install.sh --ai       # Synchronizes only AI tools adapters (Claude, OpenCode, Codex, Kilo, Agy, Pi)
./install.sh --zed          # Installs only Zed editor
./install.sh --ghostty      # Installs only Ghostty terminal
./install.sh --herdr        # Installs only Herdr workspace manager
./install.sh --pgadmin      # Installs only pgAdmin 4 Desktop
./install.sh --mongocompass # Installs only MongoDB Compass
./install.sh --brave        # Installs only Brave Browser
./install.sh --orca         # Installs only Orca IDE
./install.sh --core         # Installs only core system build dependencies and headers
./install.sh --all          # Full installation including Docker and Android Studio
```

---

## Shell Configuration (Bash & Oh My Zsh)

Both shells automatically load shared configurations from `shell/`:

### Aliases
- **Git**: `g` (`git`), `gst` (`git status -sb`), `gaa` (`git add --all`), `gc` (`git commit -v`), `gco` (`git checkout`), `gcb` (`git checkout -b`), `gd` (`git diff`), `gl` (`git pull`), `gp` (`git push`), `glog`.
- **Navigation**: `..`, `...`, `....`, `.....`, `dotfiles`.
- **Docker**: `d` (`docker`), `dco` (`docker compose`), `dps`, `dpsa`.
- **Safety**: Interactive confirmations for `rm`, `cp`, `mv`.

### Helper Functions
| Function | Description | Example |
| :--- | :--- | :--- |
| `ai-status` | Audits installation, binary paths, and versions of all 5 AI CLIs | `ai-status` |
| `mkcd <dir>` | Creates directory hierarchy and immediately navigates into it | `mkcd src/components/button` |
| `extract <file>` | Universal archive extractor (`.tar.gz`, `.zip`, `.tar.bz2`, `.7z`) | `extract backup.tar.gz` |
| `path_inspect` | Prints each entry of `$PATH` on a numbered line | `path_inspect` |
| `reload_shell` | Reloads active shell configuration (`.zshrc` or `.bashrc`) | `reload_shell` |

### Oh My Zsh Plugins & Theme
Running `./scripts/shell.sh` automatically configures:
- Plugins: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- Custom Theme: `devex.zsh-theme` (lightweight, displays Git branch and dirty state without terminal lag)

---

## Unified AI Agent Integration

This repository bridges 6 distinct AI CLI assistants through a common source of instructions and skills:

| Assistant | CLI Command | Instructions Path | Skills Target Directory |
| :--- | :--- | :--- | :--- |
| **Claude Code** | `claude` | `~/.claude/CLAUDE.md` | `~/.claude/skills/` |
| **OpenCode** | `opencode` | `~/.config/opencode/AGENTS.md` | `~/.config/opencode/skills/` |
| **Codex CLI** | `codex` | `~/.codex/AGENTS.md` | `~/.codex/skills/` |
| **Kilo CLI** | `kilo` | `~/.config/kilo/AGENTS.md` | `~/.config/kilo/skills/` |
| **Agy / Antigravity** | `agy` | `~/.gemini/GEMINI.md` | `~/.gemini/skills/` & `.agents/skills/` |
| **Pi Coding Agent** | `pi` | `~/.pi/agent/AGENTS.md` | `~/.pi/agent/skills/` & `.agents/skills/` |

### Synchronizing Adapters
Run the synchronizer at any time to link updated rules or skills:
```bash
./scripts/ai-tools.sh
# or directly:
./ai/adapters/sync-all.sh
```

Adapters are strictly idempotent and non-destructive: existing configurations are safely backed up to `~/.dotfiles_backup/ai_<timestamp>` prior to replacement.

---

## Verification & Integrity Suite

Validate the syntax of all Bash scripts, executable permissions, Git secret hygiene, shell dotfiles components, and AI adapter links with the verification suite:
```bash
./scripts/verify.sh
```

---

## Modular Scripts Reference

All modules in `scripts/` can be executed independently from any directory:

| Script | Description | Run Command |
| :--- | :--- | :--- |
| [`ai-tools.sh`](./scripts/ai-tools.sh) | Synchronizes common instructions & skills across all 6 AI CLIs | `./scripts/ai-tools.sh` |
| [`android-studio.sh`](./scripts/android-studio.sh) | Installs Java OpenJDK and Android Studio via Snap | `./scripts/android-studio.sh` |
| [`asdf.sh`](./scripts/asdf.sh) | Installs ASDF v0.15.0 and runtime plugins (Node, Ruby, Python, Elixir, Erlang) | `./scripts/asdf.sh` |
| [`brave.sh`](./scripts/brave.sh) | Installs Brave Browser via official signed APT repository | `./scripts/brave.sh` |
| [`docker.sh`](./scripts/docker.sh) | Installs Docker CE, CLI, Containerd, Buildx, and Compose v2 plugin | `./scripts/docker.sh` |
| [`ghostty.sh`](./scripts/ghostty.sh) | Installs Ghostty native terminal emulator via Snap (--classic) | `./scripts/ghostty.sh` |
| [`gitconfig.sh`](./scripts/gitconfig.sh) | Configures Git identity, aliases (`git lg`), and ED25519 SSH key | `./scripts/gitconfig.sh` |
| [`herdr.sh`](./scripts/herdr.sh) | Installs Herdr workspace manager and sets up Zsh completion | `./scripts/herdr.sh` |
| [`mongocompass.sh`](./scripts/mongocompass.sh) | Installs MongoDB Compass GUI via official Debian package | `./scripts/mongocompass.sh` |
| [`ohmyzsh.sh`](./scripts/ohmyzsh.sh) | Installs Zsh and Oh My Zsh (unattended) | `./scripts/ohmyzsh.sh` |
| [`orca.sh`](./scripts/orca.sh) | Installs Orca IDE next-gen agentic development environment via official deb | `./scripts/orca.sh` |
| [`pgadmin.sh`](./scripts/pgadmin.sh) | Installs pgAdmin 4 Desktop via official PostgreSQL APT repository | `./scripts/pgadmin.sh` |
| [`programs.sh`](./scripts/programs.sh) | Installs Google Chrome, Flameshot, VLC, and BleachBit | `./scripts/programs.sh` |
| [`shell.sh`](./scripts/shell.sh) | Sets up Bash & Oh My Zsh loaders, OMZ plugins, and custom themes | `./scripts/shell.sh` |
| [`verify.sh`](./scripts/verify.sh) | Complete linting, security, and integrity verification suite | `./scripts/verify.sh` |
| [`vscode.sh`](./scripts/vscode.sh) | Installs VS Code and 25+ curated development extensions | `./scripts/vscode.sh` |
| [`zed.sh`](./scripts/zed.sh) | Installs Zed editor via official vendor installer | `./scripts/zed.sh` |

---

## License

Licensed under the [MIT License](./LICENSE).

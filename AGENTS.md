# Agent Guidelines for Dotfiles

This repository automates the installation and configuration of developer workstations on Debian/Ubuntu-based distributions, with active support for **Pop!_OS 24.04 LTS (Noble)** and **Ubuntu 22.04 / 24.04 LTS**.

When reading, updating, or authoring code in this repository, all AI agents must adhere strictly to the following standards and architecture guidelines.

---

## 1. Core Principles

1. **Idempotency**: Every script must be safe to execute repeatedly without duplicating configurations, creating duplicate file entries, or crashing.
2. **Non-Destructive Defaults**: Never overwrite existing user credentials, SSH keys, or personal dotfiles without checking first.
3. **Unattended Execution**: Scripts must run non-interactively without prompting for user confirmation or hanging unattended runners (use `-y` for `apt-get`, `--unattended` for installers, avoid commands like `newgrp`).
4. **Modern APT & Security Practices**: Never use deprecated `apt-key`. Store GPG keys under `/etc/apt/keyrings/` and reference them explicitly via `[signed-by=...]`.
5. **Distribution Agility**: Support Ubuntu derivatives (e.g., Pop!_OS, Linux Mint) by determining codenames using `CODENAME="${UBUNTU_CODENAME:-$(lsb_release -cs)}"`.
6. **User-Managed Commits (No Automated Commits)**: AI agents must never execute `git commit` or create git commits automatically. Always apply, compile, test, and empirically verify code and configuration changes directly in the workspace, leaving Git staging, commits, and commit messages entirely for the user to review and author.
7. **DRY Principle & Single Source of Truth**: Never duplicate instructions, modular rules, or skills across repository folders. The [`ai/`](./ai) directory is the canonical source of truth for universal instructions ([`ai/common-instructions.md`](./ai/common-instructions.md)), modular rules ([`ai/rules/`](./ai/rules)), and agent skills ([`ai/skills/`](./ai/skills)). Root entrypoints ([`CLAUDE.md`](./CLAUDE.md), [`GEMINI.md`](./GEMINI.md)) and workspace customization bridges ([`.agents/rules/`](./.agents/rules), [`.agents/skills/`](./.agents/skills)) must reference `ai/` strictly via relative symbolic links (`ln -sfn`). Duplicating physical files across `.agents/` and `ai/` (e.g., maintaining twin `system-safety.md` or `bash-standards.md` files) violates this invariant and is strictly prohibited. All rule and skill authoring or updates must occur directly within `ai/`.
8. **KISS Principle (Keep It Simple & Minimal)**: Always prefer simple, readable, and direct solutions over complex, over-engineered abstractions. Avoid unnecessary layers, premature generalizations, redundant configuration, or excessive file fragmentation. Favor standard shell/CLI tools, built-in features, and unified single files before introducing sprawling multi-file architectures or external dependencies.

---

## 2. Shell Script Standards

All installer and provisioning scripts inside [`scripts/`](./scripts) and [`install.sh`](./install.sh) must observe these rules:

- **Shebang & Flags**:
  ```bash
  #!/bin/bash
  set -euo pipefail
  ```
- **Self-Locating Paths**: Never assume the user is invoking the script from the repository root or current directory. Always derive script and root paths:
  ```bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
  ```
- **Guarded Configuration Appends**: When writing to shell configuration files such as `~/.zshrc` or `~/.bashrc`, guard against duplicates:
  ```bash
  if [[ -f "$HOME/.zshrc" ]] && ! grep -q "KEYWORD_IDENTIFIER" "$HOME/.zshrc"; then
    cat <<'EOT' >> "$HOME/.zshrc"
  # Configuration Block
  export MY_TOOL="value"
  EOT
  fi
  ```
- **Cross-Shell Hygiene**: Never `source ~/.zshrc` inside a `#!/bin/bash` script. Source the tool directly (e.g. `. "$HOME/.asdf/asdf.sh"`) or instruct the user to open a new Zsh terminal.
- **Temporary File Cleanup**: Always use `mktemp -d` and trap cleanup when downloading `.deb` or archive files:
  ```bash
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  ```

---

## 3. Directory Layout

```text
.
├── AGENTS.md                  # Root workspace rules for AI agents
├── CLAUDE.md                  # Claude Code workspace entrypoint (links to AGENTS.md)
├── GEMINI.md                  # Antigravity / Gemini entrypoint (links to AGENTS.md)
├── docs/                      # Architecture & system design documentation
│   └── architecture.md        # Comprehensive system architecture & subsystem specs
├── install.sh                 # Master workstation setup entrypoint
├── mena/                      # Rust CLI source code (Clap + Dialoguer)
│   ├── Cargo.toml             # Rust package configuration
│   ├── src/                   # CLI, catalog, planner, wizard, executor
│   └── tests/                 # Integration tests (cancellation, planner, catalog)
├── LICENSE                    # MIT license
├── README.md                  # Human-readable documentation
├── .env.sample                # Sample environment configuration
├── .gitignore                 # Excludes .env, secrets, IDE configs, etc.
├── ai/                        # Unified AI agent architecture
│   ├── common-instructions.md # Universal guidelines for all 6 AI CLIs
│   ├── rules/                 # Shared rules (Context7, Bash standards, Safety)
│   ├── skills/                # Reusable Agent Skills (SKILL.md format)
│   └── adapters/              # CLI adapters (claude, opencode, codex, kilo, agy, pi)
├── shell/                     # Centralized shell dotfiles
│   ├── env.sh                 # Environment variables and PATH deduplication
│   ├── aliases.sh             # Shared Git, Docker, and navigation shortcuts
│   ├── functions.sh           # DevEx productivity functions (ai-status, mkcd, etc.)
│   ├── bashrc.sh              # Bash integration entrypoint
│   ├── zshrc.sh               # Zsh integration entrypoint
│   └── zsh/custom/themes/     # Custom prompt themes (devex.zsh-theme)
├── .agents/                   # Workspace AI agent customizations (Antigravity bridge)
│   ├── rules/                 # Modular agent rules
│   └── skills/                # On-demand agent runbooks & workflows
└── scripts/                   # Categorized modular installation scripts
    ├── verify.sh              # Repository verification & test harness
    ├── ai/                    # AI coding assistants, agents & tools
    │   ├── ai-tools.sh
    │   ├── herdr.sh
    │   └── orca.sh
    ├── api/                   # API clients & exploration tools
    │   ├── bruno.sh
    │   └── postman.sh
    ├── browsers/              # Web browsers
    │   ├── brave.sh
    │   └── chrome.sh
    ├── core/                  # Core foundations, Git, Docker & Shell
    │   ├── core.sh
    │   ├── docker.sh
    │   ├── gitconfig.sh
    │   └── shell.sh
    ├── database/              # Database management tools & clients
    │   ├── dbeaver.sh
    │   ├── dbgate.sh
    │   ├── mongocompass.sh
    │   └── pgadmin.sh
    ├── editors/               # Code editors & IDEs
    │   ├── android-studio.sh
    │   ├── cursor.sh
    │   ├── vscode.sh
    │   └── zed.sh
    ├── terminal/              # Terminals & workspace multiplexers
    │   └── ghostty.sh
    ├── tools/                 # Desktop tools & system utilities
    │   ├── bleachbit.sh
    │   ├── flameshot.sh
    │   ├── stacer.sh
    │   └── vlc.sh
    └── version-managers/      # Runtime version managers (asdf, mise)
        ├── asdf.sh
        ├── mise.sh
        └── plugins.sh
```

---

## 4. Verification Workflow

Before finishing any task that touches shell scripts, verify the workspace:

```bash
# 1. Run the repository verification script
./scripts/verify.sh

# 2. Test bash syntax across all scripts
for f in install.sh scripts/*.sh scripts/*/*.sh shell/*.sh ai/adapters/*.sh; do bash -n "$f"; done

# 3. Run mena Rust CLI test suite
cargo test --manifest-path mena/Cargo.toml
```

For detailed runbooks on creating new setup scripts or troubleshooting Ubuntu system packages, reference the specialized skills in `.agents/skills/`.

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
├── install.sh                 # Master workstation setup entrypoint
├── LICENSE                    # MIT license
├── README.md                  # Human-readable documentation
├── .env.sample                # Sample environment configuration
├── .gitignore                 # Excludes .env, IDE configs, etc.
├── .agents/                   # Workspace AI agent customizations
│   ├── rules/                 # Modular agent rules
│   │   ├── bash-standards.md
│   │   └── system-safety.md
│   └── skills/                # On-demand agent runbooks & workflows
│       ├── add-setup-script/
│       ├── validate-dotfiles/
│       └── ubuntu-workstation-troubleshooting/
└── scripts/                   # Modular installation scripts
    ├── android-studio.sh
    ├── asdf.sh
    ├── docker.sh
    ├── gitconfig.sh
    ├── ohmyzsh.sh
    ├── programs.sh
    ├── verify.sh
    └── vscode.sh
```

---

## 4. Verification Workflow

Before finishing any task that touches shell scripts, verify the workspace:

```bash
# 1. Run the repository verification script
./scripts/verify.sh

# 2. Test bash syntax across all scripts
for f in install.sh scripts/*.sh; do bash -n "$f"; done
```

For detailed runbooks on creating new setup scripts or troubleshooting Ubuntu system packages, reference the specialized skills in `.agents/skills/`.

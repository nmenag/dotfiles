# Developer Dotfiles & Workstation Automation

Automated workstation provisioning, development environment setup, and dotfiles configuration for Debian/Ubuntu-based distributions, tested and optimized for **Pop!_OS 24.04 LTS** and **Ubuntu 22.04 / 24.04 LTS**.

---

## Features

- **Idempotent & Safe**: Every script checks existing dependencies, avoids duplicate shell exports, and handles errors safely (`set -euo pipefail`).
- **Modern APT Keyrings**: Adheres to modern Debian/Ubuntu security standards using `/etc/apt/keyrings/` instead of deprecated `apt-key`.
- **Distribution Agnostic**: Automatically resolves Ubuntu release codenames across standard Ubuntu and derivatives like Pop!_OS and Linux Mint.
- **ASDF Runtime Manager**: Multi-language runtime management for Node.js, Ruby, Python, Elixir, Erlang, and Java.
- **Developer Tools & Desktop Suites**: Automated configuration for Docker, VS Code (+ curated extensions), Oh My Zsh, Android Studio, and desktop essentials.
- **AI Agent Native**: Includes root [`AGENTS.md`](./AGENTS.md) and [`.agents/`](./.agents) rules & skills for AI coding assistants.

---

## Quickstart

### 1. Prerequisites
Ensure Git is installed on your workstation:
```bash
sudo apt-get update && sudo apt-get install -y git
```

### 2. Clone Repository
```bash
git clone https://github.com/nmenag/dotfiles.git
cd dotfiles
```

### 3. Configure Environment Variables
Copy `.env.sample` to `.env` and fill in your Git user details:
```bash
cp .env.sample .env
nano .env   # Set EMAIL and USERNAME
```

### 4. Run Installation

#### Standard Setup (Recommended)
Installs core build dependencies, Oh My Zsh, desktop applications, ASDF runtimes, VS Code + extensions, and Git configuration:
```bash
./install.sh
```

#### Core Build Dependencies Only
Installs only base compilers, headers (`build-essential`, `libssl-dev`, etc.), and utility tools:
```bash
./install.sh --core
```

#### Full Setup (Includes Docker and Android Studio)
```bash
./install.sh --all
```

---

## Modular Scripts

You can also run any module independently from anywhere in the file system:

| Script | Description | Run Command |
| :--- | :--- | :--- |
| [`android-studio.sh`](./scripts/android-studio.sh) | Installs Java OpenJDK (via ASDF) and Android Studio (snap) | `./scripts/android-studio.sh` |
| [`asdf.sh`](./scripts/asdf.sh) | Installs ASDF v0.15.0 and plugins: Node.js, Ruby, Python, Erlang, Elixir | `./scripts/asdf.sh` |
| [`docker.sh`](./scripts/docker.sh) | Installs Docker CE, CLI, Containerd, Buildx, and Compose v2 plugin | `./scripts/docker.sh` |
| [`gitconfig.sh`](./scripts/gitconfig.sh) | Sets up Git identity, aliases (`git lg`), and generates ED25519 SSH key | `./scripts/gitconfig.sh` |
| [`ohmyzsh.sh`](./scripts/ohmyzsh.sh) | Installs Zsh and Oh My Zsh (unattended) | `./scripts/ohmyzsh.sh` |
| [`programs.sh`](./scripts/programs.sh) | Installs desktop apps: Google Chrome, Flameshot, VLC, BleachBit | `./scripts/programs.sh` |
| [`vscode.sh`](./scripts/vscode.sh) | Installs VS Code and 25+ curated developer extensions | `./scripts/vscode.sh` |
| [`verify.sh`](./scripts/verify.sh) | Lints and validates all shell scripts, permissions, and agent configurations | `./scripts/verify.sh` |

---

## Verification & Integrity

Run the automated verification script to validate syntax across all shell scripts:
```bash
./scripts/verify.sh
```

---

## AI Agent Integration (`.agents` & `AGENTS.md`)

This repository is equipped with agent configuration files that provide AI coding assistants (like Antigravity / Gemini CLI) with contextual rules and workflow skills:

- **Root Guidelines**: [`AGENTS.md`](./AGENTS.md) specifies project context, coding standards, and safety requirements.
- **Rules (`.agents/rules/`)**:
  - [`bash-standards.md`](./.agents/rules/bash-standards.md): Shell coding conventions (`set -euo pipefail`, path resolution, safe keyrings).
  - [`system-safety.md`](./.agents/rules/system-safety.md): Safeguards for user files, SSH keys, and system libraries.
- **Skills (`.agents/skills/`)**:
  - `add-setup-script`: Runbook and template for adding new installation scripts to `scripts/`.
  - `validate-dotfiles`: Procedure for linting and testing shell scripts across the repository.
  - `ubuntu-workstation-troubleshooting`: Diagnostic procedures for APT locks, GPG keyrings, Pop!_OS / Ubuntu derivative codenames, and Docker permissions.

---

## Contributing & License

Contributions, improvements, and custom modules are welcome! Feel free to open a pull request.
Licensed under the [MIT License](./LICENSE).

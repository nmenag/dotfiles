# Developer Dotfiles & Workstation Automation

Automated workstation provisioning, development environment setup, unified shell configurations (Bash & Oh My Zsh), and multi-agent AI assistant integrations for Debian/Ubuntu-based distributions.

---

## Features

- **Interactive Workstation CLI (`mena`)**:
  - Written in **pure Rust** (`Clap` + `Dialoguer`), zero Node.js/TypeScript dependencies.
  - Multi-select interactive installation across 7 tool categories with OS, package manager, and installed version pre-detection.
  - Two-phase architecture (Planning vs. Execution): pre-installation summary, review/modification loop, and explicit confirmation.
  - Guaranteed safe cancellation (aborts with zero mutations).
  - Subcommands for diagnostics (`mena doctor`), catalog browsing (`mena list`), and updates (`mena update`).
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
- **Developer Tools & Desktop Suites**: Automated setup for ASDF and Mise (Node.js, Ruby, Python, Elixir, Erlang, Rust), Docker Engine, VS Code, Cursor (+ curated extensions), Zed, Ghostty, Git (+ SSH ED25519), and Android Studio.

---

## Directory Layout

```text
.
├── AGENTS.md                  # Canonical workspace guidelines for AI coding agents
├── CLAUDE.md                  # Claude Code workspace entrypoint (links to AGENTS.md)
├── GEMINI.md                  # Antigravity / Gemini entrypoint (links to AGENTS.md)
├── install.sh                 # Master workstation setup and provisioning entrypoint
├── mena/                      # Rust CLI source code (Clap + Dialoguer)
│   ├── Cargo.toml             # Rust dependencies (clap, dialoguer, indicatif, console, serde)
│   ├── src/                   # CLI, catalog, planner, wizard, and executor modules
│   └── tests/                 # Integration tests (cancellation, planner, catalog)
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
    ├── cursor.sh              # Official Cursor AI Editor signed APT repository & installer
    ├── docker.sh              # Docker Engine, CLI, Buildx, and Compose v2
    ├── ghostty.sh             # Fast native terminal emulator via Snap
    ├── gitconfig.sh           # Git identity, aliases, and SSH ED25519 generation
    ├── herdr.sh               # Terminal workspace manager for AI coding agents
    ├── mise.sh                # Official Mise-en-place polyglot version manager & environment engine
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

#### Bootstrap Workstation
Bootstraps core system build tools, installs and configures **Git** and **Docker Engine** (core foundations that are always installed), compiles and links the `mena` CLI to `~/.local/bin/mena` (and `~/.local/bin/dotctl`), and launches the interactive `mena` installation wizard:
```bash
./install.sh
```

#### Tool Management via `mena`
Once bootstrapped, all workstation tools, browsers, runtimes, editors, and AI assistants are selected and managed via `mena`:

```bash
mena install            # Launch full interactive wizard across all 7 categories
mena install browser    # Wizard scoped to web browsers (Brave, Chrome)
mena install cli        # Wizard scoped to core CLI tools & Docker
mena install runtimes   # Wizard scoped to ASDF and Mise version managers
mena install dev        # Wizard scoped to editors (VS Code, Cursor, Zed), terminals & IDEs
mena install ai         # Wizard scoped to AI terminal assistants (Claude, OpenCode, Codex, Kilo, Agy, Pi)
mena install skills     # Wizard scoped to Agent Skills CLI
mena install shell      # Wizard scoped to unified Bash & Oh My Zsh dotfiles
mena install --dry-run  # Simulate installation plan without modifying the workstation
```

---

## Interactive Workstation CLI: `mena`

`mena` is an interactive workstation installation and synchronization tool authored in **Rust** using `Clap` and `Dialoguer` (no TypeScript or Node.js runtime required). It provides a guided terminal experience to configure and manage developer workstations safely and idempotently.

### Core Commands

| Command | Description |
| :--- | :--- |
| `mena install` | Full interactive wizard asking across all tool categories with multi-select and preference prompts |
| `mena install <category>` | Interactive wizard scoped to a single category (e.g. `browser`, `cli`, `ai`, `runtimes`, `dev`, `skills`, `shell`) |
| `mena install -d, --dry-run` | Preview actions, dependency resolution, and planned commands without modifying the system |
| `mena list` | View the complete tool catalog (28 tools) with real-time detection of installed versions |
| `mena list -c <category>` | View catalog tools filtered by category (supports `--json` output) |
| `mena doctor` | Comprehensive diagnostic check of OS, package managers, shell configurations, and AI adapters |
| `mena update` | Updates AI assistant adapters, shell themes/plugins, and refreshes package manager caches |
| `mena --help` | Display help, subcommands, and flags |

### Interactive Installation Flow

```text
[1. Detect System & Tools]
         │
         ▼
[2. Multi-Select Wizard per Category]
         │
         ▼
[3. Gather Preferences (Git name/email, browser, etc.)]
         │
         ▼
[4. Build Dependency Plan & Categorize Actions]
         │
         ▼
[5. Display Pre-Installation Summary]
         │
         ▼
[6. Review Loop] ──(Modify)──► [Re-enter Selection]
         │
   (Cancel) ──► Abort immediately (Guaranteed 0 actions, 0 mutations)
         │
   (Proceed)
         │
         ▼
[7. Execute Approved Actions with Progress Bar]
         │
         ▼
[8. Render Final Execution Report (Successes, Skips, Errors)]
```

### Safety & Idempotency Guarantees

1. **Two-Phase Architecture**: Complete decoupling between the **Planning Phase** (`InstallPlan::build`) and the **Execution Phase** (`execute_plan`). All dependencies and warnings are calculated upfront before any script or command is run.
2. **Cancellation Invariant**: If the user chooses `Cancel` during the review loop or declines final confirmation, `mena` immediately terminates without touching files or running package managers.
3. **Only Confirmed Actions**: Only tools explicitly approved by the user (or required as dependencies) are queued for execution; unselected tools are never touched.
4. **Idempotency**: Running `mena install` when tools are already present runs non-destructive synchronization checks rather than redundant re-installations.

### How to Add a New Tool to `mena`

To add a new tool, open [`mena/src/catalog/registry.rs`](./mena/src/catalog/registry.rs) and register it with `builder.add`:

```rust
builder.add(Tool {
    id: "my-tool".to_string(),
    name: "My Developer Tool".to_string(),
    category: Category::DevUtilities,
    description: "Brief description of the tool".to_string(),
    install_method: InstallMethod::Script("scripts/my-tool.sh".to_string()),
    detection_method: DetectionMethod::Command("my-tool".to_string()),
    dependencies: vec!["git".to_string(), "curl".to_string()],
});
```

Supported `InstallMethod`s:
- `InstallMethod::Script(path)`: Invokes an idempotent workstation bash script in `scripts/`.
- `InstallMethod::AiAdapter(path)`: Invokes an AI assistant adapter script in `ai/adapters/`.
- `InstallMethod::AptPackage(package_name)`: Installs an official APT package via `sudo apt-get install -y`.
- `InstallMethod::SnapPackage { name, classic }`: Installs a Snap package.
- `InstallMethod::ShellCommand(command)`: Executes a validated shell command.

After modifying the registry, recompile with:
```bash
cargo build --release --manifest-path mena/Cargo.toml && ln -sfn "$PWD/mena/target/release/mena" ~/.local/bin/mena
```

### Running Automated CLI Tests

The `mena` test suite verifies cancellation safety, plan summary matching, and catalog integrity:

```bash
cargo test --manifest-path mena/Cargo.toml
```

Test coverage includes:
- `test_cancellation_produces_zero_actions`: Verifies that an aborted plan executes zero actions and creates zero mutations.
- `test_only_approved_actions_are_executed`: Verifies that unselected tools are never queued or executed.
- `test_dry_run_executes_no_mutations`: Verifies that dry-run mode safely simulates all steps without modifying the workstation.
- `test_summary_matches_plan`: Verifies that the rendered summary matches the plan items, actions count, and categories.
- `test_catalog_completeness` & `test_category_filtering`: Verifies registry completeness across all 7 categories.

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

### Continuous Integration (GitHub Actions)

The repository includes an automated CI pipeline ([`.github/workflows/ci.yml`](./.github/workflows/ci.yml)) executed on pushes and pull requests across supported Ubuntu LTS releases (`ubuntu-24.04` and `ubuntu-22.04`):
- **Commitlint**: Automatically verifies that commit messages follow the Conventional Commits specification.
- **Script Validation**: Tests syntax across all shell scripts using `bash -n`.
- **Integrity & Security**: Runs `./scripts/verify.sh` to enforce permissions, secret hygiene, dotfiles links, and skills frontmatter.
- **`mena` CLI Test Suite**: Runs all unit and integration tests (`cargo test`).
- **Release Verification & Smoke Tests**: Compiles the release binary and executes non-mutating smoke tests (`mena --help`, `mena list`, `mena doctor`, `mena install --dry-run`).

### Commit Message Standards (Commitlint)

All commit messages must adhere to the [Conventional Commits](https://www.conventionalcommits.org/) specification defined in [`.commitlintrc.json`](./.commitlintrc.json):
- **Local Hook**: Automatically configured via [`scripts/gitconfig.sh`](./scripts/gitconfig.sh) in `.git/hooks/commit-msg` with zero-dependency regex fallback.
- **CI Pipeline**: Evaluated via `wagoid/commitlint-github-action@v6` on pull requests and branch pushes.
- **Format**: `<type>(<optional scope>): <subject>`
- **Allowed Types**: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `revert`.
- **Examples**:
  - `feat: add cursor AI editor`
  - `chore(cli): rename dotctl to mena`
  - `ci: add commitlint github action`

### Pull Request Checks (Title & Size)

Pull requests are automatically audited and labeled via [`.github/workflows/pr-checks.yml`](./.github/workflows/pr-checks.yml):
- **Semantic PR Title Check**: Validates that PR titles conform to Conventional Commits using `amannn/action-semantic-pull-request@v6` (with `wip: true` draft support).
- **PR Size Labeler & Audit**: Categorizes pull request changes using `pascalgn/size-label-action@v0.5.7` (ignoring lockfiles):
  - `size/XS`: 0–19 lines
  - `size/S`: 20–99 lines
  - `size/M`: 100–299 lines
  - `size/L`: 300–799 lines
  - `size/XL`: 800–1499 lines
  - `size/XXL`: 1500+ lines (triggers review advisory warning)

---

## Modular Scripts Reference

All modules in `scripts/` can be executed independently from any directory:

| Script | Description | Run Command |
| :--- | :--- | :--- |
| [`ai-tools.sh`](./scripts/ai-tools.sh) | Synchronizes common instructions & skills across all 6 AI CLIs | `./scripts/ai-tools.sh` |
| [`android-studio.sh`](./scripts/android-studio.sh) | Installs Java OpenJDK and Android Studio via Snap | `./scripts/android-studio.sh` |
| [`asdf.sh`](./scripts/asdf.sh) | Installs ASDF v0.15.0 and runtime plugins (Node, Ruby, Python, Elixir, Erlang) | `./scripts/asdf.sh` |
| [`brave.sh`](./scripts/brave.sh) | Installs Brave Browser via official signed APT repository | `./scripts/brave.sh` |
| [`cursor.sh`](./scripts/cursor.sh) | Installs Cursor AI Editor via official signed APT repository | `./scripts/cursor.sh` |
| [`docker.sh`](./scripts/docker.sh) | Installs Docker CE, CLI, Containerd, Buildx, and Compose v2 plugin | `./scripts/docker.sh` |
| [`ghostty.sh`](./scripts/ghostty.sh) | Installs Ghostty native terminal emulator via Snap (--classic) | `./scripts/ghostty.sh` |
| [`gitconfig.sh`](./scripts/gitconfig.sh) | Configures Git identity, aliases (`git lg`), and ED25519 SSH key | `./scripts/gitconfig.sh` |
| [`herdr.sh`](./scripts/herdr.sh) | Installs Herdr workspace manager and sets up Zsh completion | `./scripts/herdr.sh` |
| [`mise.sh`](./scripts/mise.sh) | Installs Mise polyglot runtime and version manager via official signed APT repository | `./scripts/mise.sh` |
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

# CI/CD & Quality Gates

This document details the automated quality gates, linting systems, Commitlint standards, and Continuous Integration (GitHub Actions) pipelines protecting the repository.

---

## 1. Quality Gate Architecture

Quality assurance is enforced through three complementary tiers:

```mermaid
graph TD
    subgraph Tier1["Tier 1: Developer Local Pre-Commit"]
        Hook[".git/hooks/commit-msg<br/>(Conventional Commits Hook)"]
        BashN["Local bash -n Syntax Checks"]
        CargoTest["Local cargo test Suite"]
        VerifyLocal["./scripts/verify.sh Suite"]
    end

    subgraph Tier2["Tier 2: Pull Request Quality Automation"]
        PRTitle["Semantic PR Title Action<br/>(action-semantic-pull-request)"]
        PRSize["PR Size Labeler & Audit<br/>(size-label-action)"]
    end

    subgraph Tier3["Tier 3: Continuous Integration (Matrix Build)"]
        Matrix["OS Matrix: ubuntu-24.04 & ubuntu-22.04"]
        CommitlintCI["Commitlint Validation (from origin/main)"]
        RepoVerify["Automated ./scripts/verify.sh"]
        RustBuild["cargo test & cargo build --release"]
        SmokeTests["Non-Mutating CLI Smoke Tests"]
    end

    Tier1 --> Tier2
    Tier2 --> Tier3
```

---

## 2. Local Verification Suite (`scripts/verify.sh`)

[`scripts/verify.sh`](file:///home/nmenag/personal-projects/dotfiles/scripts/verify.sh) is an automated 7-step test suite designed to be executed locally before pushing code or creating pull requests:

| Stage | Inspection Target | Acceptance Criteria |
| :--- | :--- | :--- |
| **1. Bash Syntax** | All `*.sh` scripts in `scripts/`, `shell/`, `ai/adapters/`, `install.sh` | Clean exit from `bash -n` on all files |
| **2. Permissions** | All script files | Must possess POSIX executable bit (`+x`); automatically fixes if missing |
| **3. Security Hygiene** | `.env`, `.env.sample`, `.gitignore`, tracked files | `.env` ignored; zero keys, certificates, or tokens tracked in Git index |
| **4. Shell Dotfiles** | `shell/` components | All environment, alias, function, and theme files exist |
| **5. AI Agent Layer** | `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `SKILL.md` | Entrypoints exist; all skills have valid `name:` and `description:` frontmatter |
| **6. AI Adapters** | `ai/adapters/` | All 6 CLI adapter scripts exist and are executable |
| **7. `mena` Rust CLI** | `mena/` crate | `Cargo.toml` exists; `cargo check` compiles without errors |

---

## 3. Commit Message Standards (Commitlint)

The repository follows the [Conventional Commits](https://www.conventionalcommits.org/) standard configured in [`.commitlintrc.json`](file:///home/nmenag/personal-projects/dotfiles/.commitlintrc.json).

### 3.1 Format Specification
```text
<type>(<optional-scope>): <description>

[optional body]

[optional footer(s)]
```

### 3.2 Permitted Commit Types
- `feat`: New developer tool, installer script, or major feature.
- `fix`: Bug fix in installers, shell dotfiles, or CLI code.
- `chore`: Maintenance, renaming, dependencies, or configuration changes.
- `docs`: Documentation updates (README, docs/).
- `style`: Formatting, whitespace, or code styling adjustments.
- `refactor`: Code reorganization without functional behavior changes.
- `perf`: Performance improvements (e.g. prompt lag optimizations).
- `test`: Adding or updating integration tests in `mena/tests/`.
- `build`: Cargo build configs, packaging, or external build changes.
- `ci`: GitHub Actions workflow or Commitlint configurations.
- `revert`: Reverting a previous commit.

---

## 4. Continuous Integration Pipeline (`.github/workflows/ci.yml`)

The CI workflow executes automatically on pushes to `main` and all pull requests across an Ubuntu LTS matrix (`ubuntu-24.04` and `ubuntu-22.04`):

```mermaid
sequenceDiagram
    autonumber
    participant GitHub as GitHub Actions Runner
    participant Node as Node.js & Commitlint
    participant Shell as Bash Test Suite
    participant Rust as Cargo & Rust Toolchain

    GitHub->>GitHub: Checkout repository with full git history (fetch-depth: 0)
    GitHub->>Node: Setup Node.js & install @commitlint/config-conventional
    Node->>GitHub: Validates all commit messages in PR branch
    GitHub->>Shell: Runs bash -n across all 35+ shell scripts
    GitHub->>Shell: Runs ./scripts/verify.sh 7-step integrity check
    GitHub->>Rust: Sets up Rust stable with cargo dependency caching
    Rust->>GitHub: Runs cargo test --manifest-path mena/Cargo.toml (9 unit & integration tests)
    Rust->>GitHub: Compiles release binary (cargo build --release)
    GitHub->>Rust: Executes non-mutating smoke tests:
    Note over GitHub,Rust: mena --help<br/>mena list<br/>mena doctor<br/>mena install --dry-run
    GitHub->>GitHub: Reports workflow status (Pass / Fail)
```

---

## 5. Pull Request Automation (`.github/workflows/pr-checks.yml`)

Every pull request is automatically audited by two GitHub Actions:
1. **Semantic PR Title Check** (`amannn/action-semantic-pull-request@v6`):
   - Validates that the pull request title conforms to Conventional Commits.
   - Supports draft / WIP PRs (`wip: true`).
2. **Pull Request Size Labeler** (`pascalgn/size-label-action@v0.5.7`):
   - Categorizes diff lines (excluding lockfiles) into distinct labels:
     - `size/XS` (0–19 lines)
     - `size/S` (20–99 lines)
     - `size/M` (100–299 lines)
     - `size/L` (300–799 lines)
     - `size/XL` (800–1499 lines)
     - `size/XXL` (1500+ lines; triggers advisory review warning)

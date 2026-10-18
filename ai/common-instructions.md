# Universal AI Agent Engineering Guidelines

These guidelines provide the common source of truth for coding assistants and agent CLIs operating in this environment (**Claude Code**, **OpenCode**, **Codex**, **Kilo CLI**, **Agy / Antigravity**, and **Pi Coding Agent**).

---

## 1. Core Operating Principles

1. **Senior DevEx Mindset**: Deliver robust, maintainable, and verified code. Preserve existing conventions, docstrings, and project architecture unless refactoring is explicitly requested.
2. **Idempotency & Non-Destructive Actions**:
   - Any script, configuration write, or installation must be safe to execute multiple times.
   - Never overwrite user dotfiles, SSH keys, or tokens without creating a timestamped backup first.
3. **Strict Security & Secret Hygiene**:
   - Never commit API keys, authentication tokens, or private credentials to version control.
   - Always load sensitive credentials from environment variables or `.env` files (which must remain in `.gitignore`).
4. **Distribution Agnostic (Debian / Ubuntu / Pop!_OS)**:
   - When configuring APT repositories, always use modern keyrings (`/etc/apt/keyrings/`) with explicit `[signed-by=...]` directives.
   - Resolve Ubuntu codenames dynamically using `CODENAME="${UBUNTU_CODENAME:-$(lsb_release -cs)}"`.
5. **User-Controlled Version Control (No Automated Commits)**:
   - AI agents must never execute `git commit` or create automated commits.
   - Always implement, compile, test, and empirically verify code and configuration changes directly in the workspace, leaving Git staging, commits, and commit messages entirely for the user to review and author.
6. **DRY Principle & Single Source of Truth**:
   - Never duplicate instruction documents, modular rules, or skills across directories.
   - The `ai/` directory is the canonical source of truth (`ai/common-instructions.md`, `ai/rules/`, `ai/skills/`).
   - Workspace customization bridges (`.agents/rules/`, `.agents/skills/`) and entrypoints (`CLAUDE.md`, `GEMINI.md`) must strictly link to `ai/` via relative symbolic links, never via duplicate copies.

---

## 2. Up-To-Date Documentation (Context7 Rule)

When researching libraries, frameworks, SDKs, APIs, CLI tools, or cloud services:
- Always use the **Context7 MCP** to fetch up-to-date documentation and code snippets rather than relying solely on frozen training weights.
- Follow the two-step resolution pattern:
  1. `resolve-library-id` with the library name and lookup intent.
  2. `query-docs` with the resolved `/org/project` library ID scoped to a single concept.
- Answer using freshly fetched documentation.

---

## 3. Shell & Scripting Standards

All Bash and shell scripts must strictly observe:
- **Strict Mode**: `#!/bin/bash` with `set -euo pipefail`.
- **Self-Locating Paths**: Derive base paths using `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)`.
- **Clean Workspace Cleanups**: Temporary files must be created via `mktemp -d` and cleaned with an `EXIT` trap.
- **Verification Workflow**: Always validate changes using `bash -n <script>` and run `./scripts/verify.sh`.

---

## 4. Empirical Verification

- Never claim that a script, service, or configuration works without executing verification commands.
- Check exit codes and outputs explicitly.

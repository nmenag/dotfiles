# Architecture & System Documentation

Welcome to the architectural documentation for the **Developer Dotfiles & Workstation Automation** platform.

In accordance with the **KISS Principle (Keep It Simple)**, the architectural specifications are consolidated into two focused documents:

---

## Documentation Navigation

| Document | Description |
| :--- | :--- |
| **[System Architecture & Subsystems](file:///home/nmenag/personal-projects/dotfiles/docs/architecture.md)** | End-to-end architectural blueprint, 5-layer topology, `mena` Rust orchestrator, centralized shell dotfiles, security & packaging models, and the 6-in-1 multi-agent AI system. |
| **[CI/CD & Quality Gates](file:///home/nmenag/personal-projects/dotfiles/docs/ci-cd-and-quality.md)** | Unified GitHub Actions CI pipeline (`ci.yml`), Conventional Commits / Commitlint specifications, native in-runner PR size audit, and the 7-step local verification suite (`verify.sh`). |

---

## Quick Reference Commands

```bash
# 1. Master Workstation Bootstrap (Idempotent)
./install.sh                  # Bootstrap core and launch interactive mena wizard
./install.sh --core           # Install or repair core foundations and exit
./scripts/core.sh             # Direct core script execution (Build tools, Git, Docker)

# 2. Interactive Workstation Orchestrator (Rust CLI)
mena install                  # Interactive category-by-category wizard
mena core                     # Re-execute or repair core tools (Git, Docker, Build Tools)
mena list                     # Inspect 34 developer tools across 7 categories
mena doctor                   # Environment diagnostic engine
mena install --dry-run --yes  # Non-mutating simulation

# 3. Repository Verification Suite (7 Quality Gates)
./scripts/verify.sh

# 4. Synchronize Multi-Agent AI Guidelines (6 AI Assistants)
./ai/adapters/sync-all.sh
```

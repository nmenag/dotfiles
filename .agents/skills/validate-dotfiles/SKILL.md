---
name: validate-dotfiles
description: >-
  Use this skill to lint, syntax-check, and validate the integrity of shell scripts,
  permissions, environment files, and agent skills in the dotfiles repository.
---

# Validating Dotfiles Scripts and Integrity

Use this procedure whenever modifying or auditing scripts in the dotfiles repository.

## Validation Steps

### 1. Run Repository Verification Suite
Execute the built-in verification script:
```bash
./scripts/verify.sh
```
This tests:
- Bash syntax validation (`bash -n`) across all `.sh` scripts.
- Executable permission bits (`+x`) on all script files.
- Configuration templates (`.env.sample`).
- Root agent guidelines (`AGENTS.md`) and `.agents/skills` frontmatter.

### 2. Check for Bash Anti-Patterns
Manually or with tools, inspect scripts for:
- Missing `set -euo pipefail`.
- Unquoted variables in subshells or command expansions (e.g. `$(echo "$EMAIL")` or `$(git config ...)`).
- Sourcing `~/.zshrc` inside `#!/bin/bash` scripts.
- Unconditional `cat <<EOF >> ~/.zshrc` without `grep` guards.
- Hardcoded Ubuntu release codenames that fail on derivatives like Pop!_OS or Linux Mint.
- Deprecated `apt-key add` usage instead of modern `/etc/apt/keyrings/`.

### 3. Dry-Run / Test Invocation
When testing scripts individually:
```bash
# Check syntax without executing
bash -n scripts/<script-name>.sh

# Run script and monitor stdout/stderr
bash scripts/<script-name>.sh
```

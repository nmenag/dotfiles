---
name: add-setup-script
description: >-
  Use this skill when adding a new program, CLI tool, or service installer script
  to the dotfiles repository (in the scripts/ directory).
---

# Adding a New Setup Script

Follow this runbook to author a new modular setup script for a software package, development tool, or service in `scripts/`.

## Step-by-Step Procedure

### 1. Determine Installation Source
Choose the preferred distribution mechanism in order of priority:
1. **Ubuntu/Debian APT Repository**: Prefer official distribution packages when modern enough.
2. **Official Vendor APT Repository**: Use official signed repositories using modern keyrings (`/etc/apt/keyrings/`).
3. **ASDF Plugin**: Preferred for programming languages and CLI version managers.
4. **Official Snap**: Preferred for desktop GUI apps or complex isolated suites (e.g., Android Studio).
5. **Direct GitHub Release Binary / Deb**: Preferred for standalone Go/Rust/C tools.

### 2. Use the Standard Script Boilerplate
Select the appropriate category folder under `scripts/` (e.g. `editors/`, `browsers/`, `database/`, `api/`, `version-managers/`, `tools/`, `terminal/`, `core/`, `ai/`) and create `scripts/<category>/<tool-name>.sh` using this template:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Installing <Tool Name>..."

# Check if already installed
if command -v <tool-binary> &>/dev/null; then
  echo "<Tool Name> is already installed: $(command -v <tool-binary>)"
  exit 0
fi

# Example: Adding official apt keyring and repository
# sudo install -m 0755 -d /etc/apt/keyrings
# CODENAME="${UBUNTU_CODENAME:-$(lsb_release -cs)}"
# curl -fsSL https://vendor.example.com/gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/<tool-name>.gpg
# echo "deb [signed-by=/etc/apt/keyrings/<tool-name>.gpg] https://vendor.example.com/apt ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/<tool-name>.list > /dev/null
# sudo apt-get update -y
# sudo apt-get install -y <package-name>

# Example: Guarded shell environment export
# if [[ -f "$HOME/.zshrc" ]] && ! grep -q "<TOOL_ENV>" "$HOME/.zshrc"; then
#   echo 'export PATH="$PATH:/path/to/<tool>/bin"' >> "$HOME/.zshrc"
# fi

echo "<Tool Name> installation completed successfully!"
```

### 3. Grant Executable Permissions
```bash
chmod +x scripts/<category>/<tool-name>.sh
```

### 4. Wire into Orchestration (Optional)
If registering in `mena`:
1. Add entry in `mena/src/catalog/registry.rs` pointing to `scripts/<category>/<tool-name>.sh`.
2. Add the tool to the table in `README.md`.

### 5. Validate the Script
Run:
```bash
bash -n scripts/<category>/<tool-name>.sh
./scripts/verify.sh
```

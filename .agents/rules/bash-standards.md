# Bash Scripting Standards for Dotfiles

This rule enforces coding quality, reliability, and security across all shell scripts in this repository.

## Standards Checklist

1. **Shebang and Strict Mode**:
   Always begin scripts with:
   ```bash
   #!/bin/bash
   set -euo pipefail
   ```

2. **Self-Location**:
   Never assume the calling directory is `$PWD`. Determine absolute paths:
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
   ```

3. **Package Manager Best Practices**:
   - Always run `sudo apt-get update -y` before installing packages.
   - Always pass non-interactive flags: `sudo apt-get install -y <package>`.
   - Never use `apt-key add`. Use `/etc/apt/keyrings/<app>.gpg` or `.asc` with `[signed-by=...]`.
   - Ensure `/etc/apt/keyrings` exists before writing to it (`sudo install -m 0755 -d /etc/apt/keyrings`).
   - Use `dpkg -s <pkg> &>/dev/null` or `command -v <binary> &>/dev/null` for checking existing packages.

4. **Variables and Quoting**:
   - Quote all variable expansions: `"$VAR"`, `"${ARRAY[@]}"`.
   - Use default fallbacks for unset variables under `set -u`: `"${VARIABLE:-}"`.

5. **Idempotency & Deduplication**:
   - Check if an entry exists before appending to `~/.zshrc`, `~/.bashrc`, or `~/.gitconfig`.
   - Check if directories exist before running `git clone`.
   - Use `ln -sf` for symlinks instead of failing on existing targets.

6. **Clean Temporary Artifacts**:
   - When downloading files (e.g. `.deb`, `.tar.gz`), download into a temporary directory created with `mktemp -d`.
   - Always register an `EXIT` trap to clean up:
     ```bash
     TMP_DIR="$(mktemp -d)"
     trap 'rm -rf "$TMP_DIR"' EXIT
     ```

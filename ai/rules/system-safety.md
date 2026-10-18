# System Safety and Workstation Integrity Rules

These rules protect user workstation state, personal configurations, and system stability during provisioning.

## Mandatory Safety Guardrails

1. **Protect Authentication Keys and Secrets**:
   - Never overwrite `~/.ssh/id_*` or SSH authorized keys without checking for existing keys.
   - Never commit `.env` or personal access tokens into version control. Ensure `.env` remains in `.gitignore`.
   - Never log secrets or private keys in terminal output.

2. **Prevent System Package Breakage**:
   - Never force-install obsolete `.deb` packages from older Ubuntu or Debian releases (e.g. downloading Ubuntu 18.04 `libssl1.1` into Ubuntu 24.04).
   - Never add unsupported or deprecated third-party repositories without checking active release status.
   - If an official repository doesn't yet support a brand-new Ubuntu release, fall back to the previous LTS codename (`jammy` for `noble`) or provide snap/binary alternative, rather than breaking APT dependencies.

3. **Avoid Blocking Headless Processes**:
   - Never invoke commands that create child shells or interactive prompts in automated scripts (e.g. raw `newgrp docker`, `chsh`, `adduser`).
   - If a group membership requires session re-evaluation, output instructions to the user instead of spawning subshells.

4. **Preserve User Customizations**:
   - Avoid destructive overwriting of existing shell dotfiles (`~/.zshrc`, `~/.bashrc`, `~/.gitconfig`). Always append conditionally or use dedicated modular include files (e.g., `~/.zshrc.d/`).

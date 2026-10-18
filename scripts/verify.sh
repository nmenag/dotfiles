#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0

echo -e "${BLUE}=== Dotfiles Repository Verification Suite ===${NC}\n"

# 1. Check Shell Script Syntax across entire repo
echo -e "${BLUE}[1/7] Checking Bash script syntax (bash -n)...${NC}"
ALL_SCRIPTS=(
  "$ROOT_DIR/install.sh"
  "$ROOT_DIR"/scripts/*.sh
  "$ROOT_DIR"/shell/*.sh
  "$ROOT_DIR"/ai/adapters/*.sh
)

for script in "${ALL_SCRIPTS[@]}"; do
  if [[ -f "$script" ]]; then
    rel_path="${script#"$ROOT_DIR/"}"
    if bash -n "$script" 2>&1; then
      echo -e "  ${GREEN}✓${NC} Syntax OK: $rel_path"
    else
      echo -e "  ${RED}✗${NC} Syntax Error: $rel_path"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

# 2. Check Executable Permissions
echo -e "\n${BLUE}[2/7] Checking executable permissions...${NC}"
for script in "${ALL_SCRIPTS[@]}"; do
  if [[ -f "$script" ]]; then
    rel_path="${script#"$ROOT_DIR/"}"
    if [[ -x "$script" ]]; then
      echo -e "  ${GREEN}✓${NC} Executable: $rel_path"
    else
      echo -e "  ${YELLOW}!${NC} Missing execute permission (fixing): $rel_path"
      chmod +x "$script"
    fi
  fi
done

# 3. Environment & Git Secret Security Checks
echo -e "\n${BLUE}[3/7] Checking environment and secret hygiene...${NC}"
if [[ -f "$ROOT_DIR/.env.sample" ]]; then
  echo -e "  ${GREEN}✓${NC} .env.sample exists"
else
  echo -e "  ${RED}✗${NC} .env.sample is missing"
  ERRORS=$((ERRORS + 1))
fi

if git -C "$ROOT_DIR" check-ignore -q "$ROOT_DIR/.env" 2>/dev/null; then
  echo -e "  ${GREEN}✓${NC} .env is properly ignored by Git"
else
  echo -e "  ${RED}✗${NC} SECURITY RISK: .env is NOT ignored by .gitignore"
  ERRORS=$((ERRORS + 1))
fi

# Ensure no tracked credentials or keys in git index
TRACKED_SECRETS="$(git -C "$ROOT_DIR" ls-files | grep -E '(\.key|\.pem|\.token|\.secret|credentials\.json|auth\.json)$' || true)"
if [[ -z "$TRACKED_SECRETS" ]]; then
  echo -e "  ${GREEN}✓${NC} No secrets or keys tracked in Git index"
else
  echo -e "  ${RED}✗${NC} SECURITY RISK: Detected tracked secrets:\n$TRACKED_SECRETS"
  ERRORS=$((ERRORS + 1))
fi

# 4. Check Shell Dotfiles Components
echo -e "\n${BLUE}[4/7] Checking Shell dotfiles components...${NC}"
EXPECTED_SHELL_FILES=(
  "shell/env.sh"
  "shell/aliases.sh"
  "shell/functions.sh"
  "shell/bashrc.sh"
  "shell/zshrc.sh"
  "shell/zsh/custom/themes/devex.zsh-theme"
)
for sf in "${EXPECTED_SHELL_FILES[@]}"; do
  if [[ -f "$ROOT_DIR/$sf" ]]; then
    echo -e "  ${GREEN}✓${NC} Shell component present: $sf"
  else
    echo -e "  ${RED}✗${NC} Missing shell component: $sf"
    ERRORS=$((ERRORS + 1))
  fi
done

# 5. Check Unified AI Agent Architecture & Skills
echo -e "\n${BLUE}[5/7] Checking AI Agent instructions and skills...${NC}"
if [[ -f "$ROOT_DIR/AGENTS.md" ]]; then
  echo -e "  ${GREEN}✓${NC} Root AGENTS.md exists"
else
  echo -e "  ${RED}✗${NC} AGENTS.md missing at root"
  ERRORS=$((ERRORS + 1))
fi

if [[ -f "$ROOT_DIR/ai/common-instructions.md" ]]; then
  echo -e "  ${GREEN}✓${NC} ai/common-instructions.md exists"
else
  echo -e "  ${RED}✗${NC} ai/common-instructions.md missing"
  ERRORS=$((ERRORS + 1))
fi

# Check root links
if [[ -L "$ROOT_DIR/CLAUDE.md" || -f "$ROOT_DIR/CLAUDE.md" ]]; then
  echo -e "  ${GREEN}✓${NC} Root CLAUDE.md entrypoint exists"
else
  echo -e "  ${YELLOW}!${NC} Root CLAUDE.md missing (run ai/adapters/claude.sh to link)"
fi

if [[ -L "$ROOT_DIR/GEMINI.md" || -f "$ROOT_DIR/GEMINI.md" ]]; then
  echo -e "  ${GREEN}✓${NC} Root GEMINI.md entrypoint exists"
else
  echo -e "  ${YELLOW}!${NC} Root GEMINI.md missing (run ai/adapters/agy.sh to link)"
fi

# Validate skills frontmatter
SKILL_FILES=("$ROOT_DIR"/ai/skills/*/SKILL.md "$ROOT_DIR"/.agents/skills/*/SKILL.md)
for skill_file in "${SKILL_FILES[@]}"; do
  if [[ -f "$skill_file" ]]; then
    rel_skill="${skill_file#"$ROOT_DIR/"}"
    if grep -q "^name:" "$skill_file" && grep -q "^description:" "$skill_file"; then
      echo -e "  ${GREEN}✓${NC} Skill valid: $rel_skill"
    else
      echo -e "  ${RED}✗${NC} Skill invalid frontmatter: $rel_skill"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

# 6. Check AI Adapters Presence
echo -e "\n${BLUE}[6/7] Checking AI adapters for 6 CLI tools...${NC}"
EXPECTED_ADAPTERS=(
  "ai/adapters/claude.sh"
  "ai/adapters/opencode.sh"
  "ai/adapters/codex.sh"
  "ai/adapters/kilo.sh"
  "ai/adapters/agy.sh"
  "ai/adapters/pi.sh"
  "ai/adapters/sync-all.sh"
)
for adapter in "${EXPECTED_ADAPTERS[@]}"; do
  if [[ -f "$ROOT_DIR/$adapter" && -x "$ROOT_DIR/$adapter" ]]; then
    echo -e "  ${GREEN}✓${NC} Adapter ready: $adapter"
  else
    echo -e "  ${RED}✗${NC} Adapter missing or not executable: $adapter"
    ERRORS=$((ERRORS + 1))
  fi
done

# 7. Check mena Rust CLI
echo -e "\n${BLUE}[7/7] Checking mena Rust CLI...${NC}"
if [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
if [[ -f "$ROOT_DIR/mena/Cargo.toml" ]]; then
  echo -e "  ${GREEN}✓${NC} mena/Cargo.toml exists"
  if command -v cargo &>/dev/null; then
    if cargo check --manifest-path "$ROOT_DIR/mena/Cargo.toml" --quiet 2>/dev/null; then
      echo -e "  ${GREEN}✓${NC} mena Rust codebase compiles cleanly"
    else
      echo -e "  ${RED}✗${NC} mena failed cargo check"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo -e "  ${YELLOW}!${NC} Cargo not in PATH; skipping cargo check"
  fi
else
  echo -e "  ${RED}✗${NC} mena/Cargo.toml missing"
  ERRORS=$((ERRORS + 1))
fi

echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo -e "${GREEN}All checks passed successfully!${NC}"
  exit 0
else
  echo -e "${RED}Verification failed with $ERRORS error(s).${NC}"
  exit 1
fi

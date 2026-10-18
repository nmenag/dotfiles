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

echo -e "${BLUE}=== Dotfiles Repository Verification ===${NC}\n"

# 1. Check Shell Script Syntax
echo -e "${BLUE}[1/4] Checking Bash script syntax (bash -n)...${NC}"
SCRIPTS=("$ROOT_DIR/install.sh" "$ROOT_DIR"/scripts/*.sh)

for script in "${SCRIPTS[@]}"; do
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

# 2. Check Executable Bits
echo -e "\n${BLUE}[2/4] Checking executable permissions...${NC}"
for script in "${SCRIPTS[@]}"; do
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

# 3. Check Configuration & Sample
echo -e "\n${BLUE}[3/4] Checking environment configurations...${NC}"
if [[ -f "$ROOT_DIR/.env.sample" ]]; then
  echo -e "  ${GREEN}✓${NC} .env.sample exists"
else
  echo -e "  ${RED}✗${NC} .env.sample is missing"
  ERRORS=$((ERRORS + 1))
fi

if [[ -f "$ROOT_DIR/.env" ]]; then
  echo -e "  ${GREEN}✓${NC} .env exists (local configuration active)"
else
  echo -e "  ${YELLOW}!${NC} .env does not exist (copy from .env.sample if configuring custom Git identity)"
fi

# 4. Check Agents & Skills Configuration
echo -e "\n${BLUE}[4/4] Checking AI agent configurations (.agents and AGENTS.md)...${NC}"
if [[ -f "$ROOT_DIR/AGENTS.md" ]]; then
  echo -e "  ${GREEN}✓${NC} Root AGENTS.md exists"
else
  echo -e "  ${RED}✗${NC} AGENTS.md missing at root"
  ERRORS=$((ERRORS + 1))
fi

SKILL_FILES=("$ROOT_DIR"/.agents/skills/*/SKILL.md)
for skill_file in "${SKILL_FILES[@]}"; do
  if [[ -f "$skill_file" ]]; then
    skill_name="$(basename "$(dirname "$skill_file")")"
    if grep -q "^name:" "$skill_file" && grep -q "^description:" "$skill_file"; then
      echo -e "  ${GREEN}✓${NC} Skill valid: $skill_name"
    else
      echo -e "  ${RED}✗${NC} Skill invalid frontmatter: $skill_name"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo -e "${GREEN}All checks passed successfully!${NC}"
  exit 0
else
  echo -e "${RED}Verification failed with $ERRORS error(s).${NC}"
  exit 1
fi

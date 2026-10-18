#!/bin/bash
set -euo pipefail

# ai/adapters/sync-all.sh - Synchronize common instructions and skills across all 5 AI CLIs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo " Starting Unified AI Adapters Synchronization"
echo " Supporting: Claude Code, OpenCode, Codex, Kilo CLI, Agy"
echo "=========================================================="

bash "$SCRIPT_DIR/claude.sh"
echo ""
bash "$SCRIPT_DIR/opencode.sh"
echo ""
bash "$SCRIPT_DIR/codex.sh"
echo ""
bash "$SCRIPT_DIR/kilo.sh"
echo ""
bash "$SCRIPT_DIR/agy.sh"
echo ""

echo "=========================================================="
echo " All 5 AI CLI Adapters Synchronized Successfully!"
echo "=========================================================="

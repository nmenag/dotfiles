#!/bin/bash
set -euo pipefail

# scripts/ai-tools.sh - Synchronize common instructions and skills across all 6 AI CLIs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ADAPTERS_DIR="$ROOT_DIR/ai/adapters"

echo "=========================================================="
echo " Starting Unified AI Adapters Synchronization"
echo " Supporting: Claude Code, OpenCode, Codex, Kilo CLI, Agy, Pi Agent"
echo "=========================================================="

ADAPTERS=(
  "claude.sh"
  "opencode.sh"
  "codex.sh"
  "kilo.sh"
  "agy.sh"
  "pi.sh"
)

for adapter in "${ADAPTERS[@]}"; do
  adapter_path="$ADAPTERS_DIR/$adapter"
  if [[ -f "$adapter_path" ]]; then
    bash "$adapter_path"
    echo ""
  else
    echo "Warning: Adapter $adapter not found at $adapter_path" >&2
  fi
done

echo "=========================================================="
echo " All 6 AI CLI Adapters Synchronized Successfully!"
echo "=========================================================="

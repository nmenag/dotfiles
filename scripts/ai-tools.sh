#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Provisioning AI Agent Configurations & Adapters ==="

# Execute master sync script
bash "$ROOT_DIR/ai/adapters/sync-all.sh"

echo "AI tools provisioning and synchronization completed!"

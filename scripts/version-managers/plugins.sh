#!/bin/bash
set -euo pipefail

# scripts/version-managers/plugins.sh - Shared runtime plugins registry for ASDF and Mise
# Single source of truth (DRY) across polyglot version managers.
#
# Format per entry: "<tool_name>|<asdf_plugin_url>|<mise_tool_name>"

VERSION_MANAGER_PLUGINS=(
  "ruby|https://github.com/asdf-vm/asdf-ruby.git|ruby"
  "erlang|https://github.com/asdf-vm/asdf-erlang.git|erlang"
  "elixir|https://github.com/asdf-vm/asdf-elixir.git|elixir"
  "nodejs|https://github.com/asdf-vm/asdf-nodejs.git|node"
  "pnpm|https://github.com/jonathanmorley/asdf-pnpm.git|pnpm"
  "python|https://github.com/asdf-community/asdf-python.git|python"
)

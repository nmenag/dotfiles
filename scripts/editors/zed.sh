#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Setting up Zed editor..."

# Ensure ~/.local/bin is in PATH (Zed official installer places binary here)
export PATH="$HOME/.local/bin:$PATH"

# 1. Install Zed if not present
if command -v zed &>/dev/null; then
  echo "Zed is already installed: $(command -v zed)"
  echo "Version: $(zed --version 2>&1 | head -n 1 || echo 'unknown')"
else
  # Ensure prerequisites
  if ! command -v curl &>/dev/null; then
    echo "Installing curl..."
    sudo apt-get update -y
    sudo apt-get install -y curl
  fi

  echo "Downloading and installing Zed (official installer)..."
  curl -fsSL https://zed.dev/install.sh | sh
  echo "Zed installation completed successfully!"
fi

# 2. Configure Zed plugins (extensions) and language support
echo "Configuring Zed plugins (extensions) and language support..."

ZED_CONFIG_DIR="$HOME/.config/zed"
SETTINGS_FILE="$ZED_CONFIG_DIR/settings.json"
mkdir -p "$ZED_CONFIG_DIR"

# Create timestamped non-destructive backup if settings file exists
if [[ -f "$SETTINGS_FILE" ]]; then
  BACKUP_DIR="$HOME/.dotfiles_backup/zed_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  cp -p "$SETTINGS_FILE" "$BACKUP_DIR/settings.json"
  echo "  Backed up existing settings to $BACKUP_DIR/settings.json"
fi

# Merge extensions and language configurations safely into settings.json
python3 - << 'EOF'
import os
import re
import json

settings_file = os.path.expanduser("~/.config/zed/settings.json")

def strip_jsonc(text):
    text = re.sub(r'//.*', '', text)
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    text = re.sub(r',\s*([}\]])', r'\1', text)
    return text

existing = {}
if os.path.exists(settings_file):
    try:
        with open(settings_file, "r", encoding="utf-8") as f:
            raw = f.read().strip()
            if raw:
                existing = json.loads(strip_jsonc(raw))
    except Exception as e:
        print(f"  Warning: Could not parse existing settings.json ({e}). Starting with default settings.")

# 1. Curated extensions (auto_install_extensions)
extensions = {
    # Web & Frontend
    "html": True,
    "emmet": True,
    "astro": True,
    "svelte": True,
    "vue": True,
    # Backend, Cloud & Databases
    "elixir": True,
    "ruby": True,
    "dockerfile": True,
    "docker-compose": True,
    "sql": True,
    "terraform": True,
    "proto": True,
    "graphql": True,
    "prisma": True,
    # Systems & Polyglot Languages
    "dart": True,
    "zig": True,
    "gleam": True,
    "nix": True,
    "kotlin": True,
    "java": True,
    # Config, Data & Productivity
    "toml": True,
    "env": True,
    "csv": True,
    "markdown-oxide": True,
    "snippets": True,
    "git-firefly": True,
}

if "auto_install_extensions" not in existing:
    existing["auto_install_extensions"] = {}

for ext, enabled in extensions.items():
    if ext not in existing["auto_install_extensions"]:
        existing["auto_install_extensions"][ext] = enabled

# 2. Languages configuration
languages_config = {
    "Elixir": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "HEEx": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "Ruby": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "Python": {
        "tab_size": 4,
        "format_on_save": "on",
        "formatter": {
            "language_server": {
                "name": "ruff"
            }
        }
    },
    "JavaScript": {
        "tab_size": 2,
        "format_on_save": "on",
        "code_actions_on_format": {
            "source.fixAll.eslint": True
        }
    },
    "TypeScript": {
        "tab_size": 2,
        "format_on_save": "on",
        "code_actions_on_format": {
            "source.fixAll.eslint": True
        }
    },
    "TSX": {
        "tab_size": 2,
        "format_on_save": "on",
        "code_actions_on_format": {
            "source.fixAll.eslint": True
        }
    },
    "Rust": {
        "tab_size": 4,
        "format_on_save": "on"
    },
    "Go": {
        "tab_size": 4,
        "hard_tabs": True,
        "format_on_save": "on"
    },
    "HTML": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "CSS": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "JSON": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "YAML": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "TOML": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "SQL": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "Dockerfile": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "Docker Compose": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "Markdown": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "Shell Script": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "Dart": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "Terraform": {
        "tab_size": 2,
        "format_on_save": "on"
    },
    "GraphQL": {
        "tab_size": 2,
        "format_on_save": "on"
    }
}

if "languages" not in existing:
    existing["languages"] = {}

for lang, cfg in languages_config.items():
    if lang not in existing["languages"]:
        existing["languages"][lang] = cfg
    elif isinstance(existing["languages"][lang], dict):
        for k, v in cfg.items():
            if k not in existing["languages"][lang]:
                existing["languages"][lang][k] = v

# 3. LSP configuration
lsp_config = {
    "rust-analyzer": {
        "initialization_options": {
            "inlayHints": {
                "lifetimeElisionHints": {
                    "enable": "skip_trivial",
                    "useParameterNames": True
                },
                "closureReturnTypeHints": {
                    "enable": "always"
                }
            }
        }
    },
    "elixir-ls": {
        "settings": {
            "dialyzerEnabled": True
        }
    }
}

if "lsp" not in existing:
    existing["lsp"] = {}

for srv, cfg in lsp_config.items():
    if srv not in existing["lsp"]:
        existing["lsp"][srv] = cfg
    elif isinstance(existing["lsp"][srv], dict):
        for k, v in cfg.items():
            if k not in existing["lsp"][srv]:
                existing["lsp"][srv][k] = v

# 4. DevEx Editor Defaults
editor_defaults = {
    "format_on_save": "on",
    "remove_trailing_whitespace_on_save": True,
    "ensure_final_newline_on_save": True
}

for k, v in editor_defaults.items():
    if k not in existing:
        existing[k] = v

with open(settings_file, "w", encoding="utf-8") as f:
    json.dump(existing, f, indent=2)
    f.write("\n")

ext_count = len(existing.get("auto_install_extensions", {}))
lang_count = len(existing.get("languages", {}))
print(f"  Successfully updated {settings_file} ({ext_count} extensions, {lang_count} languages configured)")
EOF

echo "Zed editor setup completed successfully!"
echo "NOTE: Ensure ~/.local/bin is in your PATH to run 'zed'."

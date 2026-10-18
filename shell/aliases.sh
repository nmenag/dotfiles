#!/bin/bash
# shell/aliases.sh - Shared aliases across Bash and Zsh

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Listing (detect color support)
if ls --color > /dev/null 2>&1; then
  alias ls='ls --color=auto'
  alias ll='ls -lh --color=auto'
  alias la='ls -lah --color=auto'
  alias l='ls -CF --color=auto'
else
  alias ll='ls -lh'
  alias la='ls -lah'
  alias l='ls -CF'
fi

# Safety prompts for destructive operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git shortcuts
alias g='git'
alias gst='git status -sb'
alias gco='git checkout'
alias gcb='git checkout -b'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --graph --decorate'

# Docker shortcuts
alias d='docker'
alias dco='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'

# Fast access to dotfiles
alias dotfiles='cd "${DOTFILES_DIR:-$HOME/personal-projects/dotfiles}"'

# Desktop / Development tools shortcuts
if command -v orca-ide &>/dev/null; then
  alias orca='orca-ide'
fi
if command -v brave-browser &>/dev/null; then
  alias brave='brave-browser'
fi

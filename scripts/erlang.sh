#!/bin/bash

echo "Install Erlang via ASDF package manager"

asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf install erlang latest
asdf global erlang latest

cat <<EOT >> ~/.zshrc
export ERL_AFLAGS="-kernel shell_history enabled"
EOT

source ~/.zshrc

#!/bin/bash

echo "config Tilix"

cat <<EOT >> ~/.zshrc

if [[ $TILIX_ID ]]; then
        source /etc/profile.d/vte.sh
fi

EOT

source ~/.zshrc

echo "Tilix configured!!"
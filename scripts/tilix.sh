#!/bin/bash

echo "config Tilix"

sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh

cat <<EOT >> ~/.zshrc

if [[ $TILIX_ID ]]; then
        source /etc/profile.d/vte.sh
fi

EOT

source ~/.zshrc

echo "Tilix configured!!"
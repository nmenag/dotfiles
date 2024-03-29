#!/bin/bash

echo "Install Tilix"

sudo apt-get install tilix

sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh

cat <<EOT >> ~/.zshrc

if [[ $TILIX_ID ]]; then
        source /etc/profile.d/vte.sh
fi

EOT

source ~/.zshrc

dconf load /com/gexperts/Tilix/ < tilix.dconf

echo "Tilix configured!!"
#!/bin/bash

echo 'Install Dbeaver'

wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

sudo apt update

sudo apt install dbeaver-ce

echo 'finished Dbeaver!!!!'
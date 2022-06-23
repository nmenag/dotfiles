#!/bin/bash

echo "Installing ohmyzsh"

sudo apt install zsh -y

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "If it can't works, reboot the machine."
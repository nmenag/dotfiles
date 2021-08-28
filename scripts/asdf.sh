#!/bin/bash

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1

echo -e "\n. $HOME/.asdf/asdf.sh" >> ~/.zshrc

source ~/.zshrc

echo "ASDF already installed!!"
echo $(asdf --version)
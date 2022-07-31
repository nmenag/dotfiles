#!/bin/bash

echo "Installing ASDF"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1

echo -e "\n. $HOME/.asdf/asdf.sh" >> ~/.zshrc

source ~/.zshrc

echo "ASDF installed!!"
echo $(asdf --version)

echo "Install ruby"

asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby latest
asdf global ruby latest

echo "Install Elixir"

asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf install elixir latest
asdf global elixir latest

echo "Install Nodejs"

asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest

source ~/.zshrc

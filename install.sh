#!/bin/bash

# ./copy.sh

echo "Updating System!!!"
sudo apt update && sudo apt full-upgrade -y
echo "Updated System!!!"

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo apt install -y $1
  else
    echo "Already installed: ${1}"
  fi
}

install make
install build-essential
install libssl-dev
install zlib1g-dev
install libbz2-dev
install libreadline-dev
install libsqlite3-dev
install libyaml-dev # is required asdf install ruby
install libncurses5-dev
install libpq-dev # is required install for pg ge
install wget
install curl
install llvm
install snapd
install cheese # program for video calling
sudo apt upgrade -y
sudo apt autoremove -y

./scripts/ohmyzsh.sh
./scripts/programs.sh
./scripts/asdf.sh
./scripts/vscode.sh
./scripts/postgres.sh

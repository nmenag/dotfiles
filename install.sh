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
install wget
install curl
install llvm
install libncurses5-dev
install tilix
install snapd
install libpq-dev # is required install for pg ge

sudo apt upgrade -y
sudo apt autoremove -y

#!/bin/bash

echo "Updating System!!"
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Removing old docker version"
sudo apt-get remove docker docker-engine docker.io containerd runc -y

echo "Installing Docker"

sudo apt-get update -y

sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# sudo groupadd docker
# sudo usermod -aG docker $USER
# newgrp docker

#!/bin/bash

echo "Install Vs code"
# https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update -y
sudo apt install code

echo "Install extensions"

# Visual Studio Code :: Package list
pkglist=(
  WakaTime.vscode-wakatime
  mjmcloug.vscode-elixir
  bung87.vscode-gemfile
  rebornix.Ruby
  misogi.ruby-rubocop
  castwide.solargraph
  alefragnani.project-manager
  esbenp.prettier-vscode
  one-monokai
  MS-vsliveshare.vsliveshare
  oderwat.indent-rainbow
  eamodio.gitlens
  donjayamanne.githistory
  iampeterbanjo.elixirlinter
  streetsidesoftware.code-spell-checker
  HookyQR.beautify
)

for i in ${pkglist[@]}; do
  code --install-extension $i
done
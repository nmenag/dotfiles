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
  alefragnani.project-manager
  azemoh.one-monokai
  bradlc.vscode-tailwindcss
  bung87.vscode-gemfile
  castwide.solargraph
  craigmaslowski.erb
  dbaeumer.vscode-eslint
  donjayamanne.githistory
  eamodio.gitlens
  esbenp.prettier-vscode
  florinpatrascu.vscode-elixir-snippets
  googlecloudtools.cloudcode
  iampeterbanjo.elixirlinter
  jakebecker.elixir-ls
  maxmellen.elixir-language-support
  mermade.openapi-lint
  misogi.ruby-rubocop
  mrorz.language-gettext
  ms-vscode-remote.remote-containers
  ms-vscode.vscode-typescript-next
  ms-vsliveshare.vsliveshare
  oderwat.indent-rainbow
  redhat.vscode-yaml
  streetsidesoftware.code-spell-checker
  streetsidesoftware.code-spell-checker-spanish
  techer.open-in-browser
  wakatime.vscode-wakatime
  yoavbls.pretty-ts-errors
)

for i in ${pkglist[@]}; do
  code --install-extension $i
done

echo "Finished VS code"

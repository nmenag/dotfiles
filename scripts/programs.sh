#!/bin/bash

echo 'Updating System!!'
sudo apt-get update -y && sudo apt-get upgrade -y
echo 'updated system!!!'

echo 'Install postman'
sudo snap install postman
echo 'finished postman!!!'

echo 'Install Flameshot' # screenshots
sudo apt install flameshot

echo 'Install VLC' # media player
sudo apt-get install vlc

echo 'Install Chrome'

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

echo 'Install Dbeaver'  # Database tool

wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

sudo apt update

sudo apt install dbeaver-ce

echo 'finished Dbeaver!!!!'  # Database tool

echo 'Robomongo 3T'

sudo snap install robo3t-snap

echo 'finished Robomongo3T!!!!'  # Database tool

echo 'Bleachbit' # clean tool

sudo apt install bleachbit

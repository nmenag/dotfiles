#!/bin/bash

echo 'Updating System!!'
sudo apt-get update -y && sudo apt-get upgrade -y

echo 'INSTALL POSTMAN'
sudo snap install postman
echo 'finished postman!!!'

echo 'INSTALL FLAMESHOT' # screenshots
sudo apt install flameshot

echo 'INSTALL VLC' # media player
sudo apt-get install vlc

echo 'INSTALL GOOGLE CHROME BROWSER'

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

echo 'INSTALL BLEACHBIT CLEAN TOOL'

sudo apt install bleachbit

echo 'finished install programs'

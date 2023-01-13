#!/bin/bash

echo 'Updating System!!'
sudo apt-get update -y && sudo apt-get upgrade -y

echo 'Install okular' # PDF viewer
sudo apt install okular

echo 'Install skype'

wget https://go.skype.com/skypeforlinux-64.deb
sudo apt install ./skypeforlinux-64.deb

echo 'Install postman'
sudo snap install postman


echo 'Install Flameshot' # screenshots
sudo apt install flameshot

echo 'Install Filezilla' # sftp client
sudo apt-get install filezilla

echo 'Install VLC' # media player
sudo apt-get install vlc

echo 'Install Brave' # browser

sudo apt install apt-transport-https curl

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install brave-browser

echo 'Install Chrome'

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

echo 'Install Dbeaver'  # Database tool

wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

sudo apt update

sudo apt install dbeaver-ce

echo 'Robomongo 3T'

sudo snap install robo3t-snap

echo 'Bleachbit' # clean tool

sudo apt install bleachbit

echo "Install zoonavigator"

sudo snap install zoonavigator
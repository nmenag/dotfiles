#!/bin/bash

echo "Updating System!!"
sudo apt-get update -y && sudo apt-get upgrade -y

echo "update dependencies"
sudo apt --fix-broken install -y

sudo apt-get install libgconf-2-4

echo "Download mongocompass"
wget https://downloads.mongodb.com/compass/mongodb-compass_1.32.3_amd64.deb

echo "Installation..."
sudo dpkg -i mongodb-compass_1.32.3_amd64.deb

echo "finished"
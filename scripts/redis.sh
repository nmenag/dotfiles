#!/bin/bash

echo "Updating System!!"
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Install redis"
sudo apt install redis-server
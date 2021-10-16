#!/bin/bash

echo "Updating System!!"
sudo apt-get update -y && sudo apt-get upgrade -y

echo 'Installing Postgres'

sudo apt-get install wget ca-certificates -y
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ 'lsb_release -cs'-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

sudo apt-get update

sudo apt-get install postgresql postgresql-contrib


echo "Creating the Rol"

$(createuser -U "$USERNAME" --superuser)
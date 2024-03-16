#!/bin/bash

echo 'Install pgAdmin4 desktop'

echo 'Add the public key for the repository (if not done previously)'
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

echo 'Creating the repository configuration file in sources.list.d'

sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

# Install for both desktop and web modes:
# sudo apt install pgadmin4

echo 'Install for desktop mode only'

sudo apt install pgadmin4-desktop

# # Install for web mode only: 
# sudo apt install pgadmin4-web 

# info: https://www.pgadmin.org/download/pgadmin-4-apt/
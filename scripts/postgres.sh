#!/bin/bash

echo 'Updating System!!'
sudo apt-get update -y && sudo apt-get upgrade -y

echo 'Installing Postgres'

sudo apt-get install wget ca-certificates -y
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ 'lsb_release -cs'-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

sudo apt-get update

sudo apt-get install postgresql postgresql-contrib


###############################################################
#            CONFIG
###############################################################

# 1) open the file pg_hba.conf

# sudo nano /etc/postgresql/14/main/pg_hba.conf

# 2) Add a new line in pg_hba.conf:

# local    postgres     postgres     peer

# 3) Then restart/reload PostgreSQL:

# /etc/init.d/postgresql reload

# 4) change the password run:

# sudo -u postgres psql

# 5) From the resulting prompt:

# ALTER USER postgres PASSWORD 'postgres';

# 6) connect to postgres

# psql -h localhost -U postgres -d postgres

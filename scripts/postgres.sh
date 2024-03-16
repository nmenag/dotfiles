#!/bin/bash

echo 'Installing Postgres'

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

echo 'Import the repository signing key'
$ wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null

echo 'update!!!!'
$ sudo apt update

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

#!/bin/bash

sudo apt-get install gnupg

wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

echo "deb http://security.ubuntu.com/ubuntu impish-security main" | sudo tee /etc/apt/sources.list.d/impish-security.list

sudo apt-get update -y

sudo apt-get install libssl1.1

sudo apt-get install -y mongodb-org

sudo systemctl start mongod

# if failed the start mongoDB

# sudo systemctl daemon-reload

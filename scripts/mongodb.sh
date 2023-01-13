#!/bin/bash

sudo apt-get install gnupg

wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

echo "deb http://security.ubuntu.com/ubuntu impish-security main" | sudo tee /etc/apt/sources.list.d/impish-security.list

sudo apt-get update -y

wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1-1ubuntu2.1\~18.04.20_amd64.deb

sudo dpkg -i libssl1.1_1.1.1-1ubuntu2.1~18.04.20_amd64.deb

sudo apt-get install -y mongodb-org

sudo systemctl start mongod

# if failed the start mongoDB

# sudo systemctl daemon-reload


# check mongo status 

sudo systemctl status mongod

#  mongod.service - MongoDB Database Server
#      Loaded: loaded (/lib/systemd/system/mongod.service; disabled; vendor preset: enabled)
#      Active: active (running) since Thu 2023-01-12 22:55:45 -05; 16s ago
#        Docs: https://docs.mongodb.org/manual
#    Main PID: 14875 (mongod)
#      Memory: 61.1M
#         CPU: 226ms
#      CGroup: /system.slice/mongod.service
#              └─14875 /usr/bin/mongod --config /etc/mongod.conf
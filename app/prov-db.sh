#!/bin/bash
# prov-db.sh - Provision MongoDB 7.0 for Sparta Test App

set -e  # Stop script if any command fails

echo "========================="
echo " Updating System Packages"
echo "========================="
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
echo "System update complete."
echo


echo "====================================="
echo " Importing MongoDB 7.0 Public GPG Key"
echo "====================================="
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
gpg --dearmor | sudo tee /usr/share/keyrings/mongodb-server-7.0.gpg > /dev/null
echo "GPG key added."
echo

echo "======================================"
echo " Creating MongoDB APT Source List File"
echo "======================================"
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list > /dev/null

echo "Reloading package list..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
echo

echo "==========================="
echo " Installing MongoDB 7.0.22"
echo "==========================="
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
   mongodb-org=7.0.22 \
   mongodb-org-database=7.0.22 \
   mongodb-org-server=7.0.22 \
   mongodb-mongosh \
   mongodb-org-shell=7.0.22 \
   mongodb-org-mongos=7.0.22 \
   mongodb-org-tools=7.0.22 \
   mongodb-org-database-tools-extra=7.0.22
echo "MongoDB installed."
echo

echo "==============================="
echo " Configuring MongoDB to Allow External Connections"
echo "==============================="

# Backup existing config
sudo cp /etc/mongod.conf /etc/mongod.conf.bk

# Update bindIp to 0.0.0.0
sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
echo "bindIp updated to 0.0.0.0"
echo

echo "====================="
echo " Starting MongoDB..."
echo "====================="
sudo systemctl start mongod
sudo systemctl enable mongod


echo
echo "======================================="
echo " MongoDB provisioned and running "
echo "======================================="

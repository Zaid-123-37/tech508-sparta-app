#!/bin/bash
# prov-app.sh - Provision Sparta Test App on App VM

set -e  # Exit immediately if a command exits with a non-zero status

echo 
echo " Updating System Packages"
echo 
sudo apt-get update -y
sudo apt-get upgrade -y
echo "System update complete."
echo

echo 
echo " Installing NGINX"
echo 
sudo apt-get install -y nginx
echo "NGINX installation complete."
echo

echo 
echo " Installing Node.js v20"
echo 
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
echo "Node version: $(node -v)"
echo "NPM version:  $(npm -v)"
echo

echo 
echo " Cloning Sparta App from Git"
echo 
git clone https://github.com/Zaid-123-37/tech508-sparta-app.git repo
cd repo/app
echo "Repository cloned and moved to app folder."
echo

echo 
echo " Setting Environment Variable for DB"
echo 
export DB_HOST=mongodb://172.31.17.136:27017/posts
echo "DB_HOST set to $DB_HOST"
echo

echo 
echo " Installing NPM Modules"
echo 
npm install
echo "NPM packages installed."
echo

echo
echo " Starting the App"
echo 
npm start

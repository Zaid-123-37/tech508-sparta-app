#!/bin/bash
# prov-app.sh - Provision Sparta Test App on App VM

set -e  # Exit immediately on error

echo 
echo " Updating System Packages"
echo 
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
echo " System update complete."
echo

echo 
echo " Installing NGINX"
echo 
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
echo " NGINX installed."
echo

echo 
echo " Installing Node.js v20"
echo 
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
echo " Node version: $(node -v)"
echo " NPM version:  $(npm -v)"
echo

echo 
echo " Cloning Sparta App from GitHub"
echo 
if [ ! -d "repo" ]; then
  git clone https://github.com/Zaid-123-37/tech508-sparta-app.git repo
  echo " Repository cloned."
else
  echo "ℹ Repo already exists, skipping clone."
fi

cd repo/app || { echo " Failed to cd into repo/app"; exit 1; }

echo 
echo " Setting Environment Variable for DB"
echo 
#Make sure ip is changed to DB ip
export DB_HOST=mongodb://172.31.17.136:27017/posts
echo " DB_HOST set to $DB_HOST"
echo

echo 
echo " Installing NPM Modules"
echo 
npm install
echo " NPM packages installed."
echo

echo " Checking if anything is already using port 3000..."
PID=$(sudo lsof -t -i:3000 || true)
if [ -n "$PID" ]; then
  echo " Port 3000 is in use by PID $PID. Killing..."
  sudo kill $PID
  echo " Port 3000 cleared."
else
  echo " Port 3000 is free."
fi
echo

echo " Starting the App"
npm start &

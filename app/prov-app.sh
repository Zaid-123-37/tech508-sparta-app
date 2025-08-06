#!/bin/bash
# prov-app.sh - Provision Sparta Test App on App VM

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
# Always clone fresh by deleting existing directory first
git clone https://github.com/Zaid-123-37/tech508-sparta-app.git repo
echo " Repository cloned."
echo

echo
cd repo/app
echo "Changed to app directory: $(pwd)"

echo 
echo " Setting Environment Variable for DB"
echo 
# Make sure IP is changed to DB IP
export DB_HOST=mongodb://172.31.21.64:27017/posts
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
  echo " App not running. Port 3000 is free."
fi
echo

echo " Installing PM2 (Node.js process manager)..."
npm install -g pm2
echo " PM2 installed."

echo " Starting app with PM2..."
pm2 delete sparta-app || true  # Stop existing PM2 process if running
pm2 start npm --name sparta-app -- start  # Start app using 'npm start'
pm2 save
echo " App is now running under PM2."
echo " You can check with: pm2 list"
echo

# echo " Starting the App"
# npm start &

echo
echo " Configuring Nginx Reverse Proxy..."
# Backup the default nginx config
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

# Replace try_files line with proxy_pass
sudo sed -i 's|try_files .*;|proxy_pass http://localhost:3000;|' /etc/nginx/sites-available/default

# Restart nginx to apply changes
sudo systemctl restart nginx
echo " Nginx reverse proxy configured. App is now accessible without :3000"
echo

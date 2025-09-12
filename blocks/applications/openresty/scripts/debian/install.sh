#!/bin/bash
set -euo pipefail

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Installing OpenResty..."

# Install prerequisites
sudo apt-get update
sudo apt-get install -y wget gnupg ca-certificates lsb-release

# Add OpenResty repository
wget -O - https://openresty.org/package/pubkey.gpg | sudo apt-key add -
echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" | \
    sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null

# Update package list
sudo apt-get update

# Install OpenResty
sudo apt-get install -y openresty

# Create necessary directories
sudo mkdir -p /usr/local/openresty/nginx/conf/sites-available
sudo mkdir -p /usr/local/openresty/nginx/conf/sites-enabled
sudo mkdir -p /var/log/openresty

# Enable and start OpenResty service
sudo systemctl enable openresty

echo "[$(date +'%Y-%m-%d %H:%M:%S')] OpenResty installation completed"
openresty -v
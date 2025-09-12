# scripts/02-install-packages.sh
#!/bin/bash
set -e

echo "安裝基本套件..."
sudo apt-get install -y nginx curl wget unzip htop git mlocate

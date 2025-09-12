# scripts/02-install-packages.sh
#!/bin/bash
set -e

# 設定非互動模式，避免 debconf 前端錯誤
export DEBIAN_FRONTEND=noninteractive

echo "安裝基本套件..."
sudo apt-get install -y nginx curl wget unzip htop git

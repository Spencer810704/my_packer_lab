#!/bin/bash
set -e

# 自定義應用程式安裝腳本 - Debian/Ubuntu
echo "安裝自定義應用程式 (Debian/Ubuntu)..."

# 設定非互動模式
export DEBIAN_FRONTEND=noninteractive

# 更新套件列表
sudo apt-get update

# 安裝依賴套件
sudo apt-get install -y curl wget unzip

# 建立應用程式目錄
sudo mkdir -p /opt/my-app
sudo chown ubuntu:ubuntu /opt/my-app

# 下載和安裝應用程式
cd /opt/my-app
wget https://example.com/my-app.tar.gz
tar -xzf my-app.tar.gz
rm my-app.tar.gz

# 設定權限
sudo chown -R ubuntu:ubuntu /opt/my-app
chmod +x /opt/my-app/bin/my-app

echo "自定義應用程式安裝完成"
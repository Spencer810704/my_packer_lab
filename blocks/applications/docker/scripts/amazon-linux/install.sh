#!/bin/bash
set -e

echo "🐳 開始在 Amazon Linux 上安裝 Docker..."

# Amazon Linux 2
if grep -q "Amazon Linux 2" /etc/system-release 2>/dev/null; then
    # 更新套件
    sudo yum update -y
    
    # 安裝 Docker
    sudo amazon-linux-extras install -y docker
    
    # 安裝 docker-compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

# Amazon Linux 2023
elif grep -q "Amazon Linux 2023" /etc/system-release 2>/dev/null; then
    # 安裝 Docker
    sudo yum install -y docker
    
    # 安裝 docker-compose plugin
    sudo yum install -y docker-compose-plugin
fi

# 啟動 Docker 服務
sudo systemctl enable docker
sudo systemctl start docker

# 確認 Docker 版本
docker --version

echo "✅ Docker 安裝完成!"
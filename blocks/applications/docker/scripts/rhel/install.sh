#!/bin/bash
set -e

echo "🐳 開始在 RHEL/CentOS 系統上安裝 Docker..."

# 移除舊版本
sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine 2>/dev/null || true

# 安裝必要的套件
sudo yum install -y yum-utils

# 新增 Docker 官方倉庫
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安裝 Docker CE
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 啟動 Docker 服務
sudo systemctl enable docker
sudo systemctl start docker

# 確認 Docker 版本
docker --version

echo "✅ Docker 安裝完成!"
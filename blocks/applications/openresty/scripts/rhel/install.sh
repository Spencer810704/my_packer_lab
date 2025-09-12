#!/bin/bash
set -e

echo "🔧 開始在 RHEL/CentOS 系統上安裝 OpenResty..."

# 安裝必要的套件
sudo yum install -y yum-utils

# 添加 OpenResty 官方倉庫
sudo yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo

# 安裝 OpenResty
sudo yum install -y openresty

# 安裝額外的 Lua 模組
sudo yum install -y openresty-opm

# 設定系統服務
sudo systemctl enable openresty
sudo systemctl start openresty

# 確認版本
openresty -v

echo "✅ OpenResty 安裝完成!"
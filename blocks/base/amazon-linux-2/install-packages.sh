#!/bin/bash
set -e

echo "📦 安裝基本套件..."

# 基本工具
sudo yum install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    jq \
    unzip \
    tree

# 開發工具
sudo yum groupinstall -y "Development Tools"

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
cd /tmp
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf /tmp/aws*

# 系統監控工具
sudo yum install -y amazon-cloudwatch-agent

echo "✅ 基本套件安裝完成!"
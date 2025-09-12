#!/bin/bash
set -e

echo "⚙️ 配置 Docker 環境..."

# 配置 Docker daemon
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# 重新載入並重啟 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# 將 ec2-user 加入 docker 群組
sudo usermod -aG docker ec2-user

echo "✅ Docker 配置完成!"
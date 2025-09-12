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

# 如果有 ec2-user，將其加入 docker 群組
if id "ec2-user" &>/dev/null; then
    sudo usermod -aG docker ec2-user
    echo "✅ 已將 ec2-user 加入 docker 群組"
fi

# 如果有 centos 用戶，將其加入 docker 群組
if id "centos" &>/dev/null; then
    sudo usermod -aG docker centos
    echo "✅ 已將 centos 用戶加入 docker 群組"
fi

echo "✅ Docker 配置完成!"
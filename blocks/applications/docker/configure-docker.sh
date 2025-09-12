#!/bin/bash
set -euo pipefail

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Configuring Docker..."

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Configure Docker daemon
sudo tee /etc/docker/daemon.json > /dev/null << EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF

# Restart Docker service
sudo systemctl restart docker

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Docker configuration completed"
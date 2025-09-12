#!/bin/bash
set -euo pipefail

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Validating Docker installation..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed"
    exit 1
fi

# Check Docker version
docker --version

# Check if Docker service is running
if ! systemctl is-active --quiet docker; then
    echo "ERROR: Docker service is not running"
    exit 1
fi

# Test Docker functionality
sudo docker run --rm hello-world

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Docker validation completed successfully"
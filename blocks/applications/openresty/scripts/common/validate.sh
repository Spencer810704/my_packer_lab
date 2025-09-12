#!/bin/bash
set -euo pipefail

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Validating OpenResty installation..."

# Check if OpenResty is installed
if ! command -v openresty &> /dev/null; then
    echo "ERROR: OpenResty is not installed"
    exit 1
fi

# Check OpenResty configuration
sudo openresty -t

# Start OpenResty service
sudo systemctl start openresty

# Check if service is running
if ! systemctl is-active --quiet openresty; then
    echo "ERROR: OpenResty service is not running"
    exit 1
fi

# Test HTTP endpoint
sleep 5
if curl -f http://localhost/ > /dev/null 2>&1; then
    echo "✓ OpenResty is responding on port 80"
else
    echo "WARNING: OpenResty not responding on port 80"
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] OpenResty validation completed"
#!/bin/bash
set -e

echo "⏳ 等待 cloud-init 完成..."
sudo cloud-init status --wait || true
echo "✅ Cloud-init 完成!"
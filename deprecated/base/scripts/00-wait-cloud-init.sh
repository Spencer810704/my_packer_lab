#!/bin/bash
# scripts/00-wait-cloud-init.sh
set -e

echo "等待 cloud-init 完成..."
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo 'Waiting for cloud-init...'
  sleep 1
done
# scripts/01-system-update.sh
#!/bin/bash
set -e

echo "更新系統套件..."
sudo apt-get update
sudo apt-get upgrade -y
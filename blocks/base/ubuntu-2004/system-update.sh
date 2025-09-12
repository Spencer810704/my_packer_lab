# scripts/01-system-update.sh
#!/bin/bash
set -e

# 設定非互動模式，避免 debconf 前端錯誤
export DEBIAN_FRONTEND=noninteractive

echo "更新系統套件..."
sudo apt-get update
sudo apt-get upgrade -y
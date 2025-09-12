#!/bin/bash
set -e

echo "🧹 清理系統..."

# 清理套件快取
sudo yum clean all

# 清理日誌
sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

# 清理臨時檔案
sudo rm -rf /tmp/* /var/tmp/*

# 清理 SSH 金鑰（Packer 會重新生成）
sudo rm -f /etc/ssh/ssh_host_*

# 清理命令歷史
history -c
cat /dev/null > ~/.bash_history

echo "✅ 系統清理完成!"
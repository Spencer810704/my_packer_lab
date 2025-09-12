# scripts/99-cleanup.sh
#!/bin/bash
set -e

echo "清理系統..."
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
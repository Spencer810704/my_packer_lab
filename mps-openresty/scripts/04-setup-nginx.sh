# scripts/04-setup-nginx.sh
#!/bin/bash
set -e

echo "設定 Nginx..."
sudo systemctl enable nginx
sudo systemctl start nginx
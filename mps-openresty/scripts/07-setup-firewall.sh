# scripts/07-setup-firewall.sh
#!/bin/bash
set -e

echo "設定防火牆..."
sudo ufw --force enable
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 8888/tcp

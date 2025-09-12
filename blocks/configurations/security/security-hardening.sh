#!/bin/bash
set -euo pipefail

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Applying security hardening..."

# Install fail2ban
sudo apt-get update
sudo apt-get install -y fail2ban

# Configure fail2ban
sudo tee /etc/fail2ban/jail.local > /dev/null << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

# Start and enable fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Disable unused services
sudo systemctl disable avahi-daemon 2>/dev/null || true
sudo systemctl stop avahi-daemon 2>/dev/null || true

# Set secure SSH configuration
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Security hardening completed"
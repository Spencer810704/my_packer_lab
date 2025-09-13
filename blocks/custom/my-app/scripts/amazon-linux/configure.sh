#!/bin/bash
set -e

echo "配置自定義應用程式 (Amazon Linux)..."

# 建立配置檔案
sudo tee /opt/my-app/config.yaml > /dev/null <<EOF
server:
  port: 8080
  host: 0.0.0.0

database:
  type: sqlite
  path: /opt/my-app/data/app.db

logging:
  level: info
  file: /var/log/my-app.log
EOF

# 建立 systemd 服務
sudo tee /etc/systemd/system/my-app.service > /dev/null <<EOF
[Unit]
Description=My Custom Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/my-app
ExecStart=/opt/my-app/bin/my-app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 建立日誌目錄
sudo mkdir -p /var/log
sudo touch /var/log/my-app.log
sudo chown ec2-user:ec2-user /var/log/my-app.log

# 建立資料目錄
sudo mkdir -p /opt/my-app/data
sudo chown ec2-user:ec2-user /opt/my-app/data

# 啟用服務（但不啟動，讓使用者決定）
sudo systemctl daemon-reload
sudo systemctl enable my-app

echo "自定義應用程式配置完成"
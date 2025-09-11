# scripts/05-deploy-docker-app.sh
#!/bin/bash
set -e

echo "準備 Docker 示範應用..."
sudo mkdir -p /opt/docker-apps
cat <<EOF | sudo tee /opt/docker-apps/docker-compose.yml > /dev/null
version: '3.8'
services:
  hello-world:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    restart: unless-stopped
EOF

sudo mkdir -p /opt/docker-apps/html
cat <<EOF | sudo tee /opt/docker-apps/html/index.html > /dev/null
<!DOCTYPE html>
<html><head><title>Docker App</title></head>
<body><h1>🐳 Docker 應用執行中!</h1><p>這是在容器中運行的 Nginx</p></body></html>
EOF

sudo chown -R ubuntu:ubuntu /opt/docker-apps
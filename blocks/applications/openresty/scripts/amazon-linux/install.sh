#!/bin/bash
set -e

echo "🔧 開始在 Amazon Linux 上安裝 OpenResty..."

# 安裝依賴套件
sudo yum install -y pcre-devel openssl-devel gcc curl

# 下載並編譯 OpenResty（Amazon Linux 沒有官方倉庫）
OPENRESTY_VERSION="1.21.4.3"
cd /tmp
wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz
tar -xzvf openresty-${OPENRESTY_VERSION}.tar.gz
cd openresty-${OPENRESTY_VERSION}

# 編譯安裝
./configure --prefix=/usr/local/openresty \
            --with-pcre-jit \
            --with-ipv6 \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module

make -j$(nproc)
sudo make install

# 創建 systemd 服務檔案
sudo tee /etc/systemd/system/openresty.service > /dev/null <<EOF
[Unit]
Description=OpenResty
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/usr/local/openresty/nginx/logs/nginx.pid
ExecStartPre=/usr/local/openresty/nginx/sbin/nginx -t
ExecStart=/usr/local/openresty/nginx/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# 設定環境變數
echo 'export PATH=/usr/local/openresty/nginx/sbin:$PATH' | sudo tee -a /etc/profile.d/openresty.sh
sudo chmod +x /etc/profile.d/openresty.sh

# 啟動服務
sudo systemctl daemon-reload
sudo systemctl enable openresty
sudo systemctl start openresty

# 清理
rm -rf /tmp/openresty-${OPENRESTY_VERSION}*

echo "✅ OpenResty 安裝完成!"
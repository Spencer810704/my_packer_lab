# scripts/06-add-test-page.sh
#!/bin/bash
set -e

echo "建立更新的測試網頁..."
cat <<EOF | sudo tee /var/www/html/index.html > /dev/null
<!DOCTYPE html>
<html lang='zh-TW'>
<head>
    <meta charset='UTF-8'>
    <title>Packer v2.0 - 支援 Docker!</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background: #f0f8ff; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #1e88e5; text-align: center; }
        .success { color: #27ae60; font-size: 18px; text-align: center; }
        .info { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .new-feature { background: #e3f2fd; border-left: 4px solid #1e88e5; padding: 15px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class='container'>
        <h1>🚀 Packer v2.0 建構成功!</h1>
        <p class='success'>✅ 這台伺服器是用 Packer v2.0 建構的</p>

        <div class='new-feature'>
            <h3>🆕 新功能:</h3>
            <ul>
                <li>🐳 Docker Engine 已安裝</li>
                <li>🛠️ Docker Compose 已安裝</li>
                <li>📦 示範容器應用已準備 (port 8080)</li>
            </ul>
        </div>

        <div class='info'>
            <h3>伺服器資訊:</h3>
            <ul>
                <li>作業系統: Ubuntu 22.04 LTS</li>
                <li>Web 伺服器: Nginx</li>
                <li>容器平台: Docker + Docker Compose</li>
                <li>建構時間: $(date -u +"%Y-%m-%d %H:%M:%S UTC")</li>
                <li>版本: v2.0</li>
            </ul>
        </div>

        <p>🔧 準備好接受 Terraform 部署了!</p>
        <p><a href=":8080" target="_blank">🐳 查看 Docker 示範應用</a></p>
    </div>
</body>
</html>
EOF

#!/bin/bash
set -e

echo "驗證自定義應用程式安裝..."

# 檢查應用程式檔案是否存在
if [ ! -f "/opt/my-app/bin/my-app" ]; then
    echo "❌ 應用程式執行檔案不存在"
    exit 1
fi

# 檢查配置檔案是否存在
if [ ! -f "/opt/my-app/config.yaml" ]; then
    echo "❌ 配置檔案不存在"
    exit 1
fi

# 檢查 systemd 服務是否存在
if [ ! -f "/etc/systemd/system/my-app.service" ]; then
    echo "❌ systemd 服務檔案不存在"
    exit 1
fi

# 檢查服務是否已啟用
if ! sudo systemctl is-enabled my-app >/dev/null 2>&1; then
    echo "❌ 服務未啟用"
    exit 1
fi

# 檢查權限
if [ ! -x "/opt/my-app/bin/my-app" ]; then
    echo "❌ 應用程式檔案沒有執行權限"
    exit 1
fi

echo "✅ 自定義應用程式驗證通過"
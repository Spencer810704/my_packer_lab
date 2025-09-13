# 自定義積木開發指南

## 📁 目錄結構

```
blocks/custom/
├── README.md                   # 本說明文件
├── examples/                   # 範例積木
└── your-app/                   # 您的自定義積木
    ├── block.yaml              # 積木配置檔案
    └── scripts/                # 安裝腳本
        ├── debian/             # Debian/Ubuntu 專用腳本
        │   ├── install.sh      # 安裝腳本
        │   └── configure.sh    # 配置腳本
        ├── rhel/               # RHEL/CentOS 專用腳本
        │   ├── install.sh
        │   └── configure.sh
        ├── amazon-linux/       # Amazon Linux 專用腳本
        │   ├── install.sh
        │   └── configure.sh
        └── common/             # 共用腳本
            └── validate.sh     # 驗證腳本
```

## 🚀 建立自定義積木步驟

### 1. 建立積木目錄結構

```bash
# 建立您的積木目錄
mkdir -p blocks/custom/my-app/scripts/{debian,rhel,amazon-linux,common}
```

### 2. 建立 block.yaml 配置檔案

```yaml
name: "my-app"
description: "我的自定義應用程式"
version: "1.0.0"
category: "custom"

os_support:
  - os_family: "debian"
    os_versions: ["20.04", "22.04"]
    scripts:
      install: "scripts/debian/install.sh"
      configure: "scripts/debian/configure.sh"
      validate: "scripts/common/validate.sh"

dependencies:
  - "base-ubuntu-2004"

tags:
  - "custom"
  - "my-app"
```

### 3. 編寫安裝腳本

每個作業系統族群都需要對應的安裝腳本：

#### Debian/Ubuntu 腳本範例 (`scripts/debian/install.sh`)
```bash
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "安裝自定義應用程式..."
sudo apt-get update
sudo apt-get install -y 必要套件
# 您的安裝邏輯
```

#### RHEL/CentOS 腳本範例 (`scripts/rhel/install.sh`)
```bash
#!/bin/bash
set -e

echo "安裝自定義應用程式..."
sudo yum update -y
sudo yum install -y 必要套件
# 您的安裝邏輯
```

### 4. 更新 builder.pkr.hcl

在主要 Packer 配置檔案中新增您的自定義積木：

```hcl
# 自定義積木 - My App
provisioner "shell" {
  except = !contains(var.enabled_blocks, "custom-my-app") ? ["amazon-ebs.dynamic"] : []
  environment_vars = [
    "DEBIAN_FRONTEND=noninteractive"
  ]
  scripts = [
    "${var.blocks_path}/custom/my-app/scripts/${local.os_family}/install.sh",
    "${var.blocks_path}/custom/my-app/scripts/${local.os_family}/configure.sh"
  ]
}

# 自定義積木驗證
provisioner "shell" {
  except = !contains(var.enabled_blocks, "custom-my-app") ? ["amazon-ebs.dynamic"] : []
  script = "${var.blocks_path}/custom/my-app/scripts/common/validate.sh"
}
```

## 📋 使用自定義積木

在 Jenkins 參數中加入您的自定義積木：

```json
["base-ubuntu-2004", "app-docker", "custom-my-app", "config-security"]
```

## 🛠️ 自定義積木最佳實踐

### 1. 腳本規範
- 所有腳本必須以 `#!/bin/bash` 開頭
- 必須包含 `set -e` 以在錯誤時退出
- Debian 腳本應設定 `export DEBIAN_FRONTEND=noninteractive`
- 使用 `sudo` 執行需要權限的操作
- 在腳本開始加入說明 echo 訊息

### 2. 目錄和檔案權限
```bash
# 建立應用程式目錄
sudo mkdir -p /opt/my-app
sudo chown ubuntu:ubuntu /opt/my-app

# 設定正確權限
chmod +x /opt/my-app/bin/my-app
```

### 3. Systemd 服務範例
```bash
# 建立 systemd 服務檔案
sudo tee /etc/systemd/system/my-app.service > /dev/null <<EOF
[Unit]
Description=My Custom Application
After=network.target

[Service]
Type=simple
User=ubuntu
ExecStart=/opt/my-app/bin/my-app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 重新載入並啟用服務
sudo systemctl daemon-reload
sudo systemctl enable my-app
```

### 4. 驗證腳本
```bash
#!/bin/bash
set -e

echo "驗證安裝..."

# 檢查檔案存在
if [ ! -f "/opt/my-app/bin/my-app" ]; then
    echo "❌ 應用程式不存在"
    exit 1
fi

# 檢查服務狀態
if ! sudo systemctl is-enabled my-app; then
    echo "❌ 服務未啟用"
    exit 1
fi

echo "✅ 驗證通過"
```

## 🔧 除錯技巧

1. **測試單一積木**
   ```bash
   packer validate -var 'enabled_blocks=["custom-my-app"]' builder.pkr.hcl
   ```

2. **啟用詳細日誌**
   ```bash
   export PACKER_LOG=1
   ```

3. **檢查腳本權限**
   ```bash
   chmod +x blocks/custom/my-app/scripts/**/*.sh
   ```

## 📝 命名慣例

- 積木 ID: `custom-應用名稱` (例: `custom-my-app`)
- 目錄名稱: 使用小寫和連字號
- 腳本名稱: `install.sh`, `configure.sh`, `validate.sh`
- 服務名稱: 與積木名稱對應

## 🏷️ 標籤系統整合

自定義積木會自動歸類到 `Custom` 標籤中：

```
Custom: my-app_another-tool
```

多個自定義積木用底線分隔。

## 🧪 測試建議

1. **本地測試**: 先在本地虛擬機測試腳本
2. **段階測試**: 使用 `DRY_RUN=true` 驗證配置
3. **漸進式測試**: 從簡單積木開始，逐步增加複雜度
4. **多 OS 測試**: 確保在不同作業系統上都能正常運作

## 📞 支援

如需協助開發自定義積木，請：
1. 參考 `applications/` 目錄下的現有積木範例
2. 檢查日誌檔案診斷問題
3. 使用 Jenkins 的 DRY_RUN 模式測試配置
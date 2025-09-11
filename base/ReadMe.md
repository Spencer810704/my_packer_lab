# Packer Image Builder

這個專案使用 HashiCorp Packer 來建立和管理基礎設施映像檔，支援多環境部署。

## 專案結構

```
.
├── ReadMe.md                   # 專案說明文件
├── build.pkr.hcl               # 主要建構配置檔
├── source.pkr.hcl              # 映像檔來源配置
├── variables.pkr.hcl           # 變數定義檔
├── common.pkrvars.hcl          # 共用變數值
├── plugins.pkr.hcl             # Packer 插件配置
├── env/                        # 環境特定配置
│   ├── dev.pkrvars.hcl         # 開發環境變數
│   ├── stg.pkrvars.hcl         # 測試環境變數
│   └── prod.pkrvars.hcl        # 生產環境變數
├── metadata/                   # 建構後的元數據
│   ├── prod/
│   │   └── prod-manifest.json
│   └── stg/
│       └── stg-manifest.json
└── scripts/                    # 佈建腳本
    ├── 00-wait-cloud-init.sh   # 等待 cloud-init 完成
    ├── 01-system-update.sh     # 系統更新
    ├── 02-install-packages.sh  # 安裝套件
    └── 99-cleanup.sh           # 清理作業
```

## 前置需求

- [Packer](https://www.packer.io/downloads) >= 1.12.0
- 適當的雲端服務供應商 CLI 工具 (AWS CLI, Azure CLI, 或 GCP CLI)
- 相關的存取權限和認證設定

## 使用方法

### 1. 初始化 Packer

```bash
packer init .
```

### 2. 驗證配置

```bash
# 驗證開發環境配置
packer validate -var-file="common.pkrvars.hcl" -var-file="env/dev.pkrvars.hcl" .

# 驗證測試環境配置  
packer validate -var-file="common.pkrvars.hcl" -var-file="env/stg.pkrvars.hcl" .

# 驗證生產環境配置
packer validate -var-file="common.pkrvars.hcl" -var-file="env/prod.pkrvars.hcl" .
```

### 3. 建立映像檔

```bash
# 建立開發環境映像檔
packer build -var-file="common.pkrvars.hcl" -var-file="env/dev.pkrvars.hcl" .

# 建立測試環境映像檔
packer build -var-file="common.pkrvars.hcl" -var-file="env/stg.pkrvars.hcl" .

# 建立生產環境映像檔
packer build -var-file="common.pkrvars.hcl" -var-file="env/prod.pkrvars.hcl" .
```

## 佈建腳本說明

腳本按照編號順序執行：

1. **00-wait-cloud-init.sh** - 確保 cloud-init 初始化完成
2. **01-system-update.sh** - 更新系統套件和安全性修補
3. **02-install-packages.sh** - 安裝應用程式所需的套件
4. **99-cleanup.sh** - 清理暫存檔案和歷史記錄

## 環境配置

### 共用變數

`common.pkrvars.hcl` 包含所有環境共用的變數：
- SSH 使用者名稱
- AMI 名稱前綴
- AMI 篩選模式
- Canonical 擁有者 ID
- 資源擁有者標籤

### 環境特定變數

每個環境都有自己的變數檔案：
- `env/dev.pkrvars.hcl` - 開發環境特定設定（region、instance_type、env）
- `env/stg.pkrvars.hcl` - 測試環境特定設定（region、instance_type、env）
- `env/prod.pkrvars.hcl` - 生產環境特定設定（region、instance_type、env）

## 建構產出

建構完成後，相關的元數據和資訊會儲存在 `metadata/` 目錄中：

- `metadata/stg/stg-manifest.json` - 測試環境建構資訊
- `metadata/prod/prod-manifest.json` - 生產環境建構資訊

## 故障排除

### 常見問題

1. **認證錯誤**
   - 確認雲端服務供應商的 CLI 工具已正確配置
   - 檢查存取權限是否足夠

2. **建構失敗**
   - 檢查 `packer validate` 的輸出
   - 確認所有必要的變數都有設定

3. **腳本執行錯誤**
   - 檢查腳本檔案權限 (`chmod +x scripts/*.sh`)
   - 查看 Packer 建構日誌中的錯誤訊息

## 最佳實務

- 在推送到生產環境前，先在開發和測試環境驗證
- 定期更新基礎映像檔以包含最新的安全性修補
- 使用版本標籤來追蹤映像檔版本
- 建構前先執行 `packer validate` 驗證配置

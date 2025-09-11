# Packer Openresty Image Builder

這個專案使用 HashiCorp Packer 來建立 openresty 的 AMI 映像檔，支援多環境部署並可動態指定基底映像檔。

## 專案結構

```
.
├── ReadMe.md                    # 專案說明文件
├── build.pkr.hcl               # 主要建構配置檔
├── source.pkr.hcl              # 映像檔來源配置
├── variables.pkr.hcl           # 變數定義檔
├── plugin.pkr.hcl              # Packer 插件配置
├── env/                        # 環境特定配置
│   ├── stg.pkrvars.hcl        # 測試環境變數
│   └── prod.pkrvars.hcl       # 生產環境變數
└── scripts/                    # 佈建腳本（依序執行）
    ├── 00-wait-cloud-init.sh     # 等待 cloud-init 完成
    ├── 01-system-update.sh       # 系統更新
    ├── 02-install-packages.sh    # 安裝基礎套件
    ├── 03-install-docker.sh      # 安裝 Docker 服務
    ├── 04-setup-nginx.sh         # 設定 Nginx 反向代理
    ├── 05-deploy-docker-app.sh   # 部署 Docker 應用程式
    ├── 06-add-test-page.sh       # 新增測試頁面
    ├── 07-setup-firewall.sh      # 配置防火牆規則
    └── 99-cleanup.sh             # 清理作業
```

## 前置需求

- [Packer](https://www.packer.io/downloads) >= 1.12.0
- [AWS CLI](https://aws.amazon.com/cli/) 已配置並具備適當權限
- 有效的 AWS 認證設定（IAM 權限包含 EC2、VPC 相關操作）

## 使用方法

### 1. 初始化 Packer

```bash
packer init .
```

### 2. 驗證配置

```bash
# 驗證開發環境配置
packer validate -var-file="env/dev.pkrvars.hcl" -var "base_ami_id=ami-0b3df0f36f5b89775" .

# 驗證測試環境配置
packer validate -var-file="env/stg.pkrvars.hcl" -var "base_ami_id=ami-0b3df0f36f5b89775" .

# 驗證生產環境配置
packer validate -var-file="env/prod.pkrvars.hcl" -var "base_ami_id=ami-0b3df0f36f5b89775" .

```

### 3. 建立映像檔

#### 指定自定義基底映像檔

```bash
# 驗證開發環境配置
packer build -var-file="env/dev.pkrvars.hcl" -var "base_ami_id=ami-0b3df0f36f5b89775" .

# 驗證測試環境配置
packer build -var-file="env/stg.pkrvars.hcl" -var "base_ami_id=ami-0b3df0f36f5b89775" .

# 驗證生產環境配置
packer build -var-file="env/prod.pkrvars.hcl" -var "base_ami_id=ami-0b3df0f36f5b89775" .

```


## 佈建腳本詳細說明

佈建過程包含以下步驟，按照編號順序自動執行：

1. **00-wait-cloud-init.sh** - 等待 cloud-init 服務完成初始化
2. **01-system-update.sh** - 更新系統套件和安全性修補程式
3. **02-install-packages.sh** - 安裝必要的系統套件（curl, wget, unzip 等）
4. **03-install-docker.sh** - 安裝並啟動 Docker 服務
5. **04-setup-nginx.sh** - 安裝並配置 Nginx 作為反向代理
6. **05-deploy-docker-app.sh** - 部署 Docker 容器化應用程式
7. **06-add-test-page.sh** - 新增健康檢查和測試頁面
8. **07-setup-firewall.sh** - 配置防火牆規則和安全設定
9. **99-cleanup.sh** - 清理暫存檔案、套件快取和敏感資訊

## 變數配置

### 核心變數

專案支援以下主要變數：

- `base_ami_id` - 基底 AMI ID（可透過命令列覆寫）
- `instance_type` - EC2 執行個體類型
- `region` - AWS 區域

### 環境特定配置

**測試環境 (env/stg.pkrvars.hcl)**
```hcl
# 範例配置
instance_type = "t3.small"
region = "ap-southeast-1"
environment = "staging"
```

**生產環境 (env/prod.pkrvars.hcl)**
```hcl
# 範例配置
instance_type = "t3.medium"
region = "ap-southeast-1"
env = "production"
```

## 映像檔使用

建立完成的 AMI 包含：

- 最新的系統更新和安全性修補
- Docker CE 和 Docker Compose
- Nginx 網頁伺服器（已配置反向代理）
- 預先部署的 Docker 應用程式
- 適當的防火牆和安全設定
- 健康檢查端點


## 故障排除

### 常見問題

1. **AWS 認證錯誤**
   ```bash
   # 檢查 AWS CLI 配置
   aws configure list
   aws sts get-caller-identity
   ```

2. **基底 AMI 無法存取**
   - 確認指定的 AMI ID 在目標區域中存在
   - 檢查 AMI 是否為公開或您有存取權限

3. **建構逾時**
   - 檢查網路連線和安全群組設定
   - 確認執行個體可以存取網際網路（用於套件下載）

4. **腳本執行失敗**
   ```bash
   # 檢查腳本權限
   ls -la scripts/
   
   # 手動測試腳本（在測試執行個體上）
   bash -x scripts/03-install-docker.sh
   ```

### 除錯模式

```bash
# 啟用詳細日誌
PACKER_LOG=1 packer build -var-file="env/prod.pkrvars.hcl" -var "base_ami_id=ami-0b3df0f36f5b89775" .

# 建構失敗時保留執行個體（用於除錯）
packer build -on-error=ask -var-file="env/prod.pkrvars.hcl" -var "base_ami_id=ami-0b3df0f36f5b89775" .
```

## 最佳實務

### 安全性

- 定期更新基底 AMI 以包含最新安全修補
- 使用最小權限原則配置 IAM 角色
- 避免在映像檔中包含敏感資訊

### 效能最佳化

- 選擇適當的執行個體類型進行建構
- 使用快取友善的基底映像檔
- 最佳化 Docker 映像檔大小



# Jenkins API 整合文件 - 動態 AMI 建構系統

本文件提供 IT 管理系統與 Jenkins AMI 建構任務的整合規範。

## 🔗 Jenkins Job API 端點

```
POST https://jenkins.example.com/job/ami-builder/buildWithParameters
```

## 🔐 認證方式

支援以下認證方式：

### 1. API Token 認證 (推薦)
```bash
curl -X POST https://jenkins.example.com/job/ami-builder/buildWithParameters \
  -u "username:api_token" \
  --data-urlencode "ENABLED_BLOCKS=[\"base-ubuntu-2004\",\"app-docker\"]"
```

### 2. Basic Auth
```bash
curl -X POST https://jenkins.example.com/job/ami-builder/buildWithParameters \
  -u "username:password" \
  --data-urlencode "ENABLED_BLOCKS=[\"base-ubuntu-2004\",\"app-docker\"]"
```

## 📋 必要參數說明

| 參數名稱 | 類型 | 必填 | 說明 | 範例值 |
|---------|------|------|------|--------|
| `ENABLED_BLOCKS` | JSON Array | ✅ | 要安裝的積木列表，必須包含至少一個 base-* 積木 | `["base-ubuntu-2004","app-docker","config-security"]` |
| `BASE_AMI_ID` | String | ✅ | 基底 AMI ID，需根據區域選擇正確的 AMI | `ami-0836e97b3d843dd82` |
| `REQUESTER` | String | ✅ | 請求者識別，用於追蹤和標記 | `IT-System-001` 或 `user@company.com` |

## 📋 選填參數說明

| 參數名稱 | 類型 | 預設值 | 說明 | 範例值 |
|---------|------|--------|------|--------|
| `ENVIRONMENT` | String | `dev` | 目標環境：dev/stg/prod | `prod` |
| `AWS_REGION` | String | `ap-northeast-1` | AWS 建構區域 | `us-east-1` |
| `INSTANCE_TYPE` | String | `t3.micro` | EC2 實例類型 | `t3.small` |
| `BUILD_NAME` | String | 空值 | 自訂建構名稱，留空自動生成 | `webserver-v2` |
| `OWNER` | String | `infra-team` | 資源擁有者標籤 | `dev-team` |
| `DRY_RUN` | Boolean | `false` | 僅驗證配置，不實際建構 | `true` |
| `LOG_LEVEL` | String | `INFO` | 日誌等級：INFO/DEBUG | `DEBUG` |

## 🧩 積木類型參考

### 基礎系統積木（必選其一）
- `base-ubuntu-2004` - Ubuntu 20.04 LTS
- `base-ubuntu-2204` - Ubuntu 22.04 LTS
- `base-amazon-linux-2` - Amazon Linux 2
- `base-rhel-8` - Red Hat Enterprise Linux 8

### 通用服務積木（可選多個）
- `app-docker` - Docker 容器引擎
- `app-nginx` - Nginx Web 伺服器
- `app-openresty` - OpenResty (Nginx + Lua)
- `app-postgresql` - PostgreSQL 資料庫
- `app-redis` - Redis 快取服務
- `app-nodejs` - Node.js 運行環境

### 配置積木（可選多個）
- `config-security` - 防火牆 + fail2ban + 系統加固
- `config-monitoring` - 監控配置
- `config-logging` - 日誌配置

### 自定義積木（依客戶需求）
- `custom-*` - 客戶專有應用程式

## 📊 API 呼叫範例

### 1. 基本 Web Server 環境
```bash
curl -X POST https://jenkins.example.com/job/ami-builder/buildWithParameters \
  -u "api_user:token" \
  --data-urlencode 'ENABLED_BLOCKS=["base-ubuntu-2004","app-nginx","config-security"]' \
  --data-urlencode 'BASE_AMI_ID=ami-0836e97b3d843dd82' \
  --data-urlencode 'ENVIRONMENT=prod' \
  --data-urlencode 'REQUESTER=IT-System-001' \
  --data-urlencode 'BUILD_NAME=nginx-server'
```

### 2. Docker 開發環境
```bash
curl -X POST https://jenkins.example.com/job/ami-builder/buildWithParameters \
  -u "api_user:token" \
  --data-urlencode 'ENABLED_BLOCKS=["base-ubuntu-2004","app-docker","app-nodejs","config-security"]' \
  --data-urlencode 'BASE_AMI_ID=ami-0836e97b3d843dd82' \
  --data-urlencode 'ENVIRONMENT=dev' \
  --data-urlencode 'REQUESTER=dev-team@company.com'
```

### 3. 客戶專有應用環境
```bash
curl -X POST https://jenkins.example.com/job/ami-builder/buildWithParameters \
  -u "api_user:token" \
  --data-urlencode 'ENABLED_BLOCKS=["base-ubuntu-2004","app-nginx","app-postgresql","custom-clientA-webapp","config-security"]' \
  --data-urlencode 'BASE_AMI_ID=ami-0836e97b3d843dd82' \
  --data-urlencode 'ENVIRONMENT=prod' \
  --data-urlencode 'REQUESTER=ClientA-System' \
  --data-urlencode 'OWNER=clientA-team'
```

## 🔄 API 回應格式

### 成功觸發建構
```json
{
  "queue_id": 12345,
  "queue_url": "https://jenkins.example.com/queue/item/12345/"
}
```

### 取得建構狀態
```bash
# 使用 queue_id 查詢建構編號
curl -s https://jenkins.example.com/queue/item/12345/api/json \
  -u "api_user:token" | jq '.executable.number'

# 使用建構編號查詢狀態
curl -s https://jenkins.example.com/job/ami-builder/456/api/json \
  -u "api_user:token" | jq '{
    building: .building,
    result: .result,
    timestamp: .timestamp,
    duration: .duration
  }'
```

### 取得建構結果
```bash
# 取得建構的 AMI ID
curl -s https://jenkins.example.com/job/ami-builder/456/api/json \
  -u "api_user:token" | jq '.actions[] | select(.parameters) | .parameters[] | select(.name=="AMI_ID") | .value'
```

## ⚠️ 重要注意事項

1. **積木相依性**
   - 必須包含至少一個 `base-*` 積木
   - 某些積木可能有相依性要求（例如特定的基礎系統）

2. **AMI ID 選擇**
   - AMI ID 必須與選擇的區域相符
   - 建議維護一份各區域的基礎 AMI ID 對照表

3. **建構時間**
   - 一般建構時間約 10-20 分鐘
   - 積木越多，建構時間越長

4. **錯誤處理**
   - 建議實作重試機制
   - 監控建構失敗並發送通知

## 📊 回傳的 AMI 資訊

建構成功後，AMI 會包含以下標籤：

| 標籤名稱 | 說明 | 範例值 |
|---------|------|--------|
| `Name` | AMI 名稱 | `prod-webserver-20240912-143022` |
| `Environment` | 環境標記 | `prod` |
| `JenkinsBuild` | Jenkins 建構編號 | `456` |
| `Requester` | 請求者 | `IT-System-001` |
| `BuildDate` | 建構日期 | `2024-09-12` |
| `Base` | 基礎系統 | `ubuntu-2004` |
| `Applications` | 應用程式清單 | `docker_nginx` |
| `Configurations` | 配置清單 | `security` |
| `Custom` | 自定義積木 | `clientA-webapp` |

## 🔧 除錯建議

1. **測試連線**
   ```bash
   curl -u "username:token" https://jenkins.example.com/api/json
   ```

2. **驗證參數**
   - 使用 `DRY_RUN=true` 測試參數是否正確
   - 檢查 Jenkins 控制台輸出

3. **監控建構**
   - 使用 Jenkins API 定期查詢建構狀態
   - 設定建構逾時機制
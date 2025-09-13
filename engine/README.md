# 🚀 Packer 積木建構引擎

這是積木式 AMI 建構系統的核心引擎目錄。

## 📋 積木分層架構

本系統採用分層架構設計，確保積木的模組化、重用性與安全性：

### 第二層積木（通用服務積木）- `blocks/applications/`
包含開源或免費軟體的標準化積木：
- **特點**：
  - ✅ 開源或免費軟體（如 Docker、OpenResty、Node.js、Python）
  - ✅ 通用性高，多個客戶都可能使用
  - ✅ 配置相對標準化
  - ✅ 不包含商業機密或客戶專有邏輯
- **範例**：
  - `docker/` - Docker 容器運行環境
  - `openresty/` - 高性能 Web 服務器
  - `nodejs/` - Node.js 運行環境（預留）
  - `python/` - Python 運行環境（預留）

### 自定義層積木 - `blocks/custom/`
包含客製化或商業授權軟體的積木：
- **特點**：
  - 🔒 需要商業授權的軟體
  - 🔒 包含客戶專有邏輯或業務規則
  - 🔒 高度客製化配置
  - 🔒 可能包含敏感資訊（API 金鑰、憑證等）
- **範例**：
  - `my-app/` - 客戶自定義應用程式範例
  - 客戶專屬的商業軟體積木
  - 包含專有配置的服務積木

### 基礎層積木 - `blocks/base/`
作業系統基礎配置積木：
- `amazon-linux-2/` - Amazon Linux 2 基礎設定
- `ubuntu-2004/` - Ubuntu 20.04 基礎設定
- `ubuntu-2204/` - Ubuntu 22.04 基礎設定（預留）

### 配置層積木 - `blocks/configurations/`
系統配置類積木：
- `security/` - 安全加固配置
- `monitoring/` - 監控系統配置（預留）
- `networking/` - 網路配置（預留）

## 📁 目錄結構

```
engine/
├── builder.pkr.hcl           # 主要的動態建構器
├── simple-builder.pkr.hcl    # 簡化版建構器（用於學習和測試）
├── block-composer.py         # 積木組合器（Python 工具）
├── build-from-template.sh    # 模板建構腳本
└── examples/                 # 範例配置檔案
    ├── minimal.pkrvars.hcl
    ├── web-server.pkrvars.hcl
    └── full-stack.pkrvars.hcl
```

## 🔧 核心檔案說明

### `builder.pkr.hcl`
完整的動態積木建構器，支援所有積木的條件執行。

### `simple-builder.pkr.hcl`
簡化版本，更容易理解積木系統的運作原理。

### `block-composer.py`
Python 工具，用於：
- 查看可用積木
- 驗證積木組合
- 生成建構配置

### `build-from-template.sh`
便捷腳本，使用預定義模板快速建構 AMI。

## 💡 分層架構使用建議

### 選擇正確的層級
1. **新增開源軟體積木**：放在 `blocks/applications/`
   - 例如：Redis、PostgreSQL、Nginx、Jenkins
   
2. **新增客戶專屬積木**：放在 `blocks/custom/`
   - 例如：專有 API 服務、付費軟體、客製化應用

### 積木開發最佳實踐
1. **通用積木**應該：
   - 使用環境變數或參數化配置
   - 避免硬編碼路徑或憑證
   - 提供合理的預設值
   
2. **自定義積木**可以：
   - 包含特定的業務邏輯
   - 使用專屬的配置檔案
   - 整合私有套件庫或映像檔

### 安全性考量
- 🔐 **敏感資訊**：永遠不要將密碼、金鑰等敏感資訊直接寫在積木中
- 🔐 **版本控制**：`blocks/custom/` 目錄可以有獨立的 Git 倉庫或存取控制
- 🔐 **授權合規**：確保商業軟體的授權合規性

## 🚀 快速使用

### 1. 查看可用積木
```bash
python3 block-composer.py
```

### 2. 使用模板建構
```bash
./build-from-template.sh web-server dev
```

### 3. 直接使用 Packer
```bash
packer build -var-file=examples/minimal.pkrvars.hcl simple-builder.pkr.hcl
```

## 📚 完整文檔

詳細的使用指南和架構說明請參考 [`docs/`](../docs/) 目錄：
- [使用指南](../docs/guides/engine-usage.md)
- [架構說明](../docs/architecture/architecture-summary.md)
- [範例程式](../docs/examples/)
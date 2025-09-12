# 🚀 Packer 積木建構引擎

這是積木式 AMI 建構系統的核心引擎目錄。

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
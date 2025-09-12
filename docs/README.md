# 📚 積木式 AMI 建構系統文檔

歡迎來到積木式 AMI 建構系統的文檔中心！

## 📖 文檔結構

```
docs/
├── architecture/          # 系統架構文檔
│   └── architecture-summary.md
├── guides/               # 使用指南
│   └── engine-usage.md
└── examples/             # 範例程式碼
    ├── logic-demo.py
    ├── algorithm-demo.py
    └── dataflow-analysis.py
```

## 🗺️ 文檔導航

### 🏗️ 架構文檔
- [系統架構總結](architecture/architecture-summary.md) - 了解系統的核心設計模式和架構決策

### 📖 使用指南
- [引擎使用指南](guides/engine-usage.md) - 完整的使用說明和操作步驟

### 💻 範例程式
- [程式邏輯示範](examples/logic-demo.py) - 理解積木系統的核心邏輯
- [演算法分析](examples/algorithm-demo.py) - 深入了解依賴解析演算法
- [資料流分析](examples/dataflow-analysis.py) - 追蹤資料在系統中的流動

## 🎯 學習路徑

### 初學者
1. 閱讀[引擎使用指南](guides/engine-usage.md)的快速開始部分
2. 執行 `python3 examples/logic-demo.py` 理解基本概念
3. 嘗試使用預設模板建構 AMI

### 進階使用者
1. 研讀[系統架構總結](architecture/architecture-summary.md)
2. 執行 `python3 examples/algorithm-demo.py` 理解核心演算法
3. 創建自定義積木和模板

### 開發者
1. 研究所有範例程式碼
2. 了解資料流和控制流設計
3. 擴展系統功能

## 🔍 重要概念

### 積木 (Block)
系統的基本單位，每個積木都是一個獨立的功能模組。

### 依賴關係 (Dependencies)
積木之間的 requires/provides 關係，系統會自動驗證。

### 動態配置 (Dynamic Configuration)
根據選擇的積木動態生成 Packer 配置。

### 條件執行 (Conditional Execution)
使用 Packer 的條件邏輯選擇性執行積木。

## 📝 相關資源

- [主專案 README](../README.md)
- [引擎目錄](../engine/)
- [積木庫](../blocks/)
- [模板庫](../templates/)
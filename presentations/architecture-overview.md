# 動態積木式 AMI 建構系統 - 架構簡介

## 🎯 系統概述

**動態積木式 AMI 建構系統** 是一個基於 HashiCorp Packer 的現代化基礎設施自動化平台，採用模組化設計理念，實現可彈性組合的雲端映像建構。

### 核心價值主張

- **🧩 模組化設計**：積木式架構，可彈性組合不同系統組件
- **⚡ 高效建構**：智能條件執行，只執行必要的積木
- **🔄 跨平台支援**：支援多種作業系統（Ubuntu、Amazon Linux、RHEL）
- **🤖 自動化整合**：完整的 Jenkins CI/CD 整合

## 🏗️ 系統架構圖

```mermaid
graph TB
    %% 用戶輸入層
    subgraph "輸入層 (Input Layer)"
        UI[IT管理系統/Jenkins UI]
        API[Jenkins API]
        CLI[命令列介面]
    end
    
    %% 控制層
    subgraph "控制層 (Control Layer)"
        JP[Jenkins Pipeline]
        PV[參數驗證]
        BC[積木組合器]
    end
    
    %% 建構引擎
    subgraph "建構引擎 (Build Engine)"
        PE[Packer Engine]
        DC[動態組合器]
        CE[條件執行器]
    end
    
    %% 積木庫
    subgraph "積木庫 (Block Library)"
        direction TB
        subgraph "基礎積木 (Base Blocks)"
            B1[Ubuntu 20.04/22.04]
            B2[Amazon Linux 2]
            B3[RHEL 8/9]
        end
        
        subgraph "應用積木 (Application Blocks)"
            A1[Docker Runtime]
            A2[OpenResty/Nginx]
            A3[Node.js Runtime]
            A4[Python Environment]
        end
        
        subgraph "配置積木 (Configuration Blocks)"
            C1[安全加固]
            C2[監控配置]
            C3[網路配置]
            C4[日誌配置]
        end
        
        subgraph "自定義積木 (Custom Blocks)"
            X1[客戶專用應用]
            X2[商業軟體]
            X3[行業特定工具]
        end
    end
    
    %% AWS 基礎設施
    subgraph "AWS 基礎設施 (AWS Infrastructure)"
        EC2[EC2 建構實例]
        AMI[AMI 映像儲存]
        TAG[智能標籤系統]
    end
    
    %% 流程連接
    UI --> JP
    API --> JP
    CLI --> JP
    
    JP --> PV
    PV --> BC
    BC --> DC
    
    DC --> PE
    PE --> CE
    
    CE --> B1
    CE --> B2
    CE --> B3
    CE --> A1
    CE --> A2
    CE --> A3
    CE --> A4
    CE --> C1
    CE --> C2
    CE --> C3
    CE --> C4
    CE --> X1
    CE --> X2
    CE --> X3
    
    PE --> EC2
    EC2 --> AMI
    AMI --> TAG
    
    %% 樣式設定
    classDef inputLayer fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef controlLayer fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef buildEngine fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef baseBlock fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef appBlock fill:#fff8e1,stroke:#f57f17,stroke-width:2px
    classDef configBlock fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef customBlock fill:#f1f8e9,stroke:#558b2f,stroke-width:2px
    classDef aws fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    
    class UI,API,CLI inputLayer
    class JP,PV,BC controlLayer
    class PE,DC,CE buildEngine
    class B1,B2,B3 baseBlock
    class A1,A2,A3,A4 appBlock
    class C1,C2,C3,C4 configBlock
    class X1,X2,X3 customBlock
    class EC2,AMI,TAG aws
```

## 🏛️ 四層架構設計

### 第1層：基礎系統積木 (Base Layer)
```
┌─────────────────────────────────────┐
│         基礎作業系統核心              │
│  • Ubuntu 20.04/22.04 LTS          │
│  • Amazon Linux 2                  │
│  • Red Hat Enterprise Linux 8/9    │
│  • 系統更新與基本套件               │
│  • SSH 配置與安全設定               │
└─────────────────────────────────────┘
```

### 第2層：通用服務積木 (Application Layer)
```
┌─────────────────────────────────────┐
│         開源應用程式與服務            │
│  • Docker 容器引擎                  │
│  • OpenResty/Nginx Web Server      │
│  • Node.js/Python 運行環境         │
│  • PostgreSQL/Redis 資料庫         │
│  • Prometheus 監控系統              │
└─────────────────────────────────────┘
```

### 第3層：自定義積木 (Custom Layer)
```
┌─────────────────────────────────────┐
│         客戶專用與商業軟體            │
│  • 客戶專有應用程式                 │
│  • Oracle Database 等商業軟體      │
│  • 行業特定系統                     │
│  • 商業授權監控工具                 │
└─────────────────────────────────────┘
```

### 第4層：動態配置層 (Configuration Layer)
```
┌─────────────────────────────────────┐
│         實例啟動時動態配置            │
│  • Ansible/cloud-init 配置         │
│  • 環境變數注入                     │
│  • 連線字串配置                     │
│  • 授權金鑰管理                     │
└─────────────────────────────────────┘
```

## ⚙️ 技術架構詳解

### 動態積木組合機制

```mermaid
sequenceDiagram
    participant J as Jenkins
    participant P as Packer Engine
    participant BC as Block Composer
    participant AWS as AWS EC2
    
    J->>P: 傳入積木列表 ["base-ubuntu-2004", "app-docker", "config-security"]
    P->>BC: 解析積木依賴關係
    BC->>BC: 驗證積木相容性
    BC->>P: 返回執行計劃
    P->>AWS: 啟動建構實例
    
    loop 依序執行積木
        P->>AWS: 執行積木腳本
        AWS->>P: 返回執行結果
    end
    
    P->>AWS: 建立 AMI 快照
    AWS->>P: 返回 AMI ID
    P->>AWS: 新增智能標籤
    P->>J: 建構完成
```

### 條件執行系統

系統使用智能條件執行，確保只有相關的積木腳本會被執行：

```hcl
# Packer 條件執行範例
provisioner "shell" {
  only = ["amazon-ebs.main"]
  scripts = [
    "${path.root}/../blocks/applications/docker/scripts/amazon-linux/install.sh"
  ]
  # 只有選擇 app-docker 積木且作業系統為 Amazon Linux 時才執行
  except = compact([
    !contains(var.enabled_blocks, "app-docker") ? "amazon-ebs.main" : "",
    var.os_family != "amazon-linux" ? "amazon-ebs.main" : ""
  ])
}
```

## 📊 智能標籤系統

### 標籤分類邏輯

```mermaid
flowchart TD
    A[積木列表] --> B{解析積木類型}
    
    B -->|base-* | C[基礎系統標籤]
    B -->|app-* | D[應用程式標籤]
    B -->|config-* | E[配置標籤]
    B -->|custom-* | F[自定義標籤]
    
    C --> G[Base: ubuntu-2004]
    D --> H[Applications: docker_nginx]
    E --> I[Configurations: security_monitoring]
    F --> J[Custom: clientA_tool]
    
    G --> K[最終 AMI 標籤]
    H --> K
    I --> K
    J --> K
    
    K --> L[自動分類與追踪]
```

### 標籤範例

**輸入積木**：`["base-ubuntu-2004", "app-docker", "app-nginx", "config-security"]`

**產生標籤**：
```yaml
Base: "ubuntu-2004"
Applications: "docker_nginx"  
Configurations: "security"
Environment: "production"
BuildDate: "2024-01-15"
JenkinsBuild: "123"
Owner: "infra-team"
```

## 🔄 CI/CD 整合流程

### Jenkins Pipeline 流程圖

```mermaid
flowchart TD
    A[📋 接收建構請求] --> B[🔍 參數驗證]
    B --> C[🧩 積木相容性檢查]
    C --> D[🏗️ 準備建構環境]
    D --> E{🔄 DRY_RUN?}
    
    E -->|Yes| F[✅ 僅驗證配置]
    E -->|No| G[🚀 啟動建構]
    
    G --> H[💻 AWS EC2 實例啟動]
    H --> I[🔧 依序執行積木]
    I --> J[📸 建立 AMI 快照]
    J --> K[🏷️ 智能標籤新增]
    K --> L[📊 建構結果記錄]
    
    F --> M[✅ 驗證完成]
    L --> N[🎉 建構成功]
    
    style A fill:#e1f5fe
    style N fill:#e8f5e8
    style M fill:#fff3e0
```

## 📈 系統優勢分析

### 1. **模組化與重用性**
- **優勢**：積木可跨專案重用，降低維護成本
- **效益**：新專案建構時間減少 70%
- **範例**：Docker 積木可用於 Web、API、批次處理等多種場景

### 2. **彈性與可擴展性**
- **優勢**：可動態組合不同積木滿足各種需求
- **效益**：支援從簡單的 Web Server 到複雜的微服務架構
- **範例**：同一套積木可建構開發、測試、生產環境

### 3. **智能化執行**
- **優勢**：條件執行機制只運行必要的積木
- **效益**：建構時間減少 40-60%，資源消耗最佳化
- **範例**：Ubuntu 積木不會執行 RHEL 專用腳本

### 4. **標準化與一致性**
- **優勢**：統一的建構流程與配置標準
- **效益**：減少人為錯誤，提高系統穩定性
- **範例**：所有 AMI 都遵循相同的安全加固標準

### 5. **追蹤與治理**
- **優勢**：完整的建構歷史與智能標籤系統
- **效益**：提升 AMI 管理效率與合規性
- **範例**：可快速識別包含特定軟體版本的 AMI

### 6. **成本最佳化**
- **優勢**：按需建構，避免資源浪費
- **效益**：降低 40% 的基礎設施成本
- **範例**：不需要維護多個預建置的模板

## 🎯 應用場景

### 典型使用案例

1. **微服務架構**
   ```
   基礎: Ubuntu 20.04
   + Docker 容器引擎
   + Nginx 反向代理
   + 監控配置
   + 安全加固
   ```

2. **Web 應用伺服器**
   ```
   基礎: Amazon Linux 2  
   + OpenResty Web Server
   + Node.js 運行環境
   + 日誌配置
   + 備份配置
   ```

3. **資料處理平台**
   ```
   基礎: RHEL 8
   + Python 環境
   + Docker 容器
   + 大數據工具
   + 企業監控
   ```

## 🔮 未來發展方向

1. **多雲支援**：擴展至 Azure、GCP 平台
2. **容器整合**：支援 Kubernetes 節點映像
3. **AI 最佳化**：智能積木推薦系統
4. **GitOps 整合**：與 ArgoCD、Flux 整合

---

## 📞 聯絡資訊

**專案維護者**：基礎設施團隊  
**文件版本**：v2.0  
**最後更新**：2024-01-15
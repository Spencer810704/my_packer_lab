#!/usr/bin/env python3
"""
資料流和控制流分析
"""

def trace_data_flow():
    """追蹤資料如何在系統中流動"""
    
    print("🌊 資料流分析")
    print("=" * 50)
    
    # 資料流第一階段: 輸入資料
    print("📥 階段 1: 輸入資料")
    user_input = {
        "selected_blocks": ["base-ubuntu-2004", "app-docker"],
        "build_parameters": {
            "env": "demo",
            "region": "ap-northeast-1",
            "instance_type": "t3.micro"
        }
    }
    print(f"   用戶輸入: {user_input}")
    
    # 資料流第二階段: 載入積木定義
    print(f"\n🔄 階段 2: 載入積木定義")
    block_definitions = {
        "base-ubuntu-2004": {
            "provides": ["linux-os", "ubuntu"],
            "requires": [],
            "execution_order": 1,
            "scripts": ["wait-cloud-init.sh", "system-update.sh"]
        },
        "app-docker": {
            "provides": ["container-runtime"],
            "requires": ["linux-os"],
            "execution_order": 50,
            "scripts": ["install-docker.sh", "configure-docker.sh"]
        }
    }
    print("   積木定義載入完成")
    
    # 資料流第三階段: 依賴解析
    print(f"\n🧮 階段 3: 依賴解析")
    provided_features = set()
    for block_id in user_input["selected_blocks"]:
        provided_features.update(block_definitions[block_id]["provides"])
    
    print(f"   所有提供功能: {list(provided_features)}")
    
    dependency_satisfied = True
    for block_id in user_input["selected_blocks"]:
        required = set(block_definitions[block_id]["requires"])
        missing = required - provided_features
        if missing:
            dependency_satisfied = False
            print(f"   ❌ {block_id} 缺少: {list(missing)}")
        else:
            print(f"   ✅ {block_id} 依賴滿足")
    
    # 資料流第四階段: 生成配置
    if dependency_satisfied:
        print(f"\n⚙️ 階段 4: 生成配置")
        
        # 排序積木
        sorted_blocks = sorted(
            user_input["selected_blocks"],
            key=lambda x: block_definitions[x]["execution_order"]
        )
        
        packer_config = {
            "variables": {
                "enabled_blocks": sorted_blocks,
                **user_input["build_parameters"]
            },
            "execution_plan": []
        }
        
        # 生成執行計劃
        for block_id in sorted_blocks:
            for script in block_definitions[block_id]["scripts"]:
                step = {
                    "block": block_id,
                    "script": script,
                    "condition": f"contains(enabled_blocks, '{block_id}')"
                }
                packer_config["execution_plan"].append(step)
        
        print(f"   生成的配置:")
        print(f"   Variables: {packer_config['variables']}")
        print(f"   執行步驟數: {len(packer_config['execution_plan'])}")
        
        # 資料流第五階段: Packer 執行
        print(f"\n🚀 階段 5: Packer 執行")
        for step in packer_config["execution_plan"]:
            print(f"   執行: {step['block']}.{step['script']}")
            print(f"   條件: {step['condition']}")

def trace_control_flow():
    """追蹤控制流程如何運作"""
    
    print(f"\n🎛️ 控制流分析")  
    print("=" * 50)
    
    print("控制流決策點:")
    
    # 決策點 1: 積木存在性檢查
    print("\n🔍 決策點 1: 積木存在性檢查")
    selected_blocks = ["base-ubuntu-2004", "app-docker", "invalid-block"]
    available_blocks = ["base-ubuntu-2004", "app-docker", "app-openresty"]
    
    for block_id in selected_blocks:
        if block_id in available_blocks:
            print(f"   ✅ {block_id} → 繼續處理")
            action = "CONTINUE"
        else:
            print(f"   ❌ {block_id} → 返回錯誤")
            action = "ERROR_RETURN"
            break
    
    if action == "ERROR_RETURN":
        print("   🚨 控制流: 立即返回錯誤，終止處理")
        return
    
    # 決策點 2: 依賴滿足檢查
    print(f"\n🔗 決策點 2: 依賴滿足檢查")
    dependencies = {
        "base-ubuntu-2004": [],
        "app-docker": ["linux-os"]
    }
    provided = ["linux-os", "ubuntu", "container-runtime"]
    
    all_satisfied = True
    for block_id, required_deps in dependencies.items():
        if all(dep in provided for dep in required_deps):
            print(f"   ✅ {block_id} 依賴滿足 → 繼續")
        else:
            print(f"   ❌ {block_id} 依賴不滿足 → 錯誤")
            all_satisfied = False
    
    if not all_satisfied:
        print("   🚨 控制流: 依賴檢查失敗，返回錯誤")
        return
    
    # 決策點 3: 執行階段的條件判斷
    print(f"\n🎯 決策點 3: 執行階段條件判斷")
    enabled_blocks = ["base-ubuntu-2004", "app-docker"]
    all_possible_blocks = ["base-ubuntu-2004", "app-docker", "app-openresty", "config-security"]
    
    for block_id in all_possible_blocks:
        if block_id in enabled_blocks:
            print(f"   ✅ {block_id} → 執行相關 provisioner")
            decision = "EXECUTE"
        else:
            print(f"   ⏭️ {block_id} → 跳過 provisioner")  
            decision = "SKIP"
        
        # 這個邏輯在 Packer 中轉譯為:
        hcl_logic = f"only = contains(var.enabled_blocks, '{block_id}') ? ['amazon-ebs.demo'] : []"
        print(f"      HCL: {hcl_logic}")

def demonstrate_error_handling():
    """示範錯誤處理邏輯"""
    
    print(f"\n🚨 錯誤處理機制")
    print("=" * 50)
    
    error_scenarios = [
        {
            "name": "積木不存在",
            "input": ["non-existent-block"],
            "expected": "VALIDATION_ERROR"
        },
        {
            "name": "依賴不滿足", 
            "input": ["app-docker"],  # 缺少 linux-os 提供者
            "expected": "DEPENDENCY_ERROR"
        },
        {
            "name": "正常流程",
            "input": ["base-ubuntu-2004", "app-docker"],
            "expected": "SUCCESS"
        }
    ]
    
    for scenario in error_scenarios:
        print(f"\n📋 情境: {scenario['name']}")
        print(f"   輸入: {scenario['input']}")
        print(f"   預期結果: {scenario['expected']}")
        
        if scenario['expected'] == "VALIDATION_ERROR":
            print("   🔄 處理流程: 立即返回錯誤，不執行後續邏輯")
        elif scenario['expected'] == "DEPENDENCY_ERROR": 
            print("   🔄 處理流程: 完成驗證後返回錯誤列表")
        else:
            print("   🔄 處理流程: 繼續執行建構流程")

if __name__ == "__main__":
    trace_data_flow()
    trace_control_flow()
    demonstrate_error_handling()
#!/usr/bin/env python3
"""
關鍵演算法解析
"""

def dependency_resolution_algorithm(selected_blocks, available_blocks):
    """
    依賴解析演算法 - 這是整個系統的核心邏輯
    
    時間複雜度: O(n²) 其中 n 是選中積木數量
    空間複雜度: O(n) 用於存儲功能集合
    """
    
    print("🧮 依賴解析演算法步驟分解:")
    print("-" * 40)
    
    # Step 1: 建立積木映射表 - O(1) 查詢時間
    block_map = {block.id: block for block in available_blocks}
    print("1️⃣ 建立積木映射表 (HashMap)")
    
    # Step 2: 收集所有提供的功能 - O(n*m) 其中 m 是平均提供功能數
    provided_features = set()
    selected_block_objects = []
    
    print("\n2️⃣ 功能收集階段:")
    for block_id in selected_blocks:
        block = block_map[block_id]
        selected_block_objects.append(block)
        provided_features.update(block.provides)
        print(f"   {block_id} → provides: {list(block.provides)}")
    
    print(f"   📦 總功能集合: {list(provided_features)}")
    
    # Step 3: 依賴檢查 - O(n*k) 其中 k 是平均依賴數
    print("\n3️⃣ 依賴檢查階段:")
    dependency_errors = []
    
    for block in selected_block_objects:
        missing_deps = block.requires - provided_features
        if missing_deps:
            error = f"{block.id} 缺少依賴: {list(missing_deps)}"
            dependency_errors.append(error)
            print(f"   ❌ {error}")
        else:
            print(f"   ✅ {block.id} 依賴滿足: {list(block.requires)}")
    
    # Step 4: 拓撲排序 - O(n log n)
    print("\n4️⃣ 拓撲排序階段:")
    if not dependency_errors:
        # 使用執行順序進行排序（簡化版拓撲排序）
        sorted_blocks = sorted(selected_block_objects, key=lambda x: x.execution_order)
        execution_order = [block.id for block in sorted_blocks]
        
        print("   排序結果:")
        for i, block in enumerate(sorted_blocks):
            print(f"   {i+1}. {block.id} (priority: {block.execution_order})")
        
        return {
            'success': True,
            'execution_order': execution_order,
            'errors': []
        }
    else:
        return {
            'success': False,
            'execution_order': [],
            'errors': dependency_errors
        }

def conditional_execution_logic(enabled_blocks, target_block):
    """
    條件執行邏輯 - Packer 中的動態執行判斷
    """
    print(f"\n🎯 條件執行邏輯:")
    print(f"   enabled_blocks = {enabled_blocks}")
    print(f"   target_block = '{target_block}'")
    
    # 這個邏輯在 Packer HCL 中表示為:
    # only = contains(var.enabled_blocks, "target_block") ? ["amazon-ebs.demo"] : []
    
    should_execute = target_block in enabled_blocks
    
    print(f"   contains(enabled_blocks, '{target_block}') = {should_execute}")
    
    if should_execute:
        result = ["amazon-ebs.demo"]  # 執行目標
        print(f"   ✅ 執行: {result}")
    else:
        result = []  # 跳過執行
        print(f"   ❌ 跳過: {result}")
    
    return result

def configuration_generation_algorithm(blocks, build_params):
    """
    配置生成演算法 - 將積木組合轉換為 Packer 可執行配置
    """
    print(f"\n⚙️ 配置生成演算法:")
    print("-" * 30)
    
    # 生成基礎變數
    base_vars = {
        'env': build_params['env'],
        'region': build_params['region'], 
        'instance_type': build_params['instance_type'],
        'enabled_blocks': blocks
    }
    
    print("1️⃣ 基礎變數生成:")
    for key, value in base_vars.items():
        print(f"   {key}: {value}")
    
    # 生成條件執行邏輯
    print(f"\n2️⃣ 條件執行邏輯生成:")
    execution_conditions = {}
    for block_id in blocks:
        condition = f"contains(var.enabled_blocks, \"{block_id}\")"
        execution_conditions[block_id] = condition
        print(f"   {block_id}: {condition}")
    
    # 生成 HCL 片段（示意）
    print(f"\n3️⃣ 生成的 HCL 邏輯:")
    for block_id in blocks:
        hcl_snippet = f"""
provisioner "shell" {{
  script = "../blocks/.../install-{block_id}.sh"
  only   = {execution_conditions[block_id]} ? ["amazon-ebs.demo"] : []
}}"""
        print(f"   積木 {block_id}:")
        print(f"   {hcl_snippet.strip()}")
    
    return {
        'variables': base_vars,
        'conditions': execution_conditions
    }

# 演示這些演算法
if __name__ == "__main__":
    # 模擬資料
    class MockBlock:
        def __init__(self, id, provides, requires, order):
            self.id = id
            self.provides = set(provides)
            self.requires = set(requires)
            self.execution_order = order
    
    available_blocks = [
        MockBlock('base-ubuntu-2004', ['linux-os', 'ubuntu'], [], 1),
        MockBlock('app-docker', ['container-runtime'], ['linux-os'], 50),
        MockBlock('app-openresty', ['web-server'], ['linux-os'], 60)
    ]
    
    selected_blocks = ['base-ubuntu-2004', 'app-docker']
    
    # 執行依賴解析演算法
    result = dependency_resolution_algorithm(selected_blocks, available_blocks)
    
    if result['success']:
        # 演示條件執行邏輯
        print("\n" + "="*50)
        conditional_execution_logic(result['execution_order'], 'app-docker')
        conditional_execution_logic(result['execution_order'], 'app-openresty')
        
        # 演示配置生成演算法
        print("\n" + "="*50)
        build_params = {
            'env': 'demo',
            'region': 'ap-northeast-1',
            'instance_type': 't3.micro'
        }
        
        config = configuration_generation_algorithm(result['execution_order'], build_params)
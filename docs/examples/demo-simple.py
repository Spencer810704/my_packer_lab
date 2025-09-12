#!/usr/bin/env python3
"""
簡單的積木組合示範
"""

import sys
sys.path.append('/Users/spencer/Workspace/MySidePorject/packer/engine')

from block_composer import BlockComposer

def demo_simple_composition():
    print("🎯 簡單積木組合示範")
    print("="*50)
    
    # 初始化積木組合器
    composer = BlockComposer("../blocks")
    
    # 模擬用戶選擇：我想要 Ubuntu + Docker
    print("\n👤 用戶選擇：我想要建構一個有 Docker 的 Ubuntu AMI")
    selected_blocks = ["base-ubuntu-2004", "app-docker"]
    print(f"📝 選擇的積木: {selected_blocks}")
    
    # 系統進行依賴檢查
    print("\n🔍 系統檢查依賴關係...")
    validation = composer.validate_dependencies(selected_blocks)
    
    if validation['valid']:
        print("✅ 依賴檢查通過！")
        print(f"📋 執行順序: {validation['execution_order']}")
        
        # 解釋為什麼這個組合有效
        print("\n💡 為什麼這個組合有效？")
        print("   • Ubuntu 積木 provides: linux-os")
        print("   • Docker 積木 requires: linux-os")
        print("   • ✓ 依賴滿足！")
        
    else:
        print("❌ 依賴檢查失敗！")
        for error in validation['errors']:
            print(f"   ❌ {error}")
        return
    
    # 生成建構配置
    print("\n🏗️ 生成建構配置...")
    config = composer.generate_build_config(
        build_name="ubuntu-docker-demo",
        environment="dev", 
        selected_blocks=selected_blocks,
        parameters={
            "region": "ap-northeast-1",
            "instance_type": "t3.micro",
            "base_ami_id": "ami-0ebb6b6a1a6358fde"
        }
    )
    
    print("✅ 配置生成成功！")
    print(f"📦 將會執行的積木: {config['blocks']['enabled']}")
    
    # 顯示實際會執行的腳本
    print(f"\n🔧 實際執行流程:")
    print("   1. Ubuntu 基礎積木:")
    print("      • wait-cloud-init.sh")
    print("      • system-update.sh") 
    print("      • install-packages.sh")
    print("   2. Docker 應用積木:")
    print("      • install-docker.sh")
    print("      • configure-docker.sh")
    print("      • validate-docker.sh")
    print("   3. Ubuntu 清理積木:")
    print("      • cleanup.sh")
    
    print(f"\n🚀 Packer 執行命令:")
    packer_cmd = composer.generate_packer_command(config)
    print(f"   {packer_cmd}")

if __name__ == "__main__":
    demo_simple_composition()
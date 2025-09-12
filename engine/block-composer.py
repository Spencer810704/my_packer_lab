#!/usr/bin/env python3
"""
積木組合器 - 根據用戶選擇的積木生成 Packer 建構配置
"""

import json
import yaml
import os
import sys
from pathlib import Path
from typing import Dict, List, Any

class BlockComposer:
    def __init__(self, blocks_path: str = "../blocks"):
        self.blocks_path = Path(blocks_path)
        self.blocks_registry = {}
        self._load_blocks()
    
    def _load_blocks(self):
        """載入所有積木的 metadata"""
        for category_dir in self.blocks_path.iterdir():
            if not category_dir.is_dir():
                continue
                
            category = category_dir.name
            for block_dir in category_dir.iterdir():
                if not block_dir.is_dir():
                    continue
                    
                block_yaml = block_dir / "block.yaml"
                if block_yaml.exists():
                    with open(block_yaml, 'r', encoding='utf-8') as f:
                        block_config = yaml.safe_load(f)
                        block_id = block_config['block']['id']
                        block_config['block']['path'] = str(block_dir)
                        self.blocks_registry[block_id] = block_config['block']
    
    def get_available_blocks(self) -> Dict[str, List[Dict]]:
        """取得所有可用的積木，按類別分組"""
        blocks_by_category = {
            'base': [],
            'application': [],
            'configuration': [],
            'custom': []
        }
        
        for block_id, block_info in self.blocks_registry.items():
            category = block_info.get('category', 'custom')
            if category not in blocks_by_category:
                blocks_by_category[category] = []
            blocks_by_category[category].append({
                'id': block_id,
                'name': block_info.get('name', block_id),
                'description': block_info.get('description', ''),
                'version': block_info.get('version', ''),
                'provides': block_info.get('provides', []),
                'requires': block_info.get('requires', []),
                'parameters': block_info.get('parameters', [])
            })
        
        return blocks_by_category
    
    def validate_dependencies(self, selected_blocks: List[str]) -> Dict[str, Any]:
        """驗證積木依賴關係"""
        result = {
            'valid': True,
            'errors': [],
            'warnings': [],
            'execution_order': []
        }
        
        # 檢查每個積木的依賴
        provided_features = set()
        selected_block_info = []
        
        for block_id in selected_blocks:
            if block_id not in self.blocks_registry:
                result['errors'].append(f"積木 '{block_id}' 不存在")
                continue
                
            block_info = self.blocks_registry[block_id]
            selected_block_info.append((block_id, block_info))
            provided_features.update(block_info.get('provides', []))
        
        # 檢查依賴是否滿足
        for block_id, block_info in selected_block_info:
            required_features = set(block_info.get('requires', []))
            missing_features = required_features - provided_features
            
            if missing_features:
                result['errors'].append(
                    f"積木 '{block_id}' 需要以下功能但未提供: {', '.join(missing_features)}"
                )
        
        # 如果有錯誤，標記為無效
        if result['errors']:
            result['valid'] = False
        else:
            # 按執行順序排序
            selected_block_info.sort(key=lambda x: x[1].get('execution_order', 50))
            result['execution_order'] = [block_id for block_id, _ in selected_block_info]
        
        return result
    
    def generate_build_config(self, 
                            build_name: str,
                            environment: str,
                            selected_blocks: List[str],
                            custom_scripts: List[Dict] = None,
                            parameters: Dict = None) -> Dict[str, Any]:
        """生成建構配置"""
        
        # 驗證依賴
        validation_result = self.validate_dependencies(selected_blocks)
        if not validation_result['valid']:
            raise ValueError(f"依賴驗證失敗: {validation_result['errors']}")
        
        # 生成配置
        build_config = {
            "build_info": {
                "name": build_name,
                "environment": environment,
                "created_at": "{{timestamp}}",
                "build_type": "dynamic"
            },
            "blocks": {
                "enabled": validation_result['execution_order'],
                "execution_order": validation_result['execution_order']
            },
            "parameters": parameters or {},
            "custom_scripts": custom_scripts or [],
            "packer_vars": self._generate_packer_vars(
                environment, selected_blocks, parameters or {}
            )
        }
        
        return build_config
    
    def _generate_packer_vars(self, environment: str, selected_blocks: List[str], 
                             parameters: Dict) -> Dict[str, Any]:
        """生成 Packer 變數"""
        return {
            "env": environment,
            "enabled_blocks": selected_blocks,
            "custom_scripts": parameters.get("custom_scripts", []),
            "region": parameters.get("region", "ap-northeast-1"),
            "instance_type": parameters.get("instance_type", "t3.micro"),
            "base_ami_id": parameters.get("base_ami_id", ""),
            "owner": parameters.get("owner", "infra-team")
        }
    
    def generate_packer_command(self, build_config: Dict[str, Any]) -> str:
        """生成 Packer 執行命令"""
        packer_vars = build_config['packer_vars']
        
        cmd_parts = ["packer", "build"]
        
        # 添加變數
        for key, value in packer_vars.items():
            if isinstance(value, list):
                value_str = f"[{','.join(map(str, value))}]"
            else:
                value_str = str(value)
            cmd_parts.append(f'-var="{key}={value_str}"')
        
        cmd_parts.append("builder.pkr.hcl")
        
        return " ".join(cmd_parts)

def main():
    composer = BlockComposer()
    
    if len(sys.argv) < 2:
        # 顯示可用積木
        print("🧩 可用的積木:")
        blocks = composer.get_available_blocks()
        for category, block_list in blocks.items():
            print(f"\n📁 {category.upper()}:")
            for block in block_list:
                print(f"  • {block['id']} - {block['name']}")
                if block['description']:
                    print(f"    {block['description']}")
        return
    
    # 簡單的命令行介面
    command = sys.argv[1]
    
    if command == "compose":
        # 示例組合
        selected_blocks = ["base-ubuntu-2004", "app-docker", "app-openresty", "config-security"]
        custom_scripts = [
            {
                "name": "custom-setup",
                "content": "echo 'Custom setup completed'",
                "order": 90
            }
        ]
        parameters = {
            "region": "ap-northeast-1",
            "instance_type": "t3.small",
            "owner": "dev-team"
        }
        
        try:
            config = composer.generate_build_config(
                build_name="web-server-demo",
                environment="dev",
                selected_blocks=selected_blocks,
                custom_scripts=custom_scripts,
                parameters=parameters
            )
            
            print("✅ 建構配置生成成功:")
            print(json.dumps(config, indent=2, ensure_ascii=False))
            
            print(f"\n🚀 Packer 執行命令:")
            print(composer.generate_packer_command(config))
            
        except ValueError as e:
            print(f"❌ 配置生成失敗: {e}")

if __name__ == "__main__":
    main()
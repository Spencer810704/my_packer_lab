#!/usr/bin/env python3
"""
積木系統程式邏輯示範
"""

class Block:
    """積木資料結構"""
    def __init__(self, block_config):
        self.id = block_config['id']
        self.name = block_config.get('name', self.id)
        self.category = block_config.get('category', 'custom')
        self.provides = set(block_config.get('provides', []))
        self.requires = set(block_config.get('requires', []))
        self.execution_order = block_config.get('execution_order', 50)
        self.scripts = block_config.get('scripts', {})
        
    def __repr__(self):
        return f"Block({self.id}, order={self.execution_order})"

class BuildConfiguration:
    """建構配置資料結構"""
    def __init__(self):
        self.selected_blocks = []
        self.resolved_blocks = []
        self.execution_plan = []
        self.packer_variables = {}
        self.validation_result = None

class DependencyResolver:
    """依賴解析器"""
    
    def __init__(self, available_blocks):
        self.available_blocks = {block.id: block for block in available_blocks}
        
    def resolve_dependencies(self, selected_block_ids):
        """解析依賴關係的核心邏輯"""
        print("🔍 開始依賴解析...")
        
        result = {
            'valid': True,
            'errors': [],
            'warnings': [],
            'execution_order': []
        }
        
        # 第一步：檢查所選積木是否存在
        print("\n1️⃣ 檢查積木存在性:")
        selected_blocks = []
        for block_id in selected_block_ids:
            if block_id not in self.available_blocks:
                error = f"積木 '{block_id}' 不存在"
                result['errors'].append(error)
                print(f"   ❌ {error}")
                continue
            
            block = self.available_blocks[block_id]
            selected_blocks.append(block)
            print(f"   ✅ {block.id} - {block.name}")
        
        if result['errors']:
            result['valid'] = False
            return result
        
        # 第二步：計算所有選中積木提供的功能
        print("\n2️⃣ 計算提供的功能:")
        provided_features = set()
        for block in selected_blocks:
            provided_features.update(block.provides)
            if block.provides:
                print(f"   📦 {block.id} provides: {list(block.provides)}")
        
        print(f"   🎯 總共提供功能: {list(provided_features)}")
        
        # 第三步：檢查依賴是否滿足
        print("\n3️⃣ 檢查依賴關係:")
        for block in selected_blocks:
            missing_deps = block.requires - provided_features
            if missing_deps:
                error = f"積木 '{block.id}' 需要 {list(missing_deps)} 但未提供"
                result['errors'].append(error)
                print(f"   ❌ {error}")
            else:
                if block.requires:
                    print(f"   ✅ {block.id} requires {list(block.requires)} - 滿足")
                else:
                    print(f"   ✅ {block.id} 無依賴需求")
        
        # 第四步：按執行順序排序
        if not result['errors']:
            print("\n4️⃣ 計算執行順序:")
            selected_blocks.sort(key=lambda x: x.execution_order)
            result['execution_order'] = [block.id for block in selected_blocks]
            
            for i, block in enumerate(selected_blocks):
                print(f"   {i+1}. {block.id} (order: {block.execution_order})")
        else:
            result['valid'] = False
        
        return result

class PackerConfigGenerator:
    """Packer 配置生成器"""
    
    def __init__(self, dependency_resolver):
        self.resolver = dependency_resolver
        
    def generate_packer_vars(self, resolved_blocks, build_params):
        """生成 Packer 變數的邏輯"""
        print("\n🔧 生成 Packer 變數:")
        
        packer_vars = {
            'env': build_params.get('env', 'dev'),
            'region': build_params.get('region', 'ap-northeast-1'),
            'instance_type': build_params.get('instance_type', 't3.micro'),
            'base_ami_id': build_params.get('base_ami_id', ''),
            'enabled_blocks': resolved_blocks
        }
        
        for key, value in packer_vars.items():
            print(f"   • {key}: {value}")
        
        return packer_vars
    
    def generate_execution_plan(self, resolved_blocks):
        """生成執行計劃邏輯"""
        print("\n📋 生成執行計劃:")
        
        execution_plan = []
        
        for block_id in resolved_blocks:
            block = self.resolver.available_blocks[block_id]
            
            # 根據積木的腳本定義生成執行步驟
            for script_type, script_name in block.scripts.items():
                step = {
                    'block_id': block_id,
                    'script_type': script_type,
                    'script_path': f"../blocks/{block.category}/{block_id.replace(f'{block.category[0:3]}-', '')}/{script_name}",
                    'condition': f"contains(var.enabled_blocks, \"{block_id}\")"
                }
                execution_plan.append(step)
                print(f"   📄 {block_id}.{script_type}: {script_name}")
        
        return execution_plan

def demo_program_logic():
    """示範程式邏輯運作"""
    print("🎯 積木系統程式邏輯示範")
    print("=" * 50)
    
    # 模擬載入積木定義
    print("\n🔄 載入積木定義...")
    blocks_data = [
        {
            'id': 'base-ubuntu-2004',
            'name': 'Ubuntu 20.04 Base',
            'category': 'base',
            'provides': ['linux-os', 'ubuntu', 'systemd'],
            'requires': [],
            'execution_order': 1,
            'scripts': {'wait': 'wait-cloud-init.sh', 'update': 'system-update.sh', 'packages': 'install-packages.sh'}
        },
        {
            'id': 'app-docker',
            'name': 'Docker Runtime', 
            'category': 'application',
            'provides': ['container-runtime', 'docker'],
            'requires': ['linux-os'],
            'execution_order': 50,
            'scripts': {'install': 'install-docker.sh', 'configure': 'configure-docker.sh'}
        },
        {
            'id': 'app-openresty',
            'name': 'OpenResty Web Server',
            'category': 'application', 
            'provides': ['web-server', 'nginx'],
            'requires': ['linux-os'],
            'execution_order': 60,
            'scripts': {'install': 'install-openresty.sh', 'configure': 'setup-nginx.sh'}
        }
    ]
    
    # 建立積木物件
    available_blocks = [Block(block_data) for block_data in blocks_data]
    print(f"✅ 載入了 {len(available_blocks)} 個積木")
    
    # 初始化系統組件
    resolver = DependencyResolver(available_blocks)
    generator = PackerConfigGenerator(resolver)
    
    # 模擬用戶選擇
    print(f"\n👤 用戶選擇積木: ['base-ubuntu-2004', 'app-docker']")
    selected_blocks = ['base-ubuntu-2004', 'app-docker']
    
    # 執行依賴解析
    validation_result = resolver.resolve_dependencies(selected_blocks)
    
    if validation_result['valid']:
        print(f"\n✅ 依賴解析成功!")
        
        # 生成 Packer 配置
        build_params = {
            'env': 'demo',
            'region': 'ap-northeast-1',
            'instance_type': 't3.micro',
            'base_ami_id': 'ami-12345'
        }
        
        packer_vars = generator.generate_packer_vars(
            validation_result['execution_order'], 
            build_params
        )
        
        execution_plan = generator.generate_execution_plan(
            validation_result['execution_order']
        )
        
        print(f"\n🚀 最終 Packer 命令:")
        cmd = f"packer build -var='enabled_blocks={validation_result['execution_order']}' -var='env=demo' simple-builder.pkr.hcl"
        print(f"   {cmd}")
        
    else:
        print(f"\n❌ 依賴解析失敗:")
        for error in validation_result['errors']:
            print(f"   • {error}")

if __name__ == "__main__":
    demo_program_logic()
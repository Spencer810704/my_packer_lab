pipeline {
    agent any
    
    options {
        ansiColor('xterm')
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
    }
    
    parameters {
        // 🧩 積木選擇參數
        string(
            name: 'ENABLED_BLOCKS',
            defaultValue: '["base-ubuntu-2004"]',
            description: 'JSON 格式的積木列表，例: ["base-ubuntu-2004","app-docker","config-security"]'
        )
        
        // 🌍 環境參數
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stg', 'prod'],
            description: '目標環境'
        )
        
        choice(
            name: 'AWS_REGION',
            choices: ['ap-northeast-1', 'ap-southeast-1', 'us-east-1', 'us-west-2'],
            description: 'AWS 建構區域'
        )
        
        // 🖥️ 資源參數
        choice(
            name: 'INSTANCE_TYPE',
            choices: ['t3.micro', 't3.small', 't3.medium', 't3.large'],
            description: 'EC2 實例類型'
        )
        
        string(
            name: 'BASE_AMI_ID',
            defaultValue: '',
            description: '基底 AMI ID (留空使用系統預設)'
        )
        
        // 📋 元資料參數
        string(
            name: 'BUILD_NAME',
            defaultValue: '',
            description: 'AMI 建構名稱 (留空自動生成)'
        )
        
        string(
            name: 'OWNER',
            defaultValue: 'infra-team',
            description: 'AMI 擁有者標籤'
        )
        
        string(
            name: 'REQUESTER',
            defaultValue: '',
            description: '建構請求者 (通常由 IT 系統傳入)'
        )
        
        // ⚙️ 控制參數
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: false,
            description: '僅驗證配置，不實際建構 AMI'
        )
        
        choice(
            name: 'LOG_LEVEL',
            choices: ['INFO', 'DEBUG'],
            description: 'Packer 日誌等級'
        )
    }
    
    environment {
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"
        PACKER_LOG = "${params.LOG_LEVEL == 'DEBUG' ? '1' : '0'}"
    }
    
    stages {
        stage('📋 驗證參數') {
            steps {
                script {
                    echo "🔍 驗證建構參數"
                    
                    // 基本參數檢查
                    def buildInfo = [
                        enabled_blocks: params.ENABLED_BLOCKS,
                        environment: params.ENVIRONMENT,
                        aws_region: params.AWS_REGION,
                        instance_type: params.INSTANCE_TYPE,
                        requester: params.REQUESTER ?: 'manual',
                        dry_run: params.DRY_RUN
                    ]
                    
                    buildInfo.each { key, value ->
                        echo "  ${key}: ${value}"
                    }
                    
                    // 驗證 ENABLED_BLOCKS JSON 格式
                    try {
                        def blocks = readJSON text: params.ENABLED_BLOCKS
                        if (!(blocks instanceof List)) {
                            error("ENABLED_BLOCKS 必須是 JSON 陣列格式")
                        }
                        echo "✅ 積木列表驗證通過: ${blocks.size()} 個積木"
                    } catch (Exception e) {
                        error("❌ ENABLED_BLOCKS JSON 格式錯誤: ${e.message}")
                    }
                    
                    // 檢查必要積木
                    def blocks = readJSON text: params.ENABLED_BLOCKS
                    def hasBase = blocks.any { it.startsWith('base-') }
                    if (!hasBase) {
                        error("❌ 必須包含至少一個基礎系統積木 (base-*)")
                    }
                }
            }
        }
        
        stage('🔧 準備建構環境') {
            steps {
                script {
                    echo "📁 切換到 engine 目錄"
                    dir('engine') {
                        // 驗證 AWS 存取權限
                        sh 'aws sts get-caller-identity'
                        
                        // 初始化 Packer
                        sh 'packer init builder.pkr.hcl'
                        
                        echo "✅ 建構環境準備完成"
                    }
                }
            }
        }
        
        stage('✅ Packer 驗證') {
            steps {
                script {
                    echo "🔍 驗證 Packer 配置"
                    dir('engine') {
                        def validateCmd = buildPackerCommand('validate')
                        sh validateCmd
                        echo "✅ Packer 配置驗證通過"
                    }
                }
            }
        }
        
        stage('🚀 建構 AMI') {
            when {
                expression { !params.DRY_RUN }
            }
            steps {
                script {
                    echo "🏗️ 開始建構 AMI"
                    dir('engine') {
                        def buildCmd = buildPackerCommand('build')
                        sh buildCmd
                    }
                }
            }
        }
        
        stage('📊 處理建構結果') {
            when {
                expression { !params.DRY_RUN }
            }
            steps {
                script {
                    echo "📋 提取建構結果"
                    dir('engine') {
                        if (fileExists('packer-manifest.json')) {
                            def manifest = readJSON file: 'packer-manifest.json'
                            if (manifest.builds?.size() > 0) {
                                def build = manifest.builds[0]
                                def amiId = build.artifact_id?.split(':')?.get(1)
                                if (amiId) {
                                    env.AMI_ID = amiId
                                    echo "🎉 AMI 建構完成: ${amiId}"
                                    
                                    // 添加額外標籤
                                    sh """
                                        aws ec2 create-tags \\
                                            --region ${params.AWS_REGION} \\
                                            --resources ${amiId} \\
                                            --tags \\
                                                Key=JenkinsBuild,Value=${BUILD_NUMBER} \\
                                                Key=Requester,Value=${params.REQUESTER} \\
                                                Key=EnabledBlocks,Value='${params.ENABLED_BLOCKS}' \\
                                                Key=BuildDate,Value=${new Date().format('yyyy-MM-dd')}
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "🧹 清理工作空間"
                cleanWs()
            }
        }
        
        success {
            script {
                def message = "✅ AMI 建構成功完成！\\n"
                message += "🏷️ 建構參數:\\n"
                message += "  • 積木組合: ${params.ENABLED_BLOCKS}\\n"
                message += "  • 環境: ${params.ENVIRONMENT}\\n"
                message += "  • 區域: ${params.AWS_REGION}\\n"
                message += "  • 請求者: ${params.REQUESTER ?: 'Manual'}\\n"
                
                if (env.AMI_ID) {
                    message += "  • AMI ID: ${env.AMI_ID}\\n"
                }
                
                echo message
            }
        }
        
        failure {
            script {
                def message = "❌ AMI 建構失敗\\n"
                message += "🔍 建構參數:\\n"
                message += "  • 積木組合: ${params.ENABLED_BLOCKS}\\n"
                message += "  • 環境: ${params.ENVIRONMENT}\\n"
                message += "  • 請求者: ${params.REQUESTER ?: 'Manual'}\\n"
                
                echo message
            }
        }
    }
}

def buildPackerCommand(action) {
    def cmd = "packer ${action}"
    
    // 基本變數
    cmd += " -var='enabled_blocks=${params.ENABLED_BLOCKS}'"
    cmd += " -var='env=${params.ENVIRONMENT}'"
    cmd += " -var='region=${params.AWS_REGION}'"
    cmd += " -var='instance_type=${params.INSTANCE_TYPE}'"
    cmd += " -var='owner=${params.OWNER}'"
    
    // 可選變數
    if (params.BASE_AMI_ID?.trim()) {
        cmd += " -var='base_ami_id=${params.BASE_AMI_ID}'"
    }
    
    if (params.BUILD_NAME?.trim()) {
        cmd += " -var='build_name=${params.BUILD_NAME}'"
    }
    
    cmd += " builder.pkr.hcl"
    
    return cmd
}
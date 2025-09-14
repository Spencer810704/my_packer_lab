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
            defaultValue: 'ami-0836e97b3d843dd82',
            description: '基底 AMI ID (必填 - 請根據您的區域和需求選擇適當的 AMI)'
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
            defaultValue: true,
            description: '僅驗證配置，不實際建構 AMI'
        )

        choice(
            name: 'LOG_LEVEL',
            choices: ['INFO', 'DEBUG'],
            description: 'Packer 日誌等級'
        )

        // 🔗 回調參數 (由 infrastructure-mgmt-svc 傳入)
        string(
            name: 'CALLBACK_DATA',
            defaultValue: '',
            description: '回調數據 (由系統自動填入，包含 image_id 和 build_history_id)'
        )
    }

    environment {
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"
        PACKER_LOG = "${params.LOG_LEVEL == 'DEBUG' ? '1' : '0'}"

        // 定義固定的回調 URL - 指向 infrastructure-mgmt-svc
        CALLBACK_URL = "http://infrastructure-mgmt-svc:8087/api/v1/callback/jenkins"
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

                    // 如果有回調數據，顯示相關信息
                    if (params.CALLBACK_DATA?.trim()) {
                        echo "📡 回調數據已設定，將在建構完成後通知 infrastructure-mgmt-svc"
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

                    // 檢查必填參數
                    if (!params.BASE_AMI_ID?.trim()) {
                        error("❌ BASE_AMI_ID 是必填參數，請提供基底 AMI ID")
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
                                def amiId = build.artifact_id?.split(':')[1]
                                if (amiId) {
                                    env.AMI_ID = amiId
                                    echo "🎉 AMI 建構完成: ${amiId}"

                                    // 添加額外標籤 - 分類處理不同類型的積木
                                    def blocks = readJSON text: params.ENABLED_BLOCKS
                                    def baseBlocks = []
                                    def appBlocks = []
                                    def configBlocks = []
                                    def customBlocks = []

                                    // 分類積木
                                    blocks.each { block ->
                                        if (block.startsWith('base-')) {
                                            baseBlocks.add(block.replace('base-', ''))
                                        } else if (block.startsWith('app-')) {
                                            appBlocks.add(block.replace('app-', ''))
                                        } else if (block.startsWith('config-')) {
                                            configBlocks.add(block.replace('config-', ''))
                                        } else {
                                            customBlocks.add(block)
                                        }
                                    }

                                    // 修正：使用正確的 AWS CLI 語法，每個命令一行
                                    sh "aws ec2 create-tags --region ${params.AWS_REGION} --resources ${amiId} --tags Key=JenkinsBuild,Value=${BUILD_NUMBER}"
                                    sh "aws ec2 create-tags --region ${params.AWS_REGION} --resources ${amiId} --tags Key=Requester,Value='${params.REQUESTER ?: 'Manual'}'"
                                    sh "aws ec2 create-tags --region ${params.AWS_REGION} --resources ${amiId} --tags Key=BuildDate,Value='${new Date().format('yyyy-MM-dd')}'"
                                    sh "aws ec2 create-tags --region ${params.AWS_REGION} --resources ${amiId} --tags Key=Environment,Value='${params.ENVIRONMENT}'"
                                    sh "aws ec2 create-tags --region ${params.AWS_REGION} --resources ${amiId} --tags Key=Owner,Value='${params.OWNER}'"

                                    // 根據積木類型添加標籤
                                    if (baseBlocks.size() > 0) {
                                        def baseTag = baseBlocks.join('_')
                                        sh "aws ec2 create-tags --region ${params.AWS_REGION} --resources ${amiId} --tags Key=Base,Value='${baseTag}'"
                                    }

                                    if (appBlocks.size() > 0) {
                                        def appsTag = appBlocks.join('_')
                                        sh "aws ec2 create-tags --region ${params.AWS_REGION} --resources ${amiId} --tags Key=Applications,Value='${appsTag}'"
                                    }

                                    if (configBlocks.size() > 0) {
                                        def configTag = configBlocks.join('_')
                                        sh "aws ec2 create-tags --region ${params.AWS_REGION} --resources ${amiId} --tags Key=Configurations,Value='${configTag}'"
                                    }

                                    if (customBlocks.size() > 0) {
                                        def customTag = customBlocks.join('_')
                                        sh "aws ec2 create-tags --region ${params.AWS_REGION} --resources ${amiId} --tags Key=Custom,Value='${customTag}'"
                                    }
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
                echo "📡 發送建構結果回調到 infrastructure-mgmt-svc"

                // 準備回調數據
                def callbackData = [
                    build_id: env.BUILD_NUMBER as Integer,
                    status: determineStatus(),
                    ami_id: env.AMI_ID ?: '',
                    log_url: "${env.BUILD_URL}console",
                    callback_data: [:]
                ]

                // 如果有 CALLBACK_DATA 參數，解析並加入回調數據
                if (params.CALLBACK_DATA?.trim()) {
                    try {
                        def originalCallbackData = readJSON text: params.CALLBACK_DATA
                        callbackData.callback_data = originalCallbackData
                        echo "✅ 已解析原始回調數據: ${originalCallbackData}"
                    } catch (Exception e) {
                        echo "⚠️ 無法解析 CALLBACK_DATA: ${e.message}"
                        callbackData.callback_data = [
                            error: "Failed to parse callback data: ${e.message}"
                        ]
                    }
                } else {
                    // 如果沒有 CALLBACK_DATA，使用基本建構資訊
                    callbackData.callback_data = [
                        requester: params.REQUESTER ?: 'manual',
                        build_name: params.BUILD_NAME ?: '',
                        environment: params.ENVIRONMENT,
                        enabled_blocks: params.ENABLED_BLOCKS
                    ]
                }

                def callbackJson = groovy.json.JsonOutput.toJson(callbackData)
                echo "📋 回調數據準備完成: ${callbackJson}"

                // 使用 curl 替代 httpRequest - 更可靠且不需要額外插件
                try {
                    // 將 JSON 寫入臨時文件以避免引號問題
                    writeFile file: 'callback_payload.json', text: callbackJson
                    
                    // 使用 curl 發送 POST 請求
                    def curlResult = sh(
                        script: """
                            curl -s -w "HTTPSTATUS:%{http_code}" \\
                                 -X POST \\
                                 -H "Content-Type: application/json" \\
                                 -d @callback_payload.json \\
                                 --connect-timeout 10 \\
                                 --max-time 30 \\
                                 "${env.CALLBACK_URL}"
                        """,
                        returnStdout: true
                    ).trim()
                    
                    // 清理臨時文件
                    sh 'rm -f callback_payload.json'
                    
                    // 解析響應
                    def httpStatus = curlResult.tokenize("HTTPSTATUS:")[1]
                    def responseBody = curlResult.tokenize("HTTPSTATUS:")[0]
                    
                    if (httpStatus.startsWith('2')) {
                        echo "✅ 回調發送成功: HTTP ${httpStatus}"
                        if (responseBody) {
                            echo "回調響應: ${responseBody}"
                        }
                    } else {
                        echo "⚠️ 回調返回非成功狀態: HTTP ${httpStatus}"
                        echo "響應內容: ${responseBody}"
                    }
                    
                } catch (Exception e) {
                    echo "❌ 回調發送失敗: ${e.message}"
                    // 清理臨時文件（如果存在）
                    sh 'rm -f callback_payload.json || true'
                    // 不要因為回調失敗而影響建構結果
                }

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

    // 必填變數
    cmd += " -var='base_ami_id=${params.BASE_AMI_ID}'"

    if (params.BUILD_NAME?.trim()) {
        cmd += " -var='build_name=${params.BUILD_NAME}'"
    }

    cmd += " builder.pkr.hcl"

    return cmd
}

def determineStatus() {
    if (currentBuild.result == null) {
        return "success"  // Jenkins 中 null 表示成功
    }

    switch (currentBuild.result) {
        case 'SUCCESS':
            return "success"
        case 'FAILURE':
            return "failure"
        case 'ABORTED':
            return "cancelled"
        case 'UNSTABLE':
            return "unstable"
        default:
            return "unknown"
    }
}
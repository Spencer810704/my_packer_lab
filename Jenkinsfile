pipeline {
    agent any
    options {
        ansiColor('xterm')
    }
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stg', 'prod'],
            description: '選擇部署環境'
        )
        choice(
            name: 'PROJECT_TYPE',
            choices: ['base', 'mps-openresty'],
            description: '選擇專案類型'
        )
        choice(
            name: 'AWS_REGION',
            choices: ['ap-northeast-1', 'us-west-2', 'eu-west-1'],
            description: '選擇 AWS 區域'
        )
        choice(
            name: 'INSTANCE_TYPE',
            choices: ['t3.micro', 't3.small', 't3.medium'],
            description: '選擇 EC2 實例類型'
        )
        string(
            name: 'AMI_NAME_PREFIX',
            defaultValue: 'base-image',
            description: 'AMI 名稱前綴'
        )
        string(
            name: 'SSH_USERNAME',
            defaultValue: 'ubuntu',
            description: 'SSH 連接用戶名'
        )
        string(
            name: 'OWNER',
            defaultValue: 'infra-team',
            description: '資源擁有者標籤'
        )
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: false,
            description: '僅驗證配置，不實際建構 AMI'
        )
    }
    
    environment {
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"
        PACKER_LOG = "1"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "檢出代碼"
                checkout scm
            }
        }
        
        stage('Validate Parameters') {
            steps {
                script {
                    echo "驗證建構參數："
                    echo "環境: ${params.ENVIRONMENT}"
                    echo "專案類型: ${params.PROJECT_TYPE}"
                    echo "AWS 區域: ${params.AWS_REGION}"
                    echo "實例類型: ${params.INSTANCE_TYPE}"
                    echo "乾式運行: ${params.DRY_RUN}"
                    
                    // 檢查必要檔案是否存在
                    if (!fileExists("${params.PROJECT_TYPE}")) {
                        error("專案目錄 ${params.PROJECT_TYPE} 不存在")
                    }
                    
                    def envFile = "${params.PROJECT_TYPE}/env/${params.ENVIRONMENT}.pkrvars.hcl"
                    if (!fileExists(envFile)) {
                        error("環境配置檔案 ${envFile} 不存在")
                    }
                }
            }
        }
        
        stage('Verify AWS Access') {
            steps {
                script {
                    echo "驗證 AWS 存取權限"
                    sh 'aws sts get-caller-identity'
                }
            }
        }
        
        stage('Packer Init') {
            steps {
                dir("${params.PROJECT_TYPE}") {
                    script {
                        echo "初始化 Packer Plugins"
                        echo "檢查是否需要下載 plugins..."
                        sh 'packer init .'
                    }
                }
            }
        }
        
        stage('Packer Validate') {
            steps {
                dir("${params.PROJECT_TYPE}") {
                    script {
                        echo "驗證 Packer 配置"
                        def validateCmd = "packer validate -var-file=env/${params.ENVIRONMENT}.pkrvars.hcl"
                        
                        // 根據專案類型添加通用變數檔案
                        if (params.PROJECT_TYPE == 'base') {
                            validateCmd += " -var-file=common.pkrvars.hcl"
                        }
                        
                        // 添加動態參數
                        validateCmd += " -var='region=${params.AWS_REGION}'"
                        validateCmd += " -var='instance_type=${params.INSTANCE_TYPE}'"
                        validateCmd += " -var='ssh_username=${params.SSH_USERNAME}'"
                        validateCmd += " -var='ami_name_prefix=${params.AMI_NAME_PREFIX}'"
                        validateCmd += " -var='owner=${params.OWNER}'"
                        validateCmd += " ."
                        
                        sh validateCmd
                    }
                }
            }
        }
        
        stage('Packer Build') {
            when {
                expression { !params.DRY_RUN }
            }
            steps {
                dir("${params.PROJECT_TYPE}") {
                    script {
                        echo "開始建構 AMI"
                        echo "工作目錄: ${pwd()}"
                        
                        def buildCmd = "packer build -var-file=env/${params.ENVIRONMENT}.pkrvars.hcl"
                        
                        // 根據專案類型添加通用變數檔案
                        if (params.PROJECT_TYPE == 'base') {
                            buildCmd += " -var-file=common.pkrvars.hcl"
                        }
                        
                        // 添加動態參數
                        buildCmd += " -var='region=${params.AWS_REGION}'"
                        buildCmd += " -var='instance_type=${params.INSTANCE_TYPE}'"
                        buildCmd += " -var='ssh_username=${params.SSH_USERNAME}'"
                        buildCmd += " -var='ami_name_prefix=${params.AMI_NAME_PREFIX}'"
                        buildCmd += " -var='owner=${params.OWNER}'"
                        buildCmd += " ."
                        
                        sh buildCmd
                    }
                }
            }
        }
        
        stage('Extract AMI Info') {
            when {
                expression { !params.DRY_RUN }
            }
            steps {
                dir("${params.PROJECT_TYPE}") {
                    script {
                        echo "提取 AMI 資訊"
                        // 讀取 manifest 檔案獲取 AMI ID
                        def manifestFile = "metadata/${params.ENVIRONMENT}/${params.ENVIRONMENT}-manifest.json"
                        if (fileExists(manifestFile)) {
                            def manifest = readJSON file: manifestFile
                            if (manifest.builds && manifest.builds.size() > 0) {
                                def amiId = manifest.builds[0].artifact_id?.split(':')[1]
                                if (amiId) {
                                    echo "建構完成的 AMI ID: ${amiId}"
                                    env.AMI_ID = amiId
                                }
                            }
                        }
                    }
                }
            }
        }
        
        stage('Tag AMI') {
            when {
                allOf {
                    expression { !params.DRY_RUN }
                    expression { env.AMI_ID != null }
                }
            }
            steps {
                script {
                    echo "為 AMI 添加標籤"
                    sh """
                        aws ec2 create-tags --region ${params.AWS_REGION} --resources ${env.AMI_ID} --tags \
                            Key=Environment,Value=${params.ENVIRONMENT} \
                            Key=ProjectType,Value=${params.PROJECT_TYPE} \
                            Key=BuildBy,Value=Jenkins \
                            Key=BuildNumber,Value=${BUILD_NUMBER} \
                            Key=Owner,Value=${params.OWNER}
                    """
                }
            }
        }
    }
    
    // post {
    //     always {
    //         echo "清理工作空間"
    //         cleanWs()
    //     }
    //     success {
    //         script {
    //             def message = "AMI 建構成功！\n"
    //             message += "環境: ${params.ENVIRONMENT}\n"
    //             message += "專案類型: ${params.PROJECT_TYPE}\n"
    //             message += "AWS 區域: ${params.AWS_REGION}\n"
    //             if (env.AMI_ID) {
    //                 message += "AMI ID: ${env.AMI_ID}\n"
    //             }
    //             echo message
    //         }
    //     }
    //     failure {
    //         echo "AMI 建構失敗，請檢查日誌"
    //     }
    // }
}
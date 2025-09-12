# 動態積木建構器 - 由 Jenkins 調用
# 使用條件執行動態載入所需的積木

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Jenkins 傳入的基本變數
variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "base_ami_id" {
  type        = string
  description = "Base AMI ID (required)"
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "SSH username"
}

variable "owner" {
  type        = string
  default     = "infra-team"
  description = "Owner tag"
}

# 積木配置 - Jenkins 以 JSON 字串傳入
variable "enabled_blocks" {
  type        = list(string)
  description = "List of enabled block IDs from Jenkins"
  default     = ["base-ubuntu-2004"]
}

# 可選的建構名稱
variable "build_name" {
  type        = string
  default     = ""
  description = "Custom build name (optional)"
}

variable "blocks_path" {
  type        = string
  description = "Path to blocks directory"
  default     = "../blocks"
}

# OS 家族識別（從基礎積木推斷）
variable "os_family" {
  type        = string
  default     = ""
  description = "OS family (debian, rhel, amazon-linux) - auto-detected from base block"
}

# 動態生成 AMI 名稱和 OS 偵測
locals {
  timestamp   = formatdate("YYYYMMDD-HHmmss", timestamp())
  build_name  = var.build_name != "" ? var.build_name : "dynamic"
  ami_name    = "${var.env}-${local.build_name}-${local.timestamp}"
  
  # 從啟用的積木推斷 OS 家族
  os_family = var.os_family != "" ? var.os_family : (
    contains(var.enabled_blocks, "base-ubuntu-2004") || contains(var.enabled_blocks, "base-ubuntu-2204") ? "debian" :
    contains(var.enabled_blocks, "base-amazon-linux-2") || contains(var.enabled_blocks, "base-amazon-linux-2023") ? "amazon-linux" :
    contains(var.enabled_blocks, "base-rhel-8") || contains(var.enabled_blocks, "base-centos-8") ? "rhel" :
    "debian" # 預設值
  )
}

# AMI 來源配置
source "amazon-ebs" "dynamic" {
  region        = var.region
  instance_type = var.instance_type
  ami_name      = local.ami_name
  source_ami    = var.base_ami_id
  ssh_username  = var.ssh_username
  ssh_timeout   = "20m"

  tags = {
    Name           = local.ami_name
    Environment    = var.env
    BuildType      = "Dynamic"
    PackerBuild    = "true"
    BuildDate      = "{{isotime \"2006-01-02\"}}"
    Owner          = var.owner
    EnabledBlocks  = join(",", var.enabled_blocks)
  }
}

# 建構流程
build {
  name    = "dynamic-build"
  sources = ["source.amazon-ebs.dynamic"]

  # 系統基礎積木 - 根據選擇的基礎系統動態執行
  # Ubuntu 20.04
  provisioner "shell" {
    only = contains(var.enabled_blocks, "base-ubuntu-2004") ? ["amazon-ebs.dynamic"] : []
    scripts = [
      "${var.blocks_path}/base/ubuntu-2004/wait-cloud-init.sh",
      "${var.blocks_path}/base/ubuntu-2004/system-update.sh",
      "${var.blocks_path}/base/ubuntu-2004/install-packages.sh"
    ]
  }
  
  # Amazon Linux 2
  provisioner "shell" {
    only = contains(var.enabled_blocks, "base-amazon-linux-2") ? ["amazon-ebs.dynamic"] : []
    scripts = [
      "${var.blocks_path}/base/amazon-linux-2/wait-cloud-init.sh",
      "${var.blocks_path}/base/amazon-linux-2/system-update.sh",
      "${var.blocks_path}/base/amazon-linux-2/install-packages.sh"
    ]
  }

  # Docker 積木 - 條件執行
  provisioner "shell" {
    only    = contains(var.enabled_blocks, "app-docker") ? ["amazon-ebs.dynamic"] : []
    scripts = [
      "${var.blocks_path}/applications/docker/scripts/${local.os_family}/install.sh",
      "${var.blocks_path}/applications/docker/scripts/${local.os_family}/configure.sh"
    ]
  }

  # OpenResty 積木 - 條件執行
  provisioner "shell" {
    only    = contains(var.enabled_blocks, "app-openresty") ? ["amazon-ebs.dynamic"] : []
    scripts = [
      "${var.blocks_path}/applications/openresty/scripts/${local.os_family}/install.sh",
      "${var.blocks_path}/applications/openresty/scripts/common/configure.sh",
      "${var.blocks_path}/applications/openresty/scripts/common/add-test-page.sh"
    ]
  }

  # 安全配置積木 - 條件執行
  provisioner "shell" {
    only    = contains(var.enabled_blocks, "config-security") ? ["amazon-ebs.dynamic"] : []
    scripts = [
      "${var.blocks_path}/configurations/security/setup-firewall.sh",
      "${var.blocks_path}/configurations/security/security-hardening.sh"
    ]
  }


  # Docker 驗證 - 條件執行
  provisioner "shell" {
    only   = contains(var.enabled_blocks, "app-docker") ? ["amazon-ebs.dynamic"] : []
    script = "${var.blocks_path}/applications/docker/scripts/common/validate.sh"
  }

  # OpenResty 驗證 - 條件執行
  provisioner "shell" {
    only   = contains(var.enabled_blocks, "app-openresty") ? ["amazon-ebs.dynamic"] : []
    script = "${var.blocks_path}/applications/openresty/scripts/common/validate.sh"
  }

  # 清理階段 - 根據基礎系統選擇
  # Ubuntu 清理
  provisioner "shell" {
    only   = contains(var.enabled_blocks, "base-ubuntu-2004") ? ["amazon-ebs.dynamic"] : []
    script = "${var.blocks_path}/base/ubuntu-2004/cleanup.sh"
  }
  
  # Amazon Linux 清理
  provisioner "shell" {
    only   = contains(var.enabled_blocks, "base-amazon-linux-2") ? ["amazon-ebs.dynamic"] : []
    script = "${var.blocks_path}/base/amazon-linux-2/cleanup.sh"
  }

  # 建構結果輸出 - 簡化版供 Jenkins 使用
  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
    custom_data = {
      environment    = var.env
      build_type     = "dynamic"
      enabled_blocks = join(",", var.enabled_blocks)
      owner          = var.owner
      build_time     = timestamp()
    }
  }

  # 建構成功訊息
  post-processor "shell-local" {
    inline = [
      "echo ''",
      "echo '=========================================='",
      "echo '🎉 動態積木建構成功完成!'",
      "echo '📦 啟用的積木: ${join(", ", var.enabled_blocks)}'",
      "echo '🏷️ AMI 名稱: ${local.ami_name}'",
      "echo '=========================================='",
      "echo ''"
    ]
  }
}
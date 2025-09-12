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
  default     = "ami-0030a0ad1a88f5eb8"
  description = "Base AMI ID (Ubuntu 20.04 LTS)"
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

# 動態生成 AMI 名稱
locals {
  timestamp   = formatdate("YYYYMMDD-HHmmss", timestamp())
  build_name  = var.build_name != "" ? var.build_name : "dynamic"
  ami_name    = "${var.env}-${local.build_name}-${local.timestamp}"
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

  # 系統基礎積木 - 總是執行
  provisioner "shell" {
    scripts = [
      "${var.blocks_path}/base/ubuntu-2004/wait-cloud-init.sh",
      "${var.blocks_path}/base/ubuntu-2004/system-update.sh",
      "${var.blocks_path}/base/ubuntu-2004/install-packages.sh"
    ]
  }

  # Docker 積木 - 條件執行
  provisioner "shell" {
    only    = contains(var.enabled_blocks, "app-docker") ? ["amazon-ebs.dynamic"] : []
    scripts = [
      "${var.blocks_path}/applications/docker/install-docker.sh",
      "${var.blocks_path}/applications/docker/configure-docker.sh"
    ]
  }

  # OpenResty 積木 - 條件執行
  provisioner "shell" {
    only    = contains(var.enabled_blocks, "app-openresty") ? ["amazon-ebs.dynamic"] : []
    scripts = [
      "${var.blocks_path}/applications/openresty/install-openresty.sh",
      "${var.blocks_path}/applications/openresty/setup-nginx.sh",
      "${var.blocks_path}/applications/openresty/add-test-page.sh"
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


  # 驗證階段
  provisioner "shell" {
    scripts = compact([
      contains(var.enabled_blocks, "app-docker") ? "${var.blocks_path}/applications/docker/validate-docker.sh" : "",
      contains(var.enabled_blocks, "app-openresty") ? "${var.blocks_path}/applications/openresty/validate-openresty.sh" : ""
    ])
  }

  # 清理階段
  provisioner "shell" {
    script = "${var.blocks_path}/base/ubuntu-2004/cleanup.sh"
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
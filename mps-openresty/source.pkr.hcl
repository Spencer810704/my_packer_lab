source "amazon-ebs" "openresty" {
  # 讀取對應環境變數檔
  region        = var.region
  instance_type = var.instance_type

  # 動態產生 ami 名稱 
  ami_name      = local.ami_name

  # 由外部傳入
  source_ami    = var.base_ami_id

  ssh_username = "ubuntu"
  ssh_timeout  = "20m"

  tags = {
    Name        = local.ami_name
    OS          = "Ubuntu 22.04"
    Purpose     = "OpenResty"
    PackerBuild = "true"
    BuildDate   = "{{isotime \"2006-01-02\"}}"
    Version     = "v2.0"
    Features    = "nginx,openresty"
  }
}

build {
  name    = "openresty-build"
  sources = ["source.amazon-ebs.openresty"]

  provisioner "shell" {
    scripts = [
      "scripts/00-wait-cloud-init.sh",
      "scripts/01-system-update.sh",
      "scripts/02-install-packages.sh",
      "scripts/03-install-docker.sh",
      "scripts/04-setup-nginx.sh",
      "scripts/05-deploy-docker-app.sh",
      "scripts/06-add-test-page.sh",
      "scripts/07-setup-firewall.sh",
      "scripts/99-cleanup.sh"
    ]
  }

  post-processor "manifest" {
    output     = "metadata/${var.env}-manifest.json"
    strip_path = true

    custom_data = {
      environment = "${var.env}"
      version     = "20250601"
      owner       = "infra-team"
    }

  }

  post-processor "shell-local" {
    inline = [
      "echo ''",
      "echo '=================================='",
      "echo '🎉 Packer v2.0 建構成功完成!'",
      "echo '📦 建構內容: OpenResty + Docker'",
      "echo '=================================='",
      "echo '📋 AMI 資訊已儲存至: manifest.json'",
      "echo '🔧 現在可以執行 Terraform 更新部署'",
      "echo '=================================='",
      "echo ''"
    ]
  }
}

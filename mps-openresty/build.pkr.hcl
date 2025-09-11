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

  post-processor "shell-local" {
    inline = [
      "mkdir -p metadata/${var.env}"
    ]
  }
  post-processor "manifest" {
    output     = "metadata/${var.env}/${var.env}-manifest.json"
    strip_path = true

    custom_data = {
      environment = "${var.env}"
      owner       = var.owner
    }

  }
  

  post-processor "shell-local" {
    inline = [
      "echo ''",
      "echo '=================================='",
      "echo '🎉 Packer v2.0 建構成功完成!'",
      "echo '📦 建構內容: OpenResty'",
      "echo '=================================='",
      "echo '📋 AMI 資訊已儲存至: manifest.json'",
      "echo '🔧 現在可以執行 Terraform 更新部署'",
      "echo '=================================='",
      "echo ''"
    ]
  }
}

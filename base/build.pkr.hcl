build {
  name    = "base-build"
  sources = ["source.amazon-ebs.base"]

  # 執行 provisioner 任務
  provisioner "shell" {
    scripts = [
      "scripts/00-wait-cloud-init.sh",
      # "scripts/01-system-update.sh",
      # "scripts/02-install-packages.sh",
      "scripts/99-cleanup.sh"
    ]
  }

  # 執行成功後建立 Metadata 目錄存放個環境的 manifest 檔案
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

  # 如果後續需要一些特殊功能 , 例如 POST 資料到某些端點 , 可以透過 shell-local 實作
  # post-processor "shell-local" {
  #   inline = [
  #     "mkdir -p metadata",
  #     "mv manifest.json metadata/${var.env}-manifest.json"
  #   ]
  # }

  # 
  post-processor "shell-local" {
    inline = [
      "echo ''",
      "echo '=================================='",
      "echo '🎉 Packer 建構成功完成!'",
      "echo '📦 建構內容: Base Image'",
      "echo '=================================='",
      "echo '📋 AMI 資訊已儲存至 metadata/${var.env}-manifest.json'",
      "echo '=================================='",
      "echo ''"
    ]
  }

}

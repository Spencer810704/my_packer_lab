source "amazon-ebs" "base" {
  region        = "${var.region}"
  instance_type = "${var.instance_type}"
  ami_name      = "${var.ami_name_prefix}-{{timestamp}}"
  ssh_username  = var.ssh_username

  # 使用 Canonical 提供的 ubuntu 20.04 ( Canonical 為Ubuntu LTS 版本提供5 年的安全補丁 )
  source_ami_filter {
    filters = {
      name                = var.ami_filter_pattern
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = [var.canonical_owner_id] # Canonical
  }

  # 定義 AMI 的 Tag , 提供資訊讓人員能了解 Image 用途
  tags = {
    "Name"        = "${var.env}-base-image-{{timestamp}}"
    "Environment" = "${var.env}"
    "Owner"       = var.owner
    "BuildTime"   = timestamp()
    "PackagedBy"  = "packer"
  }

}



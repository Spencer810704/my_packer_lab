source "amazon-ebs" "openresty" {
  # 讀取對應環境變數檔
  region        = var.region
  instance_type = var.instance_type

  # 動態產生 ami 名稱 
  ami_name      = local.ami_name

  # 由外部傳入
  source_ami    = var.base_ami_id

  ssh_username = var.ssh_username
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

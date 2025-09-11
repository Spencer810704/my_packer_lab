# packer/openresty.pkr.hcl - 最終修正版本，乾淨正確使用 var.xxx 傳參數

packer {
  required_version = ">= 1.8.0"
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

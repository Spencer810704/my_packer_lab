locals {
  ami_name = "${var.env}-web-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
}

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
  description = "Base AMI ID for building"
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "SSH username for connecting to the instance"
}

variable "owner" {
  type        = string
  default     = "infra-team"
  description = "Owner tag value for resources"
}

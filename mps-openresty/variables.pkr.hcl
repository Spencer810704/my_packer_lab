locals {
  ami_name = "${var.env}-web-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
}

variable "env" {
  type = string
}

variable "region" {
  type        = string
  description = "AWS region for building AMI"
}

variable "instance_type" {
  type        = string
  description = "Instance type for building"
}

variable "base_ami_id" {
  type = string
}

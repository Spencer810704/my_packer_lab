variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "SSH username for connecting to the instance"
}

variable "ami_name_prefix" {
  type        = string
  default     = "base-image"
  description = "Prefix for the AMI name"
}

variable "ami_filter_pattern" {
  type        = string
  default     = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
  description = "Filter pattern for source AMI"
}

variable "canonical_owner_id" {
  type        = string
  default     = "099720109477"
  description = "Canonical's AWS account ID"
}

variable "owner" {
  type        = string
  default     = "infra-team"
  description = "Owner tag value for resources"
}

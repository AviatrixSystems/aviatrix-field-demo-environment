variable "vpc_id" {
  description = "Vpc for the instance"
}

variable "common_tags" {
  description = "Csp tags to be applied to infrastructure that accepts tags/labels"
}

variable "region" {
  description = "Instance region/location"
  default     = ""
}

variable "subnet_id" {
  description = "Instance subnet"
}

variable "user_data_templatefile" {
  description = "Instance user data initilization script"
}

variable "name" {
  description = "Instance name"
}

variable "private_ip" {
  description = "Instance ip if provided"
}

variable "public_ip" {
  description = "Assign public ip"
  type        = bool
}

variable "image" {
  description = "Instance image. Ubuntu 22.04 if not provided"
  default     = null
}

variable "inbound_tcp" {
  description = "Allow inbound tcp ports/cidrs"
  type        = map(list(string))
}

variable "inbound_udp" {
  description = "Allow inbound udp ports/cidrs"
  type        = map(list(string))
}

variable "instance_size" {
  description = "Size of the instance"
}

locals {
  lower_common_tags = {
    for key, value in var.common_tags :
    lower(key) => replace(lower(value), "/[ /]/", "_")
  }
}

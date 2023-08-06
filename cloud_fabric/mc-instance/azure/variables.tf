variable "common_tags" {
  description = "Csp tags to be applied to infrastructure that accepts tags/labels"
}

variable "location" {
  description = "Instance region/location"
  default     = ""
}

variable "resource_group" {
  description = "Instance resource group"
  default     = ""
}

variable "subnet_id" {
  description = "Instance subnet"
}

variable "password" {
  description = "Instance password"
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

variable "instance_size" {
  description = "Size of the instance"
}

variable "inbound_tcp" {
  description = "Allow inbound tcp ports/cidrs"
}

variable "inbound_udp" {
  description = "Allow inbound udp ports/cidrs"
}

variable "image" {
  description = "Instance image. Ubuntu 22.04 if not provided"
  default     = null
}

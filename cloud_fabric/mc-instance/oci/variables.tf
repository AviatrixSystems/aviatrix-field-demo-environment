variable "oci_compartment_ocid" {
  description = "Oci compartment ocid for the instance"
}

variable "oci_vcn_ocid" {
  description = "Oci vcn ocid for the instance"
}

variable "common_tags" {
  description = "Csp tags to be applied to infrastructure that accepts tags/labels"
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
  type        = map(string)
}

variable "inbound_udp" {
  description = "Allow inbound udp ports/cidrs"
  type        = map(string)
}

variable "instance_size" {
  description = "Size of the instance"
}

locals {
  common_tags = {
    for key, value in var.common_tags :
    key => value if key != "Terraform"
  }
  rfc_1918 = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

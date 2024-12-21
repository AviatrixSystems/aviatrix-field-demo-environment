variable "cloud" {
  description = "Instance csp"
}

variable "iam_instance_profile" {
  description = "Iam instance profile to attach to the instance"
  default     = ""
}

variable "password" {
  description = "Instance password"
}

variable "oci_compartment_ocid" {
  description = "Oci compartment ocid for the instance"
  default     = ""
}

variable "oci_vcn_ocid" {
  description = "Oci vcn ocid for the instance"
  default     = ""
}

variable "location" {
  description = "Instance region/location"
  default     = ""
}

variable "resource_group" {
  description = "Instance resource group"
  default     = ""
}

variable "vpc_id" {
  description = "Vpc for the instance"
  default     = ""
}

variable "common_tags" {
  description = "Csp tags to be applied to infrastructure that accepts tags/labels"
  default     = {}
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
  default     = null
}

variable "name" {
  description = "Instance name"
}

variable "private_ip" {
  description = "Instance ip if provided"
  default     = null
}

variable "public_ip" {
  description = "Assign public ip"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Instance ssh public key"
  default     = null
}

variable "image" {
  description = "Instance image. Ubuntu 22.04 if not provided"
  default     = null
}

variable "inbound_tcp" {
  description = "Allow inbound tcp ports/cidrs"
  default     = {}
}

variable "inbound_udp" {
  description = "Allow inbound udp ports/cidrs"
  default     = {}
}

variable "instance_size" {
  description = "Size of the instance"
  default     = null
}

variable "vpc_id" {
  description = "Vpc for the instance"
}

variable "iam_instance_profile" {
  description = "Iam instance profile to attach to the instance"
}

variable "common_tags" {
  description = "Csp tags to be applied to infrastructure that accepts tags/labels"
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

variable "public_key" {
  description = "Instance ssh public key"
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

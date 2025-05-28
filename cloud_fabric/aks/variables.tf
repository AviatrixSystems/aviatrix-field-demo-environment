variable "cluster_name" {}
variable "location" {}
variable "resource_group" {}
variable "subnet_id" {}
variable "ssh_key" {}
variable "resource_id" {}
variable "cluster_instance_size" {}
variable "max_surge" {
  default = "10%"
}

variable "name" {}
variable "namespace" {}
variable "node_port" {}
variable "port" {}
variable "container_port" {}
variable "replicas" {}
variable "limits_cpu" { default = "0.5" }
variable "limits_memory" { default = "512Mi" }
variable "requests_cpu" { default = "250m" }
variable "requests_memory" { default = "50Mi" }
variable "image" { default = "nginx:1.7.8" }

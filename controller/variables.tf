data "aws_secretsmanager_secret_version" "tfvars" {
  secret_id = "demo/field/tfvars"
}

locals {
  tfvars = jsondecode(
    data.aws_secretsmanager_secret_version.tfvars.secret_string
  )
}

variable "aws_region" {
  description = "AWS region for the controller and copilot deployment"
  default     = "us-west-2"
}

variable "controller_instance_type" {
  description = "AWS instance size for both controller and copilot"
  default     = "t3.2xlarge" #"c5.2xlarge"
}

variable "copilot_instance_type" {
  description = "AWS instance size for both controller and copilot"
  default     = "t3.2xlarge" # "m5d.4xlarge"
}

variable "vpc_cidr" {
  default = "172.64.0.0/16"
}

variable "subnet_cidr" {
  default = "172.64.1.0/24"
}

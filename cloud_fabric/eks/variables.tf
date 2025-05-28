variable "cluster_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "aviatrix_aws_account_arn" {} # data.aviatrix_account.aws_account.aws_role_arn
variable "cluster_instance_size" {}
variable "cluster_version" { default = "1.30" }

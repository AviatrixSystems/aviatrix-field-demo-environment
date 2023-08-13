data "aws_secretsmanager_secret_version" "tfvars" {
  secret_id = "demo/field/tfvars"
}

locals {
  tfvars = jsondecode(
    data.aws_secretsmanager_secret_version.tfvars.secret_string
  )
}

variable "onprem_region" {
  description = "Aws onprem region"
  default     = "sa-east-1"
}

variable "transit_aws_palo_firenet_region" {
  description = "Aws transit region with palo alto firenet"
  default     = "us-east-1"
}

variable "transit_aws_region" {
  description = "Aws transit region"
  default     = "us-east-2"
}

variable "transit_azure_region" {
  description = "Azure transit region"
  default     = "North Europe"
}

variable "transit_gcp_region" {
  description = "Gcp transit region"
  default     = "us-west1"
}

variable "edge_gcp_region" {
  description = "Gcp transit region"
  default     = "us-south1"
}

variable "transit_oci_region" {
  description = "Oci transit region"
  default     = "ap-singapore-1"
}

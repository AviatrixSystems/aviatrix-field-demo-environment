data "aws_secretsmanager_secret_version" "tfvars" {
  secret_id = "demo/backbone/tfvars"
}

locals {
  tfvars = jsondecode(
    data.aws_secretsmanager_secret_version.tfvars.secret_string
  )
}

variable "aws_region" {
  default = "us-west-2"
}
variable "azure_region" { default = "Central US" }
variable "gcp_region" { default = "us-west1" }
variable "common_tags" {
  default = {}
}

locals {
  cps = ["marketing", "engineering", "accounting", "operations", "enterprise-data"]

  https = [
    "malware.net",
    "botnet.com",
    "ransomware.org",
    "reinvent.awsevents.com",
    "aviatrix.com",
    "www.microsoft.com",
    "cloud.google.com",
    "www.oracle.com",
    "lambda.us-west-2.amazonaws.com",
    "encrypted-tbn0.gstatic.com",
    "pypi.python.org",
  ]
  http = [
    "gmile.com",
    "facobook.com",
    "aviatrix.com",
    "www.microsoft.com",
  ]
}

data "aws_secretsmanager_secret_version" "tfvars" {
  secret_id = "demo/field/tfvars"
}

locals {
  tfvars = jsondecode(
    data.aws_secretsmanager_secret_version.tfvars.secret_string
  )
}

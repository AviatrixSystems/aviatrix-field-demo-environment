data "terraform_remote_state" "controller" {
  backend = "s3"
  config = {
    bucket  = "demo.aviatrixtest.com"
    key     = "terraform/controller.tfstate"
    region  = "us-west-2"
    profile = "demo_operations"
  }
}

data "aws_s3_object" "pod_cert" {
  bucket = "demo.aviatrixtest.com"
  key    = "demo.aviatrixtest/cert.crt"
}

data "aws_s3_object" "pod_key" {
  bucket = "demo.aviatrixtest.com"
  key    = "demo.aviatrixtest/private.key"
}

# Deploy the aviatrix demo airspace
module "demo" {
  source                           = "./cloud_fabric"
  aws_accounting_account_name      = "accounting-aws"
  aws_engineering_account_name     = "engineering-aws"
  aws_operations_account_name      = "operations-aws"
  azure_marketing_account_name     = "marketing-azure"
  azure_operations_account_name    = "operations-azure"
  gcp_enterprise_data_account_name = "enterprise-data-gcp"
  gcp_operations_account_name      = "operations-gcp"
  oci_operations_account_name      = "operations-oci"
  palo_bootstrap_path              = "./palo_bootstrap"
  workload_template_path           = "./templates"
  edge_gcp_region                  = var.edge_gcp_region
  oci_operations_compartment_ocid  = local.tfvars.oci_operations_compartment_ocid
  palo_admin_password              = local.tfvars.palo_admin_password
  palo_admin_username              = local.tfvars.ctrl_username
  palo_bucket_name                 = local.tfvars.palo_bucket_name
  public_key                       = local.tfvars.public_key
  private_key_full_path            = local.tfvars.private_key_full_path
  transit_aws_region               = var.transit_aws_region
  transit_aws_palo_firenet_region  = var.transit_aws_palo_firenet_region
  transit_azure_region             = var.transit_azure_region
  transit_gcp_region               = var.transit_gcp_region
  transit_oci_region               = var.transit_oci_region
  workload_instance_password       = local.tfvars.workload_instance_password
  dashboard_public_cert            = data.aws_s3_object.pod_cert.body
  dashboard_private_key            = data.aws_s3_object.pod_key.body
  common_tags                      = local.tfvars.common_tags
  providers = {
    aws.accounting    = aws.accounting
    aws.engineering   = aws.engineering
    aws.palo          = aws.palo
    google.operations = google.operations
  }
}

resource "aviatrix_copilot_security_group_management_config" "demo" {
  enable_copilot_security_group_management = true
  cloud_type                               = 1
  account_name                             = "operations-aws"
  region                                   = "us-west-2"
  vpc_id                                   = data.terraform_remote_state.controller.outputs.controller_vpc_id
  instance_id                              = data.terraform_remote_state.controller.outputs.copilot_instance_id
  depends_on                               = [module.demo]
}

# Add friendly dns for the palo alto console
data "aws_route53_zone" "demo" {
  name         = "demo.aviatrixtest.com"
  private_zone = false
}

resource "aws_route53_record" "palo" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "palo"
  type    = "A"
  alias {
    name                   = module.demo.palo_alb.dns_name
    zone_id                = module.demo.palo_alb.zone_id
    evaluate_target_health = true
  }
}

# Deploy the aviatrix demo airspace
module "demo" {
  source                           = "./airspace"
  aws_accounting_account_name      = var.aws_accounting_account_name
  aws_engineering_account_name     = var.aws_engineering_account_name
  aws_operations_account_name      = var.aws_operations_account_name
  azure_marketing_account_name     = var.azure_marketing_account_name
  azure_operations_account_name    = var.azure_operations_account_name
  gcp_enterprise_data_account_name = var.gcp_enterprise_data_account_name
  gcp_operations_account_name      = var.gcp_operations_account_name
  oci_operations_account_name      = var.oci_operations_account_name
  palo_bootstrap_path              = var.palo_bootstrap_path
  palo_bucket_name                 = var.palo_bucket_name
  palo_admin_username              = var.ctrl_username
  palo_admin_password              = var.palo_admin_password
  # transit_aws_palo_firenet_region  = "us-east-1"
  # transit_aws_egress_fqdn_region   = "us-east-2"
  # transit_azure_region             = "Germany West Central"
  # transit_gcp_region               = "us-west1"
  # transit_oci_region               = "ap-singapore-1"
  providers = {
    aws.accounting = aws.accounting
  }
}

# Add friendly dns for the palo alto console
data "aws_route53_zone" "demo" {
  name         = "demo.aviatrixtest.com"
  private_zone = false
}

resource "aws_route53_record" "palo" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "palo.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [module.demo.palo_public_ip]
}

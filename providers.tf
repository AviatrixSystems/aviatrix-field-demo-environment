provider "aviatrix" {
  username                = var.ctrl_username
  password                = var.ctrl_password
  controller_ip           = var.ctrl_fqdn
  skip_version_validation = var.skip_version_validation
}

provider "aws" {
  profile = "demo_operations"
}

provider "aws" {
  alias   = "accounting"
  profile = "demo_accounting"
  region  = var.transit_aws_palo_firenet_region
}

provider "aws" {
  alias   = "engineering"
  profile = "demo_engineering"
  region  = var.transit_aws_egress_fqdn_region
}

provider "google" {
  alias       = "enterprise_data"
  credentials = file("../../../../_keys/aviatrix-gcp.json")
  project     = var.gcp_enterprise_data_project_id
  region      = var.transit_gcp_region
}

provider "azurerm" {
  alias = "marketing"
  features {}
  subscription_id = var.azure_marketing_subscription_id
  client_id       = var.azure_application_id
  client_secret   = var.azure_application_key
  tenant_id       = var.azure_directory_id
}

provider "oci" {
  alias               = "operations"
  region              = var.transit_oci_region
  tenancy_ocid        = var.oci_tenant_ocid
  auth                = "APIKey"
  config_file_profile = "avxlabs"
}

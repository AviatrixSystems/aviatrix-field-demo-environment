provider "aviatrix" {
  username                = local.tfvars.ctrl_username
  password                = local.tfvars.ctrl_password
  controller_ip           = local.tfvars.ctrl_fqdn
  skip_version_validation = local.tfvars.skip_version_validation
}

provider "aws" {
  profile = "demo_operations"
}

provider "aws" {
  alias   = "palo"
  profile = "demo_operations"
  region  = var.transit_aws_palo_firenet_region
}

provider "aws" {
  alias   = "accounting"
  profile = "demo_accounting"
  region  = var.transit_aws_palo_firenet_region
}

provider "aws" {
  alias   = "engineering"
  profile = "demo_engineering"
  region  = var.transit_aws_region
}

provider "aws" {
  alias   = "onprem"
  profile = "demo_operations"
  region  = var.onprem_region
}

provider "google" {
  credentials = local.tfvars.gcp_credentials_filepath
  project     = local.tfvars.gcp_enterprise_data_project_id
  region      = var.transit_gcp_region
}

provider "google" {
  alias       = "operations"
  credentials = local.tfvars.gcp_credentials_filepath
  project     = local.tfvars.gcp_operations_project_id
  region      = var.edge_gcp_region
}

provider "azurerm" {
  features {}
  subscription_id = local.tfvars.azure_marketing_subscription_id
  client_id       = local.tfvars.azure_application_id
  client_secret   = local.tfvars.azure_application_key
  tenant_id       = local.tfvars.azure_directory_id
}

provider "oci" {
  region              = var.transit_oci_region
  tenancy_ocid        = local.tfvars.oci_tenant_ocid
  auth                = "APIKey"
  config_file_profile = "avxlabs"
}

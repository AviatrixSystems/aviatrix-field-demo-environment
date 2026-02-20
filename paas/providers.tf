provider "aws" {
  profile = "demo_backbone"
  region  = var.aws_region
}

provider "aws" {
  alias   = "oci"
  profile = "demo_operations"
  region  = var.aws_region
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = local.tfvars.azure_backbone_subscription_id
  client_id                       = local.tfvars.azure_application_id
  client_secret                   = local.tfvars.azure_application_key
  tenant_id                       = local.tfvars.azure_directory_id
}

provider "google" {
  credentials = local.tfvars.gcp_credentials_filepath
  project     = local.tfvars.gcp_backbone_project_id
  region      = var.gcp_region
}

provider "oci" {
  region       = "ap-singapore-1"
  tenancy_ocid = local.oci_tfvars.oci_tenant_ocid
  auth         = "APIKey"
  user_ocid    = local.oci_tfvars.oci_user_ocid
  fingerprint  = local.oci_tfvars.oci_fingerprint
  private_key  = local.oci_tfvars.oci_private_key
}

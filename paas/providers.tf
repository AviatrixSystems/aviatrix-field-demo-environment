provider "aws" {
  profile = "demo_backbone"
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

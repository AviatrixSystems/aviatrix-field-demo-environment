terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 3.0.0"
    }
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.54.0"
      configuration_aliases = [aws.accounting]
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.43.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.52.0"
    }
    oci = {
      source  = "hashicorp/oci"
      version = "~> 4.107.0"
    }
  }
  required_version = ">= 1.2.0"
}

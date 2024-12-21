terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = ">= 3.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.43.0"
    }
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.12.0"
      configuration_aliases = [aws.accounting, aws.engineering, aws.onprem, aws.palo]
    }
    google = {
      source                = "hashicorp/google"
      version               = ">= 4.52.0"
      configuration_aliases = [google.operations]
    }
    oci = {
      source  = "oracle/oci"
      version = ">= 5.27.0"
    }
  }
  required_version = ">= 1.5.0"
}

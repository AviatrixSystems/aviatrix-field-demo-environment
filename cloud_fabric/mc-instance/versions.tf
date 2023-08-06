terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.54.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.43.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.52.0"
    }
    oci = {
      source  = "oracle/oci"
      version = ">= 4.110.0"
    }
  }
  required_version = ">= 1.2.0"
}

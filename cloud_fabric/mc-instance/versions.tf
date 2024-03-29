terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.12.0"
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
      version = ">= 5.8.0"
    }
  }
  required_version = ">= 1.2.0"
}

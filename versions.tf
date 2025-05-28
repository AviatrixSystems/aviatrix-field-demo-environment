terraform {
  backend "s3" {
    bucket  = "demo.aviatrixtest.com"
    key     = "terraform/cloud-fabric.tfstate"
    region  = "us-west-2"
    profile = "demo_operations"
  }

  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 8.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.52.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 5.27.0"
    }
  }
  required_version = ">= 1.5.0"
}
